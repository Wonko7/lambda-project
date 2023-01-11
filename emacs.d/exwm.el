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
;; TODO checkout exwm-xim

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; misc functions, should move this?

(defun my/toggle-fullscreen ()
  "maximize buffer"
  (interactive)
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

(defun my/exwm-floating-unset-floating ()
  "Toggle the current window between floating and non-floating states."
  (interactive)
  (with-current-buffer (window-buffer)
    (if exwm--floating-frame
        (exwm-floating--unset-floating exwm--id))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; exwm hooks for window management:

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; previous workspace

(defvar my/exwm-workspace-previous-index exwm-workspace-current-index "The previous active workspace index.")

(defun my/exwm-workspace--current-to-previous-index (_x)
  (setq my/exwm-workspace-previous-index exwm-workspace-current-index))

(defun my/fuck-me-init-exwm ()
  ;; When window "class" updates, use it to set the buffer name
  (add-hook 'exwm-update-class-hook #'efs/exwm-update-class)
  ;; When window title updates, use it to set the buffer name
  (add-hook 'exwm-update-title-hook #'efs/exwm-update-title)
  ;; Configure windows as they're created
  (add-hook 'exwm-manage-finish-hook #'efs/configure-window-by-class)
  (advice-add 'exwm-workspace-switch :before #'my/exwm-workspace--current-to-previous-index))

(add-hook 'exwm-init-hook 'my/fuck-me-init-exwm)

(defun my/exwm-workspace-switch-to-previous ()
  (interactive)
  "Switch to the previous active workspace."
  (let ((index my/exwm-workspace-previous-index))
    (exwm-workspace-switch index)))

;; Ctrl+Q will enable the next key to be sent directly
(define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; global key bindings

(setq exwm-input-global-keys
      `(;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
        ([?\s-r] . exwm-reset)
        ([?\s-i] . exwm-input-toggle-keyboard)

        ;; Move between windows
        ([?\s-h] . windmove-left)
        ([?\s-l] . windmove-right)
        ([?\s-k] . windmove-up)
        ([?\s-j] . windmove-down)

        ([?\s-H] . (lambda () (interactive) (my/tune-workspace "down")))
        ([?\s-L] . (lambda () (interactive) (my/tune-workspace "up")))
        ([?\s-K] . previous-buffer)
        ([?\s-J] . next-buffer)

        ([?\s-C] . kill-this-buffer)
        ([?\s-c] . exwm-reset)

        ([?\s-,] . (lambda () (interactive) (my/tune-alpha "down")))
        ([?\s-.] . (lambda () (interactive) (my/tune-alpha "up")))
        ([?\s--] . (lambda () (interactive) (evil-window-split) (next-buffer)))
        ([?\s-|] . (lambda () (interactive) (evil-window-vsplit) (next-buffer)))

        ([?\s-f] . my/toggle-fullscreen)
        ([?\s-F] . exwm-layout-toggle-fullscreen)

        ;; Launch applications via shell command
        ([?\s-&] . (lambda (command)
                     (interactive (list (read-shell-command "$ ")))
                     (start-process-shell-command command nil command)))
        ([?\s-y] . ws/force-run-auto-start)

        ;; Switch workspace
        ([?\s-w] . exwm-workspace-switch)
        ([?\s- ] . my/exwm-workspace-switch-to-previous)
        ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
        ,@(mapcar (lambda (i)
                    `(,(kbd (format "s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i)
                        ;; (persp-switch-by-number ,i)
                        )))
                  (number-sequence 0 9))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; start exwm

(exwm-systemtray-enable)
(exwm-randr-enable) ;; revisit for multi-monitor
(sleep-for 5) ;; lol fuck me: cl-no-applicable-method: No applicable method: xcb:-+request, nil, #s(xcb:SetInputFocus t 42 1 nil 0)
(exwm-enable)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; colors & transparency

;; (set-frame-parameter nil 'alpha-background 50)
;; (frame-parameter nil alpha-background)
(setq exwm-systemtray-background-color 'workspace-background)

(set-frame-parameter (selected-frame) 'alpha '(96 . 70))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist  '(alpha . (96 . 70)))
(add-to-list 'default-frame-alist  '(fullscreen . maximized))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; desktop-env

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; perspepctive

(setq persp-suppress-no-prefix-key-warning t)
(require 'perspective)
(setq persp-show-modestring nil)
(setq persp-initial-frame-name "don't speak unless spoken to")
(persp-mode)
(consult-customize consult--source-buffer :hidden t :default nil)
(add-to-list 'consult-buffer-sources persp-consult-source)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; lemon

(require 'lemon)
(require 'lemon-cpu)
(require 'lemon-memory)
(require 'lemon-network)

(setq lemon-delay 5
      lemon-refresh-rate 2
      lemon-monitors
      (list '((lemon-cpufreq-linux :display-opts '(:sparkline (:type gridded)))
              (lemon-cpu-linux)
              (lemon-memory-linux)
              ;;(lemon-swap)
              ;; also add disk space?
              (lemon-linux-network-tx)
              (lemon-linux-network-rx))))

(lemon-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto start workspaces:

(require 'cl)

(defvar ws/auto-start-state '(t t t t t t t t t t))

(defun ws/check-and-mark-auto-start-state (i)
  (let ((state (nth i ws/auto-start-state)))
    (setf (nth i ws/auto-start-state) nil) ;; mark as visited
    state))

(defun ws/run-auto-start ()
  (flet ((run-init-p (i)
           (and (= exwm-workspace-current-index i) (ws/check-and-mark-auto-start-state i))))
    (cond ((run-init-p 8)
           (projectile-switch-project-by-name "/code/wonko-mono-conf"))
          ((run-init-p 7)
           (org-roam-node-open (org-roam-node-from-title-or-alias "ssdd"))
           (delete-other-windows))
          ((run-init-p 4)
           (async-shell-command "firefox"))
          ((run-init-p 1)
           (shell)))))

(defun ws/force-run-auto-start ()
  (interactive)
  (setf (nth exwm-workspace-current-index ws/auto-start-state) t)
  (ws/run-auto-start))

(add-hook 'exwm-workspace-switch-hook 'ws/run-auto-start)

(provide 'conf/exwm)
;;; exwm.el ends here
