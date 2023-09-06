;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; prelude

;; this needs to be set before starting org
;; the equivalent for evil-org-mode-map is in evil
(general-evil-define-key '(insert normal) org-mode-map
  "C-RET"      '+org/insert-item-below
  "S-RET"    '+org/insert-item-above
  [C-return]   '+org/insert-item-below
  [S-return] '+org/insert-item-above)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; directories

(setq org-directory "/data/org/")
(setq org-roam-directory (concat org-directory "here-be-dragons/"))
(setq org-agenda-files (mapcar
                        (lambda (d)
                          (concat org-roam-directory d))
                        '("wip/" "work/" "wtf/" "the-road-so-far/")))
(setq org-roam-dailies-directory "the-road-so-far")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org

(require 'org)

(defface +org-todo-active
  '((t (:inherit link :underline nil)))
  "active todo")
(defface +org-todo-onhold
  '((t (:inherit default :foreground "brown")))
  "active todo")

(setq org-directory "/data/org/"
      org-startup-indented t
      ;; FIXME fix this with guix magic:
      org-plantuml-jar-path (shell-command-to-string "cat `which plantuml` 2>/dev/null  | 2>/dev/null sed -nre 's/.* ([^ ]+\.jar).*/\\1/p' | tr -d '\n'")
      org-extend-today-until 3
      org-startup-folded 'content
      org-todo-keywords
      '((sequence
         "NEXT(n/!)"                ;; A task that recuring
         "TODO(t)"                  ;; A task that needs doing & is ready to do
         "PROJ(p)"                  ;; A project, which usually contains other tasks
         "GOGO(g/!)"                ;; A task that is in progress
         "WAIT(w/!)"                ;; Something external is holding up this task
         "HOLD(h/!)"                ;; This task is paused/on hold because of me
         "ADD(a)"                   ;; Add
         "FIX(f)"                   ;; Fix
         "BUG(b)"                   ;; Bug
         "|"
         "DONE(d/!)"                ;; Task successfully completed
         "KILL(k)")                 ;; Task was cancelled, aborted or is no longer applicable
        (sequence
         "[ ](T)"                   ;; A task that needs doing
         "[-](G)"                   ;; Task is in progress
         "[?](W)"                   ;; Task is being held up or paused
         "|"
         "[X](D)"))                 ;; Task was completed
      org-todo-keyword-faces
      '(("[-]"  . +org-todo-active)
        ("NEXT" . +org-todo-active)
        ("GOGO" . +org-todo-active)
        ("[?]"  . +org-todo-onhold)
        ("WAIT" . +org-todo-onhold)
        ("HOLD" . +org-todo-onhold)
        ("PROJ" . +org-todo-project))
      ;; (org-confirm-babel-evaluate nil)
      ;; (org-special-ctrl-a/e t)
      ;; (org-hide-emphasis-markers t)
      ;; (org-pretty-entities t)

      ;; agenda/cal dates:
      org-agenda-start-on-weekday         1
      calendar-week-start-day             1
      org-log-into-drawer                 t
      org-auto-align-tags                 t
      org-tags-column                     72
      org-edit-timestamp-down-means-later t
      cfw:org-agenda-schedule-args        '(:timestamp))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-roam

(require 'org-roam)
(require 'consult-org-roam)
(consult-org-roam-mode 1)

;; FIXME <start https://github.com/org-roam/org-roam/issues/2198
(defalias 'org-font-lock-ensure
  (if (fboundp 'font-lock-ensure)
      #'font-lock-ensure
    (lambda (&optional _beg _end)
      (with-no-warnings (font-lock-fontify-buffer)))))

(defun org-roam-fontify-like-in-org-mode (s)
  "Fontify string S like in Org mode.
Like `org-fontify-like-in-org-mode', but supports `org-ref'."
  ;; NOTE: pretend that the temporary buffer created by `org-fontify-like-in-org-mode' to
  ;; fontify a `cite:' reference has been hacked by org-ref, whatever that means;
  ;;
  ;; `org-ref-cite-link-face-fn', which is used to supply a face for `cite:' links, calls
  ;; `hack-dir-local-variables' rationalizing that `bibtex-completion' would throw some warnings
  ;; otherwise.  This doesn't seem to be the case and calling this function just before
  ;; `org-font-lock-ensure' (alias of `font-lock-ensure') actually instead of fixing the alleged
  ;; warnings messes the things so badly that `font-lock-ensure' crashes with error and doesn't let
  ;; org-roam to proceed further. I don't know what's happening there exactly but disabling this hackery
  ;; fixes the crashing.  Fortunately, org-ref provides the `org-ref-buffer-hacked' switch, which we use
  ;; here to make it believe that the buffer was hacked.
  ;;
  ;; This is a workaround for `cite:' links and does not have any effect on other ref types.
  ;;
  ;; `org-ref-buffer-hacked' is a buffer-local variable, therefore we inline
  ;; `org-fontify-like-in-org-mode' here
  (with-temp-buffer
    (insert s)
    (let ((org-ref-buffer-hacked t))
      (org-mode)
      (org-font-lock-ensure)
      (if org-link-descriptive
          (org-link-display-format (buffer-string))
        (buffer-string)))))
;; FIXME end>

(setq org-roam-file-exclude-regexp nil) ; default is data/, lol what a fuckface! that's exactly where my org data is!
(setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
(org-roam-db-autosync-mode)
(require 'org-roam-protocol)
(setq org-roam-directory (concat org-directory "here-be-dragons/"))
(setq org-roam-completion-everywhere t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fix insert after cursor

(defadvice org-roam-node-insert (around append-if-in-evil-normal-mode activate compile)
  "If in evil normal mode and cursor is on a whitespace character, then go into
append mode first before inserting the link. This is to put the link after the
space rather than before."
  (let ((is-in-evil-normal-mode (and (bound-and-true-p evil-mode)
                                     (not (bound-and-true-p evil-insert-state-minor-mode))
                                     (looking-at "[[:blank:]]"))))
    (if (not is-in-evil-normal-mode)
        ad-do-it
      (evil-append 0)
      ad-do-it
      (evil-normal-state))))
;; FIXME merge with ^
(defadvice emojify-insert-emoji (around append-if-in-evil-normal-mode activate compile)
  "If in evil normal mode and cursor is on a whitespace character, then go into
append mode first before inserting the link. This is to put the link after the
space rather than before."
  (let ((is-in-evil-normal-mode (and (bound-and-true-p evil-mode)
                                     (not (bound-and-true-p evil-insert-state-minor-mode))
                                     (looking-at "[[:blank:]]"))))
    (if (not is-in-evil-normal-mode)
        ad-do-it
      (evil-append 0)
      ad-do-it
      (evil-normal-state))))
;; FIXME merge with ^
(defadvice org-web-tools-insert-link-for-url (around append-if-in-evil-normal-mode activate compile)
  "If in evil normal mode and cursor is on a whitespace character, then go into
append mode first before inserting the link. This is to put the link after the
space rather than before."
  (let ((is-in-evil-normal-mode (and (bound-and-true-p evil-mode)
                                     (not (bound-and-true-p evil-insert-state-minor-mode))
                                     (looking-at "[[:blank:]]"))))
    (if (not is-in-evil-normal-mode)
        ad-do-it
      (evil-append 0)
      ad-do-it
      (evil-normal-state))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; super agenda

(require 'org-agenda)
(setq org-agenda-file-regexp "\\`\\\([^.].*\\.org\\\|[0-9]\\\{8\\\}\\\(\\.gpg\\\)?\\\)\\'"
      org-agenda-prefix-format (quote
                                ((agenda . "%-21c%?-12t% s")
                                 (timeline . "% s")
                                 (todo . "%-21c")
                                 (tags . "%-12c")
                                 (search . "%-12c")))
      org-agenda-deadline-leaders (quote ("!D!: " "D%2d: " ""))
      org-agenda-scheduled-leaders (quote ("" "S%3d: "))
      ;; fixes fucky binding on jk on an agenda header:
      ;; https://github.com/alphapapa/org-super-agenda/issues/50
      org-super-agenda-header-map (make-sparse-keymap)

      ;; (setq org-agenda-time-grid '((daily today require-timed) "----------------------" nil)
      ;;       org-agenda-skip-scheduled-if-done t
      ;;       org-agenda-skip-deadline-if-done t
      ;;       org-agenda-include-deadlines t
      ;;       org-agenda-block-separator nil
      ;;       org-agenda-compact-blocks t
      ;;       org-agenda-start-with-log-mode t)
      ;;

      ;;       org-agenda-start-with-log-mode t)
      org-agenda-start-with-log-mode t
      org-habit-show-habits t
      org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-include-deadlines t

      org-agenda-custom-commands '(("c" "Simple agenda view"
                                    ((agenda "")
                                     (alltodo "" )))
                                   ("z" "Super zaen view"
                                    ((agenda "" )
                                     (alltodo "=" ((org-agenda-overriding-header "")
                                                   (org-super-agenda-groups
                                                    '((:name "🤸 wtf: focus"
                                                             :and (:tag "wtf" :tag "focus")
                                                             :order 8)
                                                      (:name "🌄 ssdd"
                                                             :and (:tag "ssdd" :tag "tt")
                                                             :order 9)
                                                      (:name "🍰 work ssdd"
                                                             :and (:tag "ssdd" :tag "work")
                                                             :order 10)
                                                      (:name "👑 king line hit list"
                                                             :tag ("kl")
                                                             :order 11)
                                                      ;; (:name "fun maximization"
                                                      ;;        :tag ("fun")
                                                      ;;        :order 40)
                                                      (:name "wtf"
                                                             :tag ("wtf")
                                                             :order 52)
                                                      (:name "innerspace"
                                                             :tag ("is" "h" "habit" "focus")
                                                             :order 60)
                                                      ;; (:name "review"
                                                      ;;        :tag ("review" "r")
                                                      ;;        :order 70)
                                                      ;; (:name "next steps"
                                                      ;;        :tag "next"
                                                      ;;        :order 80)
                                                      ;; (:name "Projects"
                                                      ;;        :todo "PROJ"
                                                      ;;        :order 90)
                                                      ;; ;;(:name "don't be a cunt"
                                                      ;; ;;       :tag "dbac"
                                                      ;; ;;       :order 100)
                                                      ;; (:name "repeat after me"
                                                      ;;  :order 9
                                                      ;;  :habit t
                                                      ;;  )
                                                      ;;(:name ".*"
                                                      ;;       :order 999
                                                      ;;       :anything t)
                                                      ))))))))
