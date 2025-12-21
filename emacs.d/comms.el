;;; comms.el  -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; prelude, load some definitions:

(let ((comms "/data/org/emacs/comms.el")) ;; this sets gnus-topic-alist & friends
  (if (file-readable-p comms)
      (load-file comms)
    (setq my/ement-ws-init '("i" "hate" "sand"))
    (setq my/gnus-topic-alist '(("tech" ;; the key of topic
                                 "nntp+news.gwene.org:gwene.com.schneier"
                                 "nntp+news.gwene.org:gwene.org.slashdot"
                                 "nntp+news.gwene.org:gwene.cat.sizeof")
                                ("dev"
                                 "nntp+news.gwene.org:gwene.org.ocsigen.news")
                                ("work"
                                 "nntp+news.gwene.org:gwene.fr.linuxjobs")
                                ("comics"
                                 "nntp+news.gwene.org:gwene.com.smbc-comics"
                                 "nntp+news.gwene.org:gwene.com.xkcd")
                                ("Feeds")))))

(use-package ement
  :commands (my/ement-init)
  :hook
  ((ement-room-compose-hook . ement-room-compose-org) ;; this isn't working?
   (ement-room-read-string-setup-hook . jinx-mode))

  :config
  (setq ement-room-message-format-spec "%S> %W%B%r%R%t")
  (setq ement-room-prism 'both)
  (setq ement-save-sessions nil)

  (general-evil-define-key '(normal) ement-room-list-mode-map
    "u" #'ement-tabulated-room-list-next-unread
    "X"  #'ement-room-list-kill-buffer
    "h" #'my/ement-home
    "l" #'ement-tabulated-room-list)

  (general-evil-define-key '(normal) ement-tabulated-room-list-mode-map
    "u" #'ement-tabulated-room-list-next-unread
    "X"  #'ement-room-list-kill-buffer
    "h" #'my/ement-home
    "l" #'ement-tabulated-room-list)

  (general-evil-define-key '(normal motion) ement-room-list-mode-map
    "RET" nil)

  (general-evil-define-key '(normal) ement-room-list-mode-map
    :prefix "RET"
    "n" #'ement-tabulated-room-list-next-unread
    "RET" #'ement-room-list-RET)

  (general-evil-define-key '(normal) ement-tabulated-room-list-mode-map
    :prefix "RET"
    "n" #'ement-tabulated-room-list-next-unread
    "RET" #'ement-room-list-RET)

  (general-evil-define-key '(normal) ement-directory-mode-map
    :prefix "RET"
    "RET" #'ement-directory-RET)

  (general-evil-define-key '(normal) ement-room-mode-map
    ;; migrate stuff down to prefix-map as these get annoying:
    ;; Movement
    "RET" nil
    "TAB" #'ement-room-goto-next
    "<backtab>" #'ement-room-goto-prev
    ;; "SPC" #'ement-room-scroll-up-mark-read
    "S-SPC" #'ement-room-scroll-down-command
    "M-SPC" #'ement-room-goto-fully-read-marker
    "m" #'ement-room-mark-read
    ;; (define-key map [remap scroll-down-command] #'ement-room-scroll-down-command)
    ;; (define-key map [remap mwheel-scroll] #'ement-room-mwheel-scroll)
    "c-p" #'ement-room-goto-prev
    "c-n" #'ement-room-goto-next
    "c-j" #'ement-room-goto-prev
    "c-k" #'ement-room-goto-next
    "(" #'ement-room-goto-prev
    ")" #'ement-room-goto-next
                                        ;"l" #'ement-tabulated-room-list
    "L" #'ement-tabulated-room-list
    "H" #'my/ement-home
    ;; "y" #'my/ement-home

    ;; Switching
    ;; "g l" #'ement-tabulated-room-list
    ;; "g r" #'ement-view-room
    ;; "g m" #'ement-notify-switch-to-mentions-buffer
    ;; "g n" #'ement-notify-switch-to-notifications-buffer
    "q" #'quit-window

    ;; Messages
    ;; "RET" #'ement-room-send-message
    "S-<return>" #'ement-room-write-reply
    "M-RET" #'ement-room-compose-message
    "<insert>" #'ement-room-edit-message
    "c"   (lambda ()
            (interactive)
            (ement-room-compose-message ement-room ement-session)
            (ement-room-compose-org))

    "x" #'ement-room-edit-message
    "X" #'ement-room-delete-message
    "s r" #'ement-room-send-reaction
    "s e" #'ement-room-send-emote
    "s f" #'ement-room-send-file
    "s i" #'ement-room-send-image
    "V" #'ement-room-view-event

    ;; go
    "g m" #'ement-notify-switch-to-mentions-buffer
    "g n" #'ement-notify-switch-to-notifications-buffer
    "g l"   #'ement-tabulated-room-list
    "g r"   #'ement-view-room
    "g R"   #'ement-room-sync
    "g y"   #'my/ement-home

    ;; Users
    "u RET" #'ement-send-direct-message
    "u i" #'ement-invite-user
    "u I" #'ement-ignore-user

    ;; Room
    "r o" #'ement-room-occur
    "r d" #'ement-describe-room
    "r m" #'ement-list-members
    "r t" #'ement-room-set-topic
    "r f" #'ement-room-set-message-format
    "r n" #'ement-room-set-notification-state
    "r N" #'ement-room-override-name
    "r T" #'ement-tag-room

    ;; Room membership
    "R c" #'ement-create-room
    "R j" #'ement-join-room
    "R l" #'ement-leave-room
    "R F" #'ement-forget-room
    "R n" #'ement-room-set-display-name
    "R s" #'ement-room-toggle-space
    ;; Other
    )

  (general-evil-define-key '(normal motion) ement-room-mode-map
    "RET" nil
    "<return>" nil)

  (general-evil-define-key '(normal) ement-room-mode-map
    :prefix "RET"
    ;; "g l" #'ement-tabulated-room-list
    ;; "g r" #'ement-view-room
    "m" #'ement-notify-switch-to-mentions-buffer
    "n" #'ement-notify-switch-to-notifications-buffer
    "l" #'ement-tabulated-room-list
    "r" #'ement-view-room
    "R" #'ement-room-sync
    "y" #'my/ement-home

    "RET" #'ement-room-send-message
    "c"   (lambda ()
            (interactive)
            (ement-room-compose-message ement-room ement-session)
            (ement-room-compose-org)))

  ;; room-list
  ;; (defvar ement-room-list-mode-map
  ;;   (let ((map (make-sparse-keymap)))
  ;;     #'ement-room-list-RET
  ;;     #'ement-room-list-next-unread
  ;;     #'ement-room-list-section-toggle
  ;;     #'ement-room-toggle-space)
  ;;   "Keymap for `ement-room-list' buffers.
  ;; See also `ement-room-list-button-map'.")

  ;;)

  (defun my/ement-init ()
    (interactive)
    (ement-connect :user-id "@wonko7:matrix.org"
                   :password (auth-source-pass-get 'secret "web/matrix/wonko7")
                   :uri-prefix "http://127.0.0.1:8666"))

  (defun my/ement-home ()
    (interactive)
    (ement-notify-switch-to-notifications-buffer)
    (delete-other-windows)
    (split-window-horizontally)
    (ement-tabulated-room-list)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; erc

(defun my/irc-init ()
  (interactive)
  (require 'erc)
  (setq erc-nick ""
        erc-user-full-name ""
        erc-dcc-verbose t
        erc-modules '(page pcomplete netsplit fill button match track completion readonly networks ring autojoin noncommands irccontrols move-to-prompt stamp menu list))
  (erc-update-modules)
  (erc-tls :server "irc.irchighway.net"
           :port   "6697"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mastodon

(use-package mastodon)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; email / rss

(use-package gnus
  :config
  (setq gnus-directory "~/gnus"
        gnus-startup-file (concat gnus-directory "/.newsrc")
        gnus-cache-directory (concat gnus-directory  "/news/cache")
        gnus-article-save-directory (concat gnus-directory "/news")
        gnus-kill-files-directory (concat gnus-directory "/news")
        nndraft-directory (concat gnus-directory "/mail/draft")
        nnfolder-directory (concat gnus-directory "/mail/archive"))

  (setq gnus-cloud-synced-files
        '("~/.authinfo.gpg" "~/gnus/.newsrc" "~/gnus/.newsrc.eld"
          (:directory "~/gnus/news" :match ".*.SCORE\\'")))

  (setq gnus-use-cache t
        gnus-save-newsrc-file nil
        gnus-read-newsrc-file nil
        ;; gnus-article-over-scroll t
        ;; gnus-article-skip-boring t
        gnus-asynchronous t)

  (setq gnus-select-method
        '(nnimap "gmail"
                 ;; it could also be imap.googlemail.com if that's your server.
                 (nnimap-address "imap.gmail.com")
                 (nnimap-server-port "imaps")
                 (nnimap-stream ssl)))

  (setq smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 587
        gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")

  (add-to-list 'gnus-secondary-select-methods '(nntp "news.gwene.org"))

  (setq my/gnus-topic-topology (cons
                                '("Gnus" visible)
                                (-filter
                                 #'identity
                                 (mapcar (lambda (topic)
                                           (let ((x (cl-first topic)))
                                             (if (string= x "Gnus")
                                                 nil
                                               `((,x visible)))))
                                         my/gnus-topic-alist))))

  (setq gnus-topic-alist my/gnus-topic-alist)
  (setq gnus-topic-topology my/gnus-topic-topology)

  (defun my/old-gnus-subscribe-to-my-stuff ()
    "might be useful"
    (interactive)
    (setq gnus-topic-alist my/gnus-topic-alist)
    (setq gnus-topic-topology my/gnus-topic-topology)
    (mapcar (lambda (topic)
              (message "topic: %s\n" (car topic))
              (mapcar
               (lambda (s)
                 (message "subscribing to: %s\n" s)
                 (gnus-subscribe-group s))
               (cdr topic)))
            gnus-topic-alist))

  (defun my/gnus-subscribe-to-my-stuff ()
    "reset gnus subscriptions, folders, topics. rm ~/.news* might help"
    ;; *sigh*: exec this, copy gnus-newsrc-alist, exit gnus, edit .newsrc.eld
    ;; and set gnus-newsrc-alist manually 🤷
    (interactive)
    (setq gnus-topic-alist my/gnus-topic-alist)
    (setq gnus-topic-topology my/gnus-topic-topology)
    (setq gnus-newsrc-alist
          (append
           (mapcar (lambda (news)
                     (list news 3 nil nil "nntp:news.gwene.org" nil))
                   (seq-filter (lambda (s)
                                 (and (> (length s) 19)
                                      (string= (substring s 0 19) "nntp+news.gwene.org")))
                               (flatten-list my/gnus-topic-alist)))
           ;; example: '(("nnvirtual:comics" 3 nil nil (nnvirtual "smbc\\|xkcd"))...)
           my/gnus-virtual-folders))
    (mapcar (lambda (topic)
              (message "topic: %s\n" (car topic))
              (mapcar (lambda (s)
                        (message "subscribing to: %s\n" s)
                        (gnus-subscribe-group s))
                      (cdr topic)))
            gnus-topic-alist))

  (setq gnus-thread-sort-functions '((not gnus-thread-sort-by-date)))

  (general-evil-define-key '(normal) gnus-group-mode-map
    "u" #'gnus-group-unsubscribe
    "S" #'gnus-group-unsubscribe
    "s" #'gnus-group-subscribe)

  (general-evil-define-key '(normal) gnus-summary-mode-map
    "gu" #'gnus-summary-browse-url
    "U"  #'gnus-summary-put-mark-as-unread
    "K"  #'gnus-summary-prev-article
    "J"  #'gnus-summary-next-article)

  (general-evil-define-key '(normal) gnus-article-mode-map
    "gu" #'gnus-summary-browse-url
    "U"  #'gnus-summary-put-mark-as-unread
    "K"  #'gnus-summary-prev-article
    "J"  #'gnus-summary-next-article)

  (gnus-add-configuration
   '(article
     (horizontal 1.0
                 (vertical 0.32
                           (group 1.0))
                 (vertical 1.0
                           (summary 0.25 point)
                           (article 1.0)))))
  (gnus-add-configuration
   '(summary
     (horizontal 1.0
                 (vertical 0.32
                           (group 1.0))
                 (vertical 1.0
                           (summary 1.0 point)))))

  ;; summary
  (setq gnus-sum-thread-tree-false-root "  "
        gnus-sum-thread-tree-indent "  "
        gnus-sum-thread-tree-root "○ "
        gnus-sum-thread-tree-single-indent "◌ "
        gnus-sum-thread-tree-vertical        "│" ;; |
        gnus-sum-thread-tree-leaf-with-other "├─► "
        gnus-sum-thread-tree-single-leaf     "╰─► "

        ;; │06-Jan│  Sender Name  │ Email Subject
        gnus-summary-line-format (concat "%0{%U%R%z%}"
                                         "%3{│%}" "%1{%d%}" "%3{│%}"
                                         "  "
                                         "%4{%-20,20f%}"
                                         "  "
                                         "%3{│%}"
                                         " "
                                         "%1{%B%}"
                                         "%s\n")))

(use-package gnus-topic
  :after gnus
  :hook
  (gnus-group-mode-hook . gnus-topic-mode))

(use-package evil-collection-gnus
  :after gnus)

(provide 'conf/comms)
