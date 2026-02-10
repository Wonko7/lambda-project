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

(use-package outline-indent
  :commands (outline-indent--update-ellipsis outline-indent-minor-mode)
  :hook
  (makefile-mode-hook . outline-indent-minor-mode)
  :custom
  (outline-indent-ellipsis " ▼")
  :config
  (defun outline-toggle-children ()
    (interactive)
    (save-excursion
      (outline-back-to-heading)
      (if (not (outline-invisible-p (pos-eol)))
          (outline-hide-subtree)
        (outline-show-subtree) ;; <- this is the diff
        (outline-show-entry)))))

(use-package hideshow
  :after outline-indent
  :hook
  (emacs-lisp-mode-hook . hs-minor-mode)
  (emacs-lisp-mode-hook . outline-indent--update-ellipsis)
  (scheme-mode-hook . hs-minor-mode)
  (scheme-mode-hook . outline-indent--update-ellipsis))

(use-package seq)
(use-package origami
  :after (evil seq outline-indent)
  :custom
  (origami-fold-replacement " ▼")
  :hook
  (tuareg-mode-hook . origami-mode)
  (org-agenda-mode-hook . origami-mode)
  :config
  (let* ((op origami-parser-alist))
    (setq origami-parser-alist (append origami-parser-alist
                                       `((tuareg-mode . origami-indent-parser)))))
  (defun origami-recursively-toggle-node (buffer point)
    ;; diff is rm `if last-command` that won't work wrapped in evil-fold.
    (interactive (list (current-buffer) (point)))
    (-when-let (path (origami-search-forward-for-path buffer point))
      (let ((node (-last-item path)))
        (cond ((origami-fold-node-recursively-open? node)
               (origami-close-node-recursively buffer (origami-fold-beg node)))
              ((origami-fold-node-recursively-closed? node)
               (origami-toggle-node buffer (origami-fold-beg node)))
              (t (origami-open-node-recursively buffer (origami-fold-beg node)))))))
  (setq evil-fold-list
        (cons
         `((origami-mode)
           :open-all   ,(lambda () (origami-open-all-nodes (current-buffer)))
           :close-all  ,(lambda () (origami-close-all-nodes (current-buffer)))
           :toggle     ,(lambda () (origami-recursively-toggle-node (current-buffer) (point)))
           :open       ,(lambda () (origami-open-node (current-buffer) (point)))
           :open-rec   ,(lambda () (origami-open-node-recursively (current-buffer) (point)))
           :close      ,(lambda () (origami-close-node (current-buffer) (point))))
         (seq-filter (lambda (actions)
                       (let ((m (caar actions)))
                         (not (equal m 'origami-mode))))
                     evil-fold-list))))

(provide 'conf/lisp)
