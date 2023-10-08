;;; evil.el -*- lexical-binding: t; -*-
;;
;;
;;; Commentary:
;;
;;  the evil stuff
;;
;;; Code:


;; 😈
(setq evil-want-keybinding nil)
(setq evil-want-C-i-jump nil)
(require 'evil)
(evil-mode 1)

(require 'undo-fu)
(require 'vundo)
(setq evil-undo-system 'undo-fu)
(evil-set-undo-system evil-undo-system) ;; FIXME: this shouldn't be needed

(setq evil-want-integration t) ;; This is optional since it's already set to t by default.
(setq evil-want-keybinding t)
(setq evil-want-minibuffer t)
(when (require 'evil-collection nil t)
  (setq evil-collection-key-blacklist '("SPC"))
  (evil-collection-init))

(setq evil-want-C-i-jump nil)
(setq evil-search-wrap nil)

(setq evil-collection-setup-minibuffer t)
(setq evil-collection-calendar-want-org-bindings t)
(setq evil-collection-outline-bind-tab-p t)


(require 'evil-escape)
(evil-escape-mode 1)
(setq evil-escape-delay 0.3
      evil-escape-key-sequence "jj"
      evil-escape-excluded-states '(normal visual multiedit emacs motion)
      ;; evil-cross-lines t
      )
(setq evil-search-wrap nil)

(require 'evil-matchit)
(global-evil-matchit-mode 1)

(require 'evil-surround)
(global-evil-surround-mode)

(require 'evil-exchange)
(setq evil-exchange-key (kbd "zx")) ;; gx or zx?
(evil-exchange-install)

(require 'evil-org)
(setq evil-org-key-theme '(navigation insert textobjects additional shift todo heading calendar))
(setq evil-org-retain-visual-state-on-shift t)
(setq evil-org-special-o/O nil)

;; the equivalent for org-mode-map is in org-conf
;; this needs to be set after starting evil-org
(add-hook 'org-mode-hook
          (lambda ()
            (evil-org-mode)
            (evil-define-key 'normal 'evil-org-mode
              (kbd "<C-return>")  '+org/insert-item-below
              (kbd "<C-S-return>") '+org/insert-item-above)))

(require 'evil-org-agenda)
(evil-org-agenda-set-keys)

(require 'evil-snipe)
(setq evil-snipe-scope 'whole-visible)
(setq evil-snipe-char-fold t)
(setq evil-snipe-smart-case t)
(setq evil-snipe-override-mode t)
(evil-snipe-mode 1)

(add-hook 'magit-mode-hook #'turn-off-evil-snipe-override-mode)
;; (evil-snipe-override-mode +1)

(require 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")

(require 'evil-goggles)
(evil-goggles-mode)

(require 'evil-visualstar)
(global-evil-visualstar-mode t)

(require 'evil-commentary)
(evil-commentary-mode t)

;; <zoo
(require 'evil-lion)
(evil-lion-mode)

(require 'evil-owl)
(evil-owl-mode)
;; zoo>

(setq evil-mc-cursors-map (make-sparse-keymap)) ;; FIXME: workaround on zonked req evil-mc
(require 'evil-mc)
(global-evil-mc-mode)

(provide 'conf/evil)
;;; evil.el ends here
