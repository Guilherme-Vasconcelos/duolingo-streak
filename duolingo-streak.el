;;; duolingo-streak.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 guilherme
;;
;; Author:           guilherme <https://github.com/Guilherme-Vasconcelos>
;; Maintainer:       guilherme <https://github.com/Guilherme-Vasconcelos>
;; Version:          0.0.1
;; Keywords:         duolingo
;; Homepage:         https://github.com/guilherme/duolingo-streak
;; Package-Requires: ((emacs "24.3"))

;; This file is not part of GNU Emacs.

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
;;  This works best on Doom Emacs because of icons etc.
;;
;;  An owl icon will appear at the center of your bottom bar if you need
;;  to complete your task.
;;
;;  Inspired by: https://github.com/johnvictorfs/dotfiles/blob/master/polybar/scripts/duolingo_streak.py

;;; Code:


(provide 'duolingo-streak)
;;; duolingo-streak.el ends here
