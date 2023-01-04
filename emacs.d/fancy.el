;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI stuff

(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 5)

(setq visible-bell t)
(setq display-line-numbers-type t)
;(display-line-numbers-mode)
(global-linum-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; emoji & icons

(when (display-graphic-p)
  (require 'all-the-icons))

(with-eval-after-load 'emojify
  (progn
    (add-hook 'after-init-hook #'global-emojify-mode)
    (setq emojify-styles (list 'unicode))
    (emojify-set-emoji-styles emojify-styles)
    (setq emojify-display-style 'unicode)
    (setq emojify-emoji-styles '(unicode))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fonts & utf-8

(set-face-attribute 'default nil :font "JetBrains Mono" :height 250)
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
;; modeline

(setq display-time-day-and-date t)
;; (setq display-time-format "%a|%F|%R")
(display-time-mode 1)

(require 'doom-modeline)
(setq doom-modeline-minor-modes t)
(setq doom-modeline-column-zero-based t)
(setq doom-modeline-height 5)
(setq doom-modeline-project-detection 'projectile)
(setq doom-modeline-buffer-encoding 'nondefault)
(setq doom-modeline-persp-name nil)
(setq doom-modeline-workspace-name t)
(setq doom-modeline-persp-icon nil)
(doom-modeline-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cursor

(require 'beacon)
(beacon-mode 1)
(setq beacon-dont-blink-commands nil)
(setq beacon-blink-when-point-moves-horizontally 2)

(provide 'conf/fancy)
