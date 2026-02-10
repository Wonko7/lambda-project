;;; fancy-but-later.el  -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; emoji & icons

;; (require 'all-the-icons)
;; (require 'all-the-icons-completion)
;; (all-the-icons-completion-mode)
;; (add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup)
;; (require 'kind-icon)

(use-package nerd-icons
  :demand t)

(use-package nerd-icons-ibuffer
  :demand t
  :after ibuffer
  :hook (ibuffer-mode-hook . nerd-icons-ibuffer-mode))

(use-package nerd-icons-dired
  :demand t
  :hook (dired-mode-hook . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :demand t
  :after marginalia
  :hook (marginalia-mode-hook nerd-icons-completion-marginalia-setup)
  :config
  (nerd-icons-completion-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cursor

;; (require 'beacon)
;; (beacon-mode 1)
;; (setq beacon-blink-when-point-moves-horizontally 2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; nyan

(use-package nyan-mode
  :demand t
  :custom
  (nyan-animate-nyancat nil) ;; FIXME doesn't like to animate with emacs 29.1
  :config
  (nyan-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; folding

(use-package outline-indent
  :demand t
  :commands (outline-indent--update-ellipsis outline-indent-minor-mode)
  :hook
  (makefile-mode-hook . outline-indent-minor-mode)
  :custom
  (outline-indent-ellipsis " ▼")
  :config
  (defun outline-toggle-children ()
    (interactive)
    (save-excursion
      (outline-back-to-heading)
      (if (not (outline-invisible-p (pos-eol)))
          (outline-hide-subtree)
        (outline-show-subtree) ;; <- this is the diff
        (outline-show-entry)))))

(use-package hideshow
  :demand t
  :after outline-indent
  :hook
  (emacs-lisp-mode-hook . hs-minor-mode)
  (emacs-lisp-mode-hook . outline-indent--update-ellipsis)
  (scheme-mode-hook . hs-minor-mode)
  (scheme-mode-hook . outline-indent--update-ellipsis))

(use-package seq) ;; TODO: dash/seq/cl-lib => use cl everywhere?
(use-package origami
  :demand t
  :after (evil seq outline-indent)
  :custom
  (origami-fold-replacement " ▼")
  :hook
  (tuareg-mode-hook . origami-mode)
  (org-agenda-mode-hook . origami-mode)
  :config
  (let* ((op origami-parser-alist))
    (setq origami-parser-alist (append origami-parser-alist
                                       `((tuareg-mode . origami-indent-parser)))))
  (defun origami-recursively-toggle-node (buffer point)
    ;; diff is rm `if last-command` that won't work wrapped in evil-fold.
    (interactive (list (current-buffer) (point)))
    (-when-let (path (origami-search-forward-for-path buffer point))
      (let ((node (-last-item path)))
        (cond ((origami-fold-node-recursively-open? node)
               (origami-close-node-recursively buffer (origami-fold-beg node)))
              ((origami-fold-node-recursively-closed? node)
               (origami-toggle-node buffer (origami-fold-beg node)))
              (t (origami-open-node-recursively buffer (origami-fold-beg node)))))))
  (setq evil-fold-list
        (cons
         `((origami-mode)
           :open-all   ,(lambda () (origami-open-all-nodes (current-buffer)))
           :close-all  ,(lambda () (origami-close-all-nodes (current-buffer)))
           ;; setting this for toggle:
           :toggle     ,(lambda () (origami-recursively-toggle-node (current-buffer) (point)))
           :open       ,(lambda () (origami-open-node (current-buffer) (point)))
           :open-rec   ,(lambda () (origami-open-node-recursively (current-buffer) (point)))
           :close      ,(lambda () (origami-close-node (current-buffer) (point))))
         (seq-filter (lambda (actions)
                       (let ((m (caar actions)))
                         (not (equal m 'origami-mode))))
                     evil-fold-list))))

(provide 'conf/fancy-but-later)
