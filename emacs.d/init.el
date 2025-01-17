;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; guix home gives us stuff:

(require 'conf/generated-values "~/.emacs.d/generated-values.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; basic UI stuff:

(require 'conf/fancy "~/.emacs.d/fancy.el")
(require 'conf/evil  "~/.emacs.d/evil.el")
(require 'conf/misc  "~/.emacs.d/misc.el") ;; stuff depends on this
(require 'conf/keys  "~/.emacs.d/keys.el") ;; if init fails, at least bindings work

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; emacs general config:

(setq use-package-hook-name-suffix nil)

(require 'savehist)
(savehist-mode)

(save-place-mode)

(require 'recentf)
(recentf-mode)

(setq mouse-yank-at-point t)
(setq scroll-margin 5)

(setq-default word-wrap 1)
(setq truncate-partial-width-windows nil)
(setq truncate-lines t) ;; who is messing with my shit?
(setq org-startup-truncated nil) ;; org is messing with my shit
(add-hook 'org-agenda-mode-hook (lambda () ;; only disable in agenda.
                                  (setq truncate-lines t))) ;; and yet you shit in my mouth, why? t?

(use-package whitespace
  :config
  (setq whitespace-action '(auto-cleanup))
  (setq whitespace-style
        '(face
          tabs trailing
          empty
          tab-mark
          missing-newline-at-eof))
  (global-whitespace-mode 1))

(setq help-enable-variable-value-editing t)

;; stop touching my stuff (see perfect window placement):
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

;; line numbers

(setq display-line-numbers-type t)
(global-display-line-numbers-mode 1)
(add-hook 'shell-mode-hook                     (lambda () (display-line-numbers-mode 0)))
(add-hook 'eshell-mode-hook                    (lambda () (display-line-numbers-mode 0)))
(add-hook 'elfeed-show-mode-hook               (lambda () (display-line-numbers-mode 0)))
(add-hook 'elfeed-search-update-hook           (lambda () (display-line-numbers-mode 0)))
(add-hook 'ement-room-mode-hook                (lambda () (display-line-numbers-mode 0)))
(add-hook 'ement-room-list-mode-hook           (lambda () (display-line-numbers-mode 0)))
(add-hook 'ement-tabulated-room-list-mode-hook (lambda () (display-line-numbers-mode 0)))

(setq custom-file "~/.run/emacs/custom-cache.el")
(if (file-readable-p custom-file)
    (load custom-file))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; windows

(use-package ace-window
  :defer t
  :config
  (setq aw-keys '(?u ?h ?e ?t ?o ?n ?a ?s ?i ?d))
  (setq aw-dispatch-when-more-than 2)
  (setq aw-dispatch-always nil)
  (setq aw-leading-char-style 'path)
  (setq aw-char-position 'top-left)
  (setq aw-scope 'frame))

;; (require 'ace-link)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auth/pass

(use-package pass
  :defer t)

(require 'pinentry)
(setq epg-pinentry-mode 'loopback)
(pinentry-start)
;; (use-package pinentry
;;   :config
;;   (setq epg-pinentry-mode 'loopback)
;;   (pinentry-start))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; spelling

(use-package flyspell-correct
  ;;:defer t
  :config
  ;; (global-spell-fu-mode 0)
  ;; (setenv "DICTIONARY" "en_GB-ise")
  (setq ispell-program-name "hunspell")
  (setq ispell-dictionary "en_GB-ise,en_US,fr-toutesvariantes")
  (setq ispell-local-dictionary-alist `(("en_GB-ise,en_US,fr-toutesvariantes"
                                         "[[:alpha:]]" "[^[:alpha:]]" "[0-9']" t
                                         ("-d" "en_GB-ise,en_GB-ize,fr-toutesvariantes")
                                         nil utf-8))))

(use-package flyspell
  ;; :defer t
  :hook
  ((git-commit-mode-hook . (lambda () (flyspell-mode 1)))
   (org-mode-hook  . (lambda () (flyspell-mode 1))))
  :config
  (setq flyspell-mark-duplications-flag nil))

(use-package verbiste
  :defer t
  :commands (verbiste-deconjugate verbiste-conjugate))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; projectile

(use-package projectile
  :config
  (setq projectile-project-search-path '(( "/code" . 1) ( "/work" . 1) ("/data" . 1)))
  (setq projectile-sort-order 'recently-active)
  (setq projectile-enable-caching t)
  (projectile-global-mode))
;; FIXME (projectile-save-known-projects) call this from time to time? after each add? on session exit?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; magit

(require 'magit)
;;evil-state-property
;; (use-package magit
;;   ;; :defer t
;;   ;; :hook
;;   ;; ((magit-diff-mode-hook . #'scroll-lock-mode)
;;   ;;  (git-commit-setup-hook . #'my/org-commit-msg-setup 100))
;;   ;; (add-hook 'git-commit-setup-hook #'my/org-commit-msg-setup 100)
;;   ;; (add-hook 'magit-diff-mode-hook #'scroll-lock-mode)
;;   :config
(setq magit-status-initial-section '(((unstaged) (status))
			       ((staged) (status))
			       ((TODOs) (status))))

(general-evil-define-key '(normal) magit-diff-mode-map
  "("      #'diff-hunk-prev
  ")"      #'diff-hunk-next
  "C-k"    #'diff-hunk-prev
  "C-j"    #'diff-hunk-next)

(general-evil-define-key '(normal) magit-mode-map
  "("    #'magit-section-backward-sibling
  ")"    #'magit-section-forward-sibling
  "C-k"    #'magit-section-backward-sibling
  "C-j"    #'magit-section-backward-sibling)

(general-evil-define-key '(normal) git-rebase-mode-map ;; FIXME
  "K"    #'git-rebase-move-line-up
  "J"    #'git-rebase-move-line-down)

(general-evil-define-key '(normal) smerge-mode-map ;; FIXME
  "grk" #'smerge-prev
  "grj" #'smerge-next
  "C-k" #'smerge-prev
  "C-j" #'smerge-next
  "("   #'smerge-prev
  ")"   #'smerge-next
  "Ku"  #'smerge-keep-upper
  "Kl"  #'smerge-keep-lower)

(use-package magit-todos
  ;;:defer t
  :config
  (setq magit-todos-ignore-case t)
  (setq magit-todos-max-items 1000)
  (setq magit-todos-auto-group-items 'always)
  (advice-add #'magit-todos--insert-todos
	      :before-until #'check-if-todo-blacklisted)
  (advice-add #'magit-todos--add-to-status-buffer-kill-hook
	      :before-until #'check-if-todo-blacklisted)
  (magit-todos-mode))

(defun check-if-todo-blacklisted ()
  (let ((root (magit-with-toplevel default-directory)))
    (or (string= (substring root 0 5) "/ssh:")
	(string= root "/data/org/")
	(string= root "/work/guix/guix")
	(string= root "/code/guix/guix"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell

;; notes on eat:
;;  - line-mode is friendlier to evil
;;  - couldn't get ssh/tramp integration to work, which was the whole point

(use-package coterm
  :config
  (coterm-mode))

(use-package detached
  :ensure t
  :init
  (detached-init)
  :custom ((detached-show-output-on-attach t)
           (detached-terminal-data-command system-type)))


(setq comint-scroll-to-bottom-on-input t
      comint-scroll-to-bottom-on-output t) ;; setq-local to toggle this per shell?
;;(setq shell-prompt-pattern "^[^#$%>\n]*[#$%>λ] *")
;; (setq shell-prompt-pattern "^.*\n*[#$%>λ]")
(setq shell-prompt-pattern "^[🍏🍎].*\nλ")

(defun toggle-scroll-to-bottom-on-output ()
  (interactive)
  (setq-local comint-scroll-to-bottom-on-output
	      (not comint-scroll-to-bottom-on-output)))

(setq history-length 100000)

;; (use-package bash-completion
;;   :config
;;   (bash-completion-setup)
;;   :hook
;;   (shell-dynamic-complete-functions . #'bash-completion-dynamic-complete))
(require 'bash-completion)
(bash-completion-setup)
(add-hook 'shell-dynamic-complete-functions #'bash-completion-dynamic-complete)

;; FIXME: fuck me: comint-watch-for-password-prompt
;; run-at-time 0 nil => bug
;; run-at-time 0.01 nil => no bug. wtf?
(defun comint-watch-for-password-prompt (string)
  "Prompt in the minibuffer for password and send without echoing.
Looks for a match to `comint-password-prompt-regexp' in order
to detect the need to (prompt and) send a password.  Ignores any
carriage returns (\\r) in STRING.

This function could be in the list `comint-output-filter-functions'."
  (when (let ((case-fold-search t))
	  (string-match comint-password-prompt-regexp
			(string-replace "\r" "" string)))
    ;; Use `run-at-time' in order not to pause execution of the
    ;; process filter with a minibuffer
    ;; or don't use it so that there is no weird timeout bug.
    (with-current-buffer (current-buffer)
      (let ((comint--prompt-recursion-depth
	     (1+ comint--prompt-recursion-depth)))
	(if (> comint--prompt-recursion-depth 10)
	    (message "Password prompt recursion too deep")
	  (when (get-buffer-process (current-buffer))
	    (comint-send-invisible
	     (string-trim string "[ \n\r\t\v\f\b\a]+" "\n+"))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tramp

(use-package tramp
  :defer t
  :config
  (setq tramp-terminal-type "tramp")
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (setq tramp-ssh-controlmaster-options
	(concat
	 "-o ControlPath=/tmp/ssh-ControlPath-%%r@%%h:%%p "
	 "-o ControlMaster=auto -o ControlPersist=yes")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dired

(use-package diredfl
  :defer t
  :hook (dired-mode-hook . #'diredfl-mode))
(use-package all-the-icons-dired
  :defer t
  :hook
  (dired-mode-hook . #'all-the-icons-dired-mode))
(use-package dired-toggle-sudo
  :defer t)
(use-package dired-rsync
  :defer t)
(use-package dired-open
  :defer t)
(use-package dired-collapse
  :defer t)

(setq dired-dwim-target t)
(add-hook 'dired-mode-hook #'auto-revert-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ibuffer

(setq ibuffer-save-with-custom nil
      ibuffer-saved-filter-groups
      '(("default"
	 ("code"     (and (or (derived-mode . prog-mode)
			      (mode . yaml-mode))
			  (not (name . "^\\*scratch\\*$"))))
	 ("exwm"     (mode . exwm-mode))
	 ("dired"    (mode . dired-mode))
	 ("shell"    (or (mode . shell-mode) (derived-mode . comint-mode)))
	 ("org"      (derived-mode . org-mode))
	 ("ement"    (derived-mode . ement-room-mode))
	 ("special"  (and (name . "^\*") (not (name . "^\\*scratch\\*$"))))
	 ("scratch"  (name . "^\\*scratch\\*$")))))

(add-hook 'ibuffer-mode-hook
	  (lambda ()
	    (ibuffer-switch-to-saved-filter-groups "default")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; apps

(use-package osm
  :defer t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; async-shell-command

(setq async-shell-command-buffer 'new-buffer)

(add-to-list 'display-buffer-alist
	     '("*Async Shell Command*" display-buffer-no-window (nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; magit

;; (add-to-list 'display-buffer-alist
;;              '("*Magit Rev*" (display-buffer-reuse-window  display-buffer-in-side-window)
;;                (nil)))
;; (setq display-buffer-alist
;;       '(
;;         ("*Async Shell Command*"
;;          display-buffer-no-window
;;          (nil))
;;         ("*Magit Rev*"
;;          (display-buffer-reuse-window
;;           display-buffer-in-side-window)
;;          (nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; search

(use-package rg
  :defer t)

(use-package wgrep
  :defer t
  :hook
  (rg-mode-hook . #'wgrep-rg-setup)
  :config
  (autoload 'wgrep-rg-setup "wgrep-rg"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mentor

(setq mentor-rtorrent-download-directory "/mnt/trantor/media")
(setq mentor-rtorrent-external-rpc "~/.pirate-radio.socket")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; firefox

(use-package exwm-firefox-evil
  :defer t
  :hook
  (exwm-manage-finish-hook . #'exwm-firefox-evil-activate-if-firefox))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; midnight

;; (require 'midnight)
;; (setq clean-buffer-list-delay-general 3) ;; days

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; system stuff

(use-package bluetooth)

(defun my/brace-for-impact ()
  (recentf-save-list)
  (savehist-save)
  (save-some-buffers)
  (y-or-n-p "Fuck you Jonesy your mom shot cum straight across the room and killed my Siamese fighting fish threw off the ph levels in my aquarium"))

(defun my/sudo (command)
  (with-temp-buffer
    (cd "/sudo::/")
    (async-shell-command command)))

(defun my/reboot ()
  (interactive)
  (if (my/brace-for-impact)
      (my/sudo "reboot")))

(defun my/halt ()
  (interactive)
  (if (my/brace-for-impact)
      (my/sudo "halt")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sub config

(require 'opam-user-setup    "~/.emacs.d/opam-user-setup.el") ;; FIXME
(require 'conf/completion    "~/.emacs.d/completion.el")
(require 'conf/layouts       "~/.emacs.d/layouts.el")
(require 'conf/org           "~/.emacs.d/org-conf.el")
(require 'conf/lisp          "~/.emacs.d/lisp-dev.el")
(require 'conf/dev           "~/.emacs.d/dev.el")
(require 'conf/doom          "~/.emacs.d/doom.el")
(require 'conf/communication "~/.emacs.d/communication.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; end of config stuff:

(use-package diminish
  :config
  (diminish 'projectile-mode)
  (diminish 'org-indent-mode)
  (diminish 'snipe-mode)
  (diminish 'evil-org-mode)
  (diminish 'evil-snipe-local-mode)
  (diminish 'evil-snipe-mode)
  (diminish 'evil-escape-mode)
  (diminish 'evil-owl-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; input method

(require 'robin)
(require 'quail)

(robin-define-package "minimal-im"
                      "minimal desc"

                      ("\\\\ba"      ?à)
                      ("\\\\ca"      ?â)
                      ("\\\\ta"      ?ä)
                      ("||BA"        ?À)
                      ("||CA"        ?Â)
                      ("||TA"        ?Ä)

                      ("\\\\qe"      ?é)
                      ("\\\\be"      ?è)
                      ("\\\\ce"      ?ê)
                      ("\\\\te"      ?ë)
                      ("||QE"        ?É)
                      ("||BE"        ?È)
                      ("||CE"        ?Ê)
                      ("||TE"        ?Ë)

                      ("\\\\ti"      ?ï)
                      ("\\\\ci"      ?î)
                      ("||TI"        ?Ï)
                      ("||CI"        ?Î)

                      ("\\\\oe"      ?œ)
                      ("\\\\to"      ?ö)
                      ("\\\\co"      ?ô)
                      ("||OE"        ?Œ)
                      ("||TO"        ?Ö)
                      ("||CO"        ?Ô)

                      ("\\\\bu"      ?ù)
                      ("\\\\cu"      ?û)
                      ("\\\\tu"      ?ü)
                      ("||BU"        ?Ù)
                      ("||CU"        ?Û)
                      ("||TU"        ?Ü)

                      ("\\\\ty"      ?ÿ)
                      ("||TY"        ?Ÿ)

                      ("\\\\cc"      ?ç)
                      ("||CC"        ?Ç)
                      ("\\\\lambda"  ?λ)
                      ("||LAMBDA"    ?Λ))


(register-input-method "minimal-im"
                       "english"
                       'robin-use-package
                       "λ"
                       "minimal doc str")

;; (setq default-input-method "minimal-im")

(defun set-inp-meth! ()
  ;; (activate-input-method default-input-method)
  (set-input-method "minimal-im"))
(defun hook-set-inp-meth! ()
  ;; (activate-input-method default-input-method)
  (set-input-method "minimal-im"))

;; (add-hook 'change-major-mode-hook #'hook-set-inp-meth!)
;; (add-hook 'comint-mode-hook #'hook-set-inp-meth!)
;; (add-hook 'lisp-mode-hook #'hook-set-inp-meth!)
;; (add-hook 'minibuffer-setup-hook #'set-inp-meth!)
;;
;; (evil-set-initial-state 'exwm-mode 'emacs)

(provide 'init)
