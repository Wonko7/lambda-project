(defun my/insert-inactive-timestamp ()
  (interactive)
  (insert (format-time-string "[%F %a %H:%M]")))

(defun my/cd-up ()
  (interactive)
  (insert "cd ..")
  (pcase major-mode
    ('shell-mode (comint-send-input))
    ('eshell-mode (eshell-send-input))
    ('term-mode (term-send-input))))

(defun my/cd-- ()
  (interactive)
  (insert "cd -")
  (pcase major-mode
    ('shell-mode (comint-send-input))
    ('eshell-mode (eshell-send-input))
    ('term-mode (term-send-input))))

(defun my/init-org ()
  (interactive)
  (org-roam-node-open (org-roam-node-from-title-or-alias "ssdd"))
  (org-roam-node-from-ref "7f0e18fb-3b06-4200-a3ba-3675ccace7cc")
  (org-agenda nil "z")
  (cfw:open-org-calendar))

;; (require 'enlive)
;; (require 'seq)
;;
;; (defun ar/scrape-links-from-clipboard-url ()
;;   "Scrape links from clipboard URL and return as a list. Fails if no URL in clipboard."
;;   (unless (string-prefix-p "http" (current-kill 0))
;;     (user-error "no URL in clipboard"))
;;   (thread-last (enlive-query-all (enlive-fetch (current-kill 0)) [a])
;;     (mapcar (lambda (element)
;;               (string-remove-suffix "/" (enlive-attr element 'href))))
;;     (seq-filter (lambda (link)
;;                   (string-prefix-p "http" link)))
;;     (seq-uniq)
;;     (seq-sort (lambda (l1 l2)
;;                 (string-lessp (replace-regexp-in-string "^http\\(s\\)*://" "" l1)
;;                               (replace-regexp-in-string "^http\\(s\\)*://" "" l2))))))

(provide 'conf/misc)
