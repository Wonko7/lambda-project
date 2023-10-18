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


(provide 'conf/communication)
