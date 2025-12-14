;;; org-conf.el  -*- lexical-binding: t; -*-

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

  :custom
  (org-startup-indented t)
  ;; FIXME fix this with guix magic:
  (org-plantuml-jar-path (shell-command-to-string "cat `which plantuml` 2>/dev/null  | 2>/dev/null sed -nre 's/.* ([^ ]+\.jar).*/\\1/p' | tr -d '\n'"))
  (org-startup-folded 'content)
  (org-todo-keywords '((sequence
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
                        "[X](D)"))) ;; Task was completed
  (org-todo-keyword-faces '(("[-]"  . +org-todo-active)
                            ("NEXT" . +org-todo-active)
                            ("GOGO" . +org-todo-active)
                            ("[?]"  . +org-todo-onhold)
                            ("WAIT" . +org-todo-onhold)
                            ("HOLD" . +org-todo-onhold)
                            ("PROJ" . +org-todo-project)))

  ;; agenda/cal dates:
  (org-extend-today-until              3)
  (org-agenda-start-on-weekday         1)
  (calendar-week-start-day             1)
  (org-log-into-drawer                 t)
  (org-auto-align-tags                 t)
  (org-tags-column                     -80)
  (org-edit-timestamp-down-means-later t)
  (org-use-sub-superscripts            "{}")

  ;; babel
  (org-confirm-babel-evaluate nil)

  ;; behaviour
  (org-catch-invisible-edits 'show-and-error)
  (org-insert-heading-respect-content t)
  (org-indent-mode t)
  ;; also see org-crypt. btw, this works but needs roam db rebuild.
  (org-use-tag-inheritance '("is" "priv" ;; pub?
                             "wtf" "kl" "focus"
                             "ssdd" "fam" "tt"
                             "ei" "ol" "iv"))
  ;; org-special-ctrl-a/e t
  ;; org styling, hide markup etc.
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-ellipsis "…")

  ;; html export
  (org-html-postamble nil)
  (org-footnote-section nil)
  (org-html-footnotes-section "<div id=\"footnotes\">
<!--
<h2 class=\"footnotes\">%s: </h2>
-->
<br><br>
<div id=\"text-footnotes\">
%s
</div>
</div>")

  :config
  (defun my/align-org-tags ()
    (interactive)
    (when org-auto-align-tags
      (org-align-tags t)))

  (add-hook 'org-mode-hook
            (lambda ()
              (add-hook 'before-save-hook #'my/align-org-tags nil 'local)))

  (defface +org-todo-active
    '((t (:inherit link :underline nil)))
    "active todo")

  (defface +org-todo-onhold
    '((t (:inherit default :foreground "brown")))
    "active todo")

  (set-face-attribute 'org-tag nil :foreground "#EB64B9")
  (set-face-attribute 'org-tag nil :box t)

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
    "at"    #'my/align-org-tags
    "aT"    #'org-table-align
    "l"     #'org-toggle-link-display
    "zL"    #'org-toggle-link-display
    "o"     #'consult-outline
    "y"     #'my/kill-src-block-at-point
    "RET"   #'+org/dwim-at-point
    ;; this should be in org-roam but the "RET" prefix key overlap doesn't work
    "j"     #'org-roam-dailies-goto-next-note
    "k"     #'org-roam-dailies-goto-previous-note)

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
     (org . t))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-roam

(use-package org-roam
  :after org
  :commands (org-roam-node-open)
  :custom
  (org-roam-file-exclude-regexp nil) ; default is data/, lol what a fuckface! that's exactly where my org data is!
  (org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-completion-everywhere t)
  :config
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
    (cl-first (last (-filter (lambda (f)
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
  :custom
  (org-agenda-window-setup 'current-window)
  (org-agenda-file-regexp "\\`\\\([^.].*\\.org\\\|[0-9]\\\{8\\\}\\\(\\.gpg\\\)?\\\)\\'")
  (org-agenda-prefix-format (quote
                             ((agenda . "  %-21c%?-12t% s")
                              (timeline . "% s")
                              (todo . "  %-21c")
                              (tags . "%-12c")
                              (search . "%-12c"))))
  (org-agenda-deadline-leaders (quote ("!D!: " "D%2d: " "")))
  (org-agenda-scheduled-leaders (quote ("" "S%3d: ")))
  (org-agenda-compact-blocks t)
  ;; agenda styling
  (org-agenda-block-separator ?─)
  (org-agenda-span 15)
  (org-agenda-start-with-log-mode t)
  (org-agenda-skip-scheduled-if-done t)
  (org-agenda-skip-deadline-if-done t)
  (org-agenda-include-deadlines t)
  (org-agenda-tags-column my/org-agenda-tags-column)
  (org-agenda-remove-tags t)
  (org-super-agenda-header-prefix "")
  (org-agenda-custom-commands '(("c" "Simple agenda view"
                                 ((agenda "")
                                  (alltodo "" )))
                                ("z" "Super zaen view"
                                 ((agenda "" )
                                  (alltodo
                                   "="
                                   ((org-agenda-overriding-header "")
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
                                              :and (:tag "ssdd" :tag "ol")
                                              :order 100)
                                       (:name "🐝️ [ssdd][work] ivehte"
                                              :and (:tag "ssdd" :tag "iv")
                                              :order 101)
                                       (:name "👾️ [ssdd][work] entreprise individuelle"
                                              :and (:tag "ssdd" :tag "ei")
                                              :order 103)
                                       (:name "👑 king line hit list"
                                              :tag ("kl")
                                              :order 110)
                                       (:name "🌠 .*"
                                              :order 999
                                              :anything t))))))))))

(use-package holidays
  :after org-agenda
  :demand t
  :custom
  (calendar-holidays
   `((holiday-fixed 1 1 "🎆 Jour de l'an")
     (holiday-fixed 1 6 "👑 Épiphanie")
     (holiday-fixed 2 2 "🥞 Chandeleur")
     (holiday-fixed 2 14 "💜 Saint Valentin")
     (holiday-fixed 5 1 "📅 Fête du travail")
     (holiday-fixed 5 8 "🕊️ Commémoration de la capitulation de l'Allemagne en 1945")
     (holiday-fixed 6 21 "🎶 Fête de la musique")
     (holiday-fixed 7 14 "🎆 Fête nationale - Prise de la Bastille")
     (holiday-fixed 8 15 "👼 Assomption (Religieux)")
     (holiday-fixed 9 11 "✈️ jet fuel can't melt steel beams")
     (holiday-fixed 10 31 "🎃️ Halloween")
     (holiday-fixed 11 11 "🕊️ Armistice de 1918")
     (holiday-fixed 11 1 "👼 Toussaint")
     (holiday-fixed 11 2 "💀 Commémoration des fidèles défunts")
     (holiday-fixed 12 25 "🎄 Noël")
     ;; fetes a date variable
     (holiday-easter-etc 0 "🧟 Pâques")
     (holiday-easter-etc 1 "🧟 Lundi de Pâques")
     (holiday-easter-etc 39 "👼 Ascension")
     (holiday-easter-etc 49 "👻 Pentecôte")
     (holiday-easter-etc -47 "🤡 Mardi gras")
     (if (not (equal (calendar-nth-named-day -1 0 5 displayed-year)
                     (caar (holiday-easter-etc 49))))
         (holiday-float 5 0 -1 "👒 Fête des mères")
       (holiday-float 6 0 1 "👒 Fête des mères"))
     ;; dernier dimanche de mai ou premier dimanche de juin si c'est le
     ;; même jour que la pentecôte TODO
     (holiday-float 6 0 3 "🎩 Fête des pères"))) ;; troisième dimanche de juin
  (diary-show-holidays-flag t)
  (org-agenda-include-diary t)

  :config
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; moon phases: https://topikettunen.com/blog/emacs-org-agenda-lunar-phases/

  (require 'cl-lib)

  ;; Pass current day to `org-lunar-phases',
  ;; which is annoyingly in a stupid format, (MM DD YYYY).
  (with-no-warnings (defvar date))
  (defun my/org-lunar-phases ()
    "Show lunar phase in Agenda buffer."
    (require 'lunar)
    (let* ((phase-list (lunar-phase-list (nth 0 date) (nth 2 date)))
           (phase (cl-find-if (lambda (phase) (equal (car phase) date))
                              phase-list))
           (lunar-phase-names '("🌑 New Moon"
                                "🌓 First Quarter Moon"
                                "🌕 Full Moon"
                                "🌗 Last Quarter Moon")))
      (when phase
        ;; Return the phase to the agenda file.
        (setq ret (concat (lunar-phase-name (nth 2 phase)))))))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; s/diary/holiday category in agenda:

  (defun my/change-diary-category (entries)
    "change category from Diary to holiday."
    (mapcar
     (lambda (entry)
       (let ((cat "📜 Holiday"))
         (store-substring entry 2 cat)
         ;; remove one space between category and item because emoji = 2 spaces
         (let ((len1 (- (length entry) 1))
               (i    (+ 2 (length cat))))
           (while (< i len1)
             (aset entry i (aref entry (+ 1 i)))
             (setq i (+ 1 i)))
           (aset entry len1 ? )
           entry)))
     entries))

  (advice-add #'org-get-entries-from-diary
              :filter-return
              #'my/change-diary-category))

(use-package org-super-agenda
  :after org-agenda
  :demand t
  :custom
  (org-super-agenda-header-separator "\n")
  :config
  (org-super-agenda-mode)
  ;; https://github.com/alphapapa/org-super-agenda/issues/50
  (setq org-super-agenda-header-map (make-sparse-keymap)))

(use-package org-habit
  :after org-agenda
  :custom
  (org-habit-graph-column 40)
  (org-habit-preceding-days my/org-habit-preceding-days)
  (org-habit-show-all-today t)
  (org-habit-show-done-always-green t)
  ;; glyphs:
  ;; │ | ⋮
  ;; ⊘ ∙ ∘ ⊚ ⋰ √ ∅ ∙ ● ◎ ◉ ╳ ╋ ┼ ╱ | ◌ ⌀ * ∙ ⋰ • ⌾ ⏼ ⊙ ○
  ;; ┋┇ ;; ┃ ;; /;;⋮ ;; | ;; ?│
  ;; ▦ ;; ◼ ;; ▪ ;; ?√ ;; ?◉ ;; ⊘ ;; ◉ ;; ?•
  ;; □ ;; □ ;; ◌ ;; ?○
  ;; org-habit-today-glyph ?┋
  ;; (org-habit-clear-glyph ?○)
  (org-habit-completed-glyph ?●)
  (org-habit-today-glyph ?│)

  :config
  (setq org-habit-clear-glyph ?○) ;; because added by me
  ;; red boys:
  (set-face-attribute 'org-habit-overdue-face nil :foreground "red")
  (set-face-attribute 'org-habit-overdue-face nil :background 'unspecified)
  (set-face-attribute 'org-habit-overdue-future-face nil :foreground "red")
  (set-face-attribute 'org-habit-overdue-future-face nil :background 'unspecified)

  ;; golden boys:
  (set-face-attribute 'org-habit-alert-future-face nil :background 'unspecified)
  (set-face-attribute 'org-habit-alert-future-face nil :foreground "gold")
  (set-face-attribute 'org-habit-alert-face nil :background 'unspecified)
  (set-face-attribute 'org-habit-alert-face nil :foreground "gold")

  ;; grey boys: ;; grey:#4E415C  dvio: #6b4d76 vio: #B381C5
  (set-face-attribute 'org-habit-clear-future-face nil :foreground "steel blue")
  (set-face-attribute 'org-habit-clear-future-face nil :background 'unspecified)
  (set-face-attribute 'org-habit-clear-face nil :foreground "steel blue")
  (set-face-attribute 'org-habit-clear-face nil :background 'unspecified)

  ;; pink boys: #EB64B9 pink  cyan: #74DFC4
  (set-face-attribute 'org-habit-ready-future-face nil :foreground "#EB64B9") ;; forestgreen
  (set-face-attribute 'org-habit-ready-face nil :foreground "#EB64B9")
  (set-face-attribute 'org-habit-ready-future-face nil :background 'unspecified)
  (set-face-attribute 'org-habit-ready-face nil :background 'unspecified)

  ;; add clear glyphs:
  (defun org-habit-build-graph (habit starting current ending)
    "Build a graph for the given HABIT, from STARTING to ENDING.
CURRENT gives the current time between STARTING and ENDING, for
the purpose of drawing the graph.  It need not be the actual
current time."
    (let* ((all-done-dates (sort (org-habit-done-dates habit) #'<))
	   (done-dates all-done-dates)
	   (scheduled (org-habit-scheduled habit))
	   (s-repeat (org-habit-scheduled-repeat habit))
	   (start (time-to-days starting))
	   (now (time-to-days current))
	   (end (time-to-days ending))
	   (graph (make-string (1+ (- end start)) ?\s))
	   (index 0)
	   last-done-date)
      (while (and done-dates (< (car done-dates) start))
        (setq last-done-date (car done-dates)
	      done-dates (cdr done-dates)))
      (while (< start end)
        (let* ((in-the-past-p (< start now))
	       (todayp (= start now))
	       (donep (and done-dates (= start (car done-dates))))
	       (faces
	        (if (and in-the-past-p
		         (not last-done-date)
		         (not (< scheduled now)))
		    (if (and all-done-dates (= (car all-done-dates) start))
		        ;; This is the very first done of this habit.
		        '(org-habit-ready-face . org-habit-ready-future-face)
		      '(org-habit-clear-face . org-habit-clear-future-face))
		  (org-habit-get-faces
		   habit start
		   (and in-the-past-p
		        last-done-date
		        ;; Compute scheduled time for habit at the time
		        ;; START was current.
		        (let ((type (org-habit-repeat-type habit)))
			  (cond
			   ;; At the last done date, use current
			   ;; scheduling in all cases.
			   ((null done-dates) scheduled)
			   ((equal type ".+") (+ last-done-date s-repeat))
			   ((equal type "+")
			    ;; Since LAST-DONE-DATE, each done mark
			    ;; shifted scheduled date by S-REPEAT.
			    (- scheduled (* (length done-dates) s-repeat)))
			   (t
			    ;; Compute the scheduled time after the
			    ;; first repeat.  This is the closest time
			    ;; past FIRST-DONE which can reach SCHEDULED
			    ;; by a number of S-REPEAT hops.
			    ;;
			    ;; Then, play TODO state change history from
			    ;; the beginning in order to find current
			    ;; scheduled time.
			    (let* ((first-done (car all-done-dates))
				   (s (let ((shift (mod (- scheduled first-done)
						        s-repeat)))
				        (+ (if (= shift 0) s-repeat shift)
					   first-done))))
			      (if (= first-done last-done-date) s
			        (catch :exit
				  (dolist (done (cdr all-done-dates) s)
				    ;; Each repeat shifts S by any
				    ;; number of S-REPEAT hops it takes
				    ;; to get past DONE, with a minimum
				    ;; of one hop.
				    (cl-incf s (* (1+ (/ (max (- done s) 0)
						         s-repeat))
						  s-repeat))
				    (when (= done last-done-date)
				      (throw :exit s))))))))))
		   donep)))
	       markedp face)
	  (cond
	   (donep
	    (aset graph index org-habit-completed-glyph)
	    (setq markedp t)
	    (while (and done-dates (= start (car done-dates)))
	      (setq last-done-date (car done-dates))
	      (setq done-dates (cdr done-dates))))
	   (todayp
	    (aset graph index org-habit-today-glyph))
           ;; ⚠️ Hi there future me: tout ça pour ça:
           (t (aset graph index org-habit-clear-glyph)))
	  (setq face (if (or in-the-past-p todayp)
		         (car faces)
		       (cdr faces)))
	  (when (and in-the-past-p
		     (not (eq face 'org-habit-overdue-face))
		     (not markedp))
	    (setq face (cdr faces)))
	  (put-text-property index (1+ index) 'face face graph)
	  (put-text-property index (1+ index)
			     'help-echo
			     (concat (format-time-string
				      (org-time-stamp-format)
				      (time-add starting (days-to-time (- start (time-to-days starting)))))
				     (if donep " DONE" ""))
			     graph))
        (setq start (1+ start)
	      index (1+ index)))
      graph)))

(use-package appt
  :after org-agenda
  :demand t
  :hook (system/wake-up-hook . my/idle-org-agenda-to-appt)
  :custom
  (appt-message-warning-time 12)
  (appt-display-interval 3)
  (appt-audible nil)
  (appt-disp-window-function #'my/appt-notify)
  :config
  (appt-activate)
  (defun my/idle-org-agenda-to-appt ()
    (run-with-idle-timer 10 nil #'org-agenda-to-appt))
  (run-at-time nil 3600 #'my/idle-org-agenda-to-appt))

(use-package notifications
  :commands (my/appt-notify)
  :after appt
  :config
  (defun my/appt-notify (remaining new-time msg)
    (if (string= remaining "0")
        (notifications-notify :title msg
                              :body "\nTADADADAAAAA"
                              :urgency 'normal)
      (notifications-notify :title msg
                            :body (format "\nTHE FINAL COUNTDOWN: %sm" remaining)
                            :timeout (* appt-display-interval 60 1000)
                            :urgency 'normal))))

(use-package org-crypt
  :after org
  :demand t
  :custom
  (epa-file-encrypt-to '("william@underage.wang"))
  (org-tags-exclude-from-inheritance (quote ("crypt")))
  (org-crypt-disable-auto-save "encrypt")
  (org-crypt-key "william@underage.wang")
  :config
  (org-crypt-use-before-save-magic))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; capture

(use-package org-capture
  :after org
  :hook (org-capture-mode-hook . (lambda () (evil-insert 0)))
  :config
  ;; firefox integration
  (defun transform-square-brackets-to-round-ones (string-to-transform)
    "Transforms [ into ( and ] into ), other chars left unchanged."
    (concat
     (mapcar #'(lambda (c) (if (equal c ?\[) ?\( (if (equal c ?\]) ?\) c))) string-to-transform)))

  (defvar my/daily-header "#+title: %<%Y-%m-%d>\n#+category: 📅 %<%Y-%m-%d>")
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
           ,(string-join '("* [[%:link][%(transform-square-brackets-to-round-ones"
                           " \"%:description\")]]\n"
                           "%U\n"
                           "#+BEGIN_QUOTE\n"
                           "%i\n"
                           "#+END_QUOTE"))
           :immediate-finish t)
          ("QL" "Protocol Link direct" entry
           (file+olp "here-be-dragons/20210915144652-browsing_inbox.org" "browsing" "inbox")
           ,(string-join '("* [[%:link][%(transform-square-brackets-to-round-ones"
                           " \"%:description\")]]\n"
                           "%U"))
           :immediate-finish t))

        org-roam-dailies-capture-templates
        `(,(my/make-daily-capture "n" "🗒️ note" "* %?\n%U\n" t)

          ("g" "👣 go" plain "%?" :jump-to-captured t :if-new (file ,my/daily-file))

          ,(my/make-daily-capture "r" "📅 RDV"
                                  "* 📅 RDV %? :rdv:\n<%<%Y-%m-%d>>\n" t)

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
                           "/ssh:media@of-course-i-still-love-you.local:/mnt/trantor/media "
                           ":results value output\n"
                           "  (vlc */*s01e01* &)\n"
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
          ("is" "🌙 sleep / dreams" entry
           "* 🌙 sleep / [[roam:dreams]] :is:3e:dreams:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("ie" "👁 third eye" entry
           "* 👁 [[roam:prying open my third eye]] :is:neop:3e:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("ii" "🧘 innerspace" entry "* 🧘 %?\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("if" "❤ fam" entry "* ❤ %? :is:fam:\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("ir" "🚀 rocket go brrr" entry
           "* 🚀 [[roam:rocket go brrr]] :is:fam:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("iH" "🏥 Health" entry "* 🏥 [[roam:health]] %? :is:health:\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("iw" "⚖ weight" entry "* ⚖ [[roam:weight]] :is:health:\n%U%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))

          ("ic" "☕ coffee" entry "* ☕ [[roam:coffee]]\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("iC" "🚲 biCycle" entry "* 🚲 %?\n%U\n"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("ih" "🏡 home" entry "* 🏡 [[roam:home]] %? :is:home:\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("ip" "☠ piracy" entry "* ☠ %? :is:arr:\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))
          ("iB" "🐗 Boring" entry "* 🐗 %?\n%U\n"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🧘 innerspace")))

          ("w" "🦁 witness the fitness")
          ("wb" "🐒 bouldering" entry
           ,(string-join '("* 🐒 [[roam:bouldering]] %? :wtf:cb:\n"
                           "%U\n"
                           "** ❤ with :is:\n"
                           "** 👷 projects\n"
                           "** 🔥 topped\n"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))
          ("ws" "🐒 sport climbing" entry
           ,(string-join '("* 🐒 [[roam:sport climbing]] %? :wtf:cb:\n"
                           "%U\n"
                           "** ❤ with :is:\n"
                           "** 🔥 topped\n"
                           "** 👷 projects\n"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))
          ("ww" "📐 woody" entry
           ,(string-join '("* 📐 [[roam:woody]] :wtf:woody:\n"
                           "%U\n"
                           "** 👷 projects\n"
                           "** 🔥 topped\n"
                           "*** %?\n"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))
          ("wf" "🤘 FDP block deadhangs" entry
           ,(string-join '("* 🤘 [[roam:FDP pull blocks]] "
                           "[[roam:deadhangs]] :wtf:cb:\n"
                           "%U\n"
                           "- %?"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))
          ("wF" "🤘 fingerboard" entry
           ,(string-join '("* 🤘 [[roam:fingerboard]] :wtf:\n"
                           "%U\n"
                           "** 🤘 [[roam:deadhangs]]\n"
                           "- %?"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))
          ("wh" "🤸 handstands" entry
           ,(string-join '("* 🤸 [[roam:handstands]] :wtf:hs:\n"
                           "%U\n"
                           "** 🍚 [[roam:rice bucket]]\n"
                           "- 1x30x / 2 rnd sqz\n"
                           "** 🤸 straddle [[roam:press]]\n"
                           "- %?\n"
                           "** 🤸 [[roam:press]]\n"
                           "** 🤸 session max hold:\n"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))
          ("wr" "🍚 rice bucket" entry
           ,(string-join '("* 🍚 [[roam:rice bucket]] :wtf:cb:\n"
                           "%U\n"
                           "- 1x30x / 2 rnd sqz%?"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))
          ("wR" "👣 Running" entry
           ,(string-join '("* 👣 [[roam:running]] :wtf:\n"
                           "%U\n%?"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))
          ("wH" "👣 Hiking" entry
           ,(string-join '("* 👣 [[roam:hiking]] :wtf:\n"
                           "%U\n%?"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))
          ("wl" "💪 leg day" entry
           ,(string-join '("* 💪 leg day :wtf:brutus:\n"
                           "%U\n"
                           "** 🍚 [[roam:rice bucket]]\n"
                           "- %?\n"
                           "** 💪 [[roam:cossak hip rotations]]\n"
                           "** 💪 [[roam:pistol squats]]\n"))
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))
          ("wB" "💪 brutus" entry "* 💪 %? :wtf:brutus:\n%U"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))
          ("wP" "🍃 breath work (Pneuma)" entry
           "* 🍃 [[roam:breath work]] :wtf:\n%U\n%?\n"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))
          ("wi" "🏥 injuries" entry
           "* 🏥 [[roam:injuries]] :wtf:health:inj:\n%U\n%?\n"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🦁 witness the fitness")))

          ("t" "🚀 tech")
          ("tg" "🐧 guix" entry
           "* 🐧 [[roam:guix]] :guix:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🚀 tech")))
          ("te" "🐃 emacs" entry
           "* 🐃 [[roam:emacs]] :emacs:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🚀 tech")))
          ("tc" "☯ clojure" entry
           "* ☯ [[roam:clojure]]\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🚀 tech")))
          ("to" "🐫 ocaml" entry
           "* 🐫 [[roam:ocaml]] :ocaml:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🚀 tech")))
          ("tl" "🐧 linux" entry
           "* 🐧 [[roam:linux]] :linux:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🚀 tech")))
          ("tp" "⚛ physics" entry
           "* ⚛ [[roam:physics]] :sci:\n%U\n%?"
           :jump-to-captured t
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🚀 tech")))
          ("W" "⚒️ work")
          ("We" "👾 entreprise individuelle" entry
           "* 👾 [[roam:entreprise individuelle]] :work:ei:\n%U\n%?"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🛠️ work"))
           :jump-to-captured t)
          ("Wo" "🐫 ocsigen labs" entry
           "* 🐫 [[roam:ocsigen labs]] :work:ol:\n%U\n%?"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🛠️ work"))
           :jump-to-captured t)
          ("Wi" "🐝 ivehte" entry
           "* 🐝 [[roam:ivehte]] :work:iv:\n%U\n%?"
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🛠️ work"))
           :jump-to-captured t)
          ("WR" "📅 RDV" entry ,(string-join  '("* 📅 %? :work:rdv:"
                                                "\n<%<%Y-%m-%d>>\n"))
           :if-new (file+head+olp ,my/daily-file ,my/daily-header ("🛠️ work"))
           :jump-to-captured t))))

(use-package nano-calendar
  :custom
  (nano-calendar-workload-detail nil)
  (nano-calendar-workload-compact nil)
  (nano-calendar-workload-symbol t)
  (nano-calendar-layout '(3 . 4))
  (nano-calendar-workload-palette (let* ((def-fg (face-foreground 'default nil 'default))
                                         (def-bg (face-background 'default nil 'default)))
                                    (list (cons def-fg def-bg) ;; Base entry
                                          (cons def-bg "SteelBlue1")
                                          (cons def-bg "SteelBlue2")
                                          (cons def-bg "SteelBlue3")
                                          (cons def-bg "DodgerBlue2")
                                          (cons def-bg "DodgerBlue3")
                                          (cons def-bg "DodgerBlue4")
                                          (cons def-fg "purple1")
                                          (cons def-fg "purple2")
                                          (cons def-fg "purple3")
                                          (cons def-fg "purple4"))))
  :config
  (general-evil-define-key '(normal) nano-calendar-mode-map
    "<left>"    #'nano-calendar-goto-prev-day
    "<right>"   #'nano-calendar-goto-next-day
    "<up>"      #'nano-calendar-goto-prev-week
    "<down>"    #'nano-calendar-goto-next-week
    "<S-left>"  #'nano-calendar-goto-prev-month
    "<S-right>" #'nano-calendar-goto-next-month
    "<S-down>"  #'nano-calendar-goto-next-year
    "<S-up>"    #'nano-calendar-goto-prev-year
    ;; jk hl / eviler:
    "H"         #'nano-calendar-goto-prev-day
    "L"         #'nano-calendar-goto-next-day
    "K"         #'nano-calendar-goto-prev-week
    "J"         #'nano-calendar-goto-next-week
    "B"         #'nano-calendar-goto-prev-month
    "W"         #'nano-calendar-goto-next-month
    ">"         #'nano-calendar-goto-next-year
    "<"         #'nano-calendar-goto-prev-year
    ;;
    "v"         #'nano-calendar-show-org-agenda-entries
    "<RET>"     #'nano-calendar-goto-org-agenda
    "<SPC>"     #'nano-calendar-show-org-agenda-entries
    "m"         #'nano-calendar-workload-menu
    "."         #'nano-calendar-goto-today
    "r"         #'nano-calendar-workload-update-all
    "q"         #'nano-calendar-quit))

(use-package calfw-org
  :commands (cfw:org-read-date-command)
  :config
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
  (setq cfw:org-agenda-schedule-args '(:timestamp))
  (define-key cfw:calendar-mode-map (kbd "<SPC>") nil)
  (general-evil-define-key '(normal insert emacs motion) cfw:calendar-mode-map
    "SPC" evil-leader--default-map)
  (define-key cfw:calendar-mode-map (kbd "<SPC>") evil-leader--default-map))


(use-package org-web-tools)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-ql

(use-package org-ql
  :after org
  :custom
  (org-ql-views
   (list
    (cons "ALL >7a"
          (list :buffers-files #'my/all-dailies
                :query '(and (olps "witness" "bouldering" "topped" "")
                             (regexp "- [7-9][a-c][+]? -"))
                :sort #'my/sort-by-filename-date))
    (cons "recent >7a"
          (list :buffers-files #'org-agenda-files
                :query '(and (olps "witness" "bouldering" "topped" "")
                             (regexp "- [7-9][a-c][+]? -"))
                :sort #'my/sort-by-filename-date))
    (cons "recent >7b"
          (list :buffers-files #'org-agenda-files
                :query '(and (olps "witness" "bouldering" "topped" "")
                             (regexp "- \\([7][b-c][+]?\\|[8-9][a-c][+]?\\) -"))
                :sort #'my/sort-by-filename-date))
    (cons "ALL >7b"
          (list :buffers-files #'my/all-dailies
                :query '(and (olps "witness" "bouldering" "topped" "")
                             (regexp "- \\([7][b-c][+]?\\|[8-9][a-c][+]?\\) -"))
                :sort #'my/sort-by-filename-date))
    (cons "Tagged as Flashed"
          (list :buffers-files #'my/all-dailies
                :query '(and (olps "witness" "bouldering" "topped" "")
                             (tags "flash"))
                :sort #'my/sort-by-filename-date))
    (cons "Maybe flashed"
          (list :buffers-files #'my/all-dailies
                :query '(and (olps "witness" "bouldering" "topped" "")
                             (regexp "flash"))
                :sort #'my/sort-by-filename-date))
    (cons "active timestamps"
          (list :buffers-files #'my/recent-dailies
                :query '(ts-active :from "2025-06-12")
                :sort #'my/sort-by-filename-date))
    (cons "tv bookmarks"
          (list :buffers-files (lambda ()
                                 (cons
                                  (org-roam-node-file
                                   (org-roam-node-from-title-or-alias "foreverever"))
                                  (my/all-dailies)))
                :query '(and (tags "tv") (tags "bm") (not (tags "meh")) (not (tags "done")))
                :sort #'my/sort-by-filename-date))
    (cons "finished tv bookmarks"
          (list :buffers-files (lambda ()
                                 (cons
                                  (org-roam-node-file
                                   (org-roam-node-from-title-or-alias "foreverever"))
                                  (my/all-dailies)))
                :query '(and (tags "tv") (tags "bm") (tags "done"))
                :sort #'my/sort-by-filename-date))
    (cons "abandoned tv bookmarks"
          (list :buffers-files (lambda ()
                                 (cons
                                  (org-roam-node-file
                                   (org-roam-node-from-title-or-alias "foreverever"))
                                  (my/all-dailies)))
                :query '(and (tags "tv") (tags "bm") (tags "meh"))
                :sort #'my/sort-by-filename-date))
    (cons "movies"
          (list :buffers-files (lambda ()
                                 (cons
                                  (org-roam-node-file
                                   (org-roam-node-from-title-or-alias "foreverever"))
                                  (my/all-dailies)))
                :query '(and (tags "tv") (tags "film"))
                :sort #'my/sort-by-filename-date))
    (cons "dangling/empty titles"
          (list :buffers-files #'my/all-dailies
                :query '(and (heading "injuries")
                             (not (children))
                             (no-prop-entry-regexp "\\`.*[ \t\r\n]*\\'"))
                :sort #'my/sort-by-filename-date))
    (cons "broken2 tv bookmarks"
          (list :buffers-files #'my/all-dailies
                :query '(and (olps "media" "📺")
                             (not (tags "meh" "done" "bm" "movie" "yt")))
                :sort #'my/sort-by-filename-date))
    (cons "broken tv bookmarks"
          (list :buffers-files #'my/all-dailies
                :query '(and (olps "media" "📺")
                             (not (tags "tv")))
                :sort #'my/sort-by-filename-date))))

  :config
  (org-ql-defpred no-prop-entry-regexp (&rest regexps)
    "based on regexp, matching \\` & \\' was broken because of text properties."
    :coalesce t
    :normalizers ((`(,predicate-names . ,args)
                   `(no-prop-entry-regexp ,@args)))
    :preambles ((`(,predicate-names ,regexp)
                 (list :case-fold t :regexp regexp :query t))
                (`(,predicate-names . ,regexps)
                 ;; Search for first regexp, then confirm with predicate.
                 (list :case-fold t :regexp (car regexps) :query query)))
    :body
    (let ((end (or (save-excursion
                     (outline-next-heading))
                   (point-max))))
      (save-excursion
        (goto-char (line-beginning-position))
        (cl-loop for regexp in regexps
                 always (save-excursion
                          (s-match-strings-all
                           regexp
                           (buffer-substring-no-properties (point) end)))))))

  (when nil
    ;; I will be looking for this in the future.
    ;; you can do cool stuff like this:
    (setq org-auto-align-tags nil)
    (org-ql-query :select #'delete-line
                  :from #'my/all-dailies ;; (current-buffer)
                  :where '(and (heading "campusing")
                               (not (children))
                               (no-prop-entry-regexp "\\`.*[ \t\r\n]*\\'")))))

(use-package org-ql-search
  :after org-ql
  :commands (my/all-dailies my/recent-dailies my/sort-by-filename-date)

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
     :directories (list (concat org-roam-directory "the-road-so-far")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; board

(use-package org-board)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; books

(use-package org-books)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org appear

(use-package org-appear
  :demand t
  :hook (org-mode-hook . org-appear-mode)
  :custom
  (org-appear-autolinks t)
  (org-appear-autokeywords t))

(provide 'conf/org)
