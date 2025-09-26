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
  (scheme-mode-hook . guix-devel-mode)
  :config
  (my/nuke-all-gz-for-origami))

(use-package geiser-mode
  :hook
  (scheme-mode-hook . geiser-mode)
  :config
  (my/nuke-all-gz-for-origami))

(use-package evil-cleverparens
  :hook ((emacs-lisp-mode-hook . evil-cleverparens-mode)
         (scheme-mode-hook . evil-cleverparens-mode))

  :config
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
  (setq evil-cleverparens-use-s-and-S nil)
  (my/nuke-all-gz-for-origami))

;; c-q to insert literal character without paredit balancing
;; (add-hook 'lisp-mode-hook 'enable-paredit-mode)

(use-package origami
  :demand t
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
  ;; clear up gz for origami:
  (defun my/nuke-all-gz-for-origami ()
    (mapc
     (lambda (m)
       (evil-collection-define-key 'normal m
         "gz" nil))
     '(emacs-lisp-mode-map
       guix-devel-mode-map
       guix-devel-keys-map
       guix-ui-map
       geiser-mode-map
       scheme-mode-map
       evil-cleverparens-mode-map)))
  (my/nuke-all-gz-for-origami)
  ;; temp?
  (general-define-key
   :states 'normal
   "<TAB>" #'origami-toggle-node
   "gzc" #'origami-close-node
   "gzo" #'origami-open-node-recursively
   "gzC" #'origami-close-all-nodes
   "gzO" #'origami-open-all-nodes))

(provide 'conf/lisp)
