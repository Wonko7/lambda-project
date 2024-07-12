(require 'ement)

(setq ement-room-message-format-spec "%S> %W%B%r%R%t")
(setq ement-room-prism 'both)
(setq ement-save-sessions nil)

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
  (ement-tabulated-room-list))

(add-hook 'ement-room-compose-hook #'ement-room-compose-org) ;; this isn't working?
;; enable flyspell in the minibuffer:
(add-hook 'ement-room-read-string-setup-hook #'flyspell-mode)

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

(require 'mastodon)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; email

(require 'gnus)
(require 'gnus-topic)

(let ((gnus "/data/org/emacs/gnus.el")) ;; this sets gnus-topic-alist
  (if (f-file-p gnus)
      (load-file gnus)
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

(setq gnus-use-cache t
      gnus-save-newsrc-file nil
      gnus-read-newsrc-file nil
      ;; gnus-article-over-scroll t
      ;; gnus-article-skip-boring t
      gnus-asynchronous t)

(setq gnus-select-method
      '(nnimap "gmail"
	       (nnimap-address "imap.gmail.com")  ; it could also be imap.googlemail.com if that's your server.
	       (nnimap-server-port "imaps")
	       (nnimap-stream ssl)))

(setq smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587
      gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")

(add-to-list 'gnus-secondary-select-methods '(nntp "news.gwene.org"))

(setq my/gnus-topic-topology '(("Gnus" visible)
                               (("tech" visible))
                               (("dev" visible))
                               (("work" visible))
                               (("comics" visible))
                               (("gmail" visible))))

(setq gnus-topic-alist my/gnus-topic-alist)
(setq gnus-topic-topology my/gnus-topic-topology)

(defun my/gnus-subscribe-to-my-stuff ()
  ;; check or force gnus-topic-topology & gnus-topic-alist before calling this.
  (interactive)
  (setq gnus-topic-alist my/gnus-topic-alist)
  (setq gnus-topic-topology my/gnus-topic-topology)
  (mapcar (lambda (topic)
            (message "topic: %s\n" (car topic))
            (mapcar
             (lambda (s)
               (when (and (> (length s) 7)
                          (or (string= "nntp+" (substring s 0 5))
                              (string= "nnimap+" (substring s 0 7))))
                 (message "subscribing to: %s\n" s)
                 (gnus-subscribe-group s)))
             topic))
         gnus-topic-alist))

(add-hook 'gnus-group-mode-hook #'gnus-topic-mode)

(require 'evil-collection-gnus)

(provide 'conf/communication)
