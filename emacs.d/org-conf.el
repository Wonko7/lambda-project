;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; prelude

;; this needs to be set before starting org
;; the equivalent for evil-org-mode-map is in evil
(general-evil-define-key '(normal) org-mode-map
  "C-RET"           '+org/insert-item-below
  "C-S-RET"         '+org/insert-item-above
  [C-return]        '+org/insert-item-below
  [C-S-return]      '+org/insert-item-above)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; directories

(setq org-directory "/data/org/")
(setq org-roam-directory (concat org-directory "here-be-dragons/"))
(setq org-agenda-files (mapcar
                        (lambda (d)
                          (concat org-roam-directory d))
                        '("wip/" "work/" "wtf/" "daily/")))

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
         "NEXT(n/!)"                ; A task that recuring
         "TODO(t)"                  ; A task that needs doing & is ready to do
         "PROJ(p)"                  ; A project, which usually contains other tasks
         "GOGO(g/!)"                ; A task that is in progress
         "WAIT(w/!)"                ; Something external is holding up this task
         "HOLD(h/!)"                ; This task is paused/on hold because of me
         "ADD(a)"                   ; feature
         "FIX(f)"                   ; feature
         "BUG(b)"                   ; feature
         "|"
         "DONE(d/!)"       ; Task successfully completed
         "KILL(k)")        ; Task was cancelled, aborted or is no longer applicable
        (sequence
         "[ ](T)"                          ; A task that needs doing
         "[-](G)"                          ; Task is in progress
         "[?](W)"                          ; Task is being held up or paused
         "|"
         "[X](D)"))                        ; Task was completed
      org-todo-keyword-faces
      '(("[-]"  . +org-todo-active)
        ("NEXT" . +org-todo-active)
        ("GOGO" . +org-todo-active)
        ("[?]"  . +org-todo-onhold)
        ("WAIT" . +org-todo-onhold)
        ("HOLD" . +org-todo-onhold)
        ("PROJ" . +org-todo-project))
                                        ;(org-confirm-babel-evaluate nil)
                                        ;(org-special-ctrl-a/e t)
                                        ;(org-hide-emphasis-markers t)
                                        ;(org-pretty-entities t)
      ;; agenda/cal dates:
      org-agenda-start-on-weekday 1
      calendar-week-start-day 1
      org-log-into-drawer t
      org-auto-align-tags t
      org-tags-column 72
      org-edit-timestamp-down-means-later t
      cfw:org-agenda-schedule-args '(:timestamp))

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
        org-habit-show-habits nil
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
                                                      '((:name "ssdd: daily edition"
                                                               :tag ("ssdd")
                                                               :order 10)
                                                        (:name "ssdd: yolo"
                                                               :tag ("tt" "lol" "yolo")
                                                               :order 20)
                                                        (:name "BS"
                                                               :tag ("bs" "fm" "fuckme")
                                                               :order 30)
                                                        (:name "fun maximization"
                                                               :tag ("fun")
                                                               :order 40)
                                                        (:name "WWSCD"
                                                               :tag ("wwscd")
                                                               :order 50)
                                                        (:name "wtf: focus"
                                                               :and (:tag "wtf" :tag "focus")
                                                               :order 51)
                                                        (:name "wtf"
                                                               :tag ("wtf")
                                                               :order 52)
                                                        (:name "innerspace"
                                                               :tag ("is" "h" "habit" "focus")
                                                               :order 60)
                                                        (:name "review"
                                                               :tag ("review" "r")
                                                               :order 70)
                                                        (:name "next steps"
                                                               :tag "next"
                                                               :order 80)
                                                        (:name "Projects"
                                                               :todo "PROJ"
                                                               :order 90)
                                                        (:name "don't be a cunt"
                                                               :tag "dbac"
                                                               :order 100)
                                                        ;; (:name "repeat after me"
                                                        ;;  :order 9
                                                        ;;  :habit t
                                                        ;;  )
                                                        (:name ".*"
                                                               :order 999
                                                               :anything t)
                                                        ))))))))
(setq org-agenda-compact-blocks t
      ;;org-agenda-start-with-follow-mode t
      org-super-agenda-header-separator "\n")

