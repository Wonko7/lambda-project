;;; evil.el -*- lexical-binding: t; -*-
;;
;;
;;; Commentary:
;;
;;  the evil stuff
;;
;;; Code:


;; 😈
(require 'evil)
(evil-mode 1)

;;; ;; set leader key in all states
;;; (evil-set-leader nil (kbd "C-SPC"))
;;;
;;; ;; set leader key in normal state
;;; (evil-set-leader 'normal (kbd "SPC"))
;;;
;;; ;; set local leader
;;; (evil-set-leader 'normal "," t)
;;;
;;; (defvar my-leader-map (make-sparse-keymap)
;;;   "Keymap for \"leader key\" shortcuts.")
;;;
;;; ;; binding "," to the keymap
;;; (define-key evil-normal-state-map "," my-leader-map)
;;;
;;; ;; binding ",b"
;;; (define-key my-leader-map "b" 'list-buffers)
;;;
;;; ;; change the "leader" key to space
;;; (define-key evil-normal-state-map "," 'evil-repeat-find-char-reverse)
;;; (define-key evil-normal-state-map (kbd "SPC") my-leader-map)

;; general.el can automate the process of prefix map/command creation
;; (general-nmap
;;   :prefix "SPC"
;;   :prefix-map 'my-leader-map
;;   "," 'list-buffers)

(require 'undo-fu)
(require 'vundo)
(setq evil-undo-system 'undo-fu)
(evil-set-undo-system evil-undo-system) ;; FIXME: this shouldn't be needed

(setq evil-want-integration t) ;; This is optional since it's already set to t by default.
(setq evil-want-keybinding t)
(setq evil-want-minibuffer t)
(when (require 'evil-collection nil t)
  (evil-collection-init))

(evil-global-set-key 'motion "j" 'evil-next-visual-line)
(evil-global-set-key 'motion "k" 'evil-previous-visual-line)
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
(setq evil-snipe-scope 'whole-visible)

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
            ;;(general-evil-define-key '(normal) evil-org-mode-map
            ;;                      "C-RET"           '+org/insert-item-below
            ;;                      "C-S-RET"         '+org/insert-item-above
            ;;                      [C-return]        '+org/insert-item-below
            ;;                      [C-S-return]      '+org/insert-item-above)
            (evil-define-key 'normal 'evil-org-mode
              (kbd "<C-return>")  '+org/insert-item-below
              (kbd "<C-S-return>") '+org/insert-item-above)))

(require 'evil-org-agenda)
(evil-org-agenda-set-keys)

(require 'evil-snipe)
(setq evil-snipe-scope 'whole-visible)
(evil-snipe-mode +1)
(add-hook 'magit-mode-hook 'turn-off-evil-snipe-override-mode)
;; (evil-snipe-override-mode +1)

(provide 'conf/evil)

;;; evil.el ends here
