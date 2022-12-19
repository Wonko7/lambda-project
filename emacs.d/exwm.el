;;; exwm.el -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 William
;;
;; Author: William <https://github.com/wonko7>
;; Maintainer: William <john@doe.com>
;; Created: November 23, 2022
;; Modified: November 23, 2022
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/wjc/exwm
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;
;;
;;; Code:

(require 'exwm)
(require 'exwm-config)

(require 'desktop-environment)
(desktop-environment-mode)

(setq desktop-environment-volume-get-command "pamixer --get-volume")
(setq desktop-environment-volume-set-command "pamixer %s")
(setq desktop-environment-volume-get-regexp "\\([0-9]+\\)")
(setq desktop-environment-volume-normal-increment "-i 5 --allow-boost")
(setq desktop-environment-volume-normal-decrement "-d 5")
(setq desktop-environment-volume-toggle-command "pamixer -t")

(setq exwm-workspace-number 10)
(setq exwm-input-prefix-keys
      '(?\C-x
        ?\C-u
        ?\C-:
        ?\C-h
        ?\M-:
        ;?\C-?RET   ; C-RET would be bad ass
        ?\C-\   ; I want whitespace here
        ))

;; (evil-define-key '(normal input) exwm-mode-map
;;   "ESC" 'exwm-input-send-next-key
;;   "C-q" 'exwm-input-send-next-key
;;   )

(defun my/toggle-fullscreen ()
  "maximize buffer"
  (interactive)
  (if (= 1 (length (window-list)))
      (jump-to-register '_)
    (progn
      (window-configuration-to-register '_)
      (delete-other-windows))))

(defun my/decrease-alpha ()
  (interactive)
  (let* ((a (frame-parameter (selected-frame) 'alpha))
         (a (if a (car a) a))
         (a (- a 5))
         (a (if (< a 0) 0 a)))
    (set-frame-parameter (selected-frame) 'alpha (cons a 50))))

(defun my/increase-alpha ()
  (interactive)
  (let* ((a (frame-parameter (selected-frame) 'alpha))
         (a (if a (car a) 100 ))
         (a (+ a 5))
         (a (if (> a 100) 100 a)))
    (set-frame-parameter (selected-frame) 'alpha (cons a 50))))

;; Ctrl+Q will enable the next key to be sent directly
(define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

;; Set up global key bindings.  These always work, no matter the input state!
;; Keep in mind that changing this list after EXWM initializes has no effect.
(setq exwm-input-global-keys
      `(
        ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
        ([?\s-r] . exwm-reset)

        ;; Move between windows
        ([?\s-h] . windmove-left)
        ([?\s-l] . windmove-right)
        ([?\s-k] . windmove-up)
        ([?\s-j] . windmove-down)
        ;;
        ([?\s-f] . my/toggle-maximize-buffer)

        ([?\s-C] . kill-buffer)
        ;;
        ([?\s-,] . my/decrease-alpha)
        ([?\s-.] . my/increase-alpha)
        ([?\s--] . evil-window-split)
        ([?\s-|] . evil-window-vsplit)

        ([?\s-f] . my/toggle-fullscreen)

        ;; Launch applications via shell command
        ([?\s-&] . (lambda (command)
                     (interactive (list (read-shell-command "$ ")))
                     (start-process-shell-command command nil command)))

        ;; Switch workspace
        ([?\s-w] . exwm-workspace-switch)
        ([?\s-`] . (lambda () (interactive) (exwm-workspace-switch-create 0)))

        ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
        ,@(mapcar (lambda (i)
                    `(,(kbd (format "s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i))))
                  (number-sequence 0 9))))

(exwm-enable)

(setq exwm-systemtray-background-color 'workspace-background)
;; (set-frame-parameter nil 'alpha-background 50)
;; (frame-parameter nil 'alpha-background)

(provide 'conf/exwm)
;;; exwm.el ends here
