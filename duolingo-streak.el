;;; duolingo-streak.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 guilherme
;;
;; Author:           guilherme <https://github.com/Guilherme-Vasconcelos>
;; Maintainer:       guilherme <https://github.com/Guilherme-Vasconcelos>
;; Version:          0.0.1
;; Keywords:         duolingo
;; Homepage:         https://github.com/guilherme/duolingo-streak
;; Package-Requires: ((emacs "24.3") (request "0.3.3"))

;; This file is not part of GNU Emacs.
;; This program is not associated with Duolingo.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;;  This package allows you to verify whether you have done your personal
;;  daily Duolingo task or not with the function `duolingo-verify'. I
;;  recommend that you schedule it to run periodically, e.g.:
;;  (run-with-timer 0 (* 30 60) 'duolingo-verify)
;;
;;  This works best on Doom Emacs because of icons, env vars, etc.
;;
;;  An owl icon will appear at the center of your bottom bar if you need
;;  to complete your task.
;;
;;  Inspired by: https://github.com/johnvictorfs/dotfiles/blob/master/polybar/scripts/duolingo_streak.py
;;  TODO: try to remove some progs
;;  TODO: when parsing login response, use let to bind status-code
;;  TODO: when parsing login response, also store jwt in a global variable
;;  TODO: when parsing login response, also check for non 200

;;; Code:

(require 'request)

(defconst duolingo-streak--user-username (getenv "DUOLINGO_USERNAME"))
(defconst duolingo-streak--user-password (getenv "DUOLINGO_PASSWORD"))
(defconst duolingo-streak--user-info-url (concat "https://www.duolingo.com/users/" duolingo-streak--user-username))
(defconst duolingo-streak--user-login-url "https://www.duolingo.com/login")
(defconst duolingo-streak--default-user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36")

(defvar duolingo-streak--jwt-token nil)


(defun duolingo-streak--assert-env-vars ()
  "Assert that user has set their environment variables."
  (unless (and duolingo-streak--user-username duolingo-streak--user-password)
    (error "Error: you should set the environment variables `DUOLINGO_USERNAME' and `DUOLINGO_PASSWORD'")))


(defun duolingo-streak--parse-user-info-response (response)
  "Parse RESPONSE to verify whether user has completed their daily task or not."
  (message "%S" (request-response-data response)))  ; TODO


(defun duolingo-streak--get-user-info-request ()
  "Send request to Duolingo to get user's data."
  (request duolingo-streak--user-info-url
    :headers `(("Authorization" . ,(concat "Bearer " duolingo-streak--jwt-token)) ("User-Agent" . ,duolingo-streak--default-user-agent))
    :parser 'json-read
    :success (cl-function
              (lambda (&key response &allow-other-keys)
                (duolingo-streak--parse-user-info-response response)))
    :error (cl-function
            (lambda (&key response &allow-other-keys)
              (error "Unexpected error occurred when reading user data. Response: %S" response)))))


(defun duolingo-streak--parse-login-response (response)
  "Parse login RESPONSE from Duolingo and return either an error or the jwt token."
  (let ((login-resp-status-code (request-response-status-code response)))
    (if (eq login-resp-status-code 403)
        (error "Duolingo has returned status code 403 forbidden: either change your User Agent, or try again later")
      (unless (eq login-resp-status-code 200)
        (error "Duolingo has returned unexpected status code %s" login-resp-status-code))))
  (setq-default duolingo-streak--jwt-token (request-response-header response "jwt"))
  (duolingo-streak--get-user-info-request))


(defun duolingo-streak--perform-login-and-parse-user-data ()
  "Send request to Duolingo to log in."
  (request duolingo-streak--user-login-url
    :type "POST"
    :data `(("login" . ,duolingo-streak--user-username) ("password" . ,duolingo-streak--user-password))
    :headers `(("User-Agent" . ,duolingo-streak--default-user-agent))
    :parser 'json-read
    :success (cl-function
              (lambda (&key response &allow-other-keys)
                (duolingo-streak--parse-login-response response)))
    :error (cl-function
            (lambda (&key response &allow-other-keys)
              (error "Unexpected error occurred when retrieving jwt token. Response: %S" response)))))


(defun duolingo-streak--verify-daily-task ()
  "Verify if user has completed their daily task."
  (interactive)
  (duolingo-streak--assert-env-vars)
  (duolingo-streak--perform-login-and-parse-user-data))


(provide 'duolingo-streak)
;;; duolingo-streak.el ends here
