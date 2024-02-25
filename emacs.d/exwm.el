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

(require 'cl)

;; (frame-list)
;; exwm-workspace--workspace-from-frame-or-index(exwm-workspace--count)
;; (list exwm-workspace--list)
;; (exwm-workspace--init)
;; (require 'xcb)
;; (exwm-init)
;; (exwm-workspace--init)

(setq exwm-workspace-number 10)
(require 'exwm)
(require 'exwm-randr)
(require 'exwm-config)
(require 'exwm-workspace)
(require 'exwm-systemtray)
;; TODO checkout exwm-xim

(setq exwm-workspace-number 10)
(setq exwm-input-prefix-keys
      `(?\s-i
        ?\s-I
        ;; ?\C-: ;; FIXME: I need to use these
        ?\C-\ ;; I want whitespace here ;; but this is also unused
        ?\s-\S-J
        ?\s-\S-K
        ?\s-\S-j
        ?\s-\S-k
        ?\s-J
        ?\s-K
        ?\s-l
        ?\s-h
        ?\s-\ ;; yep
        ?\M-:
        ?\A-\s-\S-J
        ?\A-\s-\S-K
        ?\A-\s-\S-j
        ?\A-\s-\S-k
        ?\A-\s-i
        ?\A-\s-I
        ?\A-\s-J
        ?\A-\s-K
        ?\A-\s-l
        ?\A-\s-h
        ?\A-\s- ;; yep
        ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; misc functions, should move this?

(defun my/toggle-fullscreen ()
  "maximize buffer"
  (interactive)
  (if exwm-class-name
      (exwm-layout-toggle-fullscreen exwm--id))
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
    ("Firefox" (progn
                 (exwm-workspace-move-window 4)
                 (exwm-layout-set-fullscreen))
     ("vlc" (exwm-layout-set-fullscreen))
     ("mpv" (exwm-layout-set-fullscreen)))))

(defvar my/init-ement-room-list
  '((lambda (buffer-name action)
      (and (string= buffer-name "*Ement Room List*")
           (> (exwm-workspace--count) 9)))
    (lambda (buffer alist)
      (with-selected-frame (elt exwm-workspace--list 9)
        (display-buffer-same-window buffer alist))
      (setq display-buffer-alist (delete my/init-ement-room-list display-buffer-alist)))))

;; see https://github.com/ch11ng/exwm/wiki/Cookbook
(defun my/set-window-dedicated (arg)
  "Toggle loose window dedication.  If prefix ARG, set strong."
  (interactive "P")
  (let* ((dedicated (if arg t (if (window-dedicated-p) nil "loose"))))
    (message "setting window dedication to %s" dedicated)
    (set-window-dedicated-p (selected-window) dedicated)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; previous workspace

(defvar my/exwm-workspace-previous-index exwm-workspace-current-index "The previous active workspace index.")

(defun my/exwm-workspace--current-to-previous-index (_x)
  (setq my/exwm-workspace-previous-index exwm-workspace-current-index))

(defun my/init-exwm ()
  ;; When window "class" updates, use it to set the buffer name
  (add-hook 'exwm-update-class-hook #'efs/exwm-update-class)
  ;; When window title updates, use it to set the buffer name
  (add-hook 'exwm-update-title-hook #'efs/exwm-update-title)
  ;; Configure windows as they're created
  (add-hook 'exwm-manage-finish-hook #'efs/configure-window-by-class)
  (advice-add 'exwm-workspace-switch :before #'my/exwm-workspace--current-to-previous-index))

(add-hook 'exwm-init-hook #'my/init-exwm)

(defun my/exwm-workspace-switch-to-previous ()
  (interactive)
  "Switch to the previous active workspace."
  (let ((index my/exwm-workspace-previous-index))
    (exwm-workspace-switch index)))

;; Ctrl+Q will enable the next key to be sent directly
(define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; desktop-env
;; this needs to be activated before we set exwm-input-global-keys

(require 'desktop-environment)
(desktop-environment-mode)

(setq desktop-environment-update-exwm-global-keys :global)
(define-key desktop-environment-mode-map (kbd "s-l") nil)
(setq desktop-environment-screenlock-command my/lock-cmd)

(setq desktop-environment-volume-get-command "pamixer --get-volume")
(setq desktop-environment-volume-set-command "pamixer %s")
(setq desktop-environment-volume-get-regexp "\\([0-9]+\\)")
(setq desktop-environment-volume-normal-increment "-i 5 --allow-boost")
(setq desktop-environment-volume-normal-decrement "-d 5")
(setq desktop-environment-volume-toggle-command "pamixer -t")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; global key bindings

(setq exwm-input-global-keys
      `(;; FIXME: emacs 29 sometimes sees my key inputs as \A-\s-x, sometimes \s-x
        ;; https://emacs.stackexchange.com/questions/78135/why-does-emacs-29-translates-meta-to-metahyper-m-somekey-to-h-m-somekey
        ;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=51001
        ;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=65802
        ([?\A-\s-r] . exwm-reset)
        ([?\A-\s-i] . exwm-input-toggle-keyboard)
        ([?\A-\s-I] . coterm-char-mode-cycle)

        ;; Move between windows
        ([?\A-\s-h] . windmove-left)
        ([?\A-\s-l] . windmove-right)
        ([?\A-\s-k] . windmove-up)
        ([?\A-\s-j] . windmove-down)

        ([?\A-\s-H] . (lambda () (interactive) (my/tune-workspace "down")))
        ([?\A-\s-L] . (lambda () (interactive) (my/tune-workspace "up")))
        ([?\A-\s-K] . previous-buffer)
        ([?\A-\s-J] . next-buffer)

        ([?\A-\s-C] . kill-this-buffer)
        ([?\A-\s-c] . (lambda () (interactive) (async-shell-command "dunstctl close")))

        ([?\A-\s-,] . (lambda () (interactive) (my/tune-alpha "down")))
        ([?\A-\s-.] . (lambda () (interactive) (my/tune-alpha "up")))
        ([?\A-\s--] . (lambda () (interactive) (evil-window-split) (next-buffer)))
        ([?\A-\s-|] . (lambda () (interactive) (evil-window-vsplit) (next-buffer)))
        ([?\A-\s-&] . async-shell-command)

        ([?\A-\s-f] . my/toggle-fullscreen)
        ([?\A-\s-F] . exwm-layout-toggle-fullscreen)
        ([?\A-\s-d] . my/set-window-dedicated)

        ;; Launch applications via shell command
        ([?\A-\s-:] . (lambda (command)
                        (interactive (list (read-shell-command "$ ")))
                        (start-process-shell-command command nil command)))
        ([?\A-\s-y] . ws/force-run-auto-start)

        ;; Switch workspace
        ([?\A-\s-w] . exwm-workspace-switch)
        ([?\A-\s- ] . my/exwm-workspace-switch-to-previous)
        ([?\A-\s-M] . exwm-workspace-move-window)
        ,@(mapcar (lambda (i)
                    `(,(kbd (format "A-s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i))))
                  (number-sequence 0 9))

        ([?\s-r] . exwm-reset)
        ([?\s-i] . exwm-input-toggle-keyboard)
        ([?\s-I] . coterm-char-mode-cycle)

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
        ([?\s-c] . (lambda () (interactive) (async-shell-command "dunstctl close")))

        ([?\s-,] . (lambda () (interactive) (my/tune-alpha "down")))
        ([?\s-.] . (lambda () (interactive) (my/tune-alpha "up")))
        ([?\s--] . (lambda () (interactive) (evil-window-split) (next-buffer)))
        ([?\s-|] . (lambda () (interactive) (evil-window-vsplit) (next-buffer)))
        ([?\s-&] . async-shell-command)

        ([?\s-f] . my/toggle-fullscreen)
        ([?\s-F] . exwm-layout-toggle-fullscreen)
        ([?\s-d] . my/set-window-dedicated)

        ;; Launch applications via shell command
        ([?\s-:] . (lambda (command)
                     (interactive (list (read-shell-command "$ ")))
                     (start-process-shell-command command nil command)))
        ([?\s-y] . ws/force-run-auto-start)

        ;; Switch workspace
        ([?\s-w] . exwm-workspace-switch)
        ([?\s- ] . my/exwm-workspace-switch-to-previous)
        ([?\s-M] . exwm-workspace-move-window)
        ,@(mapcar (lambda (i)
                    `(,(kbd (format "s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i))))
                  (number-sequence 0 9))
        ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; exwm settings

(setq exwm-manage-force-tiling t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; colors & transparency

;; (set-frame-parameter nil 'alpha-background 50)
;; (frame-parameter nil alpha-background)
(setq exwm-systemtray-background-color 'workspace-background)

(set-frame-parameter (selected-frame) 'alpha '(94 . 70))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist  '(alpha . (94 . 70)))
(add-to-list 'default-frame-alist  '(fullscreen . maximized))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; perspepctive
;; not directly exwm stuff, but I only use it in exwm workspace context

(setq persp-suppress-no-prefix-key-warning t)
(require 'perspective)
(persp-mode)

(setq persp-show-modestring nil)
(setq persp-initial-frame-name "don't speak unless spoken to")
(consult-customize consult--source-buffer :hidden t :default nil)
(add-to-list 'consult-buffer-sources persp-consult-source)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; start exwm

(exwm-systemtray-enable)
(exwm-randr-enable)
(sleep-for 10) ;; lol fuck me: cl-no-applicable-method: No applicable method: xcb:-+request, nil, #s(xcb:SetInputFocus t 42 1 nil 0)
(exwm-enable)

;; (system-name) pcase, or based on `autorandr --current`, change this on hook, then run exwm-randr-refresh
(setq exwm-randr-workspace-monitor-plist '(0 "HDMI-A-0"
                                           10 "HDMI-A-0"
                                           11 "HDMI-A-0"))
(setq exwm-workspace-warp-cursor t
      mouse-autoselect-window t
      focus-follows-mouse t)

;; autorandr

;; autorandr --save tv
;; autorandr --save work-monitor
;; autorandr --save obama-s-elf

(defun my/run-autorandr ()
  (async-shell-command "autorandr --change --force")
  ;; (message "autorandr config: %s" (shell-cmd-to-string "autorandr --current"))
  ;; FIXME also feh background
  (message "autorandr"))

;; (add-hook 'exwm-randr-screen-change-hook #'my/run-autorandr)
;; (my/run-autorandr)

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

(defvar ws/auto-start-state '(t t t t t t t t t t))

(defun ws/check-and-mark-auto-start-state (i)
  (let ((state (nth i ws/auto-start-state)))
    (setf (nth i ws/auto-start-state) nil) ;; mark as visited
    state))

(defun ws/run-auto-start ()
  (cl-flet ((run-init-p (i)
              (and (= exwm-workspace-current-index i)
                   (ws/check-and-mark-auto-start-state i))))
    (cond ((run-init-p 9)
           (push my/init-ement-room-list display-buffer-alist)
           (my/ement-init))
          ((run-init-p 8)
           (projectile-switch-project-by-name my/lambda-project))
          ((run-init-p 7)
           (my/init-org))
          ((run-init-p 6)
           (require 'conf/elfeed "~/.emacs.d/elfeed.el")
           (elfeed))
          ((run-init-p 4)
           (async-shell-command "firefox"))
          ((run-init-p 3)
           (projectile-switch-project))
          ((run-init-p 2)
           (org-roam-node-open (org-roam-node-from-title-or-alias "Gotham"))
           (delete-other-windows)
           (evil-window-vsplit)
           (project-shell))
          ((run-init-p 1)
           (shell)))))

(defun ws/force-run-auto-start ()
  (interactive)
  (setf (nth exwm-workspace-current-index ws/auto-start-state) t)
  (ws/run-auto-start))

(add-hook 'exwm-workspace-switch-hook #'ws/run-auto-start)

;;; exwm.el ends here
(provide 'conf/exwm)
