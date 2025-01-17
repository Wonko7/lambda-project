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
          ( :layout tramp-4
            :recipe (| (:left-size-ratio 0.5)
                       (- (:upper-size-ratio 0.7)
                          topl
                          botl)
                       (- (:upper-size-ratio 0.7)
                          topr
                          botr))
            :buffers-f (let* ((pr (projectile-acquire-root))
                              (rm (my/choose-remote-from-fleet))
                              (rpr (concat "/ssh:" rm ":" pr)))
                         `((:name topl :buffer-f (magit-status ,pr))
                           (:name topr :buffer-f (magit-status ,rpr))
                           ( :name botl
                             :buffer-f (projectile-with-default-dir ,pr
                                         (shell
                                          (projectile-generate-process-name "shell" nil ,pr))))
                           ( :name botr
                             :buffer-f (projectile-with-default-dir ,rpr
                                         (shell
                                          (projectile-generate-process-name
                                           "tramp-shell" nil ,rpr)))))))
          ( :layout grid9
            :recipe (|
                     (:left-size-ratio 0.3)
                     (-
                      (:upper-size-ratio 0.3)
                      a
                      (-
                       (:upper-size-ratio 0.5)
                       b
                       c))
                     (| (:left-size-ratio 0.5)
                        (-
                         (:upper-size-ratio 0.3)
                         d
                         (-
                          (:upper-size-ratio 0.5)
                          e
                          f))
                        (-
                         (:upper-size-ratio 0.3)
                         g
                         (-
                          (:upper-size-ratio 0.5)
                          h
                          i))))
            :buffers-f (mapcar
                        (lambda (ab)
                          (let ((a (car ab))
                                (b (cdr ab)))
                            `(:name ,a :buffer ,b)))
                        (-zip '(a b c d e f g h i)
                              (-filter (lambda (b)
                                         (not (string-prefix-p " " (buffer-name b))))
                                       (buffer-list)))))))

  (defun ws/set-layout ()
    (interactive)
    (let* ((layouts     (mapcar (lambda (lo)
                                  (plist-get lo ':layout))
                                ws/layouts))
           (layout-name (consult--read
                         (mapcar #'symbol-name layouts)
                         :prompt "layout? "
                         :sort nil
                         :require-match t))
           (layout       (first (-filter (lambda (lo)
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
              (mapcar
               #'(lambda (b)
                   (let* ((name (plist-get b ':name))
                          (bf   (plist-get b ':buffer-f)))
                     (if bf
                         `(:buffer ,(eval bf) :name ,name)
                       b)))
               (plist-get layout ':buffers)))))))

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

  (defun unused/filter-project-buffs (name)
    (first (-filter (lambda (b)
                      (string-prefix-p name (buffer-name b)))
                    (projectile-project-buffers)))))

(provide 'conf/layouts)
