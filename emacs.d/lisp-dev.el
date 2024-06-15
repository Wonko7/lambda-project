;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clojure

(require 'cider)
(require 'clojure-mode)
(setq org-babel-clojure-backend 'cider)

;; TODO: try out tropin's clojure settings:
;; (setq-local completion-at-point-functions (list (cape-super-capf #'cider-complete-at-point #'eglot-completion-at-point)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; guile

(require 'eval-in-repl-geiser)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; paredit

(add-hook 'emacs-lisp-mode-hook #'evil-cleverparens-mode)
(add-hook 'scheme-mode-hook #'evil-cleverparens-mode)

(require 'eval-sexp-fu)
(require 'evil-cleverparens)

(setq evil-cleverparens-complete-parens-in-yanked-region nil)
(setq evil-cleverparens-move-skip-delimiters t)
(setq evil-cleverparens-swap-move-by-word-and-symbol nil)
(setq evil-cleverparens-drag-ignore-lines t)
(setq evil-cleverparens-use-s-and-S nil)


(require 'paredit)
;; c-q to insert literal character without paredit balancing
;; (add-hook 'lisp-mode-hook 'enable-paredit-mode)


(provide 'conf/lisp)