(require 'org-super-agenda)
(org-super-agenda-mode)

(require 'org-habit)
(setq org-habit-graph-column 60)

(require 'org-crypt)
(setq
 epa-file-encrypt-to '("william@underage.wang")
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

(defun fuck-me/init-capture ()
  (setq org-capture-projects-file "dev"
        ;; add project stuff.
        org-capture-templates
        `(("Qp" "Protocol" entry
           (file+olp "here-be-dragons/20210915144652-browsing_inbox.org" "browsing" "inbox")
           "* [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\n%U\n#+BEGIN_QUOTE\n%i\n#+END_QUOTE"
           :immediate-finish t)
          ("QL" "Protocol Link direct" entry
           (file+olp "here-be-dragons/20210915144652-browsing_inbox.org" "browsing" "inbox")
           "* [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\n%U"
           :immediate-finish t)

          ;; TODO these look nice, look into this:
          ;; Will use {project-root}/{todo,notes,changelog}.org, unless a
          ;; {todo,notes,changelog}.org file is found in a parent directory.
          ;; Uses the basename from `+org-capture-todo-file',
          ;; `+org-capture-changelog-file' and `+org-capture-notes-file'.
          ("p" "Templates for projects")
          ("pt" "Project-local todo" entry ; {project-root}/todo.org
           (file+headline +org-capture-project-todo-file "Inbox")
           "* TODO %?\n%i\n%a" :prepend t)
          ("pn" "Project-local notes" entry ; {project-root}/notes.org
           (file+headline +org-capture-project-notes-file "Inbox")
           "* %U %?\n%i\n%a" :prepend t)
          ("pc" "Project-local changelog" entry ; {project-root}/changelog.org
           (file+headline +org-capture-project-changelog-file "Unreleased")
           "* %U %?\n%i\n%a" :prepend t)
          ;; Will use {org-directory}/{+org-capture-projects-file} and store
          ;; these under {ProjectName}/{Tasks,Notes,Changelog} headings. They
          ;; support `:parents' to specify what headings to put them under, e.g.
          ;; :parents ("Projects")
          ("o" "Centralized templates for projects")
          ("ot" "Project todo" entry
           (function +org-capture-central-project-todo-file)
           "* TODO %?\n %i\n %a"
           :heading "Tasks"
           :prepend nil)
          ("on" "Project notes" entry
           (function +org-capture-central-project-notes-file)
           "* %U %?\n %i\n %a"
           :heading "Notes"
           :prepend t)
          ("oc" "Project changelog" entry
           (function +org-capture-central-project-changelog-file)
           "* %U %?\n %i\n %a"
           :heading "Changelog"
           :prepend t))

        org-roam-dailies-capture-templates
        `(,(my/make-daily-capture "n" "note" "* %?\n%U\n" t)
          ("d" "ssdd top" entry "* [ ] %?"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🖖 ssdd"))
           :prepend t)
          ("s" "ssdd bottom" entry "* [ ] %?"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🖖 ssdd")))
          ("g" "go" plain "%?" :jump-to-captured t :if-new (file ,my/daily-file))

          ("m" "media")
          ("mt" "tv" entry "* 📺 %?\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
          ("mb" "book" entry "* 📕 %?\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
          ("mm" "music (is so nice)" entry "* 🎵 %?\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
          ("mp" "podcast" entry "* 🎙 %?\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))

          ("i" "innerspace")
          ("ic" "coffee" entry "* ☕ [[id:88321f53-b156-4254-91b7-4af1359853ca][coffee]]\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
          ("ie" "third eye" entry "* ☯ [[id:b94c6aad-213c-4091-8275-bfa8c0c363e6][prying open my third eye]]\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
          ("ii" "innerspace" entry "* ☯ %?\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
          ("if" "fam" entry "* ❤ %?\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
          ("ih" "home" entry "* 🏡 [[id:ce6bdbed-76a3-42b6-b614-43438ffd742d][home]] %?\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
          ("iH" "Health" entry "* ⚖ [[id:721ab13d-c8ff-4f55-8c8f-54687d031fab][weight]] %?\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
          ("iw" "weight" entry "* 🏥 [[id:3e525893-2e96-401b-bb98-a5a47601192d][health]] %?\n%U"
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

          ,(my/make-daily-capture "r" "RDV"
                                  "* RDV %? \n<%<%Y-%m-%d>>\n" t)
          ("w" "witness the fitness")
          ("wb" "bouldering" entry "* ⛰ [[id:546e7d60-daa1-413c-96de-a026f4649a17][bouldering]] %? :wtf:\n%U\n** ❤ with :innerspace:\n** 🔥 topped\n** 👷 projects\n** 🏥 [[id:820e7fc2-6cd0-4865-988f-7f526f5545a9][injuries]]\n"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
          ("ws" "sport climbing" entry "* ⛰ [[id:80360dc7-4428-433b-8651-30248b4fe46d][sport climbing]] %? :wtf:\n%U\n** ❤ with :innerspace:\n** 🔥 topped\n** 👷 projects\n** 🏥 [[id:820e7fc2-6cd0-4865-988f-7f526f5545a9][injuries]]\n"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
          ("wf" "fingerboard" entry "* 🤘 [[id:f9bffcdd-13d2-474b-811a-3a8f90458daf][fingerboard]] :wtf:\n%U\n** 🍚 [[id:7acd1856-7e65-4134-b6ec-715976a03e7e][rice bucket]]\n- %?\n** 💪 [[id:0c8446f1-0640-4492-9f2c-5cddfb601a27][pull-ups]]\n** 🐒 [[id:dc388e37-deec-4241-b014-7d99e7f02ad4][campusing]]\n** 🤘 [[id:793f903d-06eb-4368-b057-b30412aff151][deadhangs]]"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
          ("wh" "handstands" entry "** 🤸 [[id:4fd6d453-4088-4182-91b8-ae020d456487][handstands]] :wtf:\n%U *** 🍚 [[id:7acd1856-7e65-4134-b6ec-715976a03e7e][rice bucket]]\n- %?x *** 💪 [[id:5636c886-4684-4343-8797-b46ae4c08301][crow to push butt up high straight back]]\n*** 💪 [[id:ee90c7f5-5ee6-4db4-b613-fccf792e6c2f][baby HSPUs]]\n*** 🤸 [[id:4fd6d453-4088-4182-91b8-ae020d456487][handstands]]\nsession max hold: \n*** 🍌 [[id:6d270194-77c5-4dba-a682-6de4e28ecd38][btw banana stretch]]"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
          ("wr" "rice bucket" entry "* 🍚 [[id:7acd1856-7e65-4134-b6ec-715976a03e7e][rice bucket]] :wtf:\n%U%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
          ("wl" "leg day" entry "* 💪 leg day :wtf:\n%U\n** 🍚 [[id:7acd1856-7e65-4134-b6ec-715976a03e7e][rice bucket]]\n- %?\n** 💪 [[id:12d61817-b852-4ccb-ade2-40b29415694d][cossak hip rotations]]\n** 💪 [[id:a561809c-02eb-4f18-88dc-67eb6810fe8c][pistol squats]]\n"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
          ("wi" "injuries" entry "* 🏥 [[id:820e7fc2-6cd0-4865-988f-7f526f5545a9][injuries]] :wtf:inj:\n%U\n%?\n"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
          ("ww" "woody" entry "* 📐 [[id:a679eafc-fcaf-404d-a14e-d730a1a5b58b][woody]] :wtf:\n%U\n** 🍚 [[id:7acd1856-7e65-4134-b6ec-715976a03e7e][rice bucket]]\n- %?\n** 🔥 topped\n** 👷 projects\n** 🏥 [[id:820e7fc2-6cd0-4865-988f-7f526f5545a9][injuries]]"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))

          ("t" "tech")
          ("tg" "guix" entry "* 🐧 [[id:844ed739-42ce-4277-b7b5-b8f4a79869dc][guix]]\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
          ("te" "emacs" entry "* 🐧 [[id:ab80bf16-aadd-4fa3-a9d6-4d4f7fd1b2e9][emacs]]\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
          ("tl" "linux" entry "* 🐧 [[id:25647313-7296-4803-b2c4-f57b5b6e2d72][linux]]\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
          ("tp" "physics" entry "* ⚛ [[id:a3e5f916-a260-4925-81ef-5f7c6f5e3157][physics]]\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))


          ("b" "besport")
          ("bd" "BS ssdd top" entry "* [ ] %?"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🐫 BS ssdd"))
           :prepend t)
          ("bs" "BS ssdd bottom" entry "* [ ] %?"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🐫 BS ssdd")))
          ("bb" "boop" entry "* boop %? :bs:boop:\n%U\n"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🐫 BS"))
           :jump-to-captured t)
          ("bl" "backlog prep" entry "* backlog :bs:bl:\n%U\n%?"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🐫 BS"))
           :jump-to-captured t)
          ("bn" "note" entry "* %? :bs:\n%U"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🐫 BS"))
           :jump-to-captured t)
          ("br" "réu" entry "* %? :bs:\n%U"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🐫 BS"))
           :jump-to-captured t)
          ;; ("ba" "réu appli" entry
          ;;  ,(->> (+pass-get-entry "besport/capture/team")
          ;;        (mapcar #'cdr)
          ;;        (-drop 1)
          ;;        (mapcar (lambda (s) (concat s "\n")))
          ;;        (apply #'concat))
          ;;  :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🐫 BS"))
          ;;  :jump-to-captured t)
          )))
(fuck-me/init-capture)

;; FIXME review this:
(setq
 org-catch-invisible-edits 'show-and-error
 ;org-special-ctrl-a/e t
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

(require 'calfw-org)
(require 'org-web-tools)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-ql

(require 'org-ql)
(require 'org-ql-search)


(defun my/sort-by-filename-date (a b)
  (cl-flet ((get-fn (e)
                    (buffer-name (marker-buffer (org-element-property :org-marker e))))
            (to-ts (fn)
                   (org-timestamp-format
                    (org-timestamp-from-string
                     (concat "[" (file-name-sans-extension fn) "]"))
                    "%s")))
    (string>
     (to-ts (get-fn a))
     (to-ts (get-fn b)))))

(defun my/all-dailies ()
  (org-ql-search-directories-files
   :directories (mapcar (lambda (d)
                          (concat org-roam-directory d))
                        (list "daily"
                              "daily/_archive/"))))

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

(provide 'conf/org)
