
;; UI
(require 'conf/fancy "~/.emacs.d/fancy.el")
(require 'conf/evil "~/.emacs.d/evil.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; emacs general config:

(require 'savehist)
(savehist-mode)

(save-place-mode)

(require 'recentf)
(recentf-mode)

(setq mouse-yank-at-point t)
(setq scroll-margin 5)

(require 'whitespace)
(setq whitespace-action '(auto-cleanup))

;; (global-visual-line-mode) ;; most certainly not, was I high?

;; stop touching my stuff (see perfect window placement)
(setq display-buffer-base-action
  '((display-buffer-reuse-window display-buffer-same-window)
    (reusable-frames . t)))

(setq even-window-sizes nil)     ; avoid resizing

(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist '(("." . "~/.saves/"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups
;; (setq tramp-backup-directory-alist backup-directory-alist)

(setq emacsql-sqlite-executable (executable-find "emacsql-sqlite"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auth

(require 'pass)
(require 'pinentry)
(pinentry-start)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; projectile

(require 'projectile)
(projectile-global-mode)
(setq projectile-project-search-path '(( "/code" . 3) ( "/work" . 3) ("/data" . 1)))
(setq projectile-sort-order 'recently-active)
(setq projectile-enable-caching t)
;; FIXME (projectile-save-known-projects) call this from time to time? after each add? on session exit?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; magit

(require 'magit)
(setq magit-status-initial-section '(3))
(add-hook 'magit-diff-mode-hook 'scroll-lock-mode)
(add-hook 'magit-log-mode-hook 'scroll-lock-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; eshell

(setq eshell-history-size         10000
      eshell-buffer-maximum-lines 10000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t)

(setq comint-scroll-to-bottom-on-input t
      comint-scroll-to-bottom-on-output t);; setq-local to toggle this per shell?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dired

(require 'diredfl)
(require 'all-the-icons-dired) ;; and after that try all icons init
(require 'dired-toggle-sudo)
(require 'dired-rsync)
(require 'dired-open)
;; (require 'dired-ranger)
(require 'dired-collapse)
(setq dired-dwim-target t)

(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
(add-hook 'dired-mode-hook 'diredfl-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; search

(require 'rg)
(require 'wgrep)

(autoload 'wgrep-rg-setup "wgrep-rg")
(add-hook 'rg-mode-hook 'wgrep-rg-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sub config

(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
(require 'conf/misc "~/.emacs.d/misc.el")
(require 'conf/completion "~/.emacs.d/completion.el")
(require 'conf/org "~/.emacs.d/org-conf.el")
(require 'conf/lisp "~/.emacs.d/lisp-config.el")
(require 'conf/doom "~/.emacs.d/doom.el")
(require 'conf/maps "~/.emacs.d/maps.el")
(require 'conf/dev "~/.emacs.d/dev.el")
(require 'conf/communication "~/.emacs.d/communication.el")
(require 'conf/elfeed "~/.emacs.d/elfeed.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; end of config stuff:

(require 'diminish)
(diminish 'projectile-mode)
(diminish 'org-indent-mode)
(diminish 'snipe-mode)
(diminish 'evil-org-mode)
(diminish 'evil-snipe-local-mode)
(diminish 'evil-snipe-mode)
(diminish 'evil-escape-mode)

(provide 'init)
