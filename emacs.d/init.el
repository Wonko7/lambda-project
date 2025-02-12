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
(setq use-package-always-defer t)

(require 'savehist)
(savehist-mode)

(save-place-mode)
(setq history-length 100000)

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

(setq-default fill-column 80
              indent-tabs-mode nil
              mode-line-format (remove '(vc-mode vc-mode) mode-line-format)
              scroll-down-aggressively 0
              scroll-up-aggressively 0)

(setq tab-width 8
      disabled-command-function nil
      track-eol t
      view-read-only t)
(setq help-enable-variable-value-editing t)

(use-package whitespace
  :demand t
  :config
  (setq whitespace-action '(auto-cleanup))
  (setq whitespace-style
        '(face
          tabs trailing
          empty
          tab-mark
          missing-newline-at-eof))
  (global-whitespace-mode 1))

(use-package elec-pair
  :demand t
  :config
  (electric-pair-mode))

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
  :custom
  (aw-keys '(?u ?h ?e ?t ?o ?n ?a ?s ?i ?d))
  (aw-dispatch-when-more-than 2)
  (aw-dispatch-always nil)
  (aw-leading-char-style 'path)
  (aw-char-position 'top-left)
  (aw-scope 'frame))

;; (require 'ace-link)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auth/gpg/pass

(use-package epg
  :custom
  (epg-pinentry-mode 'loopback))

(use-package pinentry
  :demand t
  :after epg
  :config
  (setq epg-pinentry-mode 'loopback)
  (pinentry-start))

(use-package pass)

(use-package password-store
  :custom
  (password-store-time-before-clipboard-restore 5))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; spelling

(use-package flyspell-correct
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
  :hook
  ((git-commit-mode-hook . (lambda () (flyspell-mode 1)))
   (org-mode-hook  . (lambda () (flyspell-mode 1))))
  :config
  (setq flyspell-mark-duplications-flag nil))

(use-package verbiste
  :commands (verbiste-deconjugate verbiste-conjugate)
  :config
  (general-evil-define-key '(normal) verbiste-mode-keymap
    "q"    #'kill-this-buffer))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; projectile

(use-package projectile
  :demand t
  :config
  (setq projectile-project-search-path '(( "/code" . 0) ( "/work" . 0) ("/data" . 0)
                                         ( "/code/maxi-passat" . 0)))
  (setq projectile-sort-order 'recently-active)
  (setq projectile-enable-caching t)
  (projectile-global-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; magit

(use-package magit
  :custom
  (magit-status-initial-section '(((unstaged) (status))))
  :hook
  (magit-refresh-buffer-hook . magit-status-goto-initial-section)

  :config
  (general-evil-define-key '(normal) magit-diff-mode-map
    "("      #'diff-hunk-prev
    ")"      #'diff-hunk-next
    "C-k"    #'diff-hunk-prev
    "C-j"    #'diff-hunk-next)

  (general-evil-define-key '(normal) magit-mode-map
    "("      #'magit-section-backward-sibling
    ")"      #'magit-section-forward-sibling
    "C-k"    #'magit-section-backward-sibling
    "C-j"    #'magit-section-forward-sibling)

  (general-evil-define-key '(normal) git-rebase-mode-map
    "K"    #'git-rebase-move-line-up
    "J"    #'git-rebase-move-line-down)

  (general-evil-define-key '(normal) diff-hl-mode-map
    "grk" #'smerge-prev
    "grj" #'smerge-next
    "C-k" #'smerge-prev
    "C-j" #'smerge-next
    "("   #'smerge-prev
    ")"   #'smerge-next
    "Ku"  #'smerge-keep-upper
    "Kl"  #'smerge-keep-lower))

(use-package magit-todos
  :after magit
  :config
  (setq magit-todos-ignore-case t)
  (setq magit-todos-max-items 1000)
  (setq magit-todos-auto-group-items 'always)
  (advice-add #'magit-todos--insert-todos
              :before-until #'check-if-todo-blacklisted)
  (advice-add #'magit-todos--add-to-status-buffer-kill-hook
              :before-until #'check-if-todo-blacklisted)
  (magit-todos-mode)
  (defun check-if-todo-blacklisted ()
    (let ((root (magit-with-toplevel default-directory)))
      (or (string= (substring root 0 5) "/ssh:")
          (string= root "/data/org/")
          (string= root "/work/guix/guix")
          (string= root "/code/guix/guix")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell

(use-package comint
  :demand t
  :custom
  (comint-scroll-to-bottom-on-input t)
  (comint-scroll-to-bottom-on-output t)
  (comint-prompt-read-only t)
  :config
  ;; FIXME: fuck me: comint-watch-for-password-prompt - try w/o on emacs 30.
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

  (general-evil-define-key '(normal visual) comint-mode-map
    "|"           #'my/insert-shell-line
    "ï"           #'my/cd-up
    "-"           #'my/cd--
    "("           #'comint-previous-prompt
    ")"           #'comint-next-prompt
    "gm"          #'man-follow
    "gS"          #'my/toggle-scroll-to-bottom-on-output
    "C-k"         #'comint-previous-prompt
    "C-j"         #'comint-next-prompt
    "C-r"         #'consult-history
    "RET"         #'comint-send-input
    "C-<return>"  #'comint-copy-old-input
    "A"           (lambda() (interactive) (evil-goto-line) (evil-append-line 1)))

  (general-evil-define-key '(insert) comint-mode-map
    "C-k"         #'comint-previous-prompt
    "C-j"         #'comint-next-prompt
    "C-r"         #'consult-history
    "C-<return>"  #'comint-copy-old-input
    "RET"         #'comint-send-input)

  (evil-collection-define-key 'insert 'comint-mode-map
    (kbd "C-s") #'my/insert-shell-line
    (kbd "C-r") #'consult-history
    (kbd "C-p") #'comint-previous-input
    (kbd "C-n") #'comint-next-input))

(use-package coterm
  :after comint
  :demand t
  :config
  (coterm-mode)
  (defun my/toggle-scroll-to-bottom-on-output ()
    (interactive)
    (setq-local comint-scroll-to-bottom-on-output
	        (not comint-scroll-to-bottom-on-output))))

(use-package shell
  :after coterm
  :demand t
  :custom
  (shell-prompt-pattern "^[🍏🍎].*\nλ ")
  ;; for tramp shell sessions:
  (explicit-shell-file-name "bash")
  :config
  (general-evil-define-key '(insert normal) shell-mode-map
    "C-S-<return>" #'detached-shell-send-input))

(use-package bash-completion
  :after shell
  :demand t
  :config
  (bash-completion-setup))

(use-package detached
  :demand t
  :init
  (detached-init)
  :custom ((detached-show-output-on-attach t)
           (detached-terminal-data-command system-type)
           (detached-list-config
            `((:name "Host" :function detached--host-str :length 15 :face detached-host-face)
              (:name "Command" :function detached-list--command-str :length 75)
              (:name "Status" :function detached-list--status-str :length 7)
              ( :name "Directory" :function detached--working-dir-str
                :length 30 :face detached-working-dir-face)
              ( :name "Duration" :function detached--duration-str
                :length 10 :face detached-duration-face)
              ( :name "Created" :function detached--creation-str
                :length 20 :face detached-creation-face)
              ( :name "Metadata" :function detached--metadata-str
                :length 20 :face detached-metadata-face))))
  :config
  (general-evil-define-key '(normal) detached-list-mode-map
    "a" #'detached-edit-session-annotation
    "d" #'detached-list-delete-session
    "e" #'detached-edit-and-run-session
    "f" #'detached-list-select-filter
    "g" #'detached-list-revert
    "I" #'detached-list-initialize-session-directory
    ;; "i" #'imenu
    "K" #'detached-list-kill-session
    "m" #'detached-list-mark-session
    ;; Narrow
    "na" #'detached-list-narrow-annotation
    "nc" #'detached-list-narrow-command
    "nd" #'detached-list-narrow-session-directory
    ;; Host
    "nhh" #'detached-list-narrow-host
    "nhc" #'detached-list-narrow-currenthost
    "nhl" #'detached-list-narrow-localhost
    "nhr" #'detached-list-narrow-remotehost
    "no" #'detached-list-narrow-output
    "nO" #'detached-list-narrow-origin
    ;; State
    "nsa" #'detached-list-narrow-active
    "nsf" #'detached-list-narrow-failure
    "nsi" #'detached-list-narrow-inactive
    "nss" #'detached-list-narrow-success
    "nu" #'detached-list-narrow-unique
    "nw" #'detached-list-narrow-working-directory
    "n+" #'detached-list-narrow-after-time
    "n-" #'detached-list-narrow-before-time
    "q" #'detached-list-quit
    "r" #'detached-rerun-session
    "t" #'detached-list-toggle-mark-session
    "T" #'detached-list-toggle-sessions
    "u" #'detached-list-unmark-session
    "U" #'detached-list-unmark-sessions
    "v" #'detached-list-view-session
    "w" #'detached-copy-session-command
    "W" #'detached-copy-session-output
    "x" #'detached-list-detach-from-session
    "%" #'detached-list-mark-regexp
    "=" #'detached-list-diff-marked-sessions
    "-" #'detached-list-widen
    "!" #'detached-shell-command
    ;; Describe
    ". s" #'detached-describe-session
    ". d" #'detached-describe-duration
    "<backspace>" #'detached-list-remove-narrow-criterion
    "<return>" #'detached-list-open-session))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tramp

(use-package tramp
  :config
  (setq tramp-terminal-type "tramp")
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (setq tramp-ssh-controlmaster-options
	(concat
	 "-o ControlPath=/tmp/ssh-ControlPath-%%r@%%h:%%p "
	 "-o ControlMaster=auto -o ControlPersist=yes")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dired

(use-package dired
  :config
  (general-evil-define-key '(normal) dired-mode-map
    "ï"    #'dired-up-directory))

(use-package diredfl
  :hook (dired-mode-hook . #'diredfl-mode))
(use-package all-the-icons-dired
  :hook
  (dired-mode-hook . #'all-the-icons-dired-mode))
(use-package dired-toggle-sudo)
(use-package dired-rsync)
(use-package dired-open)
(use-package dired-collapse)

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
;; calc

(use-package calc
  :config
  (general-evil-define-key '(normal) calc-mode-map
    "i"    (lambda ()
             (interactive) ;; avoid having info popping up all the time.
             (message "beep boop - I'm a robot"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; info

(use-package info
  :config
  (general-evil-define-key '(normal) Info-mode-map ;; this is not working anymore :(
    "s"   #'consult-info))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; search

(use-package isearch
  :bind ( :map isearch-mode-map
          ("C-e" . #'isearch-edit-string)))

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
;; transmission

(use-package transmission
  :custom
  (transmission-host "enterprise.local")
  (transmission-refresh-modes '(transmission-mode
                                transmission-files-mode
                                transmission-info-mode
                                transmission-peers-mode))
  (transmission-refresh-interval 2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; system stuff

(use-package bluetooth
  :config
  (setq bluetooth-battery-display-warning nil))

(use-package pulseaudio-control)

(defun my/brace-for-impact ()
  (interactive)
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

;; (require 'opam-user-setup    "~/.emacs.d/opam-user-setup.el") ;; FIXME
(require 'conf/completion    "~/.emacs.d/completion.el")
(require 'conf/workspaces    "~/.emacs.d/workspaces.el")
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

(use-package quail)

(use-package robin
  :config
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
  )

(provide 'init)
