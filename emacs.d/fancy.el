;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI stuff

(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 5)

(setq visible-bell t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; theme

(require 'doom-themes)
;; Global settings (defaults)
(setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
      doom-themes-enable-italic t) ; if nil, italics is universally disabled
                                        ;(load-theme 'doom-city-lights t)
(load-theme (intern my/theme) t)

;; Enable flashing mode-line on errors
(doom-themes-visual-bell-config)
;; Corrects (and improves) org-mode's native fontification.
(doom-themes-org-config)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fonts & utf-8

(set-face-attribute 'default nil :font my/font :height my/font-size)
;;(setq use-default-font-for-symbols t)
(set-fontset-font t 'emoji "Symbols Nerd Font Mono" nil 'append)

;; lol fuck me.
;; (defun my-emoji-fonts ()
;;   (set-fontset-font t 'unicode (face-attribute 'default :family))
;;   (set-fontset-font t '(#x2300 . #x27e7) "Twemoji")
;;   (set-fontset-font t '(#x2300 . #x27e7) "Noto Color Emoji" nil 'append)
;;   (set-fontset-font t '(#x27F0 . #x1FAFF) "Twemoji")
;;   (set-fontset-font t '(#x27F0 . #x1FAFF) "Noto Color Emoji" nil 'append)
;;   (set-fontset-font t 'unicode "Symbola" nil 'append))

(set-fontset-font t '(#x2300 . #x1FAFF) "Noto Color Emoji")
;; test:
;; ☮ 🐫 📀 📐 ⛰

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; modeline: major mode

(setq my/mode-line-major-mode
      (let ((recursive-edit-help-echo
             "Recursive edit, type C-M-c to get out"))
        (list (propertize "%[" 'help-echo recursive-edit-help-echo)
              "{"
              `(:propertize
                (:eval (or (nerd-icons-icon-for-mode major-mode :face 'mode-line-buffer-id)
                           mode-name))
                help-echo (lambda (window _object _point)
                            (with-selected-window window
                              (concat (format-mode-line mode-name) ": \
mouse-1: Display major mode menu\n\
mouse-2: Show help for major mode\n\
mouse-3: Toggle minor modes")))
                mouse-face mode-line-highlight
                local-map ,mode-line-major-mode-keymap)
              '("" mode-line-process)
              (propertize "%n" 'help-echo "mouse-2: Remove narrowing from buffer"
                          'mouse-face 'mode-line-highlight
                          'local-map (make-mode-line-mouse-map
                                      'mouse-2 #'mode-line-widen))
              "}"
              (propertize "%]" 'help-echo recursive-edit-help-echo)
              " ")))
(put 'my/mode-line-major-mode 'risky-local-variable t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; modeline: exwm workspace / misc mood

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
  `((:propertize " " display (space :align-to (- right 6)))
    (:propertize (:eval (format "🖥️%d" exwm-workspace-current-index))
                 local-map ,exwm-mode-line-workspace-map
                 mouse-face mode-line-highlight))
  "EXWM workspace in the mode line."
  :type 'sexp)

(setq my/mode-line-misc
      (list "🌻🐝️"
            ;; "🛻🦖"
            exwm-mode-line-format))
(put 'my/mode-line-misc 'risky-local-variable t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; modeline: file status

(defvar-local my/mode-line-remote
    `((:propertize
       (:eval
        (if (file-remote-p default-directory) "📡" ""))
       mouse-face mode-line-highlight
       help-echo (lambda (window _object _point)
                   (format "%s"
                           (with-selected-window window
                             (if (stringp default-directory)
                                 (concat
                                  (if (file-remote-p default-directory)
                                      "Current directory is remote: "
                                    "Current directory is local: ")
                                  default-directory)
                               "Current directory is nil")))))))
(put 'my/mode-line-remote 'risky-local-variable t)

(defvar-local my/mode-line-modified
    `((:propertize
       (:eval (if buffer-read-only "🔒" ""))
       mouse-face mode-line-highlight
       help-echo mode-line-read-only-help-echo)
      (:propertize
       (:eval (if (and (buffer-file-name) (buffer-modified-p)) "💾" ""))
       mouse-face mode-line-highlight
       help-echo mode-line-modified-help-echo)))
(put 'my/mode-line-modified 'risky-local-variable t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; modeline with margin:

(setq mode-line-with-margin
      `((:eval
         (let ((ml (format-mode-line
                    '("%e"
                      mode-line-front-space
                      mode-line-mule-info mode-line-client
                      my/mode-line-modified
                      my/mode-line-remote
                      mode-line-frame-identification
                      mode-line-buffer-identification
                      evil-mode-line-tag
                      my/mode-line-major-mode
                      mode-line-position
                      my/mode-line-misc
                      mode-line-end-spaces))))
           (concat
            (propertize "  " 'face 'fringe)
            ml
            (propertize
             " " ;;'face 'holiday
             'display `((space :align-to (- (+ right right-fringe right-margin 1) 3))))
            (propertize  "  " 'face 'fringe 'display `((space :width 2))))))))

(setq mode-line-format mode-line-with-margin)
(setq-default mode-line-format mode-line-with-margin)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; windows

(set-face-foreground 'vertical-border "#4e2e49")
(setq window-divider-default-right-width my/window-divider-default-right-width)
(window-divider-mode)

(provide 'conf/fancy)
