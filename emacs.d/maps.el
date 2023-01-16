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
  "'"      #'projectile-find-file          ;;  "proj buffers"
  ;; "'" #'counsel-projectile-find-file

  ;; embark
  "e" #'embark-act
  "x" #'embark-export

  ;; apps
  "ab"  #'ibuffer
  "ad"  #'dired
  "as"  #'shell
  "ap"  #'proced
  "aee" #'elfeed
  "aes" #'elfeed-update
  ;; browsers
  "aBf" (lambda () (interactive) (async-shell-command "firefox"))
  "aBc" (lambda () (interactive) (async-shell-command "chromium"))
  "aBt" #'my/tbb
  ;; secondary apps
  "zz"  #'desktop-environment-lock-screen

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
  "rdb" #'org-roam-dailies-goto-previous-note    ;;  :desc "Goto previous note"
  "rdk" #'org-roam-dailies-goto-previous-note    ;;  :desc "Goto previous note"
  "rdd" #'org-roam-dailies-goto-date             ;;  :desc "Goto date"
  "rdD" #'org-roam-dailies-capture-date          ;;  :desc "Capture date"
  "rdf" #'org-roam-dailies-goto-next-note        ;;  :desc "Goto next note"
  "rdj" #'org-roam-dailies-goto-next-note        ;;  :desc "Goto next note"
  "rdm" #'org-roam-dailies-goto-tomorrow         ;;  :desc "Goto tomorrow"
  "rdM" #'org-roam-dailies-capture-tomorrow      ;;  :desc "Capture tomorrow"
  "rdn" #'org-roam-dailies-capture-today         ;;  :desc "Capture today"
  "rdt" #'org-roam-dailies-goto-today            ;;  :desc "Goto today"
  "rdT" #'org-roam-dailies-capture-today         ;;  :desc "Capture today"
  "rdy" #'org-roam-dailies-goto-yesterday        ;;  :desc "Goto yesterday"
  "rdY" #'org-roam-dailies-capture-yesterday     ;;  :desc "Capture yesterday"
  "rd-" #'org-roam-dailies-find-directory        ;;  :desc "Find directory"

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
  ;; roam
  ;; insert stuff
  "ie" #'emojify-insert-emoji                ;;  :desc "Emoji"
  "id" #'my/insert-inactive-timestamp        ;;  :desc "date (now)"
  "in" #'my/insert-inactive-timestamp        ;;  :desc "date (now)"
  ;; rm stuff
  "-d" #'delete-trailing-whitespace  ;; :desc "trailing whitespace"

  ;; file stuff, dired, ibuffer
  "fr" #'consult-recent-file ;; :desc "file recent"

  ;;
  "ss" #'consult-line  ;; :desc "filter line"

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

  ;; misc?
  "zl" #'scroll-lock-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; states

(general-define-key
 :states 'normal
 "-" nil
 ;; :desc "trailing whitespace"
 "-d" #'delete-trailing-whitespace
 "z=" #'flyspell-correct-wrapper)
;; TODO: sentence & paragraph motions.

(general-define-key
 :states '(normal emacs insert visual global motion)
 (kbd "C-SPC") evil-leader--default-map)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell

(general-evil-define-key '(normal input visual) comint-mode-map
  "ï"    #'my/cd-up ;; restrict this to eshell, or generalise solution?
  "-"    #'my/cd--
  "C-r"  #'consult-history
  "RET"  #'comint-send-input
  "A"    (lambda() (interactive) (evil-goto-line) (evil-append-line 1)))

(evil-collection-define-key 'insert 'comint-mode-map
  (kbd "C-r") #'consult-history
  (kbd "C-p") #'comint-previous-input
  (kbd "C-n") #'comint-next-input)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dired

(general-evil-define-key '(normal) dired-mode-map
  "ï"    #'dired-up-directory)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; lisps

(general-evil-define-key '(normal visual) evil-cleverparens-mode-map
  "{"     #'evil-backward-paragraph
  "}"     #'evil-forward-paragraph
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
  ;; "C-i"   #'org-roam-node-insert
  ;; "S-TAB" #'org-shiftab
  )


(general-evil-define-key '(normal) org-mode-map
  :prefix "RET"
  "RET"   #'+org/dwim-at-point)

(general-evil-define-key '(normal) org-mode-map
  "zD"    #'org-decrypt-entries
  "zq"    (lambda() (interactive) (org-show-branches-buffer))
  "("     #'org-previous-visible-heading
  ")"     #'org-next-visible-heading
  "{"     #'evil-backward-paragraph
  "}"     #'evil-forward-paragraph
  "C-k"   #'org-move-subtree-up
  "C-j"   #'org-move-subtree-down
  "C-h"   #'org-promote-subtree
  "C-l"   #'org-demote-subtree)

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

(general-evil-define-key '(normal) ement-room-mode-map
  "K" #'ement-room-goto-prev
  "J" #'ement-room-goto-next)

(general-evil-define-key '(normal) ement-room-mode-map
  :prefix "RET"
  "d"   #'ement-room-delete-message
  "l"   #'ement-room-list
  "r"   #'ement-view-room
  "RET" #'ement-room-send-message
  "c"   (lambda ()
          (interactive)
          (ement-room-compose-message ement-room ement-session)
          (ement-room-compose-org)))

(provide 'conf/maps)
