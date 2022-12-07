(setq emacs-home-config-root "~/.emacs.d/")
(setq evil-want-keybinding nil) ;; sigh

;; UI
(load (concat emacs-home-config-root "fancy.el"))
(load (concat emacs-home-config-root "evil.el"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; emacs general config:

(use-package savehist
  :init
  (savehist-mode))

(recentf-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; spell

;; (global-spell-fu-mode 0)
(setenv "LANG" "en_GB-ise.utf8")
(setq ispell-program-name "hunspell")
(setq ispell-dictionary "en_GB-ise,en_GB-ize,fr-toutesvariantes")
(setq ispell-local-dictionary-alist `(("en_GB-ise,en_GB-ize,fr-toutesvariantes"
                                       "[[:alpha:]]" "[^[:alpha:]]" "[0-9']" t
                                       ("-d" "en_GB-ise,en_GB-ize,fr-toutesvariantes")
                                       nil utf-8)))

(use-package flyspell
  :init
  (add-hook 'org-mode-hook
            (lambda () (flyspell-mode 1))))

(global-visual-line-mode)


(use-package projectile)
(use-package magit)

;; this should be in my load-path, should it not?
(load (concat emacs-home-config-root "completion.el"))
(load (concat emacs-home-config-root "org-conf.el"))
(load (concat emacs-home-config-root "lisp-config.el"))
(load (concat emacs-home-config-root "maps.el"))
(load (concat emacs-home-config-root "dev.el"))
;; (load (concat emacs-home-config-root "exwm.el"))

(provide 'init)
