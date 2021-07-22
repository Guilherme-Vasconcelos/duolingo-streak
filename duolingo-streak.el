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

;;; Code:

(require 'request)

(defconst duolingo-streak--user-username (getenv "DUOLINGO_USERNAME"))
(defconst duolingo-streak--user-password (getenv "DUOLINGO_PASSWORD"))
(defconst duolingo-streak--user-info-url (concat "https://www.duolingo.com/users/" duolingo-streak--user-username))
(defconst duolingo-streak--user-login-url "https://www.duolingo.com/login")
(defconst duolingo-streak--default-user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36")


(defun duolingo-streak--assert-env-vars ()
  "Asserts that user has set their environment variables."
  (unless (and duolingo-streak--user-username duolingo-streak--user-password)
    (error "Error: you should set the environment variables `DUOLINGO_USERNAME' and `DUOLINGO_PASSWORD'")))


(defun duolingo-streak--login-user-request ())

(defun duolingo-streak--get-user-info-request ()
  "Sends request to Duolingo to get user's data."
  (request duolingo-streak--user-info-url
           :parser 'json-read))


(defun duolingo-streak--verify-daily-task ()
  "Verifies if user has completed their daily task."
  (interactive)
  (progn
    (duolingo-streak--assert-env-vars)
    (duolingo-streak--get-user-info-request)))


(provide 'duolingo-streak)
;;; duolingo-streak.el ends here
