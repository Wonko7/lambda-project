;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org

(use-package org
  :init
  ;; this needs to be set before starting org
  ;; the equivalent for evil-org-mode-map is in evil
  (general-evil-define-key '(insert normal) org-mode-map
    "C-RET"    #'+org/insert-item-below
    "S-RET"    #'+org/insert-item-above
    [C-return] #'+org/insert-item-below
    [S-return] #'+org/insert-item-above)
  ;; directories:
  (setq org-directory "/data/org/")
  (setq org-roam-directory (concat org-directory "here-be-dragons/"))
  (setq org-agenda-files (mapcar
                          (lambda (d)
                            (concat org-roam-directory d))
                          '("wip/" "work/" "wtf/" "the-road-so-far/")))
  (setq org-roam-dailies-directory "the-road-so-far")

  :config
  ;; FIXME review this:
  (setq
   org-catch-invisible-edits 'show-and-error
   ;; org-special-ctrl-a/e t
   org-insert-heading-respect-content t
   org-indent-mode t

   ;; org styling, hide markup etc.
   org-hide-emphasis-markers t
   org-pretty-entities t
   org-ellipsis "…")
  (defface +org-todo-active
    '((t (:inherit link :underline nil)))
    "active todo")
  (defface +org-todo-onhold
    '((t (:inherit default :foreground "brown")))
    "active todo")
  (setq org-startup-indented t
        ;; FIXME fix this with guix magic:
        org-plantuml-jar-path (shell-command-to-string "cat `which plantuml` 2>/dev/null  | 2>/dev/null sed -nre 's/.* ([^ ]+\.jar).*/\\1/p' | tr -d '\n'")
        org-startup-folded 'content
        org-todo-keywords
        '((sequence
           "NEXT(n/!)" ;; A task that recuring
           "TODO(t)"   ;; A task that needs doing & is ready to do
           "PROJ(p)"   ;; A project, which usually contains other tasks
           "GOGO(g/!)" ;; A task that is in progress
           "WAIT(w/!)" ;; Something external is holding up this task
           "HOLD(h/!)" ;; This task is paused/on hold because of me
           "ADD(a)"    ;; Add
           "FIX(f)"    ;; Fix
           "BUG(b)"    ;; Bug
           "|"
           "DONE(d/!)" ;; Task successfully completed
           "KILL(k)")  ;; Task was cancelled, aborted or is no longer applicable
          (sequence
           "[ ](T)" ;; A task that needs doing
           "[-](G)" ;; Task is in progress
           "[?](W)" ;; Task is being held up or paused
           "|"
           "[X](D)")) ;; Task was completed
        org-todo-keyword-faces
        '(("[-]"  . +org-todo-active)
          ("NEXT" . +org-todo-active)
          ("GOGO" . +org-todo-active)
          ("[?]"  . +org-todo-onhold)
          ("WAIT" . +org-todo-onhold)
          ("HOLD" . +org-todo-onhold)
          ("PROJ" . +org-todo-project))

        ;; agenda/cal dates:
        org-extend-today-until              3
        org-agenda-start-on-weekday         1
        calendar-week-start-day             1
        org-log-into-drawer                 t
        org-auto-align-tags                 t
        org-tags-column                     -80
        org-edit-timestamp-down-means-later t
        org-use-sub-superscripts            "{}")
  (general-evil-define-key '(insert) org-mode-map
    "TAB"   #'completion-at-point
    "C-l"   #'org-demote-subtree
    ;; "C-i"   #'org-roam-node-insert
    ;; "S-TAB" #'org-shiftab
    )

  (defun my/kill-src-block-at-point ()
    (interactive)
    (org-element-at-point))

  (general-evil-define-key '(normal) org-mode-map
    :prefix "RET"
    "o"     #'consult-outline
    "y"     #'my/kill-src-block-at-point
    "RET"   #'+org/dwim-at-point)

  (general-evil-define-key '(normal) org-mode-map
    "zD"    #'org-decrypt-entries
    "zq"    (lambda() (interactive) (org-show-branches-buffer))
    "C-k"   #'org-previous-visible-heading
    "C-j"   #'org-next-visible-heading
    "("     #'org-previous-visible-heading
    ")"     #'org-next-visible-heading
    "{"     #'evil-backward-paragraph
    "}"     #'evil-forward-paragraph
    "C-K"   #'org-move-subtree-up
    "C-J"   #'org-move-subtree-down
    "C-H"   #'org-promote-subtree
    "C-L"   #'org-demote-subtree)

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

  ;; html export
  (setq org-html-postamble nil)
  (setq org-footnote-section nil)
  (setq org-html-footnotes-section
        "<div id=\"footnotes\">
<!--
<h2 class=\"footnotes\">%s: </h2>
-->
<br><br>
<div id=\"text-footnotes\">
%s
</div>
</div>")


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
    (my/justify-right-org-tags)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-roam

(use-package org-roam
  :after org
  :commands (org-roam-node-open)
  :config
  (setq org-roam-file-exclude-regexp nil) ; default is data/, lol what a fuckface! that's exactly where my org data is!
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (setq org-roam-directory (concat org-directory "here-be-dragons/"))
  (setq org-roam-completion-everywhere t)
  (org-roam-db-autosync-mode))

(use-package org-roam-dailies
  :commands (org-roam-dailies-latest)
  :after org
  :config
  (defun org-roam-dailies--list-active-files (&rest extra-files)
    "List all files in `org-roam-dailies-directory', non recursively.
EXTRA-FILES can be used to append extra files to the list."
    (let ((dir (expand-file-name org-roam-dailies-directory org-roam-directory))
          (regexp (rx-to-string `(and "." (or ,@org-roam-file-extensions)))))
      (append (--remove (let ((file (file-name-nondirectory it)))
                          (when (or (auto-save-file-name-p file)
                                    (backup-file-name-p file)
                                    (string-match "^\\." file))
                            it))
                        (directory-files dir regexp))
              extra-files)))

  (defun org-roam-dailies-latest ()
    "Find latest dailies that is not in the future."
    (first (last (-filter (lambda (f)
                            (let ((fn    (file-name-base f))
                                  (ext   (file-name-extension f))
                                  (today (format-time-string "%Y-%m-%d")))
                              (and (string= "org" (file-name-extension f))
                                   (not (string< today fn)))))
                          (org-roam-dailies--list-active-files))))))

(use-package consult-org-roam
  :after org-roam
  :config
  (consult-org-roam-mode 1)) ;; meh.

(use-package org-roam-protocol
  :after org-roam)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; super agenda

(use-package org-agenda
  :after org
  :config
  (setq org-agenda-file-regexp "\\`\\\([^.].*\\.org\\\|[0-9]\\\{8\\\}\\\(\\.gpg\\\)?\\\)\\'"
        org-agenda-prefix-format (quote
                                  ((agenda . "%-21c%?-12t% s")
                                   (timeline . "% s")
                                   (todo . "%-21c")
                                   (tags . "%-12c")
                                   (search . "%-12c")))
        org-agenda-deadline-leaders (quote ("!D!: " "D%2d: " ""))
        org-agenda-scheduled-leaders (quote ("" "S%3d: "))
        org-agenda-compact-blocks t
        ;; agenda styling
        org-agenda-block-separator ?─
        ;; org-agenda-time-grid
        ;; '((daily today require-timed)
        ;;   (800 1000 1200 1400 1600 1800 2000)
        ;;   " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
        ;; org-agenda-current-time-string
        ;; "⭠ now ─────────────────────────────────────────────────"
        org-agenda-span 15
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
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t
        org-agenda-include-deadlines t
        org-agenda-tags-column       my/org-agenda-tags-column

        org-agenda-custom-commands '(("c" "Simple agenda view"
                                      ((agenda "")
                                       (alltodo "" )))
                                     ("z" "Super zaen view"
                                      ((agenda "" )
                                       (alltodo "=" ((org-agenda-overriding-header "")
                                                     (org-super-agenda-groups
                                                      '((:name "🤸 [wtf] focus"
                                                               :and (:tag "wtf" :tag "focus")
                                                               :order 80)
                                                        (:name "❤️ fam"
                                                               :and (:tag "ssdd" :tag "fam")
                                                               :order 90)
                                                        (:name "🌄 ssdd"
                                                               :and (:tag "ssdd" :tag "tt")
                                                               :order 90)
                                                        (:name "🐫 [ssdd][work] ocsigen labs"
                                                               :and (:tag "ssdd" :tag "work" :tag "ol")
                                                               :order 100)
                                                        (:name "☮️ [ssdd][work] ivehte"
                                                               :and (:tag "ssdd" :tag "work" :tag "iv")
                                                               :order 101)
                                                        (:name "☮️ [ssdd][work] kimesuis"
                                                               :and (:tag "ssdd" :tag "work" :tag "ks")
                                                               :order 102)
                                                        (:name "☮️ [ssdd][work] entreprise individuelle"
                                                               :and (:tag "ssdd" :tag "work" :tag "ei")
                                                               :order 103)
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
                                                        )))))))))

(use-package org-super-agenda
  :after org-agenda
  :demand t
  :config
  ;; fixes fucky binding on jk on an agenda header:
  ;; https://github.com/alphapapa/org-super-agenda/issues/50
  (setq org-super-agenda-header-separator "\n")
  (setq org-super-agenda-header-map (make-sparse-keymap))
  (org-super-agenda-mode))

(use-package org-habit
  :after org-agenda
  :config
  (setq org-habit-graph-column 40
        org-habit-preceding-days my/org-habit-preceding-days
        org-habit-show-all-today t
        org-habit-show-done-always-green t
        ;; glyphs:
        ;; │ | ⋮
        ;; ⊘ ∙ ∘ ⊚ ⋰ √ ∅ ∙ ● ◎ ◉ ╳ ╋ ┼ ╱ | ◌ ⌀ * ∙ ⋰ • ⌾ ⏼ ⊙
        org-habit-completed-glyph ?•
        org-habit-today-glyph ?│))

(use-package org-crypt
  :after org
  :config
  (setq epa-file-encrypt-to '("william@underage.wang")
        org-tags-exclude-from-inheritance (quote ("crypt"))
        org-crypt-disable-auto-save "encrypt"
        org-crypt-key "william@underage.wang")

  (org-crypt-use-before-save-magic))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; capture

(use-package org-capture
  :after org
  :config
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
        `(,(my/make-daily-capture "n" "🗒️ note" "* %?\n%U\n" t)

          ("g" "👣 go" plain "%?" :jump-to-captured t :if-new (file ,my/daily-file))

          ,(my/make-daily-capture "r" "📅 RDV"
                                  "* 📅 RDV %?\n<%<%Y-%m-%d>>\n" t)

          ("m" "📺 media")
          ;; ("mt" "tv" entry "* 📺 %?\n%U"
          ;;  :jump-to-captured t
          ;;  :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
          ("mb" "📚 book" entry "%(let* ((url (substring-no-properties (current-kill 0)))
                                      (details (org-books-get-details url)))
                                 (when details (apply #'org-books-format 1 details)))"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
          ("mt" "📺 tv bookmark" entry
           ,(string-join '("* 📺 %? :bm:tv:\n"
                           "#+begin_src shell :dir "
                           "/ssh:media@enterprise.local:/mnt/trantor/media " ;; FIXME: media-center.local?
                           ":results value output\n"
                           "  (mpv --slang=eng */*s01e01* &)\n"
                           "#+end_src\n"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
          ;; ("mB" "book" entry "* 📚 %?\n%U"
          ;;  :jump-to-captured t
          ;;  :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
          ("mm" "🎶 music (is so nice)" entry "* 🎵 %?\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))
          ("mp" "🎙 podcast" entry "* 🎙 %?\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("📼 media")))

          ("i" "🧘 innerspace")
          ("ib" "🧘 Buddhism" entry "* 🧘 [[roam:Buddhism]] :is:bud:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("ic" "☕ coffee" entry "* ☕ [[roam:coffee]]\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("ie" "👁 third eye" entry "* 👁 [[roam:prying open my third eye]] :is:neop:3e:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("ii" "🧘 innerspace   :is:" entry "* 🧘 %?\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("if" "❤ fam" entry "* ❤ %? :is:fam:\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("ih" "🏡 home" entry "* 🏡 [[roam:home]] %? :is:home:\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("iH" "🏥 Health" entry "* 🏥 [[roam:health]] %? :is:health:\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("iw" "⚖ weight" entry "* ⚖ [[roam:weight]] %? :is:health:\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("im" "❤ metta" entry "* ❤ metta :is:3e:metta:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("in" "🧘 neoplatonism" entry "* 🧘 [[roam:neoplatonism]] :is:3e:neop:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("ip" "☠ piracy" entry "* ☠ %? :is:arr:\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("iv" "🧘 vipassana" entry "* 🧘 [[roam:vipassana]] :is:3e:vip:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("is" "🌙 sleep / dreams" entry "* 🌙 sleep / [[roam:dreams]] :is:3e:dreams:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("it" "🌳 trees" entry "* 🌳 trees / [[roam:brocoli]] :is:junky:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))

          ("w" "🗿 witness the fitness")
          ("wb" "🐒 bouldering" entry ,(string-join '("* 🐒 [[roam:bouldering]] %? :wtf:cb:\n"
                                                      "%U\n"
                                                      "** ❤ with :is:\n"
                                                      "** 👷 projects\n"
                                                      "** 🔥 topped\n"
                                                      "** 🏥 [[roam:injuries]]\n"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🗿 witness the fitness")))
          ("ws" "🐒 sport climbing" entry "* 🐒 [[roam:sport climbing]] %? :wtf:cb:\n%U\n** ❤ with :is:\n** 🔥 topped\n** 👷 projects\n** 🏥 [[roam:injuries]]\n"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🗿 witness the fitness")))
          ("ww" "📐 woody" entry ,(string-join '("* 📐 [[roam:woody]] :wtf:woody:\n"
                                                 "%U\n"
                                                 "** 🍚 [[roam:rice bucket]]\n"
                                                 "- %?\n"
                                                 "** 👷 projects\n"
                                                 "** 🔥 topped\n"
                                                 "** 🐒 [[roam:campusing]]\n"
                                                 "** 🏥 [[roam:injuries]]"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🗿 witness the fitness")))
          ("wf" "🤘 fingerboard" entry ,(string-join '("* 🤘 [[roam:fingerboard]] :wtf:\n"
                                                       "%U\n"
                                                       "** 🍚 [[roam:rice bucket]]\n"
                                                       "- %?\n"
                                                       "** 💪 [[roam:pull-ups]]\n"
                                                       "** 🐒 [[roam:campusing]]\n"
                                                       "** 🤘 [[roam:deadhangs]]"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🗿 witness the fitness")))
          ("wh" "🤸 handstands" entry
           ,(string-join '("* 🤸 [[roam:handstands]] :wtf:hs:\n"
                           "%U\n"
                           "** 🍚 [[roam:rice bucket]]\n"
                           "- %?\n"
                           "** 💪 [[roam:HSPU]]\n"
                           "** 💪 [[roam:press]]\n"
                           "** 🤸 session max hold:\n"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🗿 witness the fitness")))
          ("wr" "🍚 rice bucket" entry "* 🍚 [[roam:rice bucket]] :wtf:cb:\n%U%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🗿 witness the fitness")))
          ("wH" "👣 Hiking" entry ,(string-join '("* 👣 [[roam:hiking]] :wtf:\n"
                                                  "%U\n"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🗿 witness the fitness")))
          ("wl" "💪 leg day" entry ,(string-join '("* 💪 leg day :wtf:brutus:\n"
                                                   "%U\n"
                                                   "** 🍚 [[roam:rice bucket]]\n"
                                                   "- %?\n"
                                                   "** 💪 [[roam:cossak hip rotations]]\n"
                                                   "** 💪 [[roam:pistol squats]]\n"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🗿 witness the fitness")))
          ("wB" "💪 brutus" entry "* 💪 %? :wtf:brutus:\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🗿 witness the fitness")))
          ("wP" "🍃 breath work (Pneuma)" entry "* 🍃 [[roam:breath work]] :wtf:\n%U\n%?\n"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🗿 witness the fitness")))
          ("wi" "🏥 injuries" entry "* 🏥 [[roam:injuries]] :wtf:health:inj:\n%U\n%?\n"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🗿 witness the fitness")))

          ("t" "🚀 tech")
          ("tg" "🐧 guix" entry "* 🐧 [[roam:guix]] :guix:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🚀 tech")))
          ("te" "🐃 emacs" entry "* 🐃 [[roam:emacs]] :emacs:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🚀 tech")))
          ("tc" "☯ clojure" entry "* ☯ [[roam:clojure]]\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🚀 tech")))
          ("to" "🐫 ocaml" entry "* 🐫 [[roam:ocaml]] :ocaml:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🚀 tech")))
          ("tl" "🐧 linux" entry "* 🐧 [[roam:linux]] :linux:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🚀 tech")))
          ("tp" "⚛ physics" entry "* ⚛ [[roam:physics]] :sci:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🚀 tech")))
          ;; ("ts" "ssh session" entry
          ;;  ,(string-join '( "* ⚛ [[roam:ssh session]]\n"
          ;;                   "#+begin_src shell  :results value output :dir /ssh:wonko@rocinante.local:/junkyard\n"
          ;;                   "  %?\n"
          ;;                   "#+end_src\n"))
          ;;  :jump-to-captured t
          ;;  :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
          ;; ("tS" "sudo ssh session" entry
          ;;  ,(string-join '( "* ⚛ [[roam:ssh session]]\n"
          ;;                   "#+begin_src shell  :results value output :dir /ssh:wonko@rocinante.local|sudo:rocinante.local:/mnt/trantor/media\n"
          ;;                   "  %?\n"
          ;;                   "#+end_src\n"))
          ;;  :jump-to-captured t
          ;;  :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
          ;; ("tM" "ssh session" entry
          ;;  ,(string-join '("* ⚛ [[roam:ssh session]]\n"
          ;;                  "#+begin_src shell  :results value output :dir /ssh:wonko@rocinante.local:/mnt/trantor/media\n"
          ;;                  "  export DISPLAY=:9\n"
          ;;                  "  . $GUIX_EXTRA_PROFILES/desktop/etc/profile\n"
          ;;                  "  %?\n"
          ;;                  "#+end_src\n"))
          ;;  :jump-to-captured t
          ;;  :if-new (file+head+olp ,my/daily-file ,my/daily-header ("⚛ tech")))
          ("W" "⚒️ work")
          ("We" "👾 entreprise individuelle" entry
           "* 👾 [[roam:entreprise individuelle]] :work:ei:\n%U\n%?"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🛠️ work"))
           :jump-to-captured t)
          ("Wo" "🐫 ocsigen labs" entry "* 🐫 [[roam:ocsigen labs]] :work:ol:\n%U\n%?"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🛠️ work"))
           :jump-to-captured t)
          ("Wi" "🐝 ivehte" entry "* 🐝 [[roam:ivehte]] :work:iv:\n%U\n%?"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🛠️ work"))
           :jump-to-captured t)
          ("WR" "📅 RDV" entry ,(string-join  '("* 📅 %? :work:rdv:"
                                                "\n<%<%Y-%m-%d>>\n"))
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🛠️ work"))
           :jump-to-captured t))))

(use-package calfw-org
  :config
  (setq cfw:org-agenda-schedule-args '(:timestamp))
  (define-key cfw:calendar-mode-map (kbd "<SPC>") nil)
  (general-evil-define-key '(normal insert emacs motion) cfw:calendar-mode-map
    "SPC" evil-leader--default-map)
  (define-key cfw:calendar-mode-map (kbd "<SPC>") evil-leader--default-map))

;; https://github.com/kiwanami/emacs-calfw/issues/111
;; https://github.com/kiwanami/emacs-calfw/pull/134/files
;; temporary fix:
;; (defun cfw:org-get-timerange (text)
;;   "Return a range object (begin end text).
;; If TEXT does not have a range, return nil."
;;   (let* ((dotime (cfw:org-tp text 'dotime)))
;;     (and (stringp dotime) (string-match org-ts-regexp dotime)
;;          (let* ((matches  (s-match-strings-all org-ts-regexp dotime))
;;                 (start-date (nth 1 (car matches)))
;;                 (end-date (nth 1 (nth 1 matches)))
;;                 (extra (cfw:org-tp text 'extra)))
;;            (if (string-match "(\\([0-9]+\\)/\\([0-9]+\\)): " extra)
;;                (list (calendar-gregorian-from-absolute
;;                       (time-to-days
;;                        (org-read-date nil t start-date)))
;;                      (calendar-gregorian-from-absolute
;;                       (time-to-days
;;                        (org-read-date nil t end-date))) text))))))

(use-package org-web-tools)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-ql

(use-package org-ql)
(use-package org-ql-search
  :after org-ql
  :config

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

  (defun my/recent-dailies ()
    (org-ql-search-directories-files
     :directories (list (concat org-roam-directory "the-road-so-far"))))

  (setq org-ql-views
        (list
         (cons "ts-active"
               (list :buffers-files #'my/recent-dailies
                     :query '(ts-active :from "2024-06-12")
                     :sort #'my/sort-by-filename-date))
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
                     :sort #'my/sort-by-filename-date)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; board

(use-package org-board)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; books

(use-package org-books)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org appear

;; see: https://github.com/awth13/org-appear/issues/58

;; (use-package org-appear
;;   :defer t
;;   :after org
;;   :hook
;;   (org-mode-hook . #'org-appear-mode)
;;   :config
;;   (progn
;;     (setq org-appear-autokeywords t)
;;     (setq org-appear-autolinks t)))

(provide 'conf/org)
