;;; lisp-dev.el  -*- lexical-binding: t; -*-

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

(use-package geiser-mode)

(use-package geiser-guile-mode
  :config
  (add-to-list 'geiser-guile-load-path "/code/guix"))

(use-package evil-cleverparens
  :hook ((emacs-lisp-mode-hook . evil-cleverparens-mode)
         (scheme-mode-hook . evil-cleverparens-mode))

  :custom
  (evil-cleverparens-complete-parens-in-yanked-region t)
  (evil-cleverparens-move-skip-delimiters nil)
  (evil-cleverparens-swap-move-by-word-and-symbol nil)
  (evil-cleverparens-drag-ignore-lines t)
  (evil-cleverparens-use-s-and-S nil)

  :config
  (general-evil-define-key '(normal visual) evil-cleverparens-mode-map
    ;;"Y"     #'evil-cp-yank-enclosing
    "{"     #'evil-backward-paragraph
    "}"     #'evil-forward-paragraph
    "("     #'evil-cp-previous-opening
    ")"     #'evil-cp-next-opening
    "C-k"   #'sp-backward-sexp
    "C-j"   #'sp-next-sexp
    "é"     #'backward-up-list
    "&"     #'sp-next-sexp
    "à"     #'beginning-of-defun
    ;; review, not using
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
    "r"   #'sp-raise-sexp
    "R"   #'evil-cp-raise-form
    ">"   #'sp-transpose-sexp
    "<"   (lambda() (interactive) (sp-transpose-sexp -1))
    "t"   #'sp-transpose-sexp
    "T"   (lambda() (interactive) (sp-transpose-sexp -1))
    "M-T" (lambda() (interactive) (sp-transpose-sexp -1))
    "@"  #'sp-splice-sexp
    "u"  #'sp-unwrap-sexp
    "j"  #'sp-join-sexp
    "s"  #'sp-split-sexp
    "p"  #'sp-wrap-round
    "w"  #'sp-wrap-round
    "C"  #'sp-wrap-curly
    "S"  #'sp-wrap-square))

;; c-q to insert literal character without paredit balancing
;; (add-hook 'lisp-mode-hook 'enable-paredit-mode)

(use-package origami
  :disabled t
  :custom
  (origami-fold-replacement "…")

  :config
  (global-origami-mode)
  ;; change emacs lisp parser:
  (let* ((op origami-parser-alist)
         (op (assoc-delete-all 'emacs-lisp-mode op))
         (op (assoc-delete-all 'lisp-interaction-mode op)))
    (setq origami-parser-alist (append origami-parser-alist
                                       `((emacs-lisp-mode       . origami-indent-parser)
                                         (lisp-interaction-mode . origami-indent-parser)))))
  (general-define-key
   :states 'normal
   "<TAB>" #'evil-toggle-fold))

(use-package origami
  :custom
  (origami-fold-replacement "…")

  :config
  (global-origami-mode)
  ;; change emacs lisp parser:
  (let* ((op origami-parser-alist)
         (op (assoc-delete-all 'emacs-lisp-mode op))
         (op (assoc-delete-all 'lisp-interaction-mode op)))
    (setq origami-parser-alist (append origami-parser-alist
                                       `((emacs-lisp-mode       . origami-indent-parser)
                                         (lisp-interaction-mode . origami-indent-parser)))))
  (general-define-key
   :states 'normal
   "<TAB>" #'evil-toggle-fold))

(use-package outline-indent
  :commands outline-indent-minor-mode
  :custom
  (outline-indent-ellipsis " ▼")
  ;; (origami-fold-replacement "…")

  :config
  (general-define-key
   :states 'normal
   "<TAB>" #'evil-toggle-fold))

(provide 'conf/lisp)
