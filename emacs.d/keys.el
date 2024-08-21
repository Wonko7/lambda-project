(require 'which-key)
(which-key-mode)

(require 'general)
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
  "vG" #'vertico-grid-mode
  "vu" #'vertico-unobtrusive-mode

  ;; yank
  "yp" (lambda () (interactive) (kill-new (buffer-file-name)))
  "yP" #'consult-yank-pop

  ;; emacs apps
  "ab"  #'ibuffer
  "ac"  #'calc
  "ad"  #'dired
  "aD"  #'dictionary-lookup-definition
  "as"  #'shell
  "ap"  #'proced
  "aE"  #'eww-search-words
  ;; emacs but not that close to my heart
  "aab" #'bluetooth-list-devices
  ;; external apps
  "aaT" (lambda () (interactive) (async-shell-command my/term-cmd))
  "aat" (lambda () (interactive) (async-shell-command "transmission-gtk"))
  "aac" (lambda () (interactive) (async-shell-command "calibre")) ;; FIXME guix the shit out of this.
  "aap" (lambda () (interactive) (async-shell-command "pavucontrol"))
  ;; browsers
  "aBf" (lambda () (interactive) (async-shell-command "firefox"))
  "aBc" (lambda () (interactive) (async-shell-command "chromium"))
  "aBt" #'my/tbb
  ;; utils
  "zz"  (lambda () (interactive) (async-shell-command my/lock-cmd))

  ;; buffers
  "br" #'rename-buffer
  "bk" #'kill-this-buffer
  "bn" #'evil-buffer-new
  "bo" #'consult-outline
  "bg" #'consult-focus-lines

  ;; org
  "oa"  (lambda () (interactive) (org-agenda nil "z"))
  "oc"  #'cfw:open-org-calendar ;; FIXME use this as date picker?
  "oib" (lambda ()
          (interactive)
          (execute-kbd-macro (kbd "^wD"))
          (org-web-tools-insert-link-for-url (current-kill 0 t))
          (org-id-get-create)
          (evil-next-line 2))

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
  "rdt" #'org-roam-dailies-goto-today	      ;;  :desc "Goto today"
  "rdT" #'org-roam-dailies-capture-today      ;;  :desc "Capture today"
  "rdy" #'org-roam-dailies-goto-yesterday     ;;  :desc "Goto yesterday"
  "rdY" #'org-roam-dailies-capture-yesterday  ;;  :desc "Capture yesterday"
  "rd-" #'org-roam-dailies-find-directory     ;;  :desc "Find directory"

  ;; projectile
  "pa"  #'projectile-add-known-project
  "pF"  #'(lambda ()
            (interactive)
            (let ((remote (consult--read
                           (remove "" (string-split (shell-command-to-string "cat /etc/hosts | cut -d\\\t -f2 | grep -v localhost") "\n"))
                           :prompt "choose ship from fleet: "
                           :sort nil
                           :require-match t)))
              (find-file
               (read-file-name
                "Find TRAMP file: "
                (concat "/ssh:" remote ":" default-directory)))))
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
  "ie" #'emoji-search                 ;;  :desc "Emoji"
  "in" #'my/insert-inactive-timestamp ;;  :desc "date (now)"
  "is" #'my/insert-shell-line
  "it" #'consult-yasnippet
  ;; rm stuff
  "-d" #'delete-trailing-whitespace ;; :desc "trailing whitespace"

  ;; file stuff, dired, ibuffer
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
  "wg" #'ace-select-window
  "wx" #'ace-swap-window
  "ws" #'switch-window-then-swap-buffer
  "wo" #'other-window
  "zai" #'gptel-send
  "zl"  #'scroll-lock-mode
  "z''" (lambda () (interactive) (async-shell-command "dunstctl set-paused toggle"))
  "z'c" (lambda () (interactive) (async-shell-command "dunstctl close"))
  "z'C" (lambda () (interactive) (async-shell-command "dunstctl close-all"))
  "z'h" (lambda () (interactive) (async-shell-command "dunstctl history")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; states

(general-define-key
 :states 'normal
 "C-e"  #'embark-act
 "-"    nil
 "/"    #'consult-line
 "C-/"  #'evil-search-forward
 "-d"   #'delete-trailing-whitespace
 "z="   #'flyspell-correct-at-point
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

(general-evil-define-key '(normal insert visual) minibuffer-mode-map ;; not sure about best place for this
  "C-b"        #'embark-become)

;; (general-evil-define-key '(normal insert visual) embark-collect-mode-map
;;   "C-k"        #'next line + embark default live buffer action
;;   "C-j"        #'minibuffer-next-prompt
;;   )
;; (general-evil-define-key '(normal) my/embark-become-line-map
;;   "l"        #'consult-line
;;   "i"        #'consult-imenu
;;   "o"        #'consult-outline
;;   "s"        #'consult-outline)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; async shell command

(general-evil-define-key '(normal insert visual) minibuffer-local-shell-command-map
  "C-r"        #'consult-history
  "C-k"        #'minibuffer-previous-prompt
  "C-j"        #'minibuffer-next-prompt)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell

(general-evil-define-key '(normal visual) comint-mode-map
  "|"           #'my/insert-shell-line
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
  (kbd "C-s") #'my/insert-shell-line
  (kbd "C-r") #'consult-history
  (kbd "C-p") #'comint-previous-input
  (kbd "C-n") #'comint-next-input)

(general-evil-define-key '(insert normal) shell-mode-map
  "C-S-<return>" #'detached-shell-send-input)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dired

(general-evil-define-key '(normal) dired-mode-map
  "ï"    #'dired-up-directory)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; calc

(general-evil-define-key '(normal) calc-mode-map
  "i"    (lambda ()
           (interactive) ;; avoid having info popping up all the time.
           (message "beep boop - I'm a robot")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; magit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; lisps


;; (general-evil-define-key '(normal) geiser-mode-map
;;   :prefix "RET"
;;   "RET" #'geiser-eval-definition)

(general-evil-define-key '(normal) emacs-lisp-mode-map
  :prefix "RET"
  "RET" #'eval-defun)

(general-evil-define-key '(normal) scheme-mode-map
  :prefix "RET"
  "RET" #'geiser-eval-definition
  "b"   #'geiser-eval-buffer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; info

(general-evil-define-key '(normal) Info-mode-map ;; this is not working anymore :(
  "s"   #'consult-info)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org



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
;; ement


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gnus

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
