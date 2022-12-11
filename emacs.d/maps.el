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
  :keymaps '(normal insert visual emacs)
  :prefix "SPC"
  :global-prefix "C-SPC")

(w/leader-keys
  :desc "exec stuff" ":" 'execute-extended-command
  :desc "buffers" "<SPC>" 'consult-buffer
  :desc "grep" "/" 'consult-grep
  :desc "proj buffers" "'" 'consult-project-buffer
  ;; "'" 'counsel-projectile-find-file
  ;; embark
  "e" 'embark-act
  ;; org
  "oa" 'org-agenda
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

  ;; magit
  "gg" 'magit-status
  "gj" '(git-gutter:next-hunk :properties (:repeat t :jump t))
  "gk" '(git-gutter:previous-hunk :repeat t :jump t)
  ;; roam
  ;; insert stuff
  :desc "Emoji"        "ie" 'emojify-insert-emoji
  :desc "date (now)"   "in" 'my/insert-inactive-timestamp

  ;; file stuff, dired, ibuffer
  :desc "file recent" "fr" 'consult-recent-file

  ;;
  :desc "filter line"  "ss" 'consult-line)

(general-evil-define-key '(normal input visual) comint-mode-map
 ;; NOTE: keymaps specified with :keymaps must be quoted
 "C-r"  'consult-history)

(provide 'maps)
