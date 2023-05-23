(add-hook 'emacs-lisp-mode-hook #'evil-cleverparens-mode)
(add-hook 'scheme-mode-hook #'evil-cleverparens-mode)

(require 'eval-sexp-fu)
(require 'evil-cleverparens)
(setq evil-cleverparens-complete-parens-in-yanked-region t)
(setq evil-cleverparens-move-skip-delimiters t)
(setq evil-cleverparens-swap-move-by-word-and-symbol t)
(setq evil-cleverparens-drag-ignore-lines t)
(setq evil-cleverparens-use-s-and-S nil)

(require 'eval-in-repl-geiser)


(provide 'conf/lisp)
