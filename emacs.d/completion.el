;; default config for orderless, vertico

(require 'marginalia)
(require 'orderless)
(require 'consult)
(require 'vertico)
(require 'vertico-repeat)
(add-hook 'minibuffer-setup-hook #'vertico-repeat-save)
;; FIXME `vertico-repeat-history' to `savehist-additional-variables'.
(require 'vertico-directory)

(vertico-mode)
(vertico-mouse-mode)

(keymap-set vertico-map "RET" #'vertico-directory-enter)
(keymap-set vertico-map "DEL" #'vertico-directory-delete-char)
(keymap-set vertico-map "M-DEL" #'vertico-directory-delete-word)
(keymap-set vertico-map "C-DEL" #'vertico-directory-up)
(add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)

(marginalia-mode 1)
(setq marginalia-align 'right)
(setq marginalia-max-relative-age 0)

;; Different scroll margin
;; (setq vertico-scroll-margin 2)

;; Show more candidates
(setq vertico-count 20)

;; Grow and shrink the Vertico minibuffer
(setq vertico-resize t)

;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
(setq vertico-cycle t)

;; (vertico-multiform-mode)
;; (setq vertico-multiform-categories '((file grid)
;;                                      (consult-grep buffer)))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fancy

;; Prefix the current candidate with “» ”. From
;; https://github.com/minad/vertico/wiki#prefix-current-candidate-with-arrow
;; (defvar +vertico-current-arrow t)
;;
;; (cl-defmethod vertico--format-candidate :around
;;   (cand prefix suffix index start &context ((and +vertico-current-arrow
;;                                                  (not (bound-and-true-p vertico-flat-mode)))
;;                                             (eql t)))
;;   (setq cand (cl-call-next-method cand prefix suffix index start))
;;   (if (bound-and-true-p vertico-grid-mode)
;;       (if (= vertico--index index)
;;           (concat #("▶" 0 1 (face vertico-current)) cand)
;;         (concat #("_" 0 1 (display " ")) cand))
;;     (if (= vertico--index index)
;;         (concat
;;          #(" " 0 1 (display (left-fringe right-triangle vertico-current)))
;;          cand)
;;       cand)))

;; Prefix the current candidate with “» ”. From
;; https://github.com/minad/vertico/wiki#prefix-current-candidate-with-arrow
(advice-add #'vertico--format-candidate :around
            (lambda (orig cand prefix suffix index _start)
              (setq cand (funcall orig cand prefix suffix index _start))
              (concat
               (if (= vertico--index index)
                   (propertize "▶ " 'face 'vertico-current)
                 "  ")
               cand)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tramp

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
             '(basic-remote           ; Name of `completion-style'
               kb/basic-remote-try-completion kb/basic-remote-all-completions nil))


(provide 'conf/completion)
;;; completion.el ends here
