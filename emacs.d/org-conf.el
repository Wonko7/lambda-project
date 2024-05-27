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
      org-extend-today-until              3
      org-agenda-start-on-weekday         1
      calendar-week-start-day             1
      org-log-into-drawer                 t
      org-auto-align-tags                 t
      org-tags-column                     -80
      org-agenda-tags-column              my/org-agenda-tags-column
      org-edit-timestamp-down-means-later t
      cfw:org-agenda-schedule-args        '(:timestamp))

(defun my/reset-tag-spacing-to-zero-org-tags ()
  (interactive)
  (replace-regexp "^\\(\\*.*?\\)[[:blank:]]+\\(:[0-9A-Za-z:_-]+:\\)" "\\1 \\2" nil
                  (point-min) (point-max)))

(defun my/justify-right-org-tags ()
  (interactive)
  (align-regexp (point-min) (point-max)
                "^\\(\\*.*[[:blank:]]\\(:[0-9A-Za-z:_-]+:\\)\\)" -2 1))

(defun my/align-org-tags ()
  (interactive)
  ;; highly annoying, why does this not work?
  (my/reset-tag-spacing-to-zero-org-tags)
  (my/justify-right-org-tags))

;; (remove-hook 'org-after-tags-change-hook #'my/align-org-tags)

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
                                                             :order 80)
                                                      (:name "🌄 ssdd"
                                                             :and (:tag "ssdd" :tag "tt")
                                                             :order 90)
                                                      (:name "🍰 work ssdd"
                                                             :and (:tag "ssdd" :tag "work")
                                                             :order 100)
                                                      (:name "👑 king line hit list"
                                                             :tag ("kl")
                                                             :order 110)
                                                      (:name "🌠 .*"
                                                             :order 999
                                                             :anything t)
                                                      ;; (:name "fun maximization"
                                                      ;;        :tag ("fun")
                                                      ;;        :order 40)
                                                      ;; (:name "wtf"
                                                      ;;        :tag ("wtf")
                                                      ;;        :order 520)
                                                      ;; (:name "innerspace"
                                                      ;;        :tag ("is" "h" "habit" "focus")
                                                      ;;        :order 600)
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
(setq org-habit-graph-column 40
      org-habit-preceding-days my/org-habit-preceding-days
      org-habit-show-all-today t
      org-habit-show-done-always-green t
      ;; glyphs:
      ;; │ | ⋮
      ;; ⊘ ∙ ∘ ⊚ ⋰ √ ∅ ∙ ● ◎ ◉ ╳ ╋ ┼ ╱ | ◌ ⌀ * ∙ ⋰ • ⌾ ⏼ ⊙
      org-habit-completed-glyph ?•
      org-habit-today-glyph ?│)

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
        ;; ("mt" "tv" entry "* 📺 %?\n%U"
        ;;  :jump-to-captured t
        ;;  :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
        ("mb" "book" entry "%(let* ((url (substring-no-properties (current-kill 0)))
                                      (details (org-books-get-details url)))
                                 (when details (apply #'org-books-format 1 details)))"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
        ("mt" "tv bookmark" entry
         ,(string-join '("* 📺 %? :bm:tv:\n"
                         "#+begin_src shell  :results output :dir "
                         "/ssh:wonko@enterprise.local:/mnt/trantor/media\n"
                         "  ls -t\n"
                         "#+end_src\n"))
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
        ;; ("mB" "book" entry "* 📚 %?\n%U"
        ;;  :jump-to-captured t
        ;;  :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
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
        ("ie" "third eye" entry "* 👁 [[roam:prying open my third eye]] :is:neop:3e:\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("ii" "innerspace   :is:" entry "* ☯ %?\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("if" "fam" entry "* ❤ %? :is:fam:\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("ih" "home" entry "* 🏡 [[roam:home]] %? :is:home:\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("iH" "Health" entry "* 🏥 [[roam:health]] %? :is:health:\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("iw" "weight" entry "* ⚖ [[roam:weight]] %? :is:health:\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("im" "metta" entry "* ❤ metta :is:3e:metta:\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("in" "neoplatonism" entry "* ☯ [[roam:neoplatonism]] :is:3e:neop:\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("ip" "piracy" entry "* ☠ %? :is:arr:\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("iv" "vipassana" entry "* ☯ [[roam:vipassana]] :is:3e:vip:\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("is" "sleep / dreams" entry "* 🌙 sleep / [[roam:dreams]] :is:3e:dreams:\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))
        ("it" "trees" entry "* 🌳 trees / [[roam:brocoli]] :is:junky:\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("☯ innerspace")))

        ("w" "witness the fitness")
        ("wb" "bouldering" entry ,(string-join '("* 🐒 [[roam:bouldering]] %? :wtf:cb:\n"
                                                 "%U\n"
                                                 "** ❤ with :is:\n"
                                                 "** 👷 projects\n"
                                                 "** 🔥 topped\n"
                                                 "** 🏥 [[roam:injuries]]\n"))
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("ws" "sport climbing" entry "* 🐒 [[roam:sport climbing]] %? :wtf:cb:\n%U\n** ❤ with :is:\n** 🔥 topped\n** 👷 projects\n** 🏥 [[roam:injuries]]\n"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("ww" "woody" entry ,(string-join '("* 📐 [[roam:woody]] :wtf:woody:\n"
                                            "%U\n"
                                            "** 🍚 [[roam:rice bucket]]\n"
                                            "- %?\n"
                                            "** 👷 projects\n"
                                            "** 🔥 topped\n"
                                            "** 🐒 [[roam:campusing]]\n"
                                            "** 🏥 [[roam:injuries]]"))
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
         ,(string-join '("* 🤸 [[roam:handstands]] :wtf:hs:\n"
                         "%U\n"
                         "** 🍚 [[roam:rice bucket]]\n"
                         "- %?\n"
                         "** 💪 [[roam:HSPU]]\n"
                         "** 💪 [[roam:press]]\n"
                         "** 🤸 session max hold:\n"))
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("wr" "rice bucket" entry "* 🍚 [[roam:rice bucket]] :wtf:cb:\n%U%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("wH" "Hiking" entry ,(string-join '("* 👣 [[roam:hiking]] :wtf:\n"
                                            "%U\n"))
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("wl" "leg day" entry ,(string-join '("* 💪 leg day :wtf:brutus:\n"
                                              "%U\n"
                                              "** 🍚 [[roam:rice bucket]]\n"
                                              "- %?\n"
                                              "** 💪 [[roam:cossak hip rotations]]\n"
                                              "** 💪 [[roam:pistol squats]]\n"))
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("wB" "brutus" entry "* 💪 %? :wtf:brutus:\n%U"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("wP" "breath work (Pneuma)" entry "* 🍃 [[roam:breath work]] :wtf:\n%U\n%?\n"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))
        ("wi" "injuries" entry "* 🏥 [[roam:injuries]] :wtf:health:inj:\n%U\n%?\n"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⛰ witness the fitness")))

        ("t" "tech")
        ("tg" "guix" entry "* 🐧 [[roam:guix]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("te" "emacs" entry "* 🐃 [[roam:emacs]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("tc" "clojure" entry "* ☯ [[roam:clojure]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("to" "ocaml" entry "* 🐫 [[roam:ocaml]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("tl" "linux" entry "* 🐧 [[roam:linux]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("tp" "physics" entry "* ⚛ [[roam:physics]]\n%U\n%?"
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("ts" "ssh session" entry
         ,(string-join '( "* ⚛ [[roam:ssh session]]\n"
                          "#+begin_src shell  :results value output :dir /ssh:wonko@rocinante.local:/junkyard\n"
                          "  %?\n"
                          "#+end_src\n"))
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("tS" "sudo ssh session" entry
         ,(string-join '( "* ⚛ [[roam:ssh session]]\n"
                          "#+begin_src shell  :results value output :dir /ssh:wonko@rocinante.local|sudo:rocinante.local:/mnt/trantor/media\n"
                          "  %?\n"
                          "#+end_src\n"))
         :jump-to-captured t
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("tM" "ssh session" entry
         ,(string-join '("* ⚛ [[roam:ssh session]]\n"
                         "#+begin_src shell  :results value output :dir /ssh:wonko@rocinante.local:/mnt/trantor/media\n"
                         "  export DISPLAY=:9\n"
                         "  . $GUIX_EXTRA_PROFILES/desktop/etc/profile\n"
                         "  %?\n"
                         "#+end_src\n"))
        :jump-to-captured t
        :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
        ("W" "work")
        ("j" "Journal" entry (file+datetree "~/org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")
        ("Wo" "🐫 ocsigen labs" entry "* 🐫 [[roam:ocsigen labs]] :work:ol:\n%U\n%?"
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🛠️ work"))
         :jump-to-captured t)
        ("Wi" "🐝 ivehte" entry "* 🐝 [[roam:ivehte]] :work:iv:\n%U\n%?"
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🛠️ work"))
         :jump-to-captured t)
        ("WR" "📅 RDV" entry ,(string-join  '("* 📅 %? :work:rdv:"
                                              "\n<%<%Y-%m-%d>>\n"))
         :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🛠️ work"))
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

;; https://github.com/kiwanami/emacs-calfw/issues/111
;; temporary fix:
(defun cfw:org-get-timerange (text)
  "Return a range object (begin end text).
If TEXT does not have a range, return nil."
  (let* ((dotime (cfw:org-tp text 'dotime)))
    (and (stringp dotime) (string-match org-ts-regexp dotime)
         (let* ((matches  (s-match-strings-all org-ts-regexp dotime))
                (start-date (nth 1 (car matches)))
                (end-date (nth 1 (nth 1 matches)))
                (extra (cfw:org-tp text 'extra)))
           (if (string-match "(\\([0-9]+\\)/\\([0-9]+\\)): " extra)
               (list (calendar-gregorian-from-absolute
                      (time-to-days
                       (org-read-date nil t start-date)))
                    (calendar-gregorian-from-absolute
                     (time-to-days
                      (org-read-date nil t end-date))) text))))))

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
   (css . t)
   (dot . t)
   (emacs-lisp . t)
   (gnuplot . t)
   (latex . t)
   ;; (matlab . t)
   (sass . t)
   (scheme . t)
   (sed . t)
   (shell . t)
   (sql . t)
   (ocaml . t)
   (org . t)))

(setq org-confirm-babel-evaluate nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; board

(require 'org-board)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; books

(require 'org-books) ;; never worked :(

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org commit / magit

(defun check-if-org ()
  (string= (magit-with-toplevel (pwd)) "Directory /data/org/"))

;; FIXME: fix this with git hook.
(defun my/org-commit-msg-setup ()
  (when (check-if-org)
    (emoji-search)))
(add-hook 'git-commit-setup-hook #'my/org-commit-msg-setup 100)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; svg-tag-mode

(require 'svg-tag-mode)
(require 'powerline) ;; for face

(defface my/tag-kl
  '((t :inherit epa-mark
      :background "#4e2e49"))
  "tag face"
  :group 'basic-bitches)

(defface my/tag-is
  '((t :inherit region
      :background "#4e2e49"))
  "tag face"
  :group 'basic-bitches)

(defface my/tag-wtf
  '((t :inherit helm-ff-socket
      :background "#4e2e49"))
  "tag face"
  :group 'basic-bitches)

(defface my/tag-tech
  '((t :inherit vundo-saved
      :background "#4e2e49"))
  "tag face"
  :group 'basic-bitches)

(defface my/tag-work
  '((t :inherit homoglyph
      :background "#4e2e49"))
  "tag face"
  :group 'basic-bitches)

(defface my/tag-lol
  '((t :inherit org-todo
      :background "#4e2e49"))
  "tag face"
  :group 'basic-bitches)

(defface my/tag-default
  '((t :inherit powerline-inactive2
      :background "#4e2e49"))
  "tag face"
  :group 'basic-bitches)

(defun my/mk-tag (tag face &optional &rest args)
  (apply #'svg-tag-make tag
         :face      face
         :weight    'bold
         :height    my/tag-height
         :font-size my/tag-font-size
         :radius    my/tag-radius
         :padding   my/tag-padding
         :margin    0
         args))

(setq my/svg-tag-mode-on t)
(defun my/toggle-svg-tag-mode ()
  (interactive)
  (setq my/svg-tag-mode-on (not my/svg-tag-mode-on)))


(defconst date-re "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}")
(defconst time-re "[0-9]\\{2\\}:[0-9]\\{2\\}")
(defconst day-re "[A-Za-z]\\{3\\}")
(defconst repeat-re "[0-9a-z/+.]+")
(defconst day-time-re (format "\\(%s\\)? ?\\(%s\\)?" day-re time-re))
(defconst day-time-repeat-re (format "\\(%s\\)? ?\\(%s\\)? ?\\(%s\\)?" day-re time-re repeat-re))

(setq svg-tag-tags
      `(("\\(:[0-9A-Za-z:_-]+:\\([0-9A-Za-z:_-]+:\\)*\\)" .
         ((lambda (tags)
            (when my/svg-tag-mode-on
              (let ((tag (first (split-string tags ":" t))))
                (cl-flet ((eq-tag (t2)
                                  (string-equal tag t2))
                          (mk-tag (tags f)
                                  (my/mk-tag tags f :beg 1 :end -1)))
                  (cond ((eq-tag "kl")
                         (mk-tag tags 'my/tag-kl))
                        ((some #'eq-tag '("work" "ivehte" "iv" "bs" "ol"))
                         (mk-tag tags 'my/tag-work))
                        ((some #'eq-tag '("is" "innerspace" "neop" "3e" "home"))
                         (mk-tag tags 'my/tag-is))
                        ((some #'eq-tag '("wtf" "cb" "woody" "hs"))
                         (mk-tag tags 'my/tag-wtf))
                        ((some #'eq-tag '("tech" "linux" "guix" "gx" "tf"))
                         (mk-tag tags 'my/tag-tech))
                        ((some #'eq-tag '("rdv" "ssdd" "tt" "lol"))
                         (mk-tag tags 'my/tag-lol))
                        (t (mk-tag tags 'my/tag-default)))))))))
        ;; inactive timestamps
        (,(format "\\(\\[%s\\]\\)" date-re) .
         ((lambda (tag)
            (my/mk-tag tag 'my/tag-kl :inverse t :beg 1 :end -1))))
        (,(format   "\\(\\[%s \\)%s\\]" date-re day-time-re) .
         ((lambda (date)
            (when my/svg-tag-mode-on
              (my/mk-tag date 'my/tag-kl :crop-right t :inverse t :beg 1)))))
        (,(format "\\[%s\\( %s\\]\\)" date-re day-time-re) .
          ((lambda (day-time)
            (when my/svg-tag-mode-on
              (my/mk-tag day-time 'my/tag-kl :crop-left t :end -1 :beg 0)))))
        ;; active timestamps
        (,(format "\\(<%s>\\)" date-re) .
         ((lambda (tag)
            (my/mk-tag tag 'my/tag-work :inverse t :beg 1 :end -1))))
        (,(format "\\(<%s \\)%s>" date-re day-time-repeat-re) .
         ((lambda (date)
            (when my/svg-tag-mode-on
              (my/mk-tag date 'my/tag-work :crop-right t :inverse t :beg 1)))))
        (,(format "<%s \\(%s>\\)" date-re day-time-repeat-re) .
         ((lambda (day-time)
            (when my/svg-tag-mode-on
              (my/mk-tag day-time 'my/tag-work :crop-left t :end -1 :beg 0)))))))


(defun svg-lib-tag (label &optional style &rest args)
  "Create an image displaying LABEL in a rounded box using given STYLE
and style elements ARGS."

  (let* ((default svg-lib-style-default)
         (style (if style (apply #'svg-lib-style nil style) default))
         (style (if args  (apply #'svg-lib-style style args) style))

         (foreground  (plist-get style :foreground))
         (background  (plist-get style :background))

         (crop-left   (plist-get style :crop-left))
         (crop-right  (plist-get style :crop-right))

         (alignment   (plist-get style :alignment))
         (stroke      (plist-get style :stroke))
         ;; (width       (plist-get style :width))
         (height      (plist-get style :height))
         (radius      (plist-get style :radius))
         ;; (scale       (plist-get style :scale))
         (margin      (plist-get style :margin))
         (padding     (plist-get style :padding))
         (font-size   (plist-get style :font-size))
         (font-family (plist-get style :font-family))
         (font-weight (plist-get style :font-weight))

         (txt-char-width  (window-font-width))
         (txt-char-height (window-font-height))
         (txt-char-height (if line-spacing
                              (+ txt-char-height line-spacing)
                            txt-char-height))
         (font-info       (font-info (format "%s-%d" font-family font-size)))
         (font-size       (aref font-info 2)) ;; redefine font-size
         (ascent          (aref font-info 8))
         (tag-char-width  (aref font-info 11))
         ;; (tag-char-height (aref font-info 3))
         ;; this is my diff:
         (tag-width       (/ (* (+ (length label) padding) txt-char-width) 2))
         (tag-height      (* txt-char-height height))

         (svg-width       (+ tag-width (* margin txt-char-width)))
         (svg-height      tag-height)
         (svg-ascent      (plist-get style :ascent))

         (tag-x  (* (- svg-width tag-width)  alignment))
         (text-x (+ tag-x (/ (- tag-width (* (length label) tag-char-width)) 2)))
         (text-y ascent)

         (tag-x      (if crop-left  (- tag-x     txt-char-width) tag-x))
         (tag-width  (if crop-left  (+ tag-width txt-char-width) tag-width))
         (text-x     (if crop-left  (- text-x (/ stroke 2)) text-x))
         (tag-width  (if crop-right (+ tag-width txt-char-width) tag-width))
         (text-x     (if crop-right (+ text-x (/ stroke 2)) text-x))

         (svg (svg-create svg-width svg-height)))

    (when (>= stroke 0.25)
      (svg-rectangle svg tag-x 0 tag-width tag-height
                     :fill foreground :rx radius))
    (svg-rectangle svg (+ tag-x (/ stroke 2.0)) (/ stroke 2.0)
                   (- tag-width stroke) (- tag-height stroke)
                   :fill background :rx (- radius (/ stroke 2.0)))
    (svg-text svg label
              :font-family font-family :font-weight font-weight  :font-size font-size
              :fill foreground :x text-x :y  text-y)
    (svg-lib--image svg :ascent svg-ascent)))

(add-hook 'org-mode-hook #'svg-tag-mode-on)

;; org-agenda overlay fuckery (hack):
(defun org-agenda-show-svg ()
  (let* ((case-fold-search nil)
         (keywords (mapcar #'svg-tag--build-keywords svg-tag--active-tags))
         (keyword (car keywords)))
    (while keyword
      (save-excursion
        (while (re-search-forward (nth 0 keyword) nil t)
          (overlay-put (make-overlay
                        (match-beginning 0) (match-end 0))
                       'display  (nth 3 (eval (nth 2 keyword)))) ))
      (pop keywords)
      (setq keyword (car keywords)))))
(add-hook 'org-agenda-finalize-hook #'org-agenda-show-svg)

(provide 'conf/org)
