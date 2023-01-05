(require 'ement)

(setq ement-room-list-avatars nil) ;; FIXME/review bug workaround
(setq ement-room-message-format-spec "%S> %W%B%r%R%t")

(defun my/ement-init ()
  (interactive)
  (ement-connect :user-id "@wonko7:matrix.org" :password (auth-source-pass-get 'secret "web/matrix/wonko7") :uri-prefix "http://127.0.0.1:8666"))

(provide 'conf/communication)
