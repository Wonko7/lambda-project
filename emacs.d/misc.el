(defun my/insert-inactive-timestamp ()
  (interactive)
  (insert (format-time-string "[%F %a %H:%M]")))
