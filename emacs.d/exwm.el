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
(require 'exwm-randr)
(require 'exwm-config)
(require 'exwm-systemtray)
(exwm-systemtray-enable)
;; (setq exwm-systemtray-height 20)


(require 'desktop-environment)
(setq desktop-environment-update-exwm-global-keys :prefix)
(define-key desktop-environment-mode-map (kbd "s-l") nil)
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
  (if (= 1 (length (window-list)))
      (jump-to-register '_)
    (progn
      (window-configuration-to-register '_)
      (delete-other-windows))))

(defun my/tune-alpha (direction)
  (let* ((a (frame-parameter (selected-frame) 'alpha))
         (a (if a (car a) 100))
         (a (+ a (if (string= direction "up") 2 -2)))
         (a (if (> a 100) 100 a))
         (a (if (< a 0) 0 a)))
    (set-frame-parameter (selected-frame) 'alpha (cons a 70))))

(defun my/tune-workspace (dir)
  (let* ((c exwm-workspace-current-index)
         (c (+ c (if (string= dir "up") 1 -1)))
         (c (% c exwm-workspace-number))
         (c (if (< c 0) (- exwm-workspace-number 1) c)))
    (exwm-workspace-switch c)))

(defun efs/exwm-update-class ()
  (exwm-workspace-rename-buffer exwm-class-name))

(defun efs/exwm-update-title ()
  (pcase exwm-class-name
    ("Firefox" (exwm-workspace-rename-buffer (format "Firefox: %s" exwm-title)))))

(defun efs/configure-window-by-class ()
  (interactive)
  (pcase exwm-class-name
    ("Firefox" (exwm-workspace-move-window 4))
    ;; ("vlc"
    ;;  (exwm-layout-toggle-mode-line))
    ;; ("mpv" ;(exwm-floating-toggle-floating)
    ;;  (exwm-layout-toggle-mode-line))
    ))

;; When window "class" updates, use it to set the buffer name
(add-hook 'exwm-update-class-hook #'efs/exwm-update-class)

;; When window title updates, use it to set the buffer name
(add-hook 'exwm-update-title-hook #'efs/exwm-update-title)

;; Configure windows as they're created
(add-hook 'exwm-manage-finish-hook #'efs/configure-window-by-class)


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

        ([?\s-H] . (lambda () (interactive) (my/tune-workspace "down")))
        ([?\s-L] . (lambda () (interactive) (my/tune-workspace "up")))

        ([?\s-C] . kill-this-buffer)
        ([?\s-c] . exwm-reset)
        ;;
        ([?\s-,] . (lambda () (interactive) (my/tune-alpha "down")))
        ([?\s-.] . (lambda () (interactive) (my/tune-alpha "up")))
        ([?\s--] . evil-window-split)
        ([?\s-|] . evil-window-vsplit)

        ([?\s-f] . my/toggle-fullscreen)
        ([?\s-F] . exwm-layout-toggle-fullscreen)

        ;; Launch applications via shell command
        ([?\s-&] . (lambda (command)
                     (interactive (list (read-shell-command "$ ")))
                     (start-process-shell-command command nil command)))

        ;; Switch workspace
        ([?\s-w] . exwm-workspace-switch)
        ;; ([?\s-`] . (lambda () (interactive) (exwm-workspace-switch-create 0)))

        ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
        ,@(mapcar (lambda (i)
                    `(,(kbd (format "s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i))))
                  (number-sequence 0 9))))

(exwm-enable)
(exwm-randr-enable) ;; revisit for multi-monitor

(setq exwm-systemtray-background-color 'workspace-background)
;; (set-frame-parameter nil 'alpha-background 50)
;; (frame-parameter nil 'alpha-background)

(set-frame-parameter (selected-frame) 'alpha '(98 . 70))
(add-to-list 'default-frame-alist  '(alpha . (98 . 70)))

;; (set-frame-parameter (selected-frame) 'fullscreen 'maximized)
;; (add-to-list 'default-frame-alist  '(fullscreen . maximized))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; perspepctive

(setq persp-suppress-no-prefix-key-warning t)
(require 'perspective)
(persp-mode)
(consult-customize consult--source-buffer :hidden t :default nil)
(add-to-list 'consult-buffer-sources persp-consult-source)

(provide 'conf/exwm)
;;; exwm.el ends here
