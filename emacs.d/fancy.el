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
;; faces

(custom-set-faces
 '(flyspell-incorrect ((t :underline (:style line :color "deep pink")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; modeline

(setq display-time-day-and-date t)
;; (setq display-time-format "%a|%F|%R")
(display-time-mode 1)

;; disabled because it was buggy and CPU intensive at some point...
;; (require 'doom-modeline)
;; (setq doom-modeline-minor-modes t)
;; (setq doom-modeline-column-zero-based t)
;; (setq column-number-mode t)
;; (setq doom-modeline-height my/modeline-height)
;; (setq doom-modeline-project-detection 'projectile)
;; (setq doom-modeline-buffer-encoding 'nondefault)
;; (setq doom-modeline-persp-name nil)
;; (setq doom-modeline-workspace-name t)
;; (setq doom-modeline-persp-icon nil)
;; (doom-modeline-mode)

;; just remove minor modes:
(setq mode-line-modes
      (let ((recursive-edit-help-echo
             "Recursive edit, type C-M-c to get out"))
        (list (propertize "%[" 'help-echo recursive-edit-help-echo)
	      "("
	      `(:propertize ("" mode-name)
			    help-echo "Major mode\n\
mouse-1: Display major mode menu\n\
mouse-2: Show help for major mode\n\
mouse-3: Toggle minor modes"
			    mouse-face mode-line-highlight
			    local-map ,mode-line-major-mode-keymap)
	      '("" mode-line-process)
              ;; 	      `(:propertize ("" minor-mode-alist)
              ;; 			    mouse-face mode-line-highlight
              ;; 			    help-echo "Minor mode\n\
              ;; mouse-1: Display minor mode menu\n\
              ;; mouse-2: Show help for minor mode\n\
              ;; mouse-3: Toggle minor modes"
              ;; 			    local-map ,mode-line-minor-mode-keymap)
	      (propertize "%n" 'help-echo "mouse-2: Remove narrowing from buffer"
		          'mouse-face 'mode-line-highlight
		          'local-map (make-mode-line-mouse-map
				      'mouse-2 #'mode-line-widen))
	      ")"
	      (propertize "%]" 'help-echo recursive-edit-help-echo)
	      " ")))

;; add workspace:
(defcustom exwm-mode-line-format
  `((:propertize " " display (space :align-to (- right 6)))
    (:propertize (:eval (format "🖥️%d" exwm-workspace-current-index))
		 ;; local-map ,exwm-mode-line-workspace-map
		 mouse-face mode-line-highlight
                 ))
  "EXWM workspace in the mode line."
  :type 'sexp)

(add-to-list 'mode-line-misc-info exwm-mode-line-format t)

;; mode-line-format (remove '(vc-mode vc-mode) mode-line-format)

(setq mode-line-with-margin
      `(
        ;;'display '(space :width 1)
        (:eval
         (let* ((ml (format-mode-line
                     '("%e"
                       mode-line-front-space
                       (:propertize
                        ("" mode-line-mule-info mode-line-client mode-line-modified mode-line-remote)
                        ;; display (min-width (5.0))
                        )
                       mode-line-frame-identification
                       mode-line-buffer-identification
                       "   " mode-line-position evil-mode-line-tag "  " mode-line-modes mode-line-misc-info
                       mode-line-end-spaces
                       )))
                (w  (+ (window-width) 0))
                (ml (truncate-string-to-width ml w))
                )
           (concat
            (propertize " " 'face 'fringe)
            ml
            (propertize " " ;;'face 'holiday
                        'display `((space :align-to (- (+ right right-fringe right-margin 1) 2))))
            (propertize " " 'face 'fringe 'display `((space :width 1)))
            )))))

(setq mode-line-format mode-line-with-margin)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; windows

(set-face-foreground 'vertical-border "#4e2e49")
(setq window-divider-default-right-width my/window-divider-default-right-width)
(window-divider-mode)

(provide 'conf/fancy)
