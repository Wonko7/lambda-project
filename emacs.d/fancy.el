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
;; emoji & icons

(require 'all-the-icons)
(require 'all-the-icons-completion)
(all-the-icons-completion-mode)
(add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup)
(require 'kind-icon)

(with-eval-after-load 'emojify
  (progn
    (add-hook 'after-init-hook #'global-emojify-mode)
    (setq emojify-styles (list 'unicode))
    (emojify-set-emoji-styles emojify-styles)
    (setq emojify-display-style 'unicode)
    (setq emojify-emoji-styles '(unicode))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; theme

(require 'doom-themes)
;; Global settings (defaults)
(setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
      doom-themes-enable-italic t) ; if nil, italics is universally disabled
                                        ;(load-theme 'doom-city-lights t)
(load-theme 'doom-laserwave t)

;; Enable flashing mode-line on errors
(doom-themes-visual-bell-config)
;; Corrects (and improves) org-mode's native fontification.
(doom-themes-org-config)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fonts & utf-8

(set-face-attribute 'default nil :font my/font :height my/font-size)
;;(setq use-default-font-for-symbols t)
(set-fontset-font t 'symbol "Symbols Nerd Font Mono" nil 'append)

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

(require 'doom-modeline)
(setq doom-modeline-minor-modes t)
(setq doom-modeline-column-zero-based t)
(setq column-number-mode t)
(setq doom-modeline-height my/modeline-height)
(setq doom-modeline-project-detection 'projectile)
(setq doom-modeline-buffer-encoding 'nondefault)
(setq doom-modeline-persp-name nil)
(setq doom-modeline-workspace-name t)
(setq doom-modeline-persp-icon nil)
(doom-modeline-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cursor

;; (require 'beacon)
;; (beacon-mode 1)
;; (setq beacon-blink-when-point-moves-horizontally 2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; nyan

(require 'nyan-mode)
(setq nyan-animate-nyancat nil) ;; FIXME doesn't like to animate with emacs 29.1
(nyan-mode 1)

(provide 'conf/fancy)
