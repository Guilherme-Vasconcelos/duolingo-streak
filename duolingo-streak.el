;;; duolingo-streak.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 Guilherme-Vasconcelos
;;
;; Author:           Guilherme-Vasconcelos <https://github.com/Guilherme-Vasconcelos>
;; Maintainer:       Guilherme-Vasconcelos <https://github.com/Guilherme-Vasconcelos>
;; Version:          0.0.1
;; Keywords:         duolingo-streak
;; Homepage:         https://github.com/Guilherme-Vasconcelos/duolingo-streak
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
;;  daily Duolingo task or not with the function `duolingo-streak--verify'.
;;
;;  I recommend that you schedule it to run on every hour with e.g. `run-with-timer'.
;;
;;  Inspired by: https://github.com/johnvictorfs/dotfiles/blob/master/polybar/scripts/duolingo_streak.py
;;  Acknowledgements: Used the unofficial API wrapper https://github.com/KartikTalwar/Duolingo to check API endpoints.

;;; Code:

(require 'request)
(require 'notifications)

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


(defun duolingo-streak--notify-streak-not-extended-today ()
  "Send a D-Bus notification to warn the user about the daily task."
  (notifications-notify
   :title "duolingo-streak"
   :body "You have not yet completed your daily Duolingo task!"))


(defun duolingo-streak--check-streak-from-response-data-and-notify (data)
  "Parse DATA returned in order to verify whether user has completed their daily task or not, then send a notification if needed."
  (unless (booleanp (assoc-default 'streak_extended_today data))
    (duolingo-streak--notify-streak-not-extended-today)))


(defun duolingo-streak--perform-user-info-request-and-check-streak ()
  "Get user's data and later check streak."
  (request duolingo-streak--user-info-url
    :headers `(("Authorization" . ,(concat "Bearer " duolingo-streak--jwt-token)) ("User-Agent" . ,duolingo-streak--default-user-agent))
    :parser 'json-read
    :success (cl-function
              (lambda (&key data &allow-other-keys)
                (duolingo-streak--check-streak-from-response-data-and-notify data)))
    :error (cl-function
            (lambda (&key response &allow-other-keys)
              (error "Unexpected error occurred when reading user data. Response: %S" response)))))


(defun duolingo-streak--collect-token-and-request-user-data-to-check-streak (response)
  "Parse login RESPONSE to collect jwt token and later check streak."
  (let ((login-resp-status-code (request-response-status-code response)))
    (if (eq login-resp-status-code 403)
        (error "Duolingo has returned status code 403 forbidden: either change your User Agent, or try again later")
      (unless (eq login-resp-status-code 200)
        (error "Duolingo has returned unexpected status code %s" login-resp-status-code))))
  (setq-default duolingo-streak--jwt-token (request-response-header response "jwt"))
  (when (eq duolingo-streak--jwt-token nil)
    (error "Could not get jwt token. Response: %s" response))
  (duolingo-streak--perform-user-info-request-and-check-streak))


(defun duolingo-streak--perform-login-and-check-streak ()
  "Log in and use jwt token to check if user has completed their streak today.
If jwt-token is already defined, skip the login request and just verify streak instead."
  (if (eq duolingo-streak--jwt-token nil)
      (request duolingo-streak--user-login-url
        :type "POST"
        :data `(("login" . ,duolingo-streak--user-username) ("password" . ,duolingo-streak--user-password))
        :headers `(("User-Agent" . ,duolingo-streak--default-user-agent))
        :parser 'json-read
        :success (cl-function
                  (lambda (&key response &allow-other-keys)
                    (duolingo-streak--collect-token-and-request-user-data-to-check-streak response)))
        :error (cl-function
                (lambda (&key response &allow-other-keys)
                  (error "Unexpected error occurred when retrieving jwt token. Response: %S" response))))
    (duolingo-streak--perform-user-info-request-and-check-streak)))


(defun duolingo-streak--verify ()
  "Verify if user has extended their streak today and send a D-Bus notification if not."

  ;; Because web API calls are asynchronous, it is important not to rely on luck. So each function
  ;; calls the other on the `:success' hook.
  ;; That is the reason all the functions are chained together instead of being separate units.
  ;; Unfortunately I could not think of a better implementation at the moment.

  (interactive)
  (duolingo-streak--assert-env-vars)
  (duolingo-streak--perform-login-and-check-streak))


(provide 'duolingo-streak)
;;; duolingo-streak.el ends here
