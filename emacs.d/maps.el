(require 'which-key)
(which-key-mode)

(require 'general)
(general-evil-setup t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; leader actions

(evil-leader/set-key
  ":"      #'execute-extended-command ;;  "exec stuff"
  "<SPC>"  #'consult-buffer           ;;  "buffers"
  "/"      #'consult-ripgrep          ;;  "grep"
  "'"      #'projectile-find-file     ;;  "proj buffers"
  ;; "'" #'counsel-projectile-find-file

  ;; embark
  "e" #'embark-act
  "x" #'embark-export
  ;; vertico / completion
  "." #'vertico-repeat

  ;; emacs apps
  "ab"  #'ibuffer
  "ac"  #'calc
  "ad"  #'dired
  "aD"  #'dictionary-lookup-definition
  "as"  #'shell
  "ap"  #'proced
  ;; elfeed
  "aee" #'elfeed
  "aes" #'elfeed-update
  ;; external apps
  "aat" (lambda () (interactive) (async-shell-command my/term-cmd))
  "aac" (lambda () (interactive) (async-shell-command "calibre")) ;; FIXME guix the shit out of this.
  "aap" (lambda () (interactive) (async-shell-command "pavucontrol-qt"))
  ;; browsers
  "aBf" (lambda () (interactive) (async-shell-command "firefox"))
  "aBc" (lambda () (interactive) (async-shell-command "chromium"))
  "aBt" #'my/tbb
  ;; utils
  "zz"  (lambda () (interactive) (async-shell-command my/lock-cmd))

  ;; org
  "oa" (lambda () (interactive) (org-agenda nil "z"))
  "oc" #'cfw:open-org-calendar ;; FIXME use this as date picker?
  ;; buffers
  "br" #'rename-buffer
  "bk" #'kill-this-buffer
  "bn" #'evil-buffer-new

  ;; roam
  "rD" #'org-roam-demote-entire-buffer
  "rf" #'org-roam-node-find
  "rF" #'org-roam-ref-find
  "rg" #'org-roam-graph
  "ri" #'org-roam-node-insert
  "rs" #'org-roam-db-sync
  "rI" #'org-id-get-create
  "rm" #'org-roam-buffer-toggle
  "rM" #'org-roam-buffer-display-dedicated
  "rn" #'org-roam-capture
  "rr" #'org-roam-refile
  "rR" #'org-roam-link-replace-all

  ;; roam date:
  "rdb" #'org-roam-dailies-goto-previous-note ;;  :desc "Goto previous note"
  "rdk" #'org-roam-dailies-goto-previous-note ;;  :desc "Goto previous note"
  "rdd" #'org-roam-dailies-goto-date          ;;  :desc "Goto date"
  "rdD" #'org-roam-dailies-capture-date       ;;  :desc "Capture date"
  "rdf" #'org-roam-dailies-goto-next-note     ;;  :desc "Goto next note"
  "rdj" #'org-roam-dailies-goto-next-note     ;;  :desc "Goto next note"
  "rdm" #'org-roam-dailies-goto-tomorrow      ;;  :desc "Goto tomorrow"
  "rdM" #'org-roam-dailies-capture-tomorrow   ;;  :desc "Capture tomorrow"
  "rdn" #'org-roam-dailies-capture-today      ;;  :desc "Capture today"
  "rdt" #'org-roam-dailies-goto-today         ;;  :desc "Goto today"
  "rdT" #'org-roam-dailies-capture-today      ;;  :desc "Capture today"
  "rdy" #'org-roam-dailies-goto-yesterday     ;;  :desc "Goto yesterday"
  "rdY" #'org-roam-dailies-capture-yesterday  ;;  :desc "Capture yesterday"
  "rd-" #'org-roam-dailies-find-directory     ;;  :desc "Find directory"

  ;; projectile
  "p'" #'projectile-find-file
  "p`" #'projectile-find-file-dwim
  "pp" #'projectile-switch-project
  "pP" #'persp-switch
  "pD" #'projectile-discover-projects-in-search-path
  "pK" #'projectile-kill-buffers
  "pS" #'projectile-save-project-buffers
  "ps" #'projectile-run-shell
  "pb" #'projectile-ibuffer
  "pd" #'projectile-dired
  "pm" #'persp-merge
  "pu" #'persp-unmerge

  ;; password-store
  "P"  #'password-store-copy

  ;; magit
  "g." #'magit-file-dispatch
  "gg" #'magit-status
  "gb" #'magit-blame

  ;; roam
  ;; insert stuff
  "ie" #'emojify-insert-emoji         ;;  :desc "Emoji"
  "id" #'my/insert-inactive-timestamp ;;  :desc "date (now)"
  "in" #'my/insert-inactive-timestamp ;;  :desc "date (now)"
  "is" #'consult-yasnippet
  ;; rm stuff
  "-d" #'delete-trailing-whitespace ;; :desc "trailing whitespace"

  ;; file stuff, dired, ibuffer
  "fr" #'consult-recent-file ;; :desc "file recent"

  ;;
  "ss" #'consult-line ;; :desc "filter line"

  ;; code stuff
  ;; M-x flymake-goto-next-error goes to previous error in the current buffer
  ;; M-x flymake-goto-prev-error goes to next error in the current buffer
  ;; M-. or M-x xref-find-definitions finds the definition of the symbol at point and opens it in the current window
  ;; M-, or M-x xref-pop-marker-stack jumps back
  ;; M-? or M-x xref-find-references finds the references of the symbol at point
  "cr" #'eglot-rename ;; :desc "lsp "

  ;; windows
  "wx" #'buffer-expose-current-mode
  "wX" #'buffer-expose
  "ws" #'switch-window-then-swap-buffer
  "wo" #'other-window

  ;; misc?
  "zl" #'scroll-lock-mode
  "z''" (lambda () (interactive) (async-shell-command "dunstctl set-paused toggle"))
  "z'c" (lambda () (interactive) (async-shell-command "dunstctl close"))
  "z'C" (lambda () (interactive) (async-shell-command "dunstctl close-all"))
  "z'h" (lambda () (interactive) (async-shell-command "dunstctl history")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; states

(general-define-key
 :states 'normal
 "-" nil
 ;; :desc "trailing whitespace"
 "-d" #'delete-trailing-whitespace
 "z=" #'flyspell-correct-wrapper
 "Y"  #'evil-cp-yank-enclosing
 ;; FIXME: add something on shift= so this can exist "zX" #'flyspell-correct-at-point
 "/" #'consult-line)
;; TODO: sentence & paragraph motions.

(general-define-key
 :states 'insert
 "C-e" #'emojify-insert-emoji)

(general-define-key
 :states '(normal emacs insert visual global motion)
 (kbd "C-SPC") evil-leader--default-map)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; eshell

(general-evil-define-key '(normal insert visual) eshell-mode-map
  "C-r"        (lambda ()
                 (interactive)
                 (evil-append 1)
                 (consult-history))
  "C-k"        #'eshell-previous-prompt
  "C-j"        #'eshell-next-prompt
  "C-<return>" #'eshell-copy-old-input)

(evil-collection-define-key 'normal 'eshell-mode-map
  (kbd "ï")    #'my/cd-up ;; restrict this to eshell, or generalise map?
  (kbd "-")    #'my/cd--
  (kbd "A")    (lambda ()
                 (interactive)
                 (evil-goto-line)
                 (evil-append 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell

(general-evil-define-key '(normal visual) comint-mode-map
  "ï"           #'my/cd-up
  "-"           #'my/cd--
  "("           #'comint-previous-prompt
  ")"           #'comint-next-prompt
  "gm"          #'man-follow
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
  (kbd "C-r") #'consult-history
  (kbd "C-p") #'comint-previous-input
  (kbd "C-n") #'comint-next-input)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dired

(general-evil-define-key '(normal) dired-mode-map
  "ï"    #'dired-up-directory)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; magit

(general-evil-define-key '(normal) magit-diff-mode-map
  "("    #'diff-hunk-prev
  ")"    #'diff-hunk-next
  "C-k"    #'diff-hunk-prev
  "C-j"    #'diff-hunk-next)

(general-evil-define-key '(normal) magit-mode-map
  "("    #'magit-section-backward-sibling
  ")"    #'magit-section-forward-sibling
  "C-k"    #'magit-section-backward-sibling
  "C-j"    #'magit-section-backward-sibling)

(general-evil-define-key '(normal) git-rebase-mode-map
  "K"    #'git-rebase-move-line-up
  "J"    #'git-rebase-move-line-down)

(general-evil-define-key '(normal) smerge-mode-map
  "grk" #'smerge-prev
  "grj" #'smerge-next
  "C-k" #'smerge-prev
  "C-j" #'smerge-next
  "(" #'smerge-prev
  ")" #'smerge-next
  "Ku" #'smerge-keep-upper
  "Kl" #'smerge-keep-lower)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; lisps

(general-evil-define-key '(normal visual) evil-cleverparens-mode-map
  "Y"     #'evil-cp-yank-enclosing
  "("     #'evil-backward-paragraph
  ")"     #'evil-forward-paragraph
  ")"     #'evil-cp-next-closing
  "("     #'sp-backward-up-sexp
  "é"     #'evil-cp-previous-opening ; FIXME put this in global map?
  "&"     #'evil-cp-next-opening
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
  "r"   #'paredit-raise-sexp
  "R"   #'evil-cp-raise-form
  ">"   #'sp-transpose-sexp
  "<"   (lambda() (interactive) (sp-transpose-sexp -1))
  "t"   #'sp-transpose-sexp
  "T"   (lambda() (interactive) (sp-transpose-sexp -1))
  "M-T" (lambda() (interactive) (sp-transpose-sexp -1))
  "gp"  #'evil-cp-wrap-next-round
  "gP"  #'evil-cp-wrap-previous-round
  "gc"  #'evil-cp-wrap-next-curly
  "gC"  #'evil-cp-wrap-previous-curly
  "gs"  #'evil-cp-wrap-next-square
  "gS"  #'evil-cp-wrap-previous-square
  "RET" #'eval-defun)

(general-evil-define-key '(normal) geiser-mode-map
  :prefix "RET"
  "RET" #'geiser-eval-definition)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org

(general-evil-define-key '(insert) org-mode-map
  "TAB"   #'completion-at-point
  "C-l"   #'org-demote-subtree
  ;; "C-i"   #'org-roam-node-insert
  ;; "S-TAB" #'org-shiftab
  )


(general-evil-define-key '(normal) org-mode-map
  :prefix "RET"
  "RET"   #'+org/dwim-at-point)

(general-evil-define-key '(normal) org-mode-map
  "zD"    #'org-decrypt-entries
  "zq"    (lambda() (interactive) (org-show-branches-buffer))
  "C-k"   #'org-previous-visible-heading
  "C-j"   #'org-next-visible-heading
  "("     #'org-previous-visible-heading
  ")"     #'org-next-visible-heading
  "("     #'evil-backward-paragraph
  ")"     #'evil-forward-paragraph
  "C-K"   #'org-move-subtree-up
  "C-J"   #'org-move-subtree-down
  "C-H"   #'org-promote-subtree
  "C-L"   #'org-demote-subtree
  "("     #'org-backward-element
  ")"     #'org-forward-element)

(define-key cfw:calendar-mode-map (kbd "SPC") nil)
(define-key cfw:org-schedule-map (kbd "SPC") nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; elfeed

(general-evil-define-key '(normal) elfeed-search-mode-map
  "RET" #'elfeed-search-show-entry)

(general-evil-define-key '(normal) elfeed-show-mode-map
  "J" #'elfeed-show-next
  "K" #'elfeed-show-prev
  "U" #'elfeed-show-tag--unread
  "u" #'elfeed-show-tag--read)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ement

(general-evil-define-key '(normal) ement-room-list-mode-map
  "u" #'ement-tabulated-room-list-next-unread
  "X"  #'ement-room-list-kill-buffer
  "h" #'my/ement-home
  "l" #'ement-tabulated-room-list)

(general-evil-define-key '(normal) ement-tabulated-room-list-mode-map
  "u" #'ement-tabulated-room-list-next-unread
  "X"  #'ement-room-list-kill-buffer
  "h" #'my/ement-home
  "l" #'ement-tabulated-room-list)

(general-evil-define-key '(normal) ement-room-list-mode-map
  :prefix "RET"
  "n" #'ement-tabulated-room-list-next-unread
  "RET" #'ement-room-list-RET)

(general-evil-define-key '(normal) ement-tabulated-room-list-mode-map
  :prefix "RET"
  "n" #'ement-tabulated-room-list-next-unread
  "RET" #'ement-room-list-RET)

(general-evil-define-key '(normal) ement-directory-mode-map
  :prefix "RET"
  "RET" #'ement-directory-RET)

(general-evil-define-key '(normal) ement-room-mode-map
  ;; migrate stuff down to prefix-map as these get annoying:
  ;; Movement
  "TAB" #'ement-room-goto-next
  "<backtab>" #'ement-room-goto-prev
  ;; "SPC" #'ement-room-scroll-up-mark-read
  "S-SPC" #'ement-room-scroll-down-command
  "M-SPC" #'ement-room-goto-fully-read-marker
  "m" #'ement-room-mark-read
  ;; (define-key map [remap scroll-down-command] #'ement-room-scroll-down-command)
  ;; (define-key map [remap mwheel-scroll] #'ement-room-mwheel-scroll)
  "c-p" #'ement-room-goto-prev
  "c-n" #'ement-room-goto-next
  "c-j" #'ement-room-goto-prev
  "c-k" #'ement-room-goto-next
  "(" #'ement-room-goto-prev
  ")" #'ement-room-goto-next
  "l" #'ement-tabulated-room-list
  "L" #'ement-room-list-side-window
  "h" #'my/ement-home
  ;; "y" #'my/ement-home

  ;; Switching
  ;; "g l" #'ement-tabulated-room-list
  ;; "g r" #'ement-view-room
  ;; "g m" #'ement-notify-switch-to-mentions-buffer
  ;; "g n" #'ement-notify-switch-to-notifications-buffer
  "q" #'quit-window

  ;; Messages
  ;; "RET" #'ement-room-send-message
  "S-<return>" #'ement-room-write-reply
  "M-RET" #'ement-room-compose-message
  "<insert>" #'ement-room-edit-message
  "x" #'ement-room-edit-message
  "X" #'ement-room-delete-message
  "s r" #'ement-room-send-reaction
  "s e" #'ement-room-send-emote
  "s f" #'ement-room-send-file
  "s i" #'ement-room-send-image
  "v" #'ement-room-view-event

  ;; Users
  "u RET" #'ement-send-direct-message
  "u i" #'ement-invite-user
  "u I" #'ement-ignore-user

  ;; Room
  "r o" #'ement-room-occur
  "r d" #'ement-describe-room
  "r m" #'ement-list-members
  "r t" #'ement-room-set-topic
  "r f" #'ement-room-set-message-format
  "r n" #'ement-room-set-notification-state
  "r N" #'ement-room-override-name
  "r T" #'ement-tag-room

  ;; Room membership
  "R c" #'ement-create-room
  "R j" #'ement-join-room
  "R l" #'ement-leave-room
  "R F" #'ement-forget-room
  "R n" #'ement-room-set-display-name
  "R s" #'ement-room-toggle-space

  ;; Other
  )

(general-evil-define-key '(normal) ement-room-mode-map
  :prefix "RET"
 ;; "g l" #'ement-tabulated-room-list
 ;; "g r" #'ement-view-room
  "g m" #'ement-notify-switch-to-mentions-buffer
  "g n" #'ement-notify-switch-to-notifications-buffer

  "l"   #'ement-tabulated-room-list
  "r"   #'ement-view-room
  "R"   #'ement-room-sync
  "y"   #'my/ement-home

  "RET" #'ement-room-send-message
  "c"   (lambda ()
          (interactive)
          (ement-room-compose-message ement-room ement-session)
          (ement-room-compose-org)))

;; room-list
;; (defvar ement-room-list-mode-map
;;   (let ((map (make-sparse-keymap)))
;;     #'ement-room-list-RET
;;     #'ement-room-list-next-unread
;;     #'ement-room-list-section-toggle
;;     #'ement-room-toggle-space)
;;   "Keymap for `ement-room-list' buffers.
;; See also `ement-room-list-button-map'.")

(provide 'conf/maps)
