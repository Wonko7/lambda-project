(require 'which-key)
(which-key-mode)

;(evil-set-leader nil (kbd "<space>"))
;(evil-set-leader nil nil (kbd "<ret>"))
;;<space>-: execute-extended-command
;;
;; general other example/way of dealing with leader:
;; (use-package general
;;   :ensure t
;;   :init
;;   (setq general-override-states '(insert
;;                                   emacs
;;                                   hybrid
;;                                   normal
;;                                   visual
;;                                   motion
;;                                   operator
;;                                   replace))
;;   :config
;;   (general-define-key
;;    :states '(normal visual motion)
;;    :keymaps 'override
;;    "SPC" 'hydra-space/body))

(require 'general)
(general-evil-setup t)

(general-create-definer w/leader-keys
  :keymaps '(normal visual emacs)
  :prefix "SPC"
  :global-prefix "C-SPC")

(w/leader-keys
  :desc "exec stuff" ":"   'execute-extended-command
  :desc "buffers" "<SPC>"  'consult-buffer
  :desc "grep" "/"         'consult-ripgrep
  :desc "proj buffers" "'" 'projectile-find-file
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
  :desc "Goto previous note" "rdb" 'org-roam-dailies-goto-previous-note
  :desc "Goto previous note" "rdk" 'org-roam-dailies-goto-previous-note
  :desc "Goto date"          "rdd" 'org-roam-dailies-goto-date
  :desc "Capture date"       "rdD" 'org-roam-dailies-capture-date
  :desc "Goto next note"     "rdf" 'org-roam-dailies-goto-next-note
  :desc "Goto next note"     "rdj" 'org-roam-dailies-goto-next-note
  :desc "Goto tomorrow"      "rdm" 'org-roam-dailies-goto-tomorrow
  :desc "Capture tomorrow"   "rdM" 'org-roam-dailies-capture-tomorrow
  :desc "Capture today"      "rdn" 'org-roam-dailies-capture-today
  :desc "Goto today"         "rdt" 'org-roam-dailies-goto-today
  :desc "Capture today"      "rdT" 'org-roam-dailies-capture-today
  :desc "Goto yesterday"     "rdy" 'org-roam-dailies-goto-yesterday
  :desc "Capture yesterday"  "rdY" 'org-roam-dailies-capture-yesterday
  :desc "Find directory"     "rd-" 'org-roam-dailies-find-directory

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
  :desc "Emoji"        "ie" 'emojify-insert-emoji
  :desc "date (now)"   "id" 'my/insert-inactive-timestamp
  :desc "date (now)"   "in" 'my/insert-inactive-timestamp
  ;; rm stuff
  :desc "trailing whitespace"  "-d" 'delete-trailing-whitespace

  ;; file stuff, dired, ibuffer
  :desc "file recent" "fr" 'consult-recent-file

  ;;
  :desc "filter line"  "ss" 'consult-line

  ;; code stuff
  :desc "lsp " "cr" 'eglot-rename)

;; (general-evil-define-key '(normal) normal-mode-map
;;    ;; rm stuff
;;   :desc "trailing whitespace"  "-d" 'delete-trailing-whitespace
;;   )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell

(general-evil-define-key '(normal input visual) comint-mode-map
 ;; NOTE: keymaps specified with :keymaps must be quoted
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
