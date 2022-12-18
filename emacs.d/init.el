(setq emacs-home-config-root "~/.emacs.d/")
(setq evil-want-keybinding nil) ;; sigh ;; FIXME

;; UI
(require 'fancy "~/.emacs.d/fancy.el")
(require 'evil "~/.emacs.d/evil.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; emacs general config:

(require 'savehist)
(savehist-mode)

(require 'recentf)
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

(with-eval-after-load 'flyspell
  (add-hook 'org-mode-hook
            (lambda () (flyspell-mode 1))))

(global-visual-line-mode)

(require 'projectile)
(setq projectile-project-search-path '(( "/code" . 3) ( "/work" . 3) ("/data" . 1)))

(require 'magit)


(require 'misc "~/.emacs.d/misc.el")
(require 'completion "~/.emacs.d/completion.el")
(require 'org-conf "~/.emacs.d/org-conf.el")
(require 'lisp-config "~/.emacs.d/lisp-config.el")
(require 'doom "~/.emacs.d/doom.el")
(require 'maps "~/.emacs.d/maps.el")
(require 'dev "~/.emacs.d/dev.el")
(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
;; (load (concat emacs-home-config-root "exwm.el"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; eshell

(setq eshell-history-size         10000
      eshell-buffer-maximum-lines 10000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t)

(require 'diredfl)
(require 'all-the-icons-dired) ;; and after that try all icons init
(require 'dired-toggle-sudo)
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
(add-hook 'dired-mode-hook 'diredfl-mode)

(provide 'init)
