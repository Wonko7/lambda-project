;;; values.el  -*- lexical-binding: t; -*-

;; code golf helper:
(defmacro li (&rest body) ;; FIXME use in exwm too.
  `(lambda ()
     (interactive)
     ,@body))


;; other values:
(setq my/exwm-workspace-number 20)
(provide 'conf/values)
