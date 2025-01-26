;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clojure

(use-package cider)
(use-package clojure-mode)
(setq org-babel-clojure-backend 'cider)

;; TODO: try out tropin's clojure settings:
;; (setq-local completion-at-point-functions (list (cape-super-capf #'cider-complete-at-point #'eglot-completion-at-point)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; guile

(use-package eval-in-repl-geiser)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; paredit


(use-package eval-sexp-fu)
(use-package paredit)

(use-package aggressive-indent
  :hook
  ((emacs-lisp-mode-hook . aggressive-indent-mode)
   (scheme-mode-hook . aggressive-indent-mode)))

(use-package guix-devel
  :hook
  (scheme-mode-hook . guix-devel-mode))

(use-package geiser-mode
  :hook
  (scheme-mode-hook . geiser-mode))

(use-package evil-cleverparens
  ;; :defer t
  :hook ((emacs-lisp-mode-hook . evil-cleverparens-mode)
         (scheme-mode-hook . evil-cleverparens-mode))
  :config
  (progn
    (general-evil-define-key '(normal visual) evil-cleverparens-mode-map
      ;;"Y"     #'evil-cp-yank-enclosing
      "{"     #'evil-backward-paragraph
      "}"     #'evil-forward-paragraph
      "("     #'evil-cp-previous-opening
      ")"     #'evil-cp-next-opening
      "C-k"   #'sp-backward-sexp
      "C-j"   #'sp-next-sexp
      "é"     #'sp-backward-up-sexp
      "&"     #'sp-next-sexp
      "ï"     #'sp-backward-up-sexp         ; FIXME put this in global map?
      "M-r"   #'paredit-raise-sexp
      "M-t"   #'sp-transpose-sexp
      "M-T"   (lambda() (interactive) (sp-transpose-sexp -1))
      "M-g p" #'evil-cp-wrap-next-round
      "M-g P" #'evil-cp-wrap-previous-round
      "M-g c" #'evil-cp-wrap-next-curly
      "M-g C" #'evil-cp-wrap-previous-curly
      "M-g s" #'evil-cp-wrap-next-square
      "M-g S" #'evil-cp-wrap-previous-square)

    (general-evil-define-key '(normal) evil-cleverparens-mode-map
      :prefix "RET"
      "r"   #'paredit-raise-sexp
      "R"   #'evil-cp-raise-form
      ">"   #'sp-transpose-sexp
      "<"   (lambda() (interactive) (sp-transpose-sexp -1))
      "t"   #'sp-transpose-sexp
      "T"   (lambda() (interactive) (sp-transpose-sexp -1))
      "M-T" (lambda() (interactive) (sp-transpose-sexp -1))
      "@"  #'sp-splice-sexp
      "p"  #'evil-cp-wrap-next-round
      "P"  #'evil-cp-wrap-previous-round
      "c"  #'evil-cp-wrap-next-curly
      "C"  #'evil-cp-wrap-previous-curly
      "s"  #'evil-cp-wrap-next-square
      "S"  #'evil-cp-wrap-previous-square)

    (setq evil-cleverparens-complete-parens-in-yanked-region nil)
    (setq evil-cleverparens-move-skip-delimiters t)
    (setq evil-cleverparens-swap-move-by-word-and-symbol nil)
    (setq evil-cleverparens-drag-ignore-lines t)
    (setq evil-cleverparens-use-s-and-S nil)))

;; c-q to insert literal character without paredit balancing
;; (add-hook 'lisp-mode-hook 'enable-paredit-mode)

(provide 'conf/lisp)
