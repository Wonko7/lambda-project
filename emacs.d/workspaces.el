;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; workspace layouts:

;; FIXME I don't understand why this isn't defined by the time :after exwm-workspace
;; [2025-09-22 Mon 00:00]
(setq exwm-workspace-number 20)

(use-package window-layout
  :commands (ws/set-layout ws/toggle-buffer)
  :after exwm-workspace
  :demand t
  :config
  (require 'dash)

  (defvar ws/current-layout (-repeat exwm-workspace-number nil))

  (setq ws/layouts
        `(( :layout code2
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers ((:name left  :buffer-f (magit-status))
                      (:name right :buffer-f (my/ws-proj-shell) :hide-your-kids t)))

          ( :layout code2-bottom-shell
            :recipe (- (:upper-size-ratio 0.8)
                       (| (:left-size-ratio 0.5)
                          left
                          right)
                       shell)
            :buffers ((:name right :buffer-f (buffer-name))
                      (:name left  :buffer-f (magit-status))
                      (:name shell :buffer-f (my/ws-proj-shell) :hide-your-kids t)))

          ( :layout code3
            :recipe (| (:left-size-ratio 0.3)
                       right
                       (| (:left-size-ratio 0.5)
                          center
                          left))
            :buffers ((:name center :buffer-f (buffer-name))
                      (:name right  :buffer-f (magit-status))
                      (:name left   :buffer-f (my/ws-proj-shell) :hide-your-kids t)))

          ( :layout tramp3
            :recipe (| (:left-size-ratio 0.5)
                       local-code
                       (- (:upper-size-ratio 0.7)
                          remote-code
                          remote-shell))
            :buffers-f (let* ((pr  (projectile-acquire-root))
                              (rm  (my/choose-remote-from-fleet))
                              (rpr (concat "/ssh:" rm ":" pr)))
                         `((:name local-code  :buffer-f (magit-status ,pr))
                           (:name remote-code :buffer-f (magit-status ,rpr))
                           ( :name remote-shell
                             :hide-your-kids t
                             :buffer-f (my/ws-remote-fleet-shell ,rm ,pr)))))

          ( :layout tramp4
            :recipe (| (:left-size-ratio 0.5)
                       (- (:upper-size-ratio 0.7)
                          local-code
                          local-shell)
                       (- (:upper-size-ratio 0.7)
                          remote-code
                          remote-shell))
            :buffers-f (let* ((pr  (projectile-acquire-root))
                              (rm  (my/choose-remote-from-fleet))
                              (rpr (concat "/ssh:" rm ":" pr)))
                         `((:name local-code  :buffer-f (magit-status ,pr))
                           (:name remote-code :buffer-f (magit-status ,rpr))
                           ( :name local-shell
                             :hide-your-kids t
                             :buffer-f (my/ws-proj-shell ,pr))
                           ( :name remote-shell
                             :hide-your-kids t
                             :buffer-f (my/ws-remote-fleet-shell ,rm ,pr)))))

          ( :layout grid9
            :recipe (| (:left-size-ratio 0.3)
                       (- (:upper-size-ratio 0.3)
                          a
                          (- (:upper-size-ratio 0.5)
                             b
                             c))
                       (| (:left-size-ratio 0.5)
                          (- (:upper-size-ratio 0.3)
                             d
                             (- (:upper-size-ratio 0.5)
                                e
                                f))
                          (- (:upper-size-ratio 0.3)
                             g
                             (- (:upper-size-ratio 0.5)
                                h
                                i))))
            :buffers-f (mapcar
                        (lambda (ab)
                          (let ((a (car ab))
                                (b (cdr ab)))
                            `(:name ,a :buffer ,b)))
                        (-zip '(a b c d e f g h i)
                              (-filter (lambda (b)
                                         ;; remove mini-buffers from list
                                         (not (string-prefix-p " " (buffer-name b))))
                                       (buffer-list)))))

          ( :layout init2
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers-f (progn
                         (bluetooth-list-devices)
                         '((:name right :buffer-f (shell))
                           (:name left  :buffer-f "*Bluetooth*" :hide-your-kids t))))

          ( :layout media2
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers (( :name left
                        :hide-your-kids t
                        :buffer-f (my/ws-proj-shell "/data/org"))
                      ( :name right
                        :buffer-f (org-roam-node-open
                                   (org-roam-node-from-title-or-alias my/current-media)))))
          ( :layout media2-remote
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers (( :name left
                        :hide-your-kids t
                        :buffer-f (my/ws-remote-fleet-shell
                                   "of-course-i-still-love-you.local"
                                   "/mnt/trantor/media/inbox"))
                      ( :name right
                        :buffer-f (org-roam-node-open
                                   (org-roam-node-from-title-or-alias my/current-media)))))
          ( :layout org2
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers (( :name left
                        :buffer-f (find-file (org-roam-dailies-latest)))
                      ( :name right
                        :hide-your-kids t
                        :buffer-f (org-agenda nil "z"))))

          ( :layout ement-notifs-4
            :recipe (| (:left-max-size 38)
                       list
                       (| (:left-size-ratio 0.33)
                          notif
                          (| (:left-size-ratio 0.5)
                             a
                             b)))
            :buffers-f
            (progn
              ;; FIXME: eek. doesn't eval if I put this in a (use-package ement-lib :config)
              (require 'ement-lib)
              (defun my/ement-get-buf-for-named-room (name)
                "get buffer for named room"
                (let ((session (alist-get "@wonko7:matrix.org" ement-sessions
                                          nil nil #'equal)))
                  (when-let (room (cl-find-if
                                   (lambda (room)
                                     (let ((members (ement-room-members room)))
                                       (or (and (= 2 (hash-table-count members))
                                                (gethash name members))
                                           (string= name (ement-room-display-name room)))))
                                   (ement-session-rooms session)))
                    (pcase-let* (((cl-struct ement-room (local (map buffer))) room))
                      (progn (unless (buffer-live-p buffer)
                               (setf buffer (ement-room--buffer session room
                                                                (ement-room--buffer-name room))
                                     (alist-get 'buffer (ement-room-local room))  buffer))
                             buffer)))))
              `(( :name list
                  :hide-your-kids t
                  :buffer-f ,(progn (ement-tabulated-room-list)
                                    "*Ement Rooms*"))
                ( :name notif
                  :hide-your-kids t
                  :buffer-f ,(progn (ement-notify-switch-to-notifications-buffer)
                                    "*Ement Notifications*"))
                ( :name a
                  :buffer-f ,(my/ement-get-buf-for-named-room (first my/ement-ws-init)))

                ( :name b
                  :buffer-f ,(my/ement-get-buf-for-named-room (second my/ement-ws-init))))))

          ( :layout ement3
            :recipe (| (:left-max-size 38)
                       list
                       (| (:left-size-ratio 0.33)
                          a
                          (| (:left-size-ratio 0.5)
                             b
                             c)))
            :buffers-f
            `(( :name list
                :hide-your-kids t
                :buffer-f ,(progn (ement-tabulated-room-list)
                                  "*Ement Rooms*"))
              ( :name a
                :buffer-f ,(my/ement-get-buf-for-named-room (first my/ement-ws-init)))

              ( :name b
                :buffer-f ,(my/ement-get-buf-for-named-room (second my/ement-ws-init)))
              ( :name c
                :buffer-f ,(my/ement-get-buf-for-named-room (third my/ement-ws-init)))))))

  (defun ws/init-layout-buffers (layout)
    (mapcar
     (lambda (b)
       (let* ((name (plist-get b ':name))
              (bf   (plist-get b ':buffer-f)))
         (if bf
             `(:buffer ,(eval bf) :name ,name)
           b)))
     (plist-get layout ':buffers)))

  (defun ws/set-layout (&optional layout)
    (interactive)
    (let* ((layouts     (mapcar (lambda (lo)
                                  (plist-get lo ':layout))
                                ws/layouts))
           (layout-name (if (null layout)
                            (consult--read
                             (mapcar #'symbol-name layouts)
                             :prompt "layout? "
                             :sort nil
                             :require-match t)
                          (symbol-name layout)))
           (layout      (first (-filter (lambda (lo)
                                          (string= layout-name (plist-get lo ':layout)))
                                        ws/layouts)))
           (buffs       (plist-get layout ':buffers-f))
           (layout      (if buffs
                            (plist-put layout ':buffers (eval buffs))
                          layout)))
      (setf (nth exwm-workspace-current-index ws/current-layout)
            (list
             layout
             (wlf:layout
              (plist-get layout ':recipe)
              (ws/init-layout-buffers layout))))))

  (defun ws/layout-reinit ()
    (interactive)
    (let* ((layout      (first (nth exwm-workspace-current-index ws/current-layout))))
      (setf (nth exwm-workspace-current-index ws/current-layout)
            (list
             layout
             (wlf:layout
              (plist-get layout ':recipe)
              (ws/init-layout-buffers layout))))))

  (defun ws/save-buffer-config ()
    (interactive)
    (let* ((lo     (nth exwm-workspace-current-index ws/current-layout))
           (layout (first lo))
           (wm     (second lo))
           (buffs  (-filter (lambda (bi)
                              (not (plist-get bi ':hide-your-kids)))
                            (plist-get layout ':buffers)))
           (buffs  (mapcar (lambda (bi)
                             (plist-get bi ':name))
                           buffs)))
      (mapcar (lambda (b)
                (wlf:set-buffer
                 wm b
                 (window-buffer (wlf:get-window wm b))))
              buffs)))

  (defun ws/toggle-buffer ()
    (interactive)
    (let* ((lo     (nth exwm-workspace-current-index ws/current-layout))
           (layout (first lo))
           (wm     (second lo))
           (buffs  (mapcar (lambda (bi)
                             (plist-get bi ':name))
                           (plist-get layout ':buffers)))
           (bn     (consult--read
                    (mapcar #'symbol-name buffs)
                    :prompt "buffer? "
                    :sort nil
                    :require-match t)))
      (wlf:toggle wm (intern bn))))

  (defun ws/toggle-hide-your-kids ()
    (interactive)
    (ws/save-buffer-config)
    (let* ((lo     (nth exwm-workspace-current-index ws/current-layout))
           (layout (first lo))
           (wm     (second lo))
           (buffs  (-filter (lambda (bi)
                              (plist-get bi ':hide-your-kids))
                            (plist-get layout ':buffers)))
           (buffs  (mapcar (lambda (bi)
                             (plist-get bi ':name))
                           buffs)))
      (mapcar (lambda (bn)
                (wlf:toggle wm bn))
              buffs)))

  (defun ws/layout-reset ()
    (interactive)
    (wlf:reset-init
     (second
      (nth exwm-workspace-current-index ws/current-layout))))

  (defun unused/filter-project-buffs (name)
    (first (-filter (lambda (b)
                      (string-prefix-p name (buffer-name b)))
                    (projectile-project-buffers)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto start workspaces:

(use-package emacs
  :ensure t
  :after exwm-workspace
  :demand t
  :config
  (defvar ws/auto-start-state (-repeat exwm-workspace-number t))
  ;; disable auto run for nameless projects:
  (setf (nth 5 ws/auto-start-state) nil)
  (setf (nth 3 ws/auto-start-state) nil)
  (setf (nth 0 ws/auto-start-state) nil)

  (defun ws/check-and-mark-auto-start-state (i)
    (let ((state (nth i ws/auto-start-state)))
      (setf (nth i ws/auto-start-state) nil) ;; mark as visited
      state))

  (if (string= "wonko" user-login-name)
      (defun ws/run-auto-start ()
        (cl-flet ((run-init-p (i)
                    (and (= exwm-workspace-current-index i)
                         (ws/check-and-mark-auto-start-state i))))
          (cond ((run-init-p 9)
                 (push my/init-ement-room-list display-buffer-alist)
                 (my/ement-init))
                ((run-init-p 8)
                 (projectile-switch-project-by-name my/lambda-project))
                ((run-init-p 7)
                 (ws/set-layout 'org2))
                ((run-init-p 6)
                 (gnus))
                ((run-init-p 5)
                 (projectile-switch-project))
                ((run-init-p 4)
                 (async-shell-command "firefox"))
                ((run-init-p 3)
                 (projectile-switch-project))
                ((run-init-p 2)
                 (ws/set-layout 'media2))
                ((run-init-p 1)
                 (ws/set-layout 'init2))
                ;; external monitor
                ((run-init-p 14)
                 (async-shell-command "GDK_DPI_SCALE=2.5 firefox")))))
    ;; else media:
    (defun ws/run-auto-start ()
      (cl-flet ((run-init-p (i)
                  (and (= exwm-workspace-current-index i)
                       (ws/check-and-mark-auto-start-state i))))
        ;; external monitor only
        (cond ((run-init-p 11)
               (ws/set-layout 'init2))
              ((run-init-p 14)
               (async-shell-command "firefox"))))))

  (defun ws/force-run-auto-start ()
    (interactive)
    (setf (nth exwm-workspace-current-index ws/auto-start-state) t)
    (ws/run-auto-start))

  (add-hook 'exwm-workspace-switch-hook #'ws/run-auto-start))

(provide 'conf/workspaces)
