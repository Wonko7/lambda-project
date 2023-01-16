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
  (evil-window-vsplit)
  (org-agenda nil "z")
  (other-window 1)
  (cfw:open-org-calendar))

(defun my/tbb ()
  (interactive)
  (async-shell-command "cd ~/.local/tbb/tor-browser &&             \
    guix shell                                                     \
      --container                                                  \
      --network                                                    \
      --emulate-fhs                                                \
      --preserve='^DISPLAY$'                                       \
      openssl@1                                                    \
      libevent                                                     \
      pciutils                                                     \
      dbus-glib                                                    \
      bash                                                         \
      libgccjit                                                    \
      libcxx                                                       \
      gtk+                                                         \
      coreutils                                                    \
      grep                                                         \
      sed                                                          \
      file                                                         \
      alsa-lib                                                     \
      --                                                           \
      ./start-tor-browser.desktop -v "))

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
