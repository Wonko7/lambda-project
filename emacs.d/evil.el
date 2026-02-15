;;; evil.el  -*- lexical-binding: t; -*-
;;  the evil stuff

(use-package undo-fu
  :demand t)
(use-package vundo)

;; 😈
(use-package evil
  :defer nil
  :demand t
  :after undo-fu

  :init
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-minibuffer t)
  (setq evil-want-keybinding nil) ;; evil tells you to
  (setq evil-want-C-i-jump t)
  (setq evil-disable-insert-state-bindings t)

  :config
  (evil-mode 1)
  ;; FIXME GREP xim/input-method: trying this before activating evil:
  ;; (evil-set-initial-state 'exwm-mode 'emacs)
  (define-advice evil-disabled-buffer-p (:before-until () no-exwm)
    (eq major-mode 'exwm-mode))
  (evil-put-property 'evil-state-properties 'normal :input-method t)
  (evil-put-property 'evil-state-properties 'motion :input-method t)
  (evil-put-property 'evil-state-properties 'replace :input-method t)
  (evil-put-property 'evil-state-properties 'operator :input-method t)
  (evil-put-property 'evil-state-properties 'visual :input-method t)

  (setq evil-undo-system 'undo-fu)
  (evil-set-undo-system evil-undo-system) ;; FIXME: this shouldn't be needed)
  ;; GREP: this concerns multi/compose key/accents/exwm-xim/input methods
  ;; (setq evil-input-method "latin-9-prefix")
  ;; I set these after evil for collection.
  ;; (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  ;; (setq evil-want-keybinding t)
  ;; (setq evil-want-minibuffer t)
  (setq evil-search-wrap nil)

  ;; C-g exits replace mode:
  (define-key evil-replace-state-map (kbd "C-g") 'evil-normal-state)

  ;; fix G -> goto last line
  (evil-define-motion evil-goto-line (count)
    "Go to line COUNT. By default the last line."
    :jump t
    :type line
    (evil-ensure-column
      (if (null count)
          (goto-char (- (point-max) 1))
        (goto-char (point-min))
        (forward-line (1- count)))))

  ;; extend n/N cycle search results to consult-line:
  (setq my/current-search-fn 'isearch)

  (advice-add #'evil-search-function :after
              (lambda (&rest _)
                (setq my/current-search-fn 'isearch)))

  (advice-add #'consult-line :after
              (lambda (&rest _)
                (setq my/current-search-fn 'consult)))

  ;; generalise next/previous:

  (defun my/search-prev ()
    (interactive)
    (if (eq my/current-search-fn 'consult)
        (call-interactively (kmacro "SPC . C-k <return>"))
      (evil-search-previous)))

  (defun my/search-next ()
    (interactive)
    (if (eq my/current-search-fn 'consult)
        (call-interactively (kmacro "SPC . C-j <return>"))
      (evil-search-next)))

  (evil-declare-ignore-repeat 'my/search-next)
  (evil-declare-ignore-repeat 'my/search-prev)

  (define-key evil-motion-state-map "n" #'my/search-next)
  (define-key evil-motion-state-map "N" #'my/search-prev))


(use-package evil-collection
  :defer nil
  :demand t
  :after evil
  :init
  (setq evil-want-keybinding nil)
  (setq evil-collection-calendar-want-org-bindings t)
  (setq evil-collection-setup-minibuffer t)
  (setq evil-collection-outline-bind-tab-p t)
  (setq evil-collection-key-blacklist '("SPC" "C-SPC" "-"))
  :config
  (evil-collection-init)
  (setq evil-want-keybinding t)
  ;; (setq evil-want-C-i-jump nil)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; readonly / view mode:

  (evil-collection-define-key 'normal 'view-mode-map
    "q" 'quit-window
    (kbd "SPC") 'View-scroll-page-forward
    (kbd "S-SPC") 'View-scroll-page-backward

    ;; zoom
    "C-+" 'text-scale-increase
    "C-=" 'text-scale-increase
    "C-0" 'text-scale-adjust
    "C--" 'text-scale-decrease
    "0" nil ;; free this for normal state's general binding
    "-" nil ;; free this for normal state's general binding

    ;; refresh
    (kbd "gr") 'revert-buffer))


(use-package evil-escape
  :demand t
  :after evil
  :config
  (evil-escape)
  (evil-escape-mode 1)
  (setq evil-escape-delay 0.3
        evil-escape-key-sequence "jj"
        evil-escape-excluded-states '(normal visual multiedit emacs motion)
        ;; evil-cross-lines t
        ))

(use-package evil-matchit
  :demand t
  :after evil
  :config
  (global-evil-matchit-mode 1))

(use-package evil-surround
  :demand t
  :after evil
  :config
  (global-evil-surround-mode))

(use-package evil-exchange
  :demand t
  :after evil
  :config
  (setq evil-exchange-key (kbd "zx"))
  (evil-exchange-install))

(use-package evil-org
  :demand t
  :after evil
  ;; the equivalent for org-mode-map is in org-conf
  ;; this needs to be set after starting evil-org
  :hook (org-mode-hook
         . (lambda ()
             (evil-org-mode)
             (evil-define-key 'normal 'evil-org-mode
               (kbd "<C-return>")  '+org/insert-item-below
               (kbd "<C-S-return>") '+org/insert-item-above)))
  :custom
  (evil-org-key-theme '(navigation insert textobjects todo calendar))
  :config
  (setq evil-org-retain-visual-state-on-shift t)
  (setq evil-org-special-o/O nil)
  (general-evil-define-key '(visual) org-mode-map
    "$" #'evil-end-of-line))

(use-package evil-org-agenda
  :demand t
  :after evil
  :config
  (evil-org-agenda-set-keys)
  (general-evil-define-key '(motion) org-agenda-mode-map
    (kbd "<tab>") #'evil-toggle-fold
    "zo"  #'evil-open-fold
    "zO"  #'evil-open-folds
    "zm"  #'evil-close-folds
    "zC"  #'evil-close-folds))

(use-package evil-snipe
  :demand t
  :after evil
  :hook (magit-mode-hook . turn-off-evil-snipe-override-mode)
  :config
  (setq evil-snipe-scope 'whole-buffer)
  (setq evil-snipe-char-fold t)
  (setq evil-snipe-smart-case t)
  (setq evil-snipe-override-mode t)
  (evil-snipe-mode 1))

(use-package evil-leader
  :demand t
  :after evil
  :config
  (global-evil-leader-mode)
  (evil-leader/set-leader "<SPC>"))

(use-package evil-goggles
  :demand t
  :after evil
  :custom
  (evil-goggles-duration 0.500)
  (evil-goggles-pulse nil)
  :config
  (evil-goggles-mode)
  ;; fancy
  (set-face-attribute 'evil-goggles-default-face nil :foreground "white")
  (set-face-attribute 'evil-goggles-default-face nil :background "#EB64B9"))

(use-package evil-visualstar
  :demand t
  :config
  (global-evil-visualstar-mode t))

(use-package evil-commentary
  :demand t
  :after evil
  :config
  (evil-commentary-mode t))

;; <zoo
(use-package evil-lion
  :demand t
  :after evil
  :config
  (evil-lion-mode))

(use-package evil-owl
  :demand t
  :after evil
  :config
  (evil-owl-mode))
;; zoo>

(use-package evil-mc
  :demand t
  :after evil
  :init
  (setq evil-mc-cursors-map (make-sparse-keymap)) ;; FIXME: workaround on zonked req evil-mc
  :config
  (define-key evil-motion-state-map "gm" nil)
  (evil-define-key '(normal visual) 'global
    "gmm" #'evil-mc-make-all-cursors
    "gmu" #'evil-mc-undo-all-cursors
    "gmq" #'evil-mc-undo-all-cursors

    "gmr" #'evil-mc-pause-cursors
    "gmR" #'evil-mc-resume-cursors
    "gmh" #'evil-mc-make-cursor-here
    "gmj" #'evil-mc-make-cursor-move-next-line
    "gmk" #'evil-mc-make-cursor-move-prev-line

    "gmn" #'evil-mc-make-and-goto-next-match
    "gmN" #'evil-mc-skip-and-goto-next-match
    "gmp" #'evil-mc-make-and-goto-prev-match
    "gmP" #'evil-mc-skip-and-goto-prev-match)
  (global-evil-mc-mode))

(provide 'conf/evil)
;;; evil.el ends here
