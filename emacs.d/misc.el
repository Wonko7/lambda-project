;;; misc.el  -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; code golf helper:

(defmacro li (&rest body) ;; FIXME use in exwm too.
  `(lambda ()
     (interactive)
     ,@body))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; up up & away

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; exec helper

(defun my/local-async-shell-command (command)
  ;; some things aren't meant to be executed remotely via tramp.
  (interactive)
  (let ((default-directory "~/"))
    (async-shell-command command)))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fleet / remote operations:

(defun my/choose-remote-from-fleet ()
  (consult--read
   (remove "" (string-split (shell-command-to-string "cat /etc/hosts | cut -d\\\t -f2 | grep -v localhost") "\n"))
   :prompt "choose ship from fleet: "
   :sort nil
   :require-match t))

(defun my/remote-fleet-find-file (&optional file)
  (interactive "FFile: ")
  (let* ((remote (my/choose-remote-from-fleet))
         (fp     (or file
                     (buffer-file-name)
                     default-directory))
         (dn     (file-name-directory fp))
         (fn     (file-name-nondirectory fp)))
    (message remote)
    (find-file
     (read-file-name
      "Find remote file: "
      (concat "/ssh:" remote ":" dn)
      (concat "/ssh:" remote ":" fp)
      'confirm fn))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fix insert after cursor

(defmacro my/insert-after-space (&rest fs)
  `(progn
     ,@(mapcar
        (lambda (f)
          ;; If in evil normal mode and cursor is on a whitespace til EOL
          ;; then go into append mode first before inserting the thing.
          ;; This is to put the thing after the space rather than before.
          `(defadvice ,f (around append-if-in-evil-normal-mode activate compile)
             (let ((is-in-evil-normal-mode (and (bound-and-true-p evil-mode)
                                                (not (bound-and-true-p
                                                      evil-insert-state-minor-mode))
                                                (looking-at "[[:blank:]]*$"))))
               (if (not is-in-evil-normal-mode)
                   ad-do-it
                 (evil-append 0)
                 ad-do-it
                 (evil-normal-state)))))
        fs)))

(my/insert-after-space org-roam-node-insert
                       emoji-search
                       org-web-tools-insert-link-for-url
                       my/insert-inactive-timestamp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; insert things

(defun my/set-date ()
  (interactive)
  (pcase-let ((`(,y ,m ,d) (split-string (org-read-date) "-" )))
    (my/sudo (format "date %s%s1300%s" m d y))))

(defun my/format-time-delta (time1 time2)
  "Return difference between TIME1 & TIME2 as a readable string."
  (format-seconds "%Y %D %H %M %z%S"
                  (float-time
                   (time-subtract (org-time-string-to-seconds time1)
                                  (org-time-string-to-seconds time2)))))

(defun my/star-date ()
  (interactive)
  (let* ((start-date   (org-read-date nil nil "1986-07-23"))
         (a-start-date (org-read-date nil nil "2019-04-11"))
         (b-start-date (org-read-date nil nil "2024-12-23"))
         (c-start-date (org-read-date nil nil "2025-10-18"))
         (end-date     (org-read-date nil nil "+0"))
         (days         (- (org-time-string-to-absolute end-date)
                          (org-time-string-to-absolute start-date)))
         (a-days       (- (org-time-string-to-absolute end-date)
                          (org-time-string-to-absolute a-start-date)))
         (b-days       (- (org-time-string-to-absolute end-date)
                          (org-time-string-to-absolute b-start-date)))
         (c-days       (- (org-time-string-to-absolute end-date)
                          (org-time-string-to-absolute c-start-date))))
    (insert (format "days: %i %i %i\n- %s\n- %s\n- %s\n- %s"
                    days a-days b-days
                    (my/format-time-delta end-date start-date)
                    (my/format-time-delta end-date a-start-date)
                    (my/format-time-delta end-date b-start-date)
                    (my/format-time-delta end-date c-start-date)))))

(defun my/insert-shell-line ()
  (interactive)
  (let* ((fs '("/data/org/here-be-dragons/tech/20230412204446-shell.org"
               "/data/org/here-be-dragons/wip/20230815232907-maxipass_at.org"))
         (buf-content (split-string
                       (with-temp-buffer
                         (mapc (lambda (f)
                                 (when (file-exists-p f)
                                   (insert-file-contents f)))
                               fs)
                         (buffer-string))
                       "\n"))
         (cmds (seq-filter
                (lambda (x)
                  (and (not (string-match-p "^\s*[*:#]" x))
                       (string-match-p "^\s+" x)))

                (remove "" buf-content)))
         (cmds (mapcar #'string-clean-whitespace cmds))
         (cmd (consult--read cmds
                             :prompt "choose command: "
                             :sort nil
                             :require-match t)))
    (insert cmd)))

(defun my/insert-line-from-buffer (buffer)
  (let* ((ln          (line-number-at-pos))
         (b           buffer)
         (buf-content (split-string
                       (with-temp-buffer
                         (insert-buffer b)
                         (buffer-string))
                       "\n"))
         (under       (reverse (take ln buf-content)))
         (over        (drop ln buf-content))
         (n           (min (length under) (length over)))
         (buf-content (flatten-list
                       (-zip (take n under)
                             (take n over))))
         (buf-content (append buf-content (drop n over) (drop n under)))
         (buf-content (remove "" buf-content))
         (line        (consult--read buf-content
                                     :prompt (string-join `("insert line from "
                                                            ,(buffer-name b)
                                                            ": "))
                                     :sort nil
                                     :require-match t)))
    (evil-open-below 1)
    (insert line)))

(defun my/insert-line ()
  (interactive)
  (my/insert-line-from-buffer (current-buffer)))

(defun my/insert-line-other ()
  (interactive)
  (my/insert-line-from-buffer (other-buffer (current-buffer) t)))

(defun my/insert-elisp-header ()
  (interactive)
  (progn ;; save-excursion
    (goto-char 0)
    (insert (concat ";;; "
                    (file-name-nondirectory buffer-file-name)
                    "  -*- lexical-binding: t; -*-\n\n"))))

(defun my/bleau-link-insert ()
  (interactive)
  (execute-kbd-macro (kbd "^wD"))
  (org-web-tools-insert-link-for-url (current-kill 0 t))
  (org-id-get-create)
  (evil-next-line 2))

(defun my/insert-inactive-timestamp ()
  (interactive)
  (insert (format-time-string "[%F %a %H:%M]")))

(provide 'conf/misc)
