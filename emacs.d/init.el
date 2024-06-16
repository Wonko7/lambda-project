;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; guix home gives us stuff:

(require 'conf/generated-values "~/.emacs.d/generated-values.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; basic UI stuff:

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

(setq-default word-wrap 1)
(setq truncate-partial-width-windows nil)
(setq truncate-lines t) ;; who is messing with my shit?
(setq org-startup-truncated nil) ;; org is messing with my shit
(add-hook 'org-agenda-mode-hook (lambda () ;; only disable in agenda.
                                  (setq truncate-lines t))) ;; and yet you shit in my mouth, why? t?

(require 'whitespace)
(setq whitespace-action '(auto-cleanup))
(setq whitespace-style
      '(face
        tabs trailing
        empty
        tab-mark
        missing-newline-at-eof))
(global-whitespace-mode 1)

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

(setq custom-file "~/.emacs.d/custom-cache.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auth/pass

(require 'pass)
(require 'pinentry)
(setq epg-pinentry-mode 'loopback)
(pinentry-start)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; spelling

(require 'flyspell-correct)

;; (global-spell-fu-mode 0)
;; (setenv "DICTIONARY" "en_GB-ise")
(setq ispell-program-name "hunspell")
(setq ispell-dictionary "en_GB-ise,en_US,fr-toutesvariantes")
(setq ispell-local-dictionary-alist `(("en_GB-ise,en_US,fr-toutesvariantes"
                                       "[[:alpha:]]" "[^[:alpha:]]" "[0-9']" t
                                       ("-d" "en_GB-ise,en_GB-ize,fr-toutesvariantes")
                                       nil utf-8)))

(with-eval-after-load 'flyspell
  (setq flyspell-mark-duplications-flag nil)
  (add-hook 'git-commit-mode-hook
	    (lambda () (flyspell-mode 1)))
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
(setq magit-status-initial-section '(((unstaged) (status))
                                     ((staged) (status))
                                     ((TODOs) (status))))
(add-hook 'magit-diff-mode-hook #'scroll-lock-mode)

(require 'magit-todos)
(setq magit-todos-ignore-case t)
(setq magit-todos-max-items 1000)
(setq magit-todos-auto-group-items 'always)
(magit-todos-mode)

(defun check-if-todo-blacklisted ()
  (let ((root (magit-with-toplevel default-directory)))
    (or (string= (substring root 0 5) "/ssh:")
        (string= root "/data/org/")
        (string= root "/work/guix/guix")
        (string= root "/code/guix/guix"))))

(advice-add #'magit-todos--insert-todos
            :before-until #'check-if-todo-blacklisted)
(advice-add #'magit-todos--add-to-status-buffer-kill-hook
            :before-until #'check-if-todo-blacklisted)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell

(require 'coterm)
(coterm-mode)

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

(require 'bash-completion)
(bash-completion-setup)
(add-hook 'shell-dynamic-complete-functions 'bash-completion-dynamic-complete)

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

(require 'tramp)
(setq tramp-terminal-type "tramp")

(add-to-list 'tramp-remote-path 'tramp-own-remote-path)

(setq tramp-ssh-controlmaster-options
 (concat
   "-o ControlPath=/tmp/ssh-ControlPath-%%r@%%h:%%p "
   "-o ControlMaster=auto -o ControlPersist=yes"))

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

(add-hook 'dired-mode-hook #'all-the-icons-dired-mode)
(add-hook 'dired-mode-hook #'diredfl-mode)
;; Auto-refresh dired on file change
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

(require 'osm)

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

(require 'rg)
(require 'wgrep)

(autoload 'wgrep-rg-setup "wgrep-rg")
(add-hook 'rg-mode-hook #'wgrep-rg-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mentor

(setq mentor-rtorrent-download-directory "/mnt/trantor/media")
(setq mentor-rtorrent-external-rpc "~/.pirate-radio.socket")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; midnight

;; (require 'midnight)
;; (setq clean-buffer-list-delay-general 3) ;; days

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; system stuff

(require 'bluetooth)

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
(require 'conf/misc          "~/.emacs.d/misc.el")
(require 'conf/completion    "~/.emacs.d/completion.el")
(require 'conf/org           "~/.emacs.d/org-conf.el")
(require 'conf/lisp          "~/.emacs.d/lisp-dev.el")
(require 'conf/dev           "~/.emacs.d/dev.el")
(require 'conf/doom          "~/.emacs.d/doom.el")
(require 'conf/communication "~/.emacs.d/communication.el")
(require 'conf/keys          "~/.emacs.d/keys.el")

;; FIXME: powerline errors, could that break exwm init?
;; (require 'conf/elfeed "~/.emacs.d/elfeed.el")

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
(diminish 'evil-owl-mode)

(provide 'init)
