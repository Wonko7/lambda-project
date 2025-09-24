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

;; (require 'exwm-modeline)
;; (require 'exwm-firefox)
;; (require 'exwm-mff)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; desktop-env
;; this needs to be activated before we set exwm-input-global-keys

(use-package desktop-environment
  :demand t

  :custom
  (desktop-environment-screenlock-command my/lock-cmd)
  (desktop-environment-volume-get-command "pamixer --get-volume")
  (desktop-environment-volume-set-command "pamixer %s")
  (desktop-environment-volume-get-regexp "\\([0-9]+\\)")
  (desktop-environment-volume-normal-increment "-i 5 --allow-boost")
  (desktop-environment-volume-normal-decrement "-d 5")
  (desktop-environment-volume-toggle-command "pamixer -t")
  (desktop-environment-update-exwm-global-keys :global)

  :config
  (define-key desktop-environment-mode-map (kbd "s-l") nil)
  (desktop-environment-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; exwm

(use-package exwm
  :demand t
  :after desktop-environment
  :config

  (setq exwm-input-prefix-keys
        `(?\s-i
          ?\s-I
          ?\C-\  ;; I want whitespace here
          ?\C-\\ ;; xim
          ?\s-\  ;; yep
          ?\M-:))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; fullscreen / toggle window config

  (setq my/worskpace-window-configs (-repeat exwm-workspace-number nil))

  (defun my/set-workspace-window-configuration ()
    (setf (nth exwm-workspace-current-index my/worskpace-window-configs)
          (list (current-window-configuration) (point-marker))))

  (defun my/get-workspace-window-configuration ()
    (nth exwm-workspace-current-index my/worskpace-window-configs))

  (defun my/toggle-fullscreen ()
    "maximize buffer"
    (interactive)
    (if exwm-class-name
        (progn
          (exwm-layout-toggle-fullscreen exwm--id)
          (exwm-input-grab-keyboard))
      (if (= 1 (length (window-list)))
          (let ((wc (my/get-workspace-window-configuration)))
            (when wc
              (register-val-jump-to wc nil)))
        (progn
          (my/set-workspace-window-configuration)
          (delete-other-windows)))))

  (defun my/force-main-menu ()
    (interactive)
    (exwm-layout-unset-fullscreen exwm--id)
    (set-transient-map evil-leader--default-map)
    (which-key-show-keymap 'evil-leader--default-map t))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; misc functions, should move this?

  (defun my/tune-alpha (direction)
    (let* ((a (frame-parameter (selected-frame) 'alpha-background))
           (a (or a 1.0))
           (a (+ a (if (string= direction "up") 0.05 -0.05)))
           (a (if (> a 1.0) 1.0 a))
           (a (if (< a 0) 0 a)))
      (set-frame-parameter (selected-frame) 'alpha-background a)))

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
    ;; unused
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
    ;; Configure windows as they're created ;; FIXME borked
    ;; (add-hook 'exwm-manage-finish-hook #'efs/configure-window-by-class)
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
  ;; global key bindings

  (defun go-to-external-screen (i)
    (let ((i (+ 11 i)))
      (pcase (system-name)
        ("yggdrasill"
         (my/local-async-shell-command
          "xdotool mousemove 1920 1000; xdotool mousemove_relative 0 3000")
         (my/local-async-shell-command
          (concat "ssh media@of-course-i-still-love-you.local DISPLAY=:11 "
                  "/home/media/.guix-home/profile/bin/wmctrl -s " (int-to-string i))))
        (_ (exwm-workspace-switch-create i)))))

  (defun go-to-screen (i)
    (pcase user-login-name
      ("media"
       (exwm-workspace-switch-create (+ i 10)))
      (_ (exwm-workspace-switch-create i))))

  (setq exwm-input-global-keys
        `(([?\s-r] . exwm-reset)
          ([?\s-i] . exwm-input-toggle-keyboard)
          ([?\s-I] . coterm-char-mode-cycle)

          ;; Move between windows
          ([?\s-h] . windmove-left)
          ([?\s-l] . windmove-right)
          ([?\s-k] . windmove-up)
          ([?\s-j] . windmove-down)
          ([?\s-g] . ace-select-window)

          ([?\s-H] . (lambda () (interactive) (my/tune-workspace "down")))
          ([?\s-L] . (lambda () (interactive) (my/tune-workspace "up")))
          ([?\s-K] . previous-buffer)
          ([?\s-J] . next-buffer)

          ([?\s-C] . kill-current-buffer)
          ([?\s-c] . (lambda () (interactive) (my/local-async-shell-command "dunstctl close")))

          ([?\s-,] . (lambda () (interactive) (my/tune-alpha "down")))
          ([?\s-.] . (lambda () (interactive) (my/tune-alpha "up")))
          ([?\s--] . (lambda () (interactive) (evil-window-split) (next-buffer)))
          ([?\s-|] . (lambda () (interactive) (evil-window-vsplit) (next-buffer)))
          ([?\s-\C-&] . async-shell-command)

          ([?\s-f] . my/toggle-fullscreen)
          ([?\s-F] . exwm-layout-toggle-fullscreen)
          ;; ([?\s-d] . my/set-window-dedicated)

          ;; Launch applications via shell command
          ([?\s-:] . (lambda (command)
                       (interactive (list (read-shell-command "$ ")))
                       (start-process-shell-command command nil command)))
          ([?\s-y] . ws/force-run-auto-start)

          ([?\s-\C-\ ] . my/force-main-menu)
          ([?\C-\ ] . my/force-main-menu) ;; => see keys.el exwm-mode-map.

          ;; Switch workspace
          ([?\s-w] . exwm-workspace-switch)
          ([?\s- ] . my/exwm-workspace-switch-to-previous)
          ([?\s-M] . exwm-workspace-move-window)
          ,@(mapcar (lambda (i)
                      `(,(kbd (format "s-%d" i)) .
                        (lambda ()
                          (interactive)
                          (go-to-screen ,i))))
                    (number-sequence 0 9))
          ,@(-map-indexed (lambda (i c)
                            `(,(kbd (format "s-%s" c)) .
                              (lambda ()
                                (interactive)
                                (go-to-external-screen ,i))))
                          (list "!" "@" "#" "$" "%" "^" "&" "*" "(" ")"))))

  ;; WTF: both this & the exwm mapping are needed for this to work.
  (general-evil-define-key '(normal insert visual global emacs) exwm-mode-map
    (kbd "C-SPC") #'my/force-main-menu)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; exwm settings

  (setq exwm-manage-force-tiling t)

  (exwm-wm-mode))



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; more exwm

(use-package exwm-xim)

(use-package exwm-randr
  :demand t
  :config
  (defun my/run-autorandr ()
    (async-shell-command "autorandr --change --force")
    ;; (message "autorandr config: %s" (shell-cmd-to-string "autorandr --current"))
    ;; FIXME also feh background
    (message "autorandr"))

  ;; (add-hook 'exwm-randr-screen-change-hook #'my/run-autorandr)
  ;; (my/run-autorandr)

  ;; autorandr

  ;; autorandr --save tv
  ;; autorandr --save work-monitor
  ;; autorandr --save obama-s-elf
  ;; (system-name) pcase, or based on `autorandr --current`, change this on hook, then run exwm-randr-refresh
  (setq exwm-randr-workspace-monitor-plist
        (mapcan (lambda (i)
                  (list i "HDMI-A-0"))
                (number-sequence 10 20)))
  (exwm-randr-mode))

(use-package exwm-workspace
  :demand t
  :custom
  (exwm-workspace-number 20) ;; see workspaces.el:6, why?
  :config
  ;;(setq exwm-workspace-number 20) ;; 10-20 for external monitors.
  (setq exwm-workspace-warp-cursor t
        mouse-autoselect-window nil
        focus-follows-mouse nil)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; modeline: exwm workspace

  (easy-menu-define exwm-workspace-menu nil
    "Menu for Exwm Workspace.

Also used in `exwm-mode-line-workspace-map'."
    '("Exwm Workspace"
      ["Add workspace" exwm-workspace-add]
      ["Delete current workspace" exwm-workspace-delete]
      ["Move workspace to" exwm-workspace-move]
      ["Swap workspaces" exwm-workspace-swap]
      ["Move X window to" exwm-workspace-move-window]
      ["Move X window from" exwm-workspace-switch-to-buffer]
      ["Toggle minibuffer" exwm-workspace-toggle-minibuffer]
      ["Switch workspace" exwm-workspace-switch]
      ;; Place this entry at bottom to avoid selecting others by accident.
      ("Switch to" :filter
       (lambda (&rest _args)
         (mapcar (lambda (i)
                   `[,(format "workspace %d" i)
                     (lambda ()
                       (interactive)
                       (exwm-workspace-switch ,i))
                     (/= ,i exwm-workspace-current-index)])
                 (number-sequence 0 (1- (exwm-workspace--count))))))))

  (defvar exwm-mode-line-workspace-map
    (let ((map (make-sparse-keymap)))
      (define-key map [mode-line mouse-1] 'exwm-workspace-switch)
      (define-key map [mode-line mouse-3] exwm-workspace-menu)
      map)
    "Local keymap for EXWM mode line string.  See `exwm-mode-line-format'.")

  (defcustom exwm-mode-line-format
    `((:propertize " " display (space :align-to (- right 7)))
      (:propertize (:eval (if (>= exwm-workspace-current-index 10)
                              (format "🖥️%d" exwm-workspace-current-index)
                            (format " 🖥️%d" exwm-workspace-current-index)))
                   local-map ,exwm-mode-line-workspace-map
                   mouse-face mode-line-highlight))
    "EXWM workspace in the mode line."
    :type 'sexp)

  (add-to-list 'my/mode-line-misc exwm-mode-line-format t))

(use-package exwm-systemtray
  :demand t
  :config
  (setq exwm-systemtray-background-color 'transparent)
  (exwm-systemtray-mode))

(use-package exwm-edit
  :demand t
  :config
  (setq exwm-edit-split 'left))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; perspepctive
;; not directly exwm stuff, but I only use it in exwm workspace context

(use-package perspective
  :demand t
  :after consult
  :init
  (setq persp-suppress-no-prefix-key-warning t)
  :custom
  (persp-show-modestring nil)
  (persp-initial-frame-name "don't speak unless spoken to")
  :config
  ;; Perspective provides `persp-consult-source` source that will list
  ;; buffers in current perspective. You can hide default buffer source
  ;; and add `persp-consult-source` to `consult-buffer-sources` for consult
  ;; to only list buffers in current perspective
  (consult-customize consult--source-buffer :hidden t :default nil)
  (add-to-list 'consult-buffer-sources persp-consult-source)
  (persp-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; lemon

(use-package lemon
  :demand t
  :custom
  (lemon-delay 1)
  (lemon-refresh-rate 2)
  (lemon-sparkline-use-xpm 1)
  (lemon-monitors
   (list '((lemon-time :display-opts '(:format "  📅 %a %b %d %H:%M"))
           (lemon-battery)
           (lemon-cpufreq-linux)
           (lemon-cpu-linux        :display-opts '(:sparkline (:type plain)))
           (lemon-memory-linux     :display-opts '(:sparkline (:type plain)))
           (lemon-disk-usage       :display-opts '(:sparkline (:type plain)))
           (lemon-linux-network-tx :display-opts '(:sparkline (:type plain)))
           (lemon-linux-network-rx :display-opts '(:sparkline (:type plain))))))
  :config
  (require 'lemon-battery)
  (require 'lemon-cpu)
  (require 'lemon-time)
  (require 'lemon-network)
  (require 'lemon-memory)

  (set-face-attribute 'lemon-time-face nil :foreground "#ffffff")

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; battery

  (defun lemon-battery--time-face (charging time-left)
    "Return monitor face based on CHARGING and TIME-LEFT.

If the battery is being charged, returns
`lemon-battery-charging-face'

If the battery is discharging, and there's between 59-30 minutes
estimated time to depletion, returns `lemon-battery-medium-face'.

If the battery is discharging, and there's between 0-29 minutes
estimated time to depletion, returns `lemon-battery-low-face'."

    (if charging 'lemon-battery-charging-face
      (cl-destructuring-bind (hh mm) (mapcar #'read (split-string time-left ":"))
        (cond
         ((and (= hh 0) (= mm 0)) 'lemon-battery-full-face)
         ((and (= hh 0) (> mm 30)) 'lemon-battery-medium-face)
         ((= hh 0) 'lemon-battery-low-face)
         (t 'lemon-battery-full-face)))))

  (cl-defmethod lemon-monitor-display ((this lemon-battery))
    "Return the display text for the battery monitor."
    (when-let ((status (lemon-monitor-value this)))
      (let ((charging (string= (downcase (cdr (assoc ?B status))) "charging"))
            (percent (pcase (read (cdr (assoc ?p status)))
                       ((and (pred numberp) pct) pct)
                       (_ 0)))
            (time-left (cdr (assoc ?t status))))
        (thread-first
          (if (or (= percent 100) (string= time-left "0:00"))
              "🔋"
            (format "🪫 %d%%%s"
                    percent
                    (if (string= time-left "N/A")
                        "" (concat (lemon-battery--indicator this charging) time-left))))
          (propertize 'face (lemon-battery--face charging percent time-left))))))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; disk usage

  (defclass lemon-disk-usage (lemon-monitor-history)
    ((default-display-opts
      :initform '(:index "DISK:" :unit "%"))))

  (cl-defmethod lemon-monitor-fetch ((_ lemon-disk-usage))
    (let* ((default-directory "~/") ;; don't show me remote disk usage
           (output (shell-command-to-string "df / | sed -nre 's/.*[^0-9]([0-9]+)%.*/\\1/p'")))
      (string-to-number output)))

  (lemon-mode 1))

;;; exwm.el ends here
(provide 'conf/exwm)
