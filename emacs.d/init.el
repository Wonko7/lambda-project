;;; init.el -*- lexical-binding: t; -*-


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; guix home gives us stuff:

(require 'conf/generated-values "~/.emacs.d/generated-values.el")
(require 'conf/values "~/.emacs.d/values.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; use-package:

(setq use-package-hook-name-suffix nil)
(setq use-package-always-defer t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; basic UI stuff:

(require 'conf/fancy "~/.emacs.d/fancy.el")
(require 'conf/evil  "~/.emacs.d/evil.el")
(require 'conf/misc  "~/.emacs.d/misc.el") ;; stuff depends on this
(require 'conf/keys  "~/.emacs.d/keys.el") ;; if init fails, at least bindings work

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; emacs general config:

(require 'savehist)
(savehist-mode)

(save-place-mode)
(setq history-length 10000)

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
              scroll-down-aggressively 0
              scroll-up-aggressively 0)

(setq tab-width 8
      disabled-command-function nil
      track-eol t
      view-read-only t)

(setq help-enable-variable-value-editing t)

(use-package whitespace
  :demand t
  :custom
  (whitespace-action '(auto-cleanup))
  (whitespace-style '(face
                      tabs trailing
                      empty
                      tab-mark
                      missing-newline-at-eof))
  :config
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
(add-hook 'org-agenda-mode-hook                (lambda () (display-line-numbers-mode 0)))
(add-hook 'shell-mode-hook                     (lambda () (display-line-numbers-mode 0)))
(add-hook 'eshell-mode-hook                    (lambda () (display-line-numbers-mode 0)))
(add-hook 'elfeed-show-mode-hook               (lambda () (display-line-numbers-mode 0)))
(add-hook 'elfeed-search-update-hook           (lambda () (display-line-numbers-mode 0)))
(add-hook 'ement-room-mode-hook                (lambda () (display-line-numbers-mode 0)))
(add-hook 'ement-room-list-mode-hook           (lambda () (display-line-numbers-mode 0)))
(add-hook 'ement-tabulated-room-list-mode-hook (lambda () (display-line-numbers-mode 0)))
(add-hook 'gnus-summary-mode-hook              (lambda () (display-line-numbers-mode 0)))
(add-hook 'gnus-group-mode-hook                (lambda () (display-line-numbers-mode 0)))

(column-number-mode)

(setq custom-file "~/.run/emacs/custom-cache.el")
(if (file-readable-p custom-file)
    (load custom-file))

(setq warning-suppress-types '((undo discard-info)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; async-shell-command

(setq async-shell-command-buffer 'new-buffer)

(add-to-list 'display-buffer-alist
             '("*Async Shell Command*" display-buffer-no-window (nil)))

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
  :custom
  (epg-pinentry-mode 'loopback)
  :config
  (pinentry-start))

(use-package pass)

(use-package password-store
  :custom
  (password-store-time-before-clipboard-restore 5))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; spelling

(use-package jinx
  :demand t
  :hook (emacs-startup-hook . global-jinx-mode)
  :custom
  (jinx-languages "en_GB-ise fr-toutesvariantes")
  :config
  (general-define-key
   :states 'normal
   "zsl"   #'jinx-languages
   "zsn"   #'jinx-next
   "zsp"   #'jinx-previous
   "zsj"   #'jinx-next
   "zsk"   #'jinx-previous
   "z="    #'jinx-correct)
  (set-face-attribute 'jinx-misspelled nil :underline '(:style dashes :color "green")))

(use-package verbiste
  :commands (verbiste-deconjugate verbiste-conjugate)
  :config
  (general-evil-define-key '(normal) verbiste-mode-keymap
    "q"    #'kill-current-buffer))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; projectile

(use-package projectile
  :demand t
  :custom
  (projectile-project-search-path '(("/code" . 1) ("/work" . 1) ("/data" . 1)
                                    ("/junkyard" . 0)
                                    ("/code/maxipassat" . 1)))
  (projectile-sort-order 'recently-active)
  (projectile-enable-caching t)
  (projectile-per-project-compilation-buffer t)
  :config
  (defun my/recompile ()
    (interactive)
    (let ((compilation-read-command nil))
      (projectile-compile-project nil)))
  (projectile-global-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; magit

(use-package magit
  ;; also emacs.d/transient/*
  :custom
  (magit-status-initial-section '(((unstaged) (status))))
  (magit-log-margin '(t age magit-log-margin-width t 18))
  (magit-format-file-function #'magit-format-file-nerd-icons)
  (magit-diff-refine-hunk 'all)
  (magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1)

  :hook
  (magit-refresh-buffer-hook . magit-status-goto-initial-section)

  :config
  ;; as per https://github.com/magit/magit/issues/5220
  (setq magit-tramp-pipe-stty-settings 'pty) ;; ends up nil if in :custom

  (general-evil-define-key '(normal) magit-log-mode-map
    "J"    #'magit-diff-show-or-scroll-up
    "K"    #'magit-diff-show-or-scroll-down)

  (general-evil-define-key '(normal) magit-diff-mode-map
    "("      #'diff-hunk-prev
    ")"      #'diff-hunk-next
    "C-k"    #'diff-hunk-prev
    "C-j"    #'diff-hunk-next)

  (general-evil-define-key '(normal) magit-mode-map
    "("      #'magit-section-backward
    ")"      #'magit-section-forward
    "à"      #'magit-section-up
    "C-k"    #'magit-section-backward-sibling
    "C-j"    #'magit-section-forward-sibling)

  (general-evil-define-key '(normal) git-rebase-mode-map
    "K"    #'git-rebase-move-line-up
    "J"    #'git-rebase-move-line-down)

  (general-evil-define-key '(normal) magit-hunk-section-smerge-map
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
  :demand t
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
          (string= root "/data/")
          (string= root "/junkyard/")
          (string= root "/work/guix/guix")
          (string= root "/code/guix")))))

(use-package git-timemachine
  :hook
  (git-timemachine-mode-hook . font-lock-mode) ;; see doom's modules/emacs/vc/config.el
  :config
  (general-evil-define-key '(normal visual) git-timemachine-mode-map
    "C-b" #'git-timemachine-blame
    "C-k" #'git-timemachine-show-previous-revision
    "C-j" #'git-timemachine-show-next-revision))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell

(use-package comint
  :demand t

  :custom
  (comint-scroll-to-bottom-on-input t)
  (comint-scroll-to-bottom-on-output t)
  (comint-prompt-read-only t)

  :config
  (general-evil-define-key '(normal visual) comint-mode-map
    "|"           #'my/insert-shell-line
    "ï"           #'my/cd-up
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
  :custom
  (comint-input-autoexpand t)
  :config
  (coterm-mode)
  (defun my/toggle-scroll-to-bottom-on-output ()
    (interactive)
    (setq-local comint-scroll-to-bottom-on-output
                (not comint-scroll-to-bottom-on-output))))

(use-package shell
  :after coterm
  :demand t
  :hook (shell-mode-hook
         . (lambda ()
             (face-remap-set-base 'comint-highlight-prompt :inherit nil)))
  :custom
  (shell-prompt-pattern "^\\([^#$%>\n]*[#$%>] *\\|.*[\n]🪄 \\)")
  ;; for tramp shell sessions:
  (explicit-shell-file-name "bash")
  (shell-has-auto-cd t)

  :config
  (defun my/comint-kill-previous-output ()
    "kill output from previous prompt to current prompt.
    If not on prompt, copies current output."
    (interactive)
    (save-excursion
      (let ((beg (progn (comint-previous-prompt 1)
                        (forward-line 1)
                        (point-marker)))
            (end (progn (comint-next-prompt 1) ;; return to prompt
                        (forward-line -2) ;; my prompt is on two lines
                        (end-of-line)
		        (point-marker))))
        (copy-region-as-kill beg end)))
    (message "killed output"))

  (defun my/no-nl-comint-send-input ()
    (interactive)
    (comint-send-input t))

  (general-evil-define-key '(normal) shell-mode-map
    "zy"  #'my/comint-kill-previous-output)

  (general-evil-define-key '(insert normal) shell-mode-map
    "C-y" #'my/comint-kill-previous-output)

  (general-evil-define-key '(insert normal) shell-mode-map
    "<return>"     #'my/no-nl-comint-send-input
    "C-S-<return>" #'detached-shell-send-input)

  (general-evil-define-key '(normal) shell-mode-map
    "à" #'my/cd-up))

(use-package bash-completion
  :after shell
  :demand t
  :custom
  (bash-completion-use-separate-processes t) ;; Fixes erratic completion / broken prompt
  :config
  ;; https://github.com/szermatt/emacs-bash-completion/issues/75 on broken alias completion.
  ;; REVIEW: check if complete_alias in homes.scm bash config is still needed.
  (bash-completion-setup))

(use-package detached
  :demand t
  :init
  (detached-init)
  :custom
  (detached-show-output-on-attach t)
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
       :length 20 :face detached-metadata-face)))
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
  :custom
  (tramp-default-method "rsync")
  (tramp-terminal-type "tramp")
  ;; https://coredumped.dev/2025/06/18/making-tramp-go-brrrr./
  ;; TODO: try this https://github.com/jsadusk/tramp-hlo
  (remote-file-name-inhibit-locks t)
  (tramp-use-scp-direct-remote-copying t)
  (remote-file-name-inhibit-auto-save-visited t)
  (tramp-copy-size-limit (* 1024 1024)) ;; 1MB ;; test and move this around
  (tramp-verbose 2)

  :config
  ;; https://coredumped.dev/2025/06/18/making-tramp-go-brrrr./
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (setq tramp-ssh-controlmaster-options ;; ends up nil if in :custom
        (concat "-o ControlPath=/tmp/ssh-ControlPath-%%r@%%h:%%p "
                "-o ControlMaster=auto -o ControlPersist=yes"))

  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))

  (connection-local-set-profiles
   '(:application tramp :protocol "rsync")
   'remote-direct-async-process)
  ;; when this fails: (setq connection-local-criteria-alist nil)

  (with-eval-after-load 'compile
    (remove-hook 'compilation-mode-hook #'tramp-compile-disable-ssh-controlmaster-options)))

;; 1/ needs tramp 2.8
;; 2/ could not find proper ls command
;; (use-package tramp-hlo
;;   :demand t
;;   :after tramp
;;   :config
;;   (tramp-hlo-setup))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dired

(use-package dired
  :hook (dired-mode-hook . auto-revert-mode)
  :custom
  (dired-dwim-target t)
  (wdired-allow-to-change-permissions t)
  :config
  (general-evil-define-key '(normal) dired-mode-map
    "à" #'dired-up-directory))

(use-package diredfl
  :hook (dired-mode-hook . diredfl-mode))
(use-package dired-toggle-sudo)
(use-package dired-rsync)
(use-package dired-open)
(use-package dired-collapse)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ibuffer

(use-package ibuffer
  :demand t
  :hook (ibuffer-mode-hook
         . (lambda ()
             (ibuffer-switch-to-saved-filter-groups "default")))
  :custom
  (ibuffer-save-with-custom nil)
  (ibuffer-saved-filter-groups
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
      ("scratch"  (name . "^\\*scratch\\*$"))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; apps

(use-package osm)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; calc

(use-package calc
  :config
  (general-evil-define-key '(normal) calc-mode-map
    "-"    #'calc-minus ;; FIXME why do I need to set this?
    "i"    (lambda ()
             (interactive) ;; avoid having info popping up all the time.
             (message "I'm sorry, Dave. I'm afraid I can't do that."))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; info

(use-package info
  :config
  (general-evil-define-key '(normal) Info-mode-map ;; this is not working anymore :(
    "s"   #'consult-info))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; firefox

(use-package exwm-firefox-evil
  :defer t
  :hook
  (exwm-manage-finish-hook . exwm-firefox-evil-activate-if-firefox))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; transmission

(use-package transmission
  :custom
  (transmission-host "of-course-i-still-love-you.local")
  (transmission-refresh-modes '(transmission-mode
                                transmission-files-mode
                                transmission-info-mode
                                transmission-peers-mode))
  (transmission-refresh-interval 2)

  :config
  (general-evil-define-key '(normal) transmission-mode-map
    "a" #'my/transmission-add)

  (defun my/transmission-add ()
    "add current-kill as a magnet link, do not try to interpret it as a file"
    (interactive)
    (let ((torrent (transmission-ffap-string (current-kill 0))))
      (transmission-request-async
       (lambda (response)
         (let-alist response
           (or (and .torrent-added.name
                    (message "Added %s" .torrent-added.name))
               (and .torrent-duplicate.name
                    (message "Already added %s" .torrent-duplicate.name)))))
       "torrent-add"
       (append `(:filename ,(if (transmission-btih-p torrent)
                                (concat "magnet:?xt=urn:btih:" torrent)
                              torrent)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; system stuff

(use-package bluetooth
  :config
  (setq bluetooth-battery-display-warning nil))

(use-package pulseaudio-control) ;; FIXME not using this yet

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

;; system wake up hook:
(setq my/wake-up-counter 0)
(setq system/wake-up-hook (list
                           (lambda ()
                             (setq my/wake-up-counter (+ 1 my/wake-up-counter))
                             (message "WAKE UP GRAB A BRUSH AND PUT A LITTLE MAKE UP #%i"
                                      my/wake-up-counter))))

(file-notify-add-watch
 my/wake-up-notification-file '(change) ;; see system.scm elogind config
 (lambda (_ev)
   (run-hooks 'system/wake-up-hook)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; text stuff

(use-package olivetti
  :custom
  (olivetti-minimum-body-width 88))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sub config

;; (require 'opam-user-setup    "~/.emacs.d/opam-user-setup.el") ;; FIXME
(require 'conf/completion      "~/.emacs.d/completion.el")
(require 'conf/workspaces      "~/.emacs.d/workspaces.el")
(require 'conf/org             "~/.emacs.d/org-conf.el")
(require 'conf/lisp            "~/.emacs.d/lisp-dev.el")
(require 'conf/dev             "~/.emacs.d/dev.el")
(require 'conf/doom            "~/.emacs.d/doom.el")
(require 'conf/comms           "~/.emacs.d/comms.el")
(require 'conf/fancy-but-later "~/.emacs.d/fancy-but-later.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; input method

(use-package quail
  :demand t)

(use-package robin
  :demand t
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
                         "🖊️"
                         "minimal doc str")

  (setq default-input-method "minimal-im")
  (set-input-method "minimal-im")

  (defun hook-set-inp-meth! ()
    (activate-input-method default-input-method))

  (add-hook 'after-change-major-mode-hook #'hook-set-inp-meth!)
  (add-hook 'minibuffer-setup-hook #'hook-set-inp-meth!)

  ;; evil
  (evil-put-property 'evil-state-properties 'normal :input-method t)
  (evil-put-property 'evil-state-properties 'motion :input-method t)
  (evil-put-property 'evil-state-properties 'replace :input-method t)
  (evil-put-property 'evil-state-properties 'operator :input-method t)
  (evil-put-property 'evil-state-properties 'visual :input-method t)
  (evil-set-initial-state 'exwm-mode 'emacs)

  ;; shell: input method only works in line mode:
  (defun my-enable-term-line-mode (&rest ignored)
    (term-line-mode))
  (advice-add 'ansi-term :after #'my-enable-term-line-mode)
  (advice-add 'term :after #'my-enable-term-line-mode))

(provide 'init)
