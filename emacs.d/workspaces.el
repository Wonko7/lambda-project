;;; workspaces.el  -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; workspace layouts:

(use-package dash)

(use-package window-layout
  :commands (ws/set-layout ws/toggle-buffer)
  :after (exwm-workspace dash)
  :hook (exwm-workspace-switch-hook . ws/run-auto-start)
  :demand t
  :config
  (require 'dash) ;; FIXME replace by cl-lib?

  (defvar ws/current-layout (-repeat my/exwm-workspace-number nil))

  (defun my/org-roam-open-node-return-buffer (node)
    (let ((n (org-roam-node-from-title-or-alias node)))
      (org-roam-node-open n)
      (marker-buffer
       (org-roam-node-marker n))))

  (setq ws/layouts
        `(( :layout code2
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers ((:name left  :buffer-f (magit-status))
                      (:name right :buffer-f (ws/proj-shell) :hide-your-kids t)))

          ( :layout code2-bottom-shell
            :recipe (- (:upper-size-ratio 0.8)
                       (| (:left-size-ratio 0.5)
                          left
                          right)
                       shell)
            :buffers ((:name right :buffer-f (buffer-name))
                      (:name left  :buffer-f (magit-status))
                      (:name shell :buffer-f (ws/proj-shell) :hide-your-kids t)))

          ( :layout code3
            :recipe (| (:left-size-ratio 0.3)
                       right
                       (| (:left-size-ratio 0.5)
                          center
                          left))
            :buffers ((:name center :buffer-f (buffer-name))
                      (:name right  :buffer-f (magit-status))
                      (:name left   :buffer-f (ws/proj-shell) :hide-your-kids t)))

          ( :layout tramp3
            :recipe (| (:left-size-ratio 0.5)
                       local-code
                       (- (:upper-size-ratio 0.7)
                          remote-shell
                          remote-code))
            :buffers-f (let* ((pr  (projectile-acquire-root))
                              (rm  (my/choose-remote-from-fleet))
                              (rpr (concat "/ssh:" rm ":" pr)))
                         `((:name local-code  :buffer-f (magit-status ,pr))
                           (:name remote-code :buffer-f (magit-status ,rpr))
                           ( :name remote-shell
                             :hide-your-kids t
                             :buffer-f (ws/remote-fleet-shell ,rm ,pr)))))

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
                             :buffer-f (ws/proj-shell ,pr))
                           ( :name remote-shell
                             :hide-your-kids t
                             :buffer-f (ws/remote-fleet-shell ,rm ,pr)))))

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
                         '((:name right :buffer-f (ws/proj-shell "~/"))
                           (:name left  :buffer-f "*Bluetooth*" :hide-your-kids t))))

          ( :layout init-no-bluetooth
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers-f (progn
                         '((:name right :buffer-f (ws/proj-shell "~/"))
                           (:name left  :buffer-f (ws/proj-shell "/data")))))

          ( :layout media3
            :recipe (| (:left-size-ratio 0.5)
                       left
                       (- (:upper-size-ratio 0.5)
                          tina-show
                          my-show))
            :buffers (( :name left
                        :hide-your-kids t
                        :buffer-f (ws/proj-shell "/data/org"))
                      ( :name tina-show
                        :buffer-f
                        (my/org-roam-open-node-return-buffer tina/current-media))
                      ( :name my-show
                        :buffer-f
                        (my/org-roam-open-node-return-buffer my/current-media))))
          ( :layout media2-remote
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers (( :name left
                        :hide-your-kids t
                        :buffer-f (ws/remote-fleet-shell
                                   "of-course-i-still-love-you.local"
                                   "/mnt/trantor/media/inbox"))
                      ( :name right
                        :buffer-f
                        (my/org-roam-open-node-return-buffer my/current-media))))

          ( :layout org2-latest-agenda
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers (( :name left
                        :buffer-f (find-file (org-roam-dailies-latest)))
                      ( :name right
                        :hide-your-kids t
                        :buffer-f (progn (org-agenda nil "z")
                                         "*Org Agenda*"))))

          ( :layout org2-cal-agenda
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers (( :name left
                        :buffer-f (progn (nano-calendar)
                                         "*nano-calendar*"))
                      ( :name right
                        :hide-your-kids t
                        :buffer-f (progn (org-agenda nil "z")
                                         "*Org Agenda*"))))

          ( :layout org3-latest-cal-agenda
            :recipe (| (:left-size-ratio 0.5)
                       (- (:upper-size-ratio 0.4)
                          left-top
                          left-bot)
                       right)
            :buffers (( :name left-top
                        :buffer-f (find-file (org-roam-dailies-latest)))
                      ( :name right
                        :buffer-f (progn (org-agenda nil "z")
                                         "*Org Agenda*"))
                      ( :name left-bot
                        :hide-your-kids t
                        :buffer-f (progn (org-timegrid-week)
                                         "*Org Time Grid*"))))

          ( :layout comms
            :recipe (| (:left-size-ratio 0.5)
                       irc
                       mtx)
            :buffers (( :name irc
                        :buffer-f (progn (my/irc-init)
                                         "#guix"))
                      ( :name mtx
                        :buffer-f (progn (my/ement-init)
                                         "*Ement Room List*"))))))

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
           (layout      (cl-first (-filter (lambda (lo)
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
    (let* ((layout      (cl-first (nth exwm-workspace-current-index ws/current-layout))))
      (setf (nth exwm-workspace-current-index ws/current-layout)
            (list
             layout
             (wlf:layout
              (plist-get layout ':recipe)
              (ws/init-layout-buffers layout))))))

  (defun ws/save-buffer-config ()
    (interactive)
    (let* ((lo     (nth exwm-workspace-current-index ws/current-layout))
           (layout (cl-first lo))
           (wm     (cl-second lo))
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
           (layout (cl-first lo))
           (wm     (cl-second lo))
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
           (layout (cl-first lo))
           (wm     (cl-second lo))
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
     (cl-second
      (nth exwm-workspace-current-index ws/current-layout))))

  (defun unused/filter-project-buffs (name)
    (cl-first (-filter (lambda (b)
                         (string-prefix-p name (buffer-name b)))
                       (projectile-project-buffers))))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; auto start workspaces:

  (defvar ws/auto-start-state (-repeat my/exwm-workspace-number t))
  ;; disable auto run for nameless project spaces:
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
                 (ws/set-layout 'comms))
                ((run-init-p 8)
                 (projectile-switch-project-by-name my/lambda-project))
                ((run-init-p 7)
                 (ws/set-layout 'org3-latest-cal-agenda))
                ((run-init-p 6)
                 (gnus))
                ((run-init-p 5)
                 (projectile-switch-project))
                ((run-init-p 4)
                 ;; [2026-03-28 Sat 22:04] firefox 149 is being annoying:
                 (my/local-async-shell-command "firefox 2>&1 > /dev/null"))
                ((run-init-p 3)
                 (projectile-switch-project))
                ((run-init-p 2)
                 (ws/set-layout 'media3))
                ((run-init-p 1)
                 (if (equal "yggdrasill" (system-name)) ;; slowly dying
                     (ws/set-layout 'init-no-bluetooth)
                   (ws/set-layout 'init2)))
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

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; per workspace shells

  (defun ws/shell ()
    (interactive)
    (shell
     (concat
      "*" (int-to-string exwm-workspace-current-index) ": " default-directory "*")))

  (defun ws/proj-shell (&optional project)
    (interactive)
    (let* ((pr (or (and project
                        (tramp-file-local-name project))
                   (projectile-project-root
                    (tramp-file-local-name default-directory))
                   "~/")))
      (projectile-with-default-dir pr
        (shell
         (projectile-generate-process-name
          (concat
           (int-to-string exwm-workspace-current-index) ":") nil pr)))))

  (defun ws/remote-fleet-shell (&optional remote project)
    (interactive)
    (let* ((pr  (or (and project
                         (tramp-file-local-name project))
                    (projectile-project-root
                     (tramp-file-local-name default-directory))
                    "~/"))
           (rm  (or remote (my/choose-remote-from-fleet)))
           (rpr (concat "/ssh:" rm ":" pr))
           (process-environment (if my/force-term-env ;; FIXME dumb shell fallback
                                    (cons my/force-term-env process-environment)
                                  process-environment)))
      (projectile-with-default-dir rpr
        (shell
         (projectile-generate-process-name
          (concat (int-to-string exwm-workspace-current-index) ":"
                  (string-remove-suffix ".local" rm)) nil rpr)))))

  (defun ws/remote-fleet-shell-with-default ()
    (interactive)
    (let* ((ws  exwm-workspace-current-index)
           (rm (nth ws ws/default-remote)))
      (ws/remote-fleet-shell rm nil)))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; default remote

  (defvar ws/default-remote
    (-repeat my/exwm-workspace-number "of-course-i-still-love-you.star-fleet.local"))
  (setf (nth 1 ws/default-remote)
        (if (equal "yggdrasill" (system-name))
            "enterprise.star-fleet.local"
          "yggdrasill.star-fleet.local"))

  (defun ws/choose-default-remote (&optional all)
    (interactive)
    (let* ((default-directory "~/")
           (rm (my/choose-remote-from-fleet)))
      (if all
          (setq ws/default-remote (-repeat my/exwm-workspace-number rm))
        (setf (nth exwm-workspace-current-index ws/default-remote) rm)))))

(provide 'conf/workspaces)
