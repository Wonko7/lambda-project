;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; emoji & icons

;; (require 'all-the-icons)
;; (require 'all-the-icons-completion)
;; (all-the-icons-completion-mode)
;; (add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup)
;; (require 'kind-icon)

(use-package nerd-icons
  :demand t)

(use-package nerd-icons-ibuffer
  :demand t
  :after ibuffer
  :hook (ibuffer-mode-hook . nerd-icons-ibuffer-mode))

(use-package nerd-icons-dired
  :demand t
  :hook (dired-mode-hook . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :demand t
  :after marginalia
  :hook (marginalia-mode-hook nerd-icons-completion-marginalia-setup)
  :config
  (nerd-icons-completion-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cursor

;; (require 'beacon)
;; (beacon-mode 1)
;; (setq beacon-blink-when-point-moves-horizontally 2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; nyan

(use-package nyan-mode
  :demand t
  :custom
  (nyan-animate-nyancat nil) ;; FIXME doesn't like to animate with emacs 29.1
  :config
  (nyan-mode 1))


(provide 'conf/fancy-but-later)
