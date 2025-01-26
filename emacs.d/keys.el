(use-package which-key
  :demand t
  :config
  (which-key-mode))

(use-package general
  :demand t
  :config
  (general-evil-setup t)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
    "yp" (lambda () (interactive) (kill-new (buffer-file-name)))
    "yP" #'consult-yank-pop

    ;; emacs apps
    "a"   '("Apps" . (keymap))
    "ab"  #'ibuffer
    "ac"  #'calc
    "ad"  #'dired
    "aD"  #'dictionary-lookup-definition
    "as"  #'shell
    "ap"  #'proced
    "aE"  #'eww-search-words
    ;; external apps
    "aa"  '("More apps" . (keymap))
    "aab" #'bluetooth-list-devices
    "aaT" (lambda () (interactive) (my/local-async-shell-command my/term-cmd))
    "aat" #'transmission
    "aac" (lambda () (interactive) (my/local-async-shell-command "calibre"))
    "aap" (lambda () (interactive) (my/local-async-shell-command "pavucontrol"))
    ;; browsers
    "aB"  '("Browsers" . (keymap))
    "aBf" (lambda () (interactive) (my/local-async-shell-command "firefox"))
    "aBc" (lambda () (interactive) (my/local-async-shell-command "chromium"))
    "aBt" #'my/tbb

    ;; buffers
    "b"  '("buffers" . (keymap))
    "br" #'rename-buffer
    "bk" #'kill-this-buffer
    "bn" #'evil-buffer-new
    "bo" #'consult-outline
    "bg" #'consult-focus-lines

    ;; org
    "o"   '("org" . (keymap))
    "oa"  (lambda () (interactive) (org-agenda nil "z"))
    "oc"  #'cfw:open-org-calendar ;; FIXME use this as date picker?
    "oi"  '("insert" . (keymap))
    "oib" (lambda ()
            (interactive)
            (execute-kbd-macro (kbd "^wD"))
            (org-web-tools-insert-link-for-url (current-kill 0 t))
            (org-id-get-create)
            (evil-next-line 2))
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
    "rg" #'org-roam-graph
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
    "ps"  #'projectile-run-shell
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
    "graa" (lambda () (interactive) (async-shell-command "git-add-remotes -lf"))
    "graf" (lambda () (interactive) (async-shell-command "git-add-remotes -f"))
    "gral" (lambda () (interactive) (async-shell-command "git-add-remotes -l"))
    "grah" (lambda () (interactive) (async-shell-command "git-add-remotes -h"))
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
    "ie" #'emoji-search                 ;;  :desc "Emoji"
    "in" #'my/insert-inactive-timestamp ;;  :desc "date (now)"
    "is" #'my/insert-shell-line
    "it" #'consult-yasnippet
    "ip" #'embark-insert-relative-path
    ;; rm stuff
    "-d" #'delete-trailing-whitespace ;; :desc "trailing whitespace"

    ;; file stuff, dired, ibuffer
    "f"  '("files" . (keymap))
    "fr" #'consult-recent-file ;; :desc "file recent"
    "ff" #'find-file

    ;; use this for something else here
    "ss" #'consult-line ;; :desc "filter line"

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
    "wg" #'ace-select-window
    "wx" #'ace-swap-window
    "ws" #'switch-window-then-swap-buffer
    "wo" #'other-window
    ;; layouts
    "l"  '("Layouts" . (keymap))
    "ll" #'ws/set-layout
    "lt" #'ws/toggle-buffer
    "lr" #'ws/layout-reset
    "lR" #'ws/layout-reinit
    "ls" #'ws/toggle-shells

    ;; xorg stuff
    "z"  '("Xorg desktop things" . (keymap))
    "zai" #'gptel-send ;; meh
    "zz"  (lambda () (interactive) (my/local-async-shell-command my/lock-cmd))
    "zl"  #'scroll-lock-mode
    "z'"  '("Notifications" . (keymap))
    "z''" (lambda () (interactive) (my/local-async-shell-command "dunstctl set-paused toggle"))
    "z'c" (lambda () (interactive) (my/local-async-shell-command "dunstctl close"))
    "z'C" (lambda () (interactive) (my/local-async-shell-command "dunstctl close-all"))
    "z'h" (lambda () (interactive) (my/local-async-shell-command "dunstctl history"))
    "z't" (lambda () (interactive)
            (my/local-async-shell-command
             "dunstify 'How are we gonna fuck this pig?' \
                     'With enough cologne to upset a Bangkok ladyboy.'")))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; states

  (general-define-key
   :states 'normal
   "C-e"  #'embark-act
   "-"    nil
   "/"    #'consult-line
   "C-/"  #'evil-search-forward
   "-d"   #'delete-trailing-whitespace
   "z="   #'flyspell-correct-at-point
   ;; "`"    #' FIXME do something with this
   "'"    #'evil-owl-goto-mark
   "Y"    (lambda () (interactive) (execute-kbd-macro (kbd "y$"))))

  ;; TODO: sentence & paragraph motions.

  (general-define-key
   :states 'insert
   "C-e"   #'emoji-search
   "C-S-H" #'term-send-invisible
   "C-v"   #'evil-paste-after
   "C-S-V" (lambda () (interactive) (evil-paste-after 1 ?\*)))

  (general-define-key
   :states '(normal emacs insert visual global motion)
   (kbd "C-SPC") evil-leader--default-map)

  (general-define-key
   :states '(normal emacs visual global motion)
   "C-e"  #'embark-act)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; async shell command

  (general-evil-define-key '(normal insert visual) minibuffer-local-shell-command-map
    "C-r"        #'consult-history
    "C-k"        #'minibuffer-previous-prompt
    "C-j"        #'minibuffer-next-prompt))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; lisps

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