(setq org-agenda-compact-blocks t
      ;;org-agenda-start-with-follow-mode t
      org-super-agenda-header-separator "\n")

(require 'org-super-agenda)
(org-super-agenda-mode)

(require 'org-habit)
(setq org-habit-graph-column 60)

(require 'org-crypt)
(setq epa-file-encrypt-to '("william@underage.wang")
      org-tags-exclude-from-inheritance (quote ("crypt"))
      org-crypt-disable-auto-save "encrypt"
      org-crypt-key "william@underage.wang")
(org-crypt-use-before-save-magic)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; capture

(require 'org-capture)

;; firefox integration
(defun transform-square-brackets-to-round-ones (string-to-transform)
  "Transforms [ into ( and ] into ), other chars left unchanged."
  (concat
   (mapcar #'(lambda (c) (if (equal c ?\[) ?\( (if (equal c ?\]) ?\) c))) string-to-transform)))

(defvar my/daily-header "#+title: %<%Y-%m-%d>\n#+category: %<%Y-%m-%d>")
(defvar my/daily-file "%<%Y-%m-%d>.org")
(defun my/make-daily-capture (key desc entry jump)
  (list key desc 'entry entry
        :if-new (list 'file+head my/daily-file my/daily-header)
        :jump-to-captured jump))

(setq org-capture-projects-file "dev"
      ;; add project stuff.
      org-capture-templates ;; REVIEW: revive this?
      `(("Qp" "Protocol" entry
         (file+olp "here-be-dragons/20210915144652-browsing_inbox.org" "browsing" "inbox")
         ,(string-join '("* [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\n"
                         "%U\n"
                         "#+BEGIN_QUOTE\n"
                         "%i\n"
                         "#+END_QUOTE"))
         :immediate-finish t)
        ("QL" "Protocol Link direct" entry
         (file+olp "here-be-dragons/20210915144652-browsing_inbox.org" "browsing" "inbox")
         ,(string-join '("* [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\n"
                         "%U"))
         :immediate-finish t))

      org-roam-dailies-capture-templates
      `(,(my/make-daily-capture "n" "note" "* %?\n%U\n" t)

        ("g" "go" plain "%?" :jump-to-captured t :if-new (file ,my/daily-file))

        ,(my/make-daily-capture "r" "RDV"
                                "* RDV %?\n<%<%Y-%m-%d>>\n" t)

        ("m" "media")
        ("mt" "tv" entry "* 📺 %?\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
        ("mb" "book" entry "%(let* ((url (substring-no-properties (current-kill 0)))
                                      (details (org-books-get-details url)))
                                 (when details (apply #'org-books-format 1 details)))"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
        ("mm" "music (is so nice)" entry "* 🎵 %?\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
        ("mp" "podcast" entry "* 🎙 %?\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))

        ("i" "innerspace")
        ("ic" "coffee" entry "* ☕ [[roam:coffee]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("ie" "third eye" entry "* ☯ [[roam:prying open my third eye]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("ii" "innerspace" entry "* ☯ %?\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("if" "fam" entry "* ❤ %?\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("ih" "home" entry "* 🏡 [[roam:home]] %?\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("iH" "Health" entry "* 🏥 [[roam:health]] %?\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("iw" "weight" entry "* ⚖ [[roam:weight]] %?\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("im" "metta" entry "* ☯ metta\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("ip" "piracy" entry "* ☠ %?\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("iv" "vipassana" entry "* ☯ [[id:37187551-897a-4f6a-a978-c057644f34af][vipassana]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("is" "sleep / dreams" entry "* 🌙 sleep / dreams\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("it" "trees" entry "* 🌳 trees / [[id:cadf3871-658d-4db2-b16c-36aa03dc71dc][brocoli]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))

        ("w" "witness the fitness")
        ("wb" "bouldering" entry ,(string-join '("* ⛰ [[roam:bouldering]] %? :wtf:\n"
                                                 "%U\n"
                                                 "** ❤ with :innerspace:\n"
                                                 "** 🔥 topped\n"
                                                 "** 👷 projects\n"
                                                 "** 🏥 [[roam:injuries]]\n"))
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("ws" "sport climbing" entry "* ⛰ [[roam:sport climbing]] %? :wtf:\n%U\n** ❤ with :innerspace:\n** 🔥 topped\n** 👷 projects\n** 🏥 [[roam:injuries]]\n"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("wf" "fingerboard" entry ,(string-join '("* 🤘 [[roam:fingerboard]] :wtf:\n"
                                                  "%U\n"
                                                  "** 🍚 [[roam:rice bucket]]\n"
                                                  "- %?\n"
                                                  "** 💪 [[roam:pull-ups]]\n"
                                                  "** 🐒 [[roam:campusing]]\n"
                                                  "** 🤘 [[roam:deadhangs]]"))
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("wh" "handstands" entry
         ,(string-join '("* 🤸 [[roam:handstands]] :wtf:\n"
                         "%U\n"
                         "** 🍚 [[roam:rice bucket]]\n"
                         "- %?\n"
                         "** 💪 [[roam:HSPU]]\n"
                         "** 💪 [[roam:press]]\n"
                         "** 🤸 [[roam:handstands]]\n"
                         "session max hold: \n"))
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("wr" "rice bucket" entry "* 🍚 [[id:7acd1856-7e65-4134-b6ec-715976a03e7e][rice bucket]] :wtf:\n%U%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("wl" "leg day" entry ,(string-join '("* 💪 leg day :wtf:\n"
                                              "%U\n"
                                              "** 🍚 [[roam:rice bucket]]\n"
                                              "- %?\n"
                                              "** 💪 [[roam:cossak hip rotations]]\n"
                                              "** 💪 [[roam:pistol squats]]\n"))
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("wi" "injuries" entry "* 🏥 [[id:820e7fc2-6cd0-4865-988f-7f526f5545a9][injuries]] :wtf:inj:\n%U\n%?\n"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("ww" "woody" entry ,(string-join '("* 📐 [[roam:woody]] :wtf:\n"
                                            "%U\n"
                                            "** 🍚 [[roam:rice bucket]]\n"
                                            "- %?\n"
                                            "** 🔥 topped\n"
                                            "** 👷 projects\n"
                                            "** 🐒 [[roam:campusing]]\n"
                                            "** 🏥 [[roam:injuries]]"))
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))

        ("t" "tech")
        ("tg" "guix" entry "* 🐧 [[id:844ed739-42ce-4277-b7b5-b8f4a79869dc][guix]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("te" "emacs" entry "* 🐃 [[id:ab80bf16-aadd-4fa3-a9d6-4d4f7fd1b2e9][emacs]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("tc" "clojure" entry "* ☯ [[id:4f11e3fe-1d86-42de-a84e-9c903893aa0a][clojure]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("to" "ocaml" entry "* 🐫 [[id:f5dd5816-0736-43d2-88c7-75e66d1ddf67][ocaml]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("tl" "linux" entry "* 🐧 [[id:25647313-7296-4803-b2c4-f57b5b6e2d72][linux]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("tp" "physics" entry "* ⚛ [[id:a3e5f916-a260-4925-81ef-5f7c6f5e3157][physics]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))

        ("W" "work")
        ("j" "Journal" entry (file+datetree "~/org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")
        ("Wm" "marge+" plain ""
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🍰 [[id:a8b719fa-7b0b-4118-afc2-5a244082d777][marge+]] :work:"))
         :jump-to-captured t)
        ("Wr" "RDV marge+" plain ""
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("RDV 🍰 [[id:a8b719fa-7b0b-4118-afc2-5a244082d777][marge+]] :work:"))
         :jump-to-captured t)))

;; FIXME review this:
(setq
 org-catch-invisible-edits 'show-and-error
 ;; org-special-ctrl-a/e t
 org-insert-heading-respect-content t
 org-indent-mode t

 ;; org styling, hide markup etc.
 org-hide-emphasis-markers t
 org-pretty-entities t
 org-ellipsis "…"

 ;; agenda styling
 org-agenda-block-separator ?─
 ;; org-agenda-time-grid
 ;; '((daily today require-timed)
 ;;   (800 1000 1200 1400 1600 1800 2000)
 ;;   " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
 ;; org-agenda-current-time-string
 ;; "⭠ now ─────────────────────────────────────────────────"
 )
(setq org-agenda-span 15)

(require 'calfw-org)
(require 'org-web-tools)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-ql

(require 'org-ql)
(require 'org-ql-search)

(defun my/sort-by-filename-date (a b)
  (cl-flet* ((get-fn (e)
                     (buffer-name (marker-buffer (org-element-property :org-marker e))))
             (to-ts (e)
                    (file-name-sans-extension (get-fn e))))
    (string> (to-ts a) (to-ts b))))

(defun my/all-dailies ()
  (org-ql-search-directories-files
   :directories (mapcar (lambda (d)
                          (concat org-roam-directory d))
                        (list "the-road-so-far"
                              "the-road-so-far/_archive/"))))

(setq org-ql-views
      (list
       (cons "ALL >7a"
             (list :buffers-files #'my/all-dailies
                   :query '(and (olps "witness" "bouldering" "topped" "")  (regexp "- [7-9][a-c][+]? -"))
                   :sort #'my/sort-by-filename-date))
       (cons "recent >7a"
             (list :buffers-files #'org-agenda-files
                   :query '(and (olps "witness" "bouldering" "topped" "")  (regexp "- [7-9][a-c][+]? -"))
                   :sort #'my/sort-by-filename-date))
       (cons "recent >7b"
             (list :buffers-files #'org-agenda-files
                   :query '(and (olps "witness" "bouldering" "topped" "")  (regexp "- [7][b-c][+]? -"))
                   :sort #'my/sort-by-filename-date))
       (cons "ALL >7b"
             (list :buffers-files #'my/all-dailies
                   :query '(and (olps "witness" "bouldering" "topped" "")  (regexp "- [7][b-c][+]? -"))
                   :sort #'my/sort-by-filename-date))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; babel

(org-babel-do-load-languages
 'org-babel-load-languages
 '((clojure . t)
   (emacs-lisp . t)
   (gnuplot . t)
   (scheme . t)
   (shell . t)
   (ocaml . t)))

(setq org-confirm-babel-evaluate nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; board

(require 'org-board)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; books

(require 'org-books)

(provide 'conf/org)
