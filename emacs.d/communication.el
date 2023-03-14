(require 'ement)

(setq ement-room-list-avatars nil) ;; FIXME/review bug workaround
(setq ement-room-message-format-spec "%S> %W%B%r%R%t")

(defun my/ement-init ()
  (interactive)
  (ement-connect :user-id "@wonko7:matrix.org"
                 :password (auth-source-pass-get 'secret "web/matrix/wonko7")
                 :uri-prefix "http://127.0.0.1:8666"))

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


(provide 'conf/communication)
