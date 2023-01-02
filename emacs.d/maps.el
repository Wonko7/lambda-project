(require 'which-key)
(which-key-mode)

(require 'general)
(general-evil-setup t)

(evil-leader/set-key
   ":"   'execute-extended-command ;;  "exec stuff"
   "<SPC>"  'consult-buffer        ;;  "buffers"
   "/"         'consult-ripgrep    ;;  "grep"
   "'" 'projectile-find-file       ;;  "proj buffers"
  ;; "'" 'counsel-projectile-find-file

  ;; embark
  "e" 'embark-act
  "x" 'embark-export

  ;; apps
  "ab" 'ibuffer
  "ad" 'dired
  "as" 'shell
  "ap" 'proced
  "aee" 'elfeed
  "aes" 'elfeed-update
  ;; secondary apps
  "zz" 'desktop-environment-lock-screen

  ;; org
  "oa" (lambda () (interactive) (org-agenda nil "z"))
  "oc" 'cfw:open-org-calendar ;; FIXME use this as date picker?
  ;; buffers
  "br" 'rename-buffer
  "bk" 'kill-this-buffer
  "bn" 'evil-buffer-new

  ;; roam
  "rD" 'org-roam-demote-entire-buffer
  "rf" 'org-roam-node-find
  "rF" 'org-roam-ref-find
  "rg" 'org-roam-graph
  "ri" 'org-roam-node-insert
  "rs" 'org-roam-db-sync
  "rI" 'org-id-get-create
  "rm" 'org-roam-buffer-toggle
  "rM" 'org-roam-buffer-display-dedicated
  "rn" 'org-roam-capture
  "rr" 'org-roam-refile
  "rR" 'org-roam-link-replace-all

  ;; roam date:
   "rdb" 'org-roam-dailies-goto-previous-note    ;;  :desc "Goto previous note"
   "rdk" 'org-roam-dailies-goto-previous-note    ;;  :desc "Goto previous note"
   "rdd" 'org-roam-dailies-goto-date             ;;  :desc "Goto date"
   "rdD" 'org-roam-dailies-capture-date          ;;  :desc "Capture date"
   "rdf" 'org-roam-dailies-goto-next-note        ;;  :desc "Goto next note"
   "rdj" 'org-roam-dailies-goto-next-note        ;;  :desc "Goto next note"
   "rdm" 'org-roam-dailies-goto-tomorrow         ;;  :desc "Goto tomorrow"
   "rdM" 'org-roam-dailies-capture-tomorrow      ;;  :desc "Capture tomorrow"
   "rdn" 'org-roam-dailies-capture-today         ;;  :desc "Capture today"
   "rdt" 'org-roam-dailies-goto-today            ;;  :desc "Goto today"
   "rdT" 'org-roam-dailies-capture-today         ;;  :desc "Capture today"
   "rdy" 'org-roam-dailies-goto-yesterday        ;;  :desc "Goto yesterday"
   "rdY" 'org-roam-dailies-capture-yesterday     ;;  :desc "Capture yesterday"
   "rd-" 'org-roam-dailies-find-directory        ;;  :desc "Find directory"

  ;; projectile
  "p'" 'projectile-find-file
  "p`" 'projectile-find-file-dwim
  "pp" 'projectile-switch-project
  "pP" 'persp-switch
  "pD" 'projectile-discover-projects-in-search-path
  "pK" 'projectile-kill-buffers
  "pS" 'projectile-save-project-buffers
  "ps" 'projectile-run-shell
  "pb" 'projectile-ibuffer
  "pd" 'projectile-dired
  "pm" 'persp-merge
  "pu" 'persp-unmerge

  ;; magit
  "g." 'magit-file-dispatch
  "gg" 'magit-status
  "gj" '(git-gutter:next-hunk :properties (:repeat t :jump t))
  "gk" '(git-gutter:previous-hunk :repeat t :jump t)
  ;; roam
  ;; insert stuff
  "ie" 'emojify-insert-emoji                ;;  :desc "Emoji"
  "id" 'my/insert-inactive-timestamp        ;;  :desc "date (now)"
  "in" 'my/insert-inactive-timestamp        ;;  :desc "date (now)"
  ;; rm stuff
  "-d" 'delete-trailing-whitespace  ;; :desc "trailing whitespace"

  ;; file stuff, dired, ibuffer
  "fr" 'consult-recent-file ;; :desc "file recent"

  ;;
  "ss" 'consult-line  ;; :desc "filter line"

  ;; code stuff
  ;; M-x flymake-goto-next-error goes to previous error in the current buffer
  ;; M-x flymake-goto-prev-error goes to next error in the current buffer
  ;; M-. or M-x xref-find-definitions finds the definition of the symbol at point and opens it in the current window
  ;; M-, or M-x xref-pop-marker-stack jumps back
  ;; M-? or M-x xref-find-references finds the references of the symbol at point
  "cr" 'eglot-rename ;; :desc "lsp "
  )

;; (general-evil-define-key '(normal) normal-mode-map
;;    ;; rm stuff
;;   :desc "trailing whitespace"  "-d" 'delete-trailing-whitespace
;;   )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell

(general-evil-define-key '(normal input visual) comint-mode-map
 ;; NOTE: keymaps specified with :keymaps must be quoted
  "^"    'my/cd-up
  "-"    'my/cd--
  "C-r"  'consult-history
  "RET" 'comint-send-input
  "A" (lambda() (interactive) (evil-goto-line) (evil-append-line 1)))

(evil-collection-define-key 'insert 'comint-mode-map
    (kbd "C-r") #'consult-history
    (kbd "C-p") #'comint-previous-input
    (kbd "C-n") #'comint-next-input)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; lisps

(general-evil-define-key '(normal visual) evil-cleverparens-mode-map
  "{" #'evil-backward-paragraph
  "}" #'evil-forward-paragraph
  ")" #'evil-cp-next-closing
  "(" #'sp-backward-up-sexp
  "é" #'evil-cp-previous-opening ; FIXME put this in global map?
  "&" #'evil-cp-next-opening
  "M-r" #'paredit-raise-sexp
  "M-t"  #'sp-transpose-sexp
  "M-T"  (lambda() (interactive) (sp-transpose-sexp -1))
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
  "gp" #'evil-cp-wrap-next-round
  "gP" #'evil-cp-wrap-previous-round
  "gc" #'evil-cp-wrap-next-curly
  "gC" #'evil-cp-wrap-previous-curly
  "gs" #'evil-cp-wrap-next-square
  "gS" #'evil-cp-wrap-previous-square
  "RET" #'eval-defun)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org

(general-evil-define-key '(insert) evil-org-mode-map
  "TAB"   'org-cycle
  "C-i"   'org-roam-node-insert
  "S-TAB" 'org-shiftab)

(general-evil-define-key '(normal) org-mode-map
  :prefix "RET"
  "RET"             '+org/dwim-at-point)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; elfeed

(general-evil-define-key '(normal) elfeed-search-mode-map
  "RET" #'elfeed-search-show-entry)

(provide 'conf/maps)
