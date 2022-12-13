(add-hook 'emacs-lisp-mode-hook #'evil-cleverparens-mode)
(add-hook 'scheme-mode-hook #'evil-cleverparens-mode)

(require 'eval-sexp-fu)
(require 'evil-cleverparens)


(provide 'lisp-config)
