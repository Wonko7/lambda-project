(require 'doom-themes)

;; UI stuff

(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

(setq visible-bell t)
(setq display-line-numbers-type t)
;(display-line-numbers-mode)
(global-linum-mode)

;; icons
(use-package all-the-icons
  :if (display-graphic-p))

(use-package emojify
  :config
  (setq emojify-styles (list 'unicode))
  (emojify-set-emoji-styles emojify-styles)
  (setq emojify-display-style 'unicode)
  (setq emojify-emoji-styles '(unicode))
  :hook
  (after-init . global-emojify-mode))

(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font Mono" :height 250)
(setq use-default-font-for-symbols t)
(set-fontset-font t 'symbol "Symbols Nerd Font Mono" nil 'append)

;; test:
;; 🐫 📀 📐 ⛰ 

;; theme
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  ;(load-theme 'doom-city-lights t)
  (load-theme 'doom-laserwave t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  ;; (doom-themes-neotree-config)
  ;; or for treemacs users
  ;; (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :config (setq doom-modeline-height 20)
  :init (doom-modeline-mode 1))

(provide 'fancy)
