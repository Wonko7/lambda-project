;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; workspace layouts:

(use-package window-layout
  :commands (ws/set-layout ws/toggle-buffer)
  :config
  (require 'dash)

  (defvar ws/current-layout (-repeat exwm-workspace-number nil))

  (setq ws/layouts
        `(( :layout code2
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers ((:name left  :buffer-f (magit-status))
                      (:name right :buffer-f (projectile-run-shell))))

          ( :layout code2-bottom-shell
            :recipe (- (:upper-size-ratio 0.8)
                       (| (:left-size-ratio 0.5)
                          left
                          right)
                       shell)
            :buffers ((:name right :buffer-f (buffer-name))
                      (:name left  :buffer-f (magit-status))
                      (:name shell :buffer-f (projectile-run-shell))))

          ( :layout code3
            :recipe (| (:left-size-ratio 0.3)
                       right
                       (| (:left-size-ratio 0.5)
                          center
                          left))
            :buffers ((:name center :buffer-f (buffer-name))
                      (:name right  :buffer-f (magit-status))
                      (:name left   :buffer-f (projectile-run-shell))))

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
                             :buffer-f (projectile-with-default-dir ,pr
                                         (shell
                                          (projectile-generate-process-name "shell" nil ,pr))))
                           ( :name remote-shell
                             :buffer-f (projectile-with-default-dir ,rpr
                                         (shell
                                          (projectile-generate-process-name
                                           "remote-shell" nil ,rpr)))))))

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
                           (:name left  :buffer-f "*Bluetooth*"))))

          ( :layout media2
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers (( :name left
                        :buffer-f (let ((d "/ssh:wonko@enterprise.local:/mnt/trantor/media/"))
                                    (projectile-with-default-dir d
                                      (shell (projectile-generate-process-name
                                              "remote-media-shell" nil d)))))
                      ( :name right
                        :buffer-f (org-roam-node-open
                                   (org-roam-node-from-title-or-alias "📺 sense8")))))
          ( :layout org2
            :recipe (| (:left-size-ratio 0.5)
                       left
                       right)
            :buffers (( :name left
                        :buffer-f (find-file (org-roam-dailies-latest)))
                      ( :name right
                        :buffer-f (org-agenda nil "z"))))))

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
           (buffs  (mapcar (lambda (bi)
                             (plist-get bi ':name))
                           (plist-get layout ':buffers)))
           (buffs  (-filter (lambda (bi) ;; non shell only
                              (not (string-search "shell" (symbol-name bi))))
                            buffs)))
      (wlf:wset-fix-windows wm)
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

  (defun ws/toggle-shells ()
    (interactive)
    (ws/save-buffer-config)
    (let* ((lo     (nth exwm-workspace-current-index ws/current-layout))
           (layout (first lo))
           (wm     (second lo))
           (buffs  (mapcar (lambda (bi)
                             (symbol-name
                              (plist-get bi ':name)))
                           (plist-get layout ':buffers)))
           (buffs  (-filter (lambda (bn)
                              (string-search "shell" bn))
                            buffs)))
      (wlf:wset-fix-windows wm)
      (mapcar (lambda (bn)
                (wlf:toggle wm (intern bn)))
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
  :after exwm
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
               (async-shell-command "GDK_DPI_SCALE=2.5 firefox"))))) )

  (defun ws/force-run-auto-start ()
    (interactive)
    (setf (nth exwm-workspace-current-index ws/auto-start-state) t)
    (ws/run-auto-start))

  (add-hook 'exwm-workspace-switch-hook #'ws/run-auto-start))

(provide 'conf/workspaces)
