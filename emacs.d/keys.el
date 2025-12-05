;;; keys.el  -*- lexical-binding: t; -*-

;; code golf helper:
(defmacro li (&rest body) ;; FIXME use in exwm too.
  `(lambda ()
     (interactive)
     ,@body))

(use-package which-key
  :demand t
  :config
  (which-key-mode))

(use-package general
  :demand t
  :after (evil-leader evil-collection)
  :config
  (general-evil-setup t)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; leader actions

  (evil-leader/set-key
    ":"       #'execute-extended-command ;;  "exec stuff"
    "<SPC>"   #'consult-buffer           ;;  "buffers"
    "C-<SPC>" #'consult-buffer           ;;  "buffers"
    "/"       #'consult-ripgrep          ;;  "grep"
    "'"       #'project-find-file        ;;  "proj buffers"
    ;; "'" #'counsel-projectile-find-file

    ;; embark
    "C-e" #'embark-act
    "e"   #'embark-act
    "x"   #'embark-export
    ;; vertico
    "."  #'vertico-repeat
    "v"  '("Vertico" . (keymap))
    "vG" #'vertico-grid-mode
    "vu" #'vertico-unobtrusive-mode

    ;; yank
    "y"  '("yank" . (keymap))
    "yp" (li (kill-new (buffer-file-name)))
    "yP" #'consult-yank-pop

    ;; regroup shells / tmp
    "ts"  #'my/ws-proj-shell
    "tt"  #'my/ws-proj-shell
    "tr"  #'my/ws-remote-fleet-shell-with-default
    "tR"  #'my/ws-remote-fleet-shell
    "tl"  #'my/consult-shell
    "tfd" (li (my/ws-remote-fleet-shell "daban-urnud.local"))
    "tfe" (li (my/ws-remote-fleet-shell "enterprise.local"))
    "tfy" (li (my/ws-remote-fleet-shell "yggdrasill.local"))
    "tfo" (li (my/ws-remote-fleet-shell "of-course-i-still-love-you.local"))

    ;; emacs apps
    "a"   '("Apps" . (keymap))
    "ab"  #'ibuffer
    "ac"  #'calc
    "ad"  #'dired
    "aD"  #'dictionary-lookup-definition
    ;; "as"  #'shell
    "as"  #'my/ws-proj-shell
    "aS"  #'my/ws-remote-fleet-shell-with-default
    "ap"  #'proced
    "aE"  #'eww-search-words
    ;; external apps
    "aa"    '("More apps" . (keymap))
    "aab"   #'bluetooth-list-devices
    "aaT"   (li (my/local-async-shell-command my/term-cmd))
    "aat"   #'transmission
    "aac"   (li (my/local-async-shell-command "calibre"))
    "aap"   (li (my/local-async-shell-command "pavucontrol"))
    "aallm" #'gptel
    "aai"   #'gptel
    ;; browsers
    "aB"  '("Browsers" . (keymap))
    "aBf" (li (my/local-async-shell-command "firefox"))
    "aBc" (li (my/local-async-shell-command "chromium"))
    "aBt" #'my/tbb

    ;; buffers
    "b"  '("buffers" . (keymap))
    "br" #'rename-buffer
    "bk" #'kill-current-buffer
    "bn" #'evil-buffer-new
    "bo" #'consult-outline
    "bg" #'consult-focus-lines

    ;; org
    "o"   '("org" . (keymap))
    "oa"  (li (org-agenda nil "z"))
    "oc"  #'cfw:open-org-calendar
    "oi"  '("insert" . (keymap))
    "oib" #'my/bleau-link-insert
    "oiw"  '("web" . (keymap))
    "oiwe" #'org-web-tools-insert-web-page-as-entry ;; :desc "web: insert entry"
    "oiwu" #'org-web-tools-insert-link-for-url      ;; :desc "web: insert url"
    "ow"  '("insert web" . (keymap))
    "owe" #'org-web-tools-insert-web-page-as-entry
    "owu" #'org-web-tools-insert-link-for-url

    ;; roam
    "r"  '("roam" . (keymap))
    "rD" #'org-roam-demote-entire-buffer
    "rf" #'org-roam-node-find
    "rF" #'org-roam-ref-find
    ;; "rg" #'org-roam-graph
    "rg" #'org-roam-dailies-goto-today
    "ri" #'org-roam-node-insert
    "rs" #'org-roam-db-sync
    "rI" #'org-id-get-create
    "rm" #'org-roam-buffer-toggle
    "rM" #'org-roam-buffer-display-dedicated
    "rn" #'org-roam-capture
    "rr" #'org-roam-refile
    "rR" #'org-roam-link-replace-all

    ;; roam dailies:
    "rd"  '("roam dailies" . (keymap))
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

    ;; detached: put in apps?
    "dl" #'detached-list-sessions

    ;; projectile
    "p"  '("projects" . (keymap))
    "pa"  #'projectile-add-known-project
    "pF"  #'my/remote-fleet-find-file
    "pf"  #'projectile-find-file
    "p'"  #'projectile-find-file
    "pgf" #'projectile-find-file-dwim
    "pp"  #'projectile-switch-project
    "pP"  #'persp-switch
    "pD"  #'projectile-discover-projects-in-search-path
    "pK"  #'projectile-kill-buffers
    "pS"  #'projectile-save-project-buffers
    ;; "ps"  #'projectile-run-shell
    "ps"  #'my/ws-proj-shell
    "pb"  #'projectile-ibuffer
    "pd"  #'projectile-dired
    "pm"  #'persp-merge
    "pu"  #'persp-unmerge

    ;; password-store
    "P"  #'password-store-copy

    ;; magit
    "g"  '("git" . (keymap))
    "g/" #'consult-git-grep
    "g." #'magit-file-dispatch
    "gg" #'magit-status
    "gb" #'magit-blame
    "gt" #'git-timemachine-toggle
    "graa" (li (async-shell-command "git-add-remotes -lf"))
    "graf" (li (async-shell-command "git-add-remotes -f"))
    "gral" (li (async-shell-command "git-add-remotes -l"))
    "grah" (li (async-shell-command "git-add-remotes -h"))
    "grap" (lambda ()
             (interactive)
             (shell-command-to-string "git remote")
             (let ((pr (consult--read
                        (remove "" (string-split (shell-command-to-string "git remote") "\n"))
                        :prompt "set push remote: "
                        :sort nil
                        :require-match t)))
               (async-shell-command (concat "git-add-remotes --push-remote=" pr))))

    ;; insert stuff
    "i"  '("insert" . (keymap))
    "id" #'consult-dir
    "ie" #'emoji-search                 ;;  :desc "Emoji"
    "in" #'my/insert-inactive-timestamp ;;  :desc "date (now)"
    "is" #'my/insert-shell-line
    "it" #'consult-yasnippet
    "ip" #'embark-insert-relative-path
    "il" #'my/insert-line
    ;; rm stuff
    "-d" #'delete-trailing-whitespace ;; :desc "trailing whitespace"

    ;; file stuff, dired, ibuffer
    "f"  '("files" . (keymap))
    "fr" #'consult-recent-file ;; :desc "file recent"
    "ff" #'find-file
    "fd" #'consult-dir

    ;; use this for something else here
    "ss" #'consult-outline ;; :desc "filter line"
    "so" #'consult-omni
    "sl" #'consult-line

    ;; code stuff
    ;; M-x flymake-goto-next-error goes to previous error in the current buffer
    ;; M-x flymake-goto-prev-error goes to next error in the current buffer
    ;; M-. or M-x xref-find-definitions finds the definition of the symbol at point and opens it in the current window
    ;; M-, or M-x xref-pop-marker-stack jumps back
    ;; M-? or M-x xref-find-references finds the references of the symbol at point
    "cr" #'eglot-rename ;; :desc "lsp "

    ;; windows
    ;; TODO: use W for other windows mirror of this map.
    "w"  '("Windows" . (keymap))
    "wl" #'my/consult-exwm-buffer
    "wg" #'ace-select-window
    "ws" #'ace-swap-window
    "wd" #'ace-delete-window
    "wo" #'other-window
    ;; layouts
    "l"  '("Layouts" . (keymap))
    "ll" #'ws/set-layout
    "lt" #'ws/toggle-buffer
    "lr" #'ws/layout-reset
    "lR" #'ws/layout-reinit
    "lh" #'ws/toggle-hide-your-kids

    ;; xorg stuff
    "z"  '("Xorg desktop things" . (keymap))
    "zz"  (li (my/local-async-shell-command my/lock-cmd))
    "zl"  #'scroll-lock-mode
    "z'"  '("Notifications" . (keymap))
    "z''" (li (my/local-async-shell-command "dunstctl set-paused toggle"))
    "z'c" (li (my/local-async-shell-command "dunstctl close"))
    "z'C" (li (my/local-async-shell-command "dunstctl close-all"))
    "z'h" (li (my/local-async-shell-command "dunstctl history"))
    "z't" (lambda () (interactive)
            (my/local-async-shell-command
             "dunstify 'How are we gonna fuck this pig?' \
                     'With enough cologne to upset a Bangkok ladyboy.'")))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; states

  (general-define-key
   :states 'normal
   "C-e"  #'embark-act
   "-"    #'mode-line-other-buffer
   "/"    #'consult-line
   "C-/"  #'evil-search-forward
   "*"    #'consult-line-word-at-point
   "C-*"  #'consult-line-symbol-at-point
   "#"    #'evil-search-word-forward
   "C-#"  #'evil-search-word-backward
   ;; "`"    #' FIXME do something with this
   "'"    #'evil-owl-goto-mark
   "Y"    (li (execute-kbd-macro (kbd "y$"))))
  ;; TODO: sentence & paragraph motions.

  (general-define-key
   :states 'insert
   "C-e"   #'emoji-search
   "C-S-H" #'term-send-invisible
   "C-v"   #'evil-paste-after
   "C-S-V" (li (evil-paste-after 1 ?\*)))

  (general-define-key
   :states '(normal emacs insert visual global motion)
   (kbd "C-SPC") evil-leader--default-map)

  (general-define-key
   :states '(normal emacs visual global motion)
   "C-e"  #'embark-act)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; readonly / view mode: in evil-collection

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; async shell command

  (general-evil-define-key '(normal insert visual) minibuffer-local-shell-command-map
    "C-r"        #'consult-history
    "C-k"        #'minibuffer-previous-prompt
    "C-j"        #'minibuffer-next-prompt))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FIXME lisps

(general-evil-define-key '(normal) emacs-lisp-mode-map
  :prefix "RET"
  "RET" #'eval-defun)

(general-evil-define-key '(normal) scheme-mode-map
  :prefix "RET"
  "RET" #'geiser-eval-definition
  "b"   #'geiser-eval-buffer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; elfeed

;; (general-evil-define-key '(normal) elfeed-search-mode-map
;;   "RET" #'elfeed-search-show-entry)
;;
;; (general-evil-define-key '(normal) elfeed-show-mode-map
;;   "J" #'elfeed-show-next
;;   "K" #'elfeed-show-prev
;;   "U" #'elfeed-show-tag--unread
;;   "u" #'elfeed-show-tag--read)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; firefox

(general-evil-define-key '(normal) exwm-firefox-evil-mode-map
  "h" #'exwm-firefox-core-tab-previous
  "l" #'exwm-firefox-core-tab-next
  "," #'exwm-firefox-core-history-back
  "." #'exwm-firefox-core-history-forward
  "d" #'exwm-firefox-core-tab-close
  "g^" #'exwm-firefox-core-tab-first
  "g$" #'exwm-firefox-core-tab-last
  "<" #'exwm-firefox-core-tab-move-left
  ">" #'exwm-firefox-core-tab-move-right
  "O" #'exwm-firefox-core-window-new
  "P" #'exwm-firefox-core-window-new-private
  ;; undo redo/redo
  ;; map H goPrevious
  ;; map L goNext
  ;; map b Vomnibar.activateTabSelection

  ;; map u restoreTab
  ;; map d removeTab
  ;; map , goBack
  ;; map . goForward
  ;; map <c-space> visitPreviousTab
  ;; map g^ firstTab
  ;; map g$ lastTab

  ;; map j scrollDown
  ;; map k scrollUp
  ;; map gg scrollToTop
  ;; map G scrollToBottom
  ;; map   <    moveTabLeft
  ;; map   >    moveTabRight

  ;; map r reload
  ;; map R reload hard

  ;; map P openCopiedUrlInCurrentTab
  ;; map p openCopiedUrlInNewTab
  ;; map t createTab
  ;; map o Vomnibar.activate
  ;; map O Vomnibar.activateEditUrl
  ;; map yy copyCurrentUrl
  ;; map gu goUp
  ;; map gU goToRoot
  ;; map f LinkHints.activateMode
  ;; map F LinkHints.activateModeToOpenInNewTab
  ;; map yf LinkHints.activateModeToCopyLinkUrl

  ;; map / enterFindMode
  ;; map n performFind
  ;; map N performBackwardsFind

  ;; map i enterInsertMode
  ;; map v enterVisualMode
  ;; map \ passNextKey normal
  ;; map gi focusInput
  ;; map m Marks.activateCreateMode
  ;; map ` Marks.activateGotoMode
  )

(provide 'conf/keys)
