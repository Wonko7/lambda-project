;;; completion.el  -*- lexical-binding: t; -*-

(use-package marginalia
  :demand t
  :config
  (marginalia-mode 1)
  (setq marginalia-align 'right)
  (setq marginalia-max-relative-age 0))

(use-package orderless
  :demand t
  :config
  ;; Andrew Topin once mentioned that tramp needs basic for completion to work.
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides nil
        completion-ignore-case t)

  ;; orderless-style-dispatchers
  ;; FIXME rewrite with orderless-affix-dispatch-alist on next release.
  (defun regex-if-twiddle (pattern _index _total)
    (when (string-suffix-p "~" pattern)
      `(orderless-regex . ,(substring pattern 0 -1))))

  (defun literal-if-equal (pattern _index _total)
    (when (string-suffix-p "=" pattern)
      `(orderless-literal . ,(substring pattern 0 -1))))

  (defun metadata-if-at (pattern _index _total)
    (when (string-prefix-p "@" pattern)
      `(orderless-annotation . ,(substring pattern 1))))

  (defun flex-if-quote (pattern _index _total)
    (when (string-suffix-p "'" pattern)
      `(orderless-flex . ,(substring pattern 0 -1))))

  (defun first-flex (pattern index _total)
    (if (= index 0) 'orderless-flex))

  (defun without-if-bang (pattern _index _total)
    (cond
     ((equal "!" pattern)
      '(orderless-literal . ""))
     ((string-prefix-p "!" pattern)
      `(orderless-without-literal . ,(substring pattern 1)))))

  (setq orderless-matching-styles '(orderless-literal
                                    char-fold-to-regexp
                                    orderless-regexp)
        orderless-style-dispatchers '(;; regex-if-twiddle
                                      metadata-if-at
                                      flex-if-quote
                                      literal-if-equal
                                      without-if-bang)
        orderless-smart-case t)

  (setq char-fold-symmetric nil)
  (setq completion-ignore-case t)
  ;; will come in handy:

  ;; (orderless-define-completion-style orderless+initialism
  ;;   (orderless-matching-styles '(orderless-initialism
  ;;                                orderless-literal
  ;;                                orderless-regexp)))
  ;; (setq completion-category-overrides
  ;;       '((command (styles orderless+initialism))
  ;;         (symbol (styles orderless+initialism))
  ;;         (variable (styles orderless+initialism))))

  ;; (setq orderless-component-separator "[ _-]")
  ;; (defun just-one-face (fn &rest args)
  ;;   (let ((orderless-match-faces [completions-common-part]))
  ;;     (apply fn args)))
  ;;
  ;; (advice-add 'company-capf--candidates :around #'just-one-face)

  ;; (add-to-list completion-at-point-functions #'cape-symbol)
  ;; (setq completion-at-point-functions (list (cape-super-capf #'cape-symbol
  ;;                                                            #'cape-keyword
  ;;                                                            #'cape-dabbrev
  ;;                                                            #'cape-elisp-block
  ;;                                                            #'cape-file)))

  (setq completion-at-point-functions (list #'cape-dabbrev)))

(use-package vertico
  :demand t
  :bind ( :map vertico-map
          ("C-j" . #'vertico-next)
          ("C-k" . #'vertico-previous)
          ("<down>" . #'vertico-next)
          ("<up>" . #'vertico-previous))
  :config
  (vertico-mode)
  (vertico-mouse-mode)
  ;; FIXME `vertico-repeat-history' to `savehist-additional-variables'.

  ;; (setq vertico-scroll-margin 2) ;; Different scroll margin
  (setq vertico-count 20) ;; Show more candidates
  (setq vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (setq vertico-cycle t)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; fancy:
  (set-face-attribute 'vertico-group-title nil :inherit 'font-lock-keyword-face)
  (set-face-attribute 'vertico-current nil :background "black")
  ;; Prefix the current candidate with “» ”. From
  ;; https://github.com/minad/vertico/wiki#prefix-current-candidate-with-arrow
  (advice-add #'vertico--format-candidate :around
              (lambda (orig cand prefix suffix index _start)
                (setq cand (funcall orig cand prefix suffix index _start))
                (concat
                 (if (= vertico--index index)
                     (propertize "▶ " 'face 'vertico-current)
                   "  ")
                 cand))))

(use-package emacs ;; regroup minibuffer things:
  :init
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  (setq completion-cycle-threshold nil)
  (setq tab-always-indent 'complete)
  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  ;; inspired from prot's conf: https://github.com/protesilaos/dotfiles
  (require 'mb-depth)
  (setq enable-recursive-minibuffers t)
  (setq read-minibuffer-restore-windows nil)
  (setq minibuffer-default-prompt-format " [%s]")

  (add-hook 'after-init-hook #'minibuffer-depth-indicate-mode)
  (require 'minibuf-eldef)
  (setq read-buffer-completion-ignore-case t)

  (setq completion-ignore-case t)
  (setq-default case-fold-search t)
  (setq read-file-name-completion-ignore-case t)

  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  (setq resize-mini-windows t) ;; FIXME: testing

  (setq read-answer-short t)
  (setq use-short-answers t)
  (setq echo-keystrokes 0.25)
  (setq minibuffer-prompt-properties ;; FIXME: testing
        '(read-only t cursor-intangible t face minibuffer-prompt))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; tramp:

  ;; Workaround for problem with `tramp' hostname completions. This overrides
  ;; the completion style specifically for remote files! See
  ;; https://github.com/minad/vertico#tramp-hostname-completion

  (defun kb/basic-remote-try-completion (string table pred point)
    (and (vertico--remote-p string)
         (completion-basic-try-completion string table pred point)))
  (defun kb/basic-remote-all-completions (string table pred point)
    (and (vertico--remote-p string)
         (completion-basic-all-completions string table pred point)))
  (add-to-list 'completion-styles-alist
               '(basic-remote           ; Name of `completion-style
                 kb/basic-remote-try-completion kb/basic-remote-all-completions nil)))

(use-package vertico-repeat
  :demand t
  :after vertico
  :hook (minibuffer-setup-hook . vertico-repeat-save))

(use-package rfn-eshadow
  :config
  (file-name-shadow-mode 1))

(use-package vertico-directory
  :demand t
  :after rfn-eshadow
  :hook (rfn-eshadow-update-overlay-hook . vertico-directory-tidy))

(use-package consult
  :after vertico
  :demand t
  :custom
  (consult-narrow-key ">")
  :config
  ;; Use `consult-completion-in-region' if Vertico is enabled.
  ;; Otherwise use the default `completion--in-region' function.
  (setq completion-in-region-function
        (lambda (&rest args)
          (apply #'consult-completion-in-region args)))
  ;; thing at point
  (consult-customize
   consult-line
   :add-history (seq-some #'thing-at-point '(region symbol)))

  (defalias 'consult-line-symbol-at-point 'consult-line)
  (defalias 'consult-line-word-at-point 'consult-line)

  (consult-customize consult-line-word-at-point :initial (thing-at-point 'word))
  (consult-customize consult-line-symbol-at-point :initial (thing-at-point 'symbol))

  (defun my/consult-shell ()
    (interactive)
    (consult-buffer `(( :name     "shells"
                        :category buffer
                        :face     consult-buffer
                        :history  buffer-name-history
                        :state    ,#'consult--buffer-state
                        :items    ,(lambda ()
                                     (consult--buffer-query
                                      :predicate #'persp-is-current-buffer
                                      :mode 'shell-mode :as #'consult--buffer-pair))))))

  (defun my/consult-exwm-buffer ()
    (interactive)
    (consult-buffer `(( :name      "EXWM"
                        :category  buffer
                        :face      consult-buffer
                        :history   buffer-name-history
                        :action    ,#'exwm-workspace-switch-to-buffer
                        :items     ,(mapcar (lambda (b)
                                              (buffer-name (cdr b)))
                                            exwm--id-buffer-alist))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; embark

(use-package embark
  :commands (embark-insert-relative-path)
  :after consult
  :demand t
  :hook (embark-collect-mode-hook . consult-preview-at-point-mode)
  :config

  (defvar-keymap my/embark-vc-file-map
    :doc "Keymap for Embark VC file actions."
    "d" #'magit-file-delete
    "r" #'magit-file-rename)
  (fset 'my/embark-vc-file-map my/embark-vc-file-map)

  (defvar-keymap my/embark-file-find
    :doc "file find"
    :parent embark-general-map
    "f" #'find-file
    "F" #'my/remote-fleet-find-file
    "r" #'my/remote-fleet-find-file
    "l" #'find-file-literally
    "o" #'find-file-other-window)
  (fset 'my/embark-file-find my/embark-file-find)

  (defvar-keymap my/embark-insert
    :doc "file stuff"
    :parent embark-general-map
    "l" #'my/insert-line
    "L" #'my/insert-line-other
    "s" #'my/insert-shell-line)
  (fset 'my/embark-insert my/embark-insert)

  (defvar-keymap my/embark-file-operations
    :doc "file operations"
    :parent embark-general-map
    "d" #'delete-file
    "D" #'delete-directory
    "r" #'rename-file
    "c" #'copy-file
    "s" #'make-symbolic-link
    "m" #'chmod
    "+" #'make-directory)
  (fset 'my/embark-file-operations my/embark-file-operations)

  (defvar-keymap my/embark-path-operations
    :doc "path operations"
    :parent embark-general-map
    "i" #'embark-insert-relative-path
    "y" #'embark-save-relative-path)
  (fset 'my/embark-path-operations my/embark-path-operations)

  (defvar-keymap my/embark-file-map3
    :doc "Keymap for Embark file actions."
    :parent embark-general-map
    "RET" #'find-file
    "f" 'my/file-stuff
    "i" 'my/embark-insert
    "o" 'my/embark-file-operations
    "p" 'my/embark-path-operations
    "d" #'embark-dired-jump
    "$" #'shell
    "<" #'insert-file
    "l" #'load-file
    "v" 'my/embark-vc-file-map)

  (defvar-keymap my/embark-buffer-actions
    :doc "buffer actions"
    :parent embark-general-map
    "k" #'kill-buffer
    "b" #'switch-to-buffer
    "o" #'switch-to-buffer-other-window
    "r" #'embark-rename-buffer
    "=" #'ediff-buffers
    "|" #'embark-shell-command-on-buffer
    "<" #'insert-buffer
    "$" #'shell)
  (fset 'my/embark-buffer-actions my/embark-buffer-actions)

  (defvar-keymap my/embark-become-file+buffer-map
    :doc "Embark become keymap for files and buffers."
    :parent embark-meta-map
    "f" 'my/embark-file-stuff
    "i" 'my/embark-insert
    "o" 'my/embark-file-operations
    "p" 'my/embark-path-operations
    "b" 'my/embark-buffer-actions
    "d" #'embark-dired-jump
    "$" #'shell
    "." #'find-file-at-point
    "l" #'locate
    "L" #'find-library
    "v" #'magit-status)

  (defvar-keymap my/embark-symbol-map
    :doc "Keymap for Embark symbol actions."
    :parent embark-identifier-map
    "RET" #'embark-find-definition
    "h" #'describe-symbol
    "I" #'embark-info-lookup-symbol
    "d" #'embark-find-definition
    ;; "e" #'pp-eval-expression
    "a" #'apropos
    ;; "\\" #'embark-history-remove
    "*" #'consult-line-symbol-at-point
    "#" #'embark-isearch-forward)

  (defvar-keymap my/embark-become-match-map3
    :doc "Embark become keymap for search."
    :parent embark-meta-map
    "*" #'consult-line-symbol-at-point
    "C-*" #'consult-line-word-at-point
    "d" #'consult-ripfd
    "r" #'consult-ripgrep
    "/" #'projectile-ripgrep
    "'" #'projectile-find-file
    "p" #'projectile-switch-project
    "g" #'consult-git-grep
    "s" #'consult-outline
    "l" #'consult-line
    "f" #'consult-focus-lines
    "K" #'keep-lines
    "F" #'flush-lines
    "P" #'projectile-find-file)

  (defvar-keymap my/embark-become-shell-command-map
    :doc "Embark become keymap for shell commands."
    :parent embark-meta-map
    "!" #'shell-command
    "$" #'shell
    "&" #'async-shell-command)

  (setq embark-become-keymaps
        '(embark-become-help-map
          embark-become-file+buffer-map
          my/embark-become-shell-command-map
          my/embark-become-match-map3))

  (setq embark-keymap-alist
        '((file my/embark-file-map3)
          (library embark-library-map)
          (environment-variables my/embark-file-map3) ; they come up in file completion
          (url embark-url-map)
          (email embark-email-map)
          (buffer my/embark-buffer-map)
          (tab embark-tab-map)
          (expression embark-expression-map)
          (identifier embark-identifier-map)
          (defun embark-defun-map)
          (symbol my/embark-symbol-map)
          (face embark-face-map)
          (command embark-command-map)
          (variable embark-variable-map)
          (function embark-function-map)
          (minor-mode embark-command-map)
          (unicode-name embark-unicode-name-map)
          (package embark-package-map)
          (bookmark embark-bookmark-map)
          (region embark-region-map)
          (sentence embark-sentence-map)
          (paragraph embark-paragraph-map)
          (kill-ring embark-kill-ring-map)
          (heading embark-heading-map)
          (flymake embark-flymake-map)
          (smerge smerge-basic-map embark-general-map)
          (t embark-general-map)))

  (general-evil-define-key '(normal insert visual) minibuffer-mode-map
    "C-b"        #'embark-become)
  (setq embark-prompter #'embark-keymap-prompter)

  (defun my/embark-toggle-prompter ()
    (interactive)
    (setq embark-prompter
          (if (equal embark-prompter #'embark-completing-read-prompter)
              #'embark-keymap-prompter
            #'embark-completing-read-prompter))))

(use-package embark-consult
  :after embark)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; yasnippet

(use-package yasnippet
  :defer t
  :config
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  (yas-global-mode 1))

(use-package consult-yasnippet
  :after yasnippet
  :defer t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell / bash

;; (use-package pcmpl-args-autoloads
;;   :demand t)
;; (use-package pcmpl-unix
;;   :demand t
;;   :config
;;   (defalias 'pcomplete/copy #'pcomplete/scp))
;; (use-package pcmpl-gnu
;;   :demand t)
;; (use-package pcmpl-cvs
;;   :demand t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; search

(use-package isearch
  :custom
  (isearch-allow-scroll t)
  (isearch-lazy-count t)
  :bind ( :map isearch-mode-map
          ("C-e" . #'isearch-edit-string)))

(use-package rg)

(use-package wgrep
  :hook
  (rg-mode-hook . wgrep-rg-setup)
  :config
  (autoload 'wgrep-rg-setup "wgrep-rg"))

(use-package consult-ripfd
  :commands (consult-ripfd))

(use-package consult-dir
  :demand t)


(provide 'conf/completion)
;;; completion.el ends here
