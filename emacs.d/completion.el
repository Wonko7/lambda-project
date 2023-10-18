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
        (apply #'consult-completion-in-region args)))


(require 'emacs)
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
(setq enable-recursive-minibuffers t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; orderless

(require 'orderless)
(setq completion-styles '(orderless)
      completion-category-defaults nil
      completion-category-overrides nil)
(setq completion-ignore-case t)

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

(defun first-flex (pattern index _total)
  (if (= index 0) 'orderless-flex))

(defun without-if-bang (pattern _index _total)
  (cond
   ((equal "!" pattern)
    '(orderless-literal . ""))
   ((string-prefix-p "!" pattern)
    `(orderless-without-literal . ,(substring pattern 1)))))


(setq orderless-matching-styles '(char-fold-to-regexp)
      orderless-style-dispatchers '(regex-if-twiddle
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; yasnippet

(require 'yasnippet)
(require 'consult-yasnippet)

(setq yas-snippet-dirs '("~/.emacs.d/snippets"))
(yas-global-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shell / bash


(require 'pcmpl-args-autoloads)
(require 'pcmpl-unix)
(require 'pcmpl-gnu)
(require 'pcmpl-cvs)

(when (< emacs-major-version 29) ;; FIXME
  ;; Silence the pcomplete capf, no errors or messages!
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)

  ;; Ensure that pcomplete does not write to the buffer
  ;; and behaves as a pure `completion-at-point-function'.
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify))

;; (add-to-list completion-at-point-functions #'cape-symbol)
(setq completion-at-point-functions (list (cape-super-capf #'cape-symbol
                                                           #'cape-keyword
                                                           #'cape-dabbrev
                                                           #'cape-elisp-block
                                                           #'cape-file)))

(provide 'conf/completion)
;;; completion.el ends here
