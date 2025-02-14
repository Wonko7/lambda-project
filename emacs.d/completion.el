(use-package marginalia
  :demand t
  :config
  (marginalia-mode 1)
  (setq marginalia-align 'right)
  (setq marginalia-max-relative-age 0))

(use-package orderless
  :demand t
  :config
  (setq completion-styles '(orderless basic) ;; Andrew Topin once mentioned that tramp needs basic for completion to work.
        completion-category-defaults nil
        completion-category-overrides nil)
  (setq completion-ignore-case t)

  ;; orderless-style-dispatchers
  ;; FIXME rewrite with orderless-affix-dispatch-alist on next release.
  (defun regex-if-twiddle (pattern _index _total)
    (when (string-suffix-p "~" pattern)
      `(orderless-regex . ,(substring pattern 0 -1))))

  (defun literal-if-equal (pattern _index _total)
    (when (string-suffix-p "=" pattern)
      `(orderless-literal . ,(substring pattern 0 -1))))

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
  )

;; (add-to-list completion-at-point-functions #'cape-symbol)
;; (setq completion-at-point-functions (list (cape-super-capf #'cape-symbol
;;                                                            #'cape-keyword
;;                                                            #'cape-dabbrev
;;                                                            #'cape-elisp-block
;;                                                            #'cape-file)))

(use-package vertico
  :demand t
  :config
  (keymap-set vertico-map "RET" #'vertico-directory-enter)
  (keymap-set vertico-map "DEL" #'vertico-directory-delete-char)
  (keymap-set vertico-map "M-DEL" #'vertico-directory-delete-word)
  (keymap-set vertico-map "C-DEL" #'vertico-directory-up)

  (vertico-mode)
  (vertico-mouse-mode)

  (general-evil-define-key '(normal insert) vertico-map
    "C-j" #'vertico-next
    "C-k" #'vertico-previous
    "<up>" #'vertico-previous
    "<down>" #'vertico-next)

  ;; FIXME `vertico-repeat-history' to `savehist-additional-variables'.

  ;; (setq vertico-scroll-margin 2) ;; Different scroll margin
  (setq vertico-count 20) ;; Show more candidates
  (setq vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (setq vertico-cycle t)

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

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
  :config
  ;; Use `consult-completion-in-region' if Vertico is enabled.
  ;; Otherwise use the default `completion--in-region' function.
  (setq completion-in-region-function
        (lambda (&rest args)
          (apply #'consult-completion-in-region args))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; embark

(use-package embark
  :commands (embark-insert-relative-path)
  :bind ( :map embark-general-map
          ("$" . #'shell)
          :map embark-library-map
          ("$" . #'shell)
          :map embark-buffer-map
          ("$" . #'shell)
          :map embark-bookmark-map
          ("$" . #'shell)
          :map embark-file-map
          ("g" . #'magit-file-dispatch)
          ("F" . #'my/remote-fleet-find-file)
          ("$" . #'shell)
          :map embark-become-file+buffer-map
          ("g" . #'magit-file-dispatch)
          ("F" . #'my/remote-fleet-find-file)
          ("b" . #'consult-buffer)
          ("l" . #'consult-line)
          ("/" . #'consult-ripgrep)
          ("$" . #'shell)
          :map embark-become-match-map
          ("g" . #'magit-file-dispatch)
          ("f" . #'find-file)
          ("F" . #'my/remote-fleet-find-file)
          ("b" . #'consult-buffer)
          ("l" . #'consult-line)
          ("/" . #'consult-ripgrep)
          ("u" . #'flush-lines))
  :after consult
  :hook (embark-collect-mode-hook . consult-preview-at-point-mode)
  :config
  (general-evil-define-key '(normal insert visual) minibuffer-mode-map
    "C-b"        #'embark-become)
  (setq embark-prompter 'embark-completing-read-prompter)
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

(use-package pcmpl-args-autoloads
  :demand t)
(use-package pcmpl-unix
  :demand t)
(use-package pcmpl-gnu
  :demand t)
(use-package pcmpl-cvs
  :demand t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; web stuff:

(use-package consult-omni
  :defer t
  :config
  (setq consult-omni-show-preview t) ;;; show previews
  ;; (setq consult-omni-preview-key "C-o")
  (setq consult-omni-multi-sources '("calc"
                                     ;; "File"
                                     ;; "Buffer"
                                     ;; "Bookmark"
                                     "Apps" ;; ??
                                     ;; "gptel"
                                     ;; "Brave"
                                     "Dictionary"
                                     "DuckDuckGo"
                                     "Wikipedia"
                                     ;; "PubMed"
                                     ;; "buffers text search"
                                     ;; "Notes Search"
                                     ;; "Org Agenda"
                                     "GitHub"
                                     ;; "StackOverflow"
                                     ;; "YouTube"
                                     ;; "Invidious"
                                     )))

(use-package consult-omni-sources
  :after consult-omni
  :config
  (consult-omni-sources-load-modules))

(use-package consult-omni-embark
  :after consult-omni)

(provide 'conf/completion)
;;; completion.el ends here
