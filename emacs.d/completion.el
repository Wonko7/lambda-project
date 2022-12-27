;; default config for orderless, vertico

(require 'consult)

(require 'vertico)
;; Different scroll margin
;; (setq vertico-scroll-margin 0)

;; Show more candidates
(setq vertico-count 20)

;; Grow and shrink the Vertico minibuffer
(setq vertico-resize t)

;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
(setq vertico-cycle t)
(vertico-mode)

;; Use `consult-completion-in-region' if Vertico is enabled.
;; Otherwise use the default `completion--in-region' function.
(setq completion-in-region-function
      (lambda (&rest args)
        (apply (if vertico-mode
                   #'consult-completion-in-region
                 #'completion--in-region)
               args)))


(require 'emacs)
(defun crm-indicator (args)
  (cons (format "[CRM%s] %s"
                (replace-regexp-in-string
                 "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                 crm-separator)
                (car args))
        (cdr args)))
(advice-add #'completing-read-multiple :filter-args #'crm-indicator)

(require 'corfu)
(require 'corfu-doc)
(require 'corfu-history)
(require 'corfu-info)

(global-corfu-mode)

;;(use-package corfu
;; Optional customizations
;; :custom
(setq corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
(setq corfu-auto nil)               ;; Enable auto completion
(setq corfu-separator ?\s)          ;; Orderless field separator
(setq corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
(setq corfu-quit-no-match nil)      ;; Never quit, even if there is no match
(setq corfu-preview-current nil)    ;; Disable current candidate preview
(setq corfu-preselect 'prompt)      ;; Preselect the prompt
(setq corfu-on-exact-match nil)     ;; Configure handling of exact matches
(setq corfu-scroll-margin 5)        ;; Use scroll margin
;; auto popup:
;; (setq corfu-auto-delay 0)
;; (setq corfu-auto-prefix 0)

(setq completion-cycle-threshold 3)
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
(setq enable-recursive-minibuffers t)


;; orderless

(require 'orderless)
(setq completion-styles '(orderless)
      completion-category-defaults nil
      completion-category-overrides nil)

;; orderless-style-dispatchers

(defun regex-if-twiddle (pattern _index _total)
  (when (string-suffix-p "~" pattern)
    `(orderless-regex . ,(substring pattern 0 -1))))

(defun literal-if-equal (pattern _index _total)
  (when (string-suffix-p "=" pattern)
    `(orderless-literal . ,(substring pattern 0 -1))))

(defun flex-if-quote (pattern _index _total)
  ;; also on prefix.
  (when (string-suffix-p "'" pattern)
    `(orderless-flex . ,(substring pattern 0 -1))))

(defun first-initialism (pattern index _total)
  (if (= index 0) 'orderless-initialism))

(defun without-if-bang (pattern _index _total)
  (cond
   ((equal "!" pattern)
    '(orderless-literal . ""))
   ((string-prefix-p "!" pattern)
    `(orderless-without-literal . ,(substring pattern 1)))))


(setq orderless-matching-styles '(orderless-literal)
      orderless-style-dispatchers '(;; first-initialism
                                    regex-if-twiddle
                                    flex-if-quote
                                    without-if-bang))

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

(provide 'conf/completion)
;;; completion.el ends here
