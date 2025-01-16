(add-hook 'prog-mode-hook #'rainbow-identifiers-mode)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(general-evil-define-key '(normal) prog-mode-map
  "zj"  #'flymake-goto-next-error
  "zk"  #'flymake-goto-prev-error)

;; ocaml + sane defaults
;; (require 'lsp)
;; (require 'lsp-ui)
;;(require 'lsp-ui-imenu)

;; (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
;; (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
;; (define-key lsp-ui-mode-map (kbd "C-c C-l .") 'lsp-ui-peek-find-definitions)
;; (define-key lsp-ui-mode-map (kbd "C-c C-l ?") 'lsp-ui-peek-find-references)
;; (define-key lsp-ui-mode-map (kbd "C-c C-l r") 'lsp-rename)
;; (define-key lsp-ui-mode-map (kbd "C-c C-l x") 'lsp-workspace-restart)
;; (define-key lsp-ui-mode-map (kbd "C-c C-l w") 'lsp-ui-peek-find-workspace-symbol)
;; (define-key lsp-ui-mode-map (kbd "C-c C-l i") 'lsp-ui-peek-find-implementation)
;; (define-key lsp-ui-mode-map (kbd "C-c C-l d") 'lsp-describe-thing-at-point)
;; (define-key lsp-ui-mode-map (kbd "C-c C-l e") 'lsp-execute-code-action)


;; (require 'eglot)
;; (add-hook 'tuareg-mode-hook #'eglot-ensure)
;; (setq eglot-autoshutdown t)
;; FIXME: eglot doesn't seem to like ocsigen.



(use-package tuareg
  :defer t
  :hook
  (tuareg-mode-hook . (lambda ()
                        (setq mode-name "🐫")
                        (add-hook 'before-save-hook #'ocamlformat-before-save)
                        (setq-local comment-style 'indent)
                        (setq-local tuareg-interactive-program
                                    (concat tuareg-interactive-program " -nopromptcont"))
                        (add-hook 'before-save-hook #'ocamlformat-before-save t t)))
  :config
  (progn
    (setq tuareg-interactive-read-only-input t)
    (general-evil-define-key '(normal) tuareg-mode-map
      :prefix "RET"
      "ge"  #'merlin-error-next
      "o"   #'merlin-pop-stack
      "RET" #'tuareg-eval-phrase
      "b"   #'tuareg-eval-buffer
      "TAB" #'tuareg-complete
      "K"   #'tuareg-kill-ocaml
      "a"   #'ff-get-other-file))
  ;; (add-hook 'tuareg-mode-hook
  ;;           (lambda ()
  ;;             (setq mode-name "🐫")
  ;;             (add-hook 'before-save-hook #'ocamlformat-before-save)
  ;;             (setq-local comment-style 'indent)
  ;;             (setq-local tuareg-interactive-program
  ;;                         (concat tuareg-interactive-program " -nopromptcont"))
  ;;             (add-hook 'before-save-hook #'ocamlformat-before-save t t)))
  ;; for your eval convenience  (remove-hook 'tuareg-mode #'ocamlformat-before-save)
  )

(use-package ocamlformat
  :defer t)

;; (use-package utop
;;   :defer t
;;   :hook
;;   (tuareg-mode-hook . #'utop-minor-mode)
;;   :config
;;   (progn
;;     (setq utop-command "dune utop . -- -emacs")
;;     (autoload 'utop-minor-mode "utop" "Minor mode for utop" t)
;;     (general-evil-define-key '(normal) utop-minor-mode-map
;;       :prefix "RET"
;;       "RET" #'utop-eval-phrase
;;       "b"   #'utop-eval-buffer
;;       "K"   #'utop-kill)))

;; (use-package tuareg :ensure t)

(setq-default fill-column 80
              indent-tabs-mode nil
              mode-line-format (remove '(vc-mode vc-mode) mode-line-format)
              require-final-newline t
              scroll-down-aggressively 0
              scroll-up-aggressively 0)

(setq tab-width 8
      ;; ocaml
      comint-prompt-read-only t ; comint -> repl
      comment-multi-line t
      compilation-scroll-output 'first-error
      compilation-context-lines 0
      disabled-command-function nil
      sql-product 'postgres
      track-eol t
      view-read-only t
      vc-follow-symlinks t)

(mapc (lambda (ext) (add-to-list 'completion-ignored-extensions ext))
      '(".bc" ".byte" ".exe" ".native"))

(mapc (lambda (ext) (add-to-list 'auto-mode-alist ext))
      '(("dune-project\\'" . dune-mode)
        ("dune-workspace\\'" . dune-mode)
        ("README\\'" . text-mode)
        ("\\.dockerignore\\'" . conf-unix-mode)
        ("\\.gitignore\\'" . conf-unix-mode)
        ("\\.merlin\\'" . conf-space-mode)
        ("\\.ocamlinit\\'" . tuareg-mode)
        ("\\.top\\'" . tuareg-mode)
        ("\\.mli?\\'" . tuareg-mode)
        ("\\.eliomi?\\'" . tuareg-mode)))

;; Hack to open files like Makefile.local with the right mode.
(add-to-list 'auto-mode-alist '("\\.[^\\.].*\\'" nil t) t)

;; (map :localleader
;;       :map tuareg-mode-map
;;       "ge"  #'merlin-error-next
;;       "o"   #'merlin-pop-stack
;;       "RET" #'tuareg-eval-phrase
;;       "b"   #'tuareg-eval-buffer
;;       "TAB" #'tuareg-complete
;;       "K"   #'tuareg-kill-ocaml
  ;; :nvm  "gd" #'+lookup/definition
;;       "a"   #'ff-get-other-file)


(use-package diff-hl
  ;; :after magit
  :config
  (global-diff-hl-mode)
  (setq diff-hl-draw-borders nil)
  (setq diff-hl-side 'right))

;;(global-diff-hl-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; buffer-env

;; use guix shell automagically <3

;; (use-package buffer-env
;;   ;; :defer t
;;   :demand t
;;   :hook
;;   ((hack-local-variables-hook . #'buffer-env-update)
;;    (utop-mode-hook . #'hack-dir-local-variables-non-file-buffer) ;; this one doesn't
;;    (comint-mode-hook . #'hack-dir-local-variables-non-file-buffer))
;;   :config
;;   (setq buffer-env-script-name "guix.scm")
;;   (setq buffer-env-commands
;;           '((".env" . "set -a && >&2 . \"$0\" && env -0")
;;             ("manifest.scm" . "guix shell -m \"$0\" -- env -0")
;;             ("guix.scm" . "guix shell -D -f \"$0\" -- env -0")
;;             ("*" . ">&2 . \"$0\" && env -0")))
;;   )

(require 'buffer-env)
(add-hook 'hack-local-variables-hook #'buffer-env-update)
(add-hook 'utop-mode-hook #'hack-dir-local-variables-non-file-buffer) ;; this one doesn't
(add-hook 'comint-mode-hook #'hack-dir-local-variables-non-file-buffer)
(setq buffer-env-script-name "guix.scm")

(use-package inheritenv
  :demand t
  ;;:defer t
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; I, for one, welcome our new ai overlords

(use-package gptel
  :defer t
  :config
  (setq gptel-api-key (lambda ()
                        (auth-source-pass-get 'secret "web/openai/token/pandora"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sql

(general-evil-define-key '(normal) sql-mode-map
  :prefix "RET"
  "RET" #'sql-send-paragraph)

(setq sql-postgres-login-params '((user :default "wonko")
                                  (database :default "maxi_passat")
                                  (server :default "localhost")
                                  (port :default 3000)))

(provide 'conf/dev)
