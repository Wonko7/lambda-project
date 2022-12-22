(define-configuration buffer
  ((default-modes (append '(vi-normal-mode dark-mode) %slot-default%))))

(define-configuration base-mode
  ((keymap-scheme
    (define-scheme (:name-prefix "my-base" :import %slot-default%)
      scheme:vi-normal
      (list "g b" (make-command switch-buffer* ()
                    (switch-buffer :current-is-last-p t)))))))

;; (defvar *my-keymap* (make-keymap "my-map"))
;; (define-key *my-keymap*
;;   "C-f" 'nyxt/web-mode:history-forwards
;;   "C-b" 'nyxt/web-mode:history-backwards)
;; 
;; (define-mode my-mode ()
;;   "Dummy mode for the custom key bindings in `*my-keymap*'."
;;   ((keymap-scheme (keymap:make-scheme
;;                    scheme:cua *my-keymap*
;;                    scheme:emacs *my-keymap*
;;                    scheme:vi-normal *my-keymap*))))
;; 
;; (define-configuration (buffer web-buffer)
;;   ((default-modes (append '(my-mode) %slot-default%))))
;; 
;; 
;; (defvar *my-search-engines*
;;   (list
;;    '("python3" "https://docs.python.org/3/search.html?q=~a" "https://docs.python.org/3")
;;    '("doi" "https://dx.doi.org/~a" "https://dx.doi.org/"))
;;   "List of search engines.")
;; 
;; (define-configuration buffer
;;   ((search-engines (append (mapcar (lambda (engine) (apply 'make-search-engine engine))
;;                                    *my-search-engines*)
;;                            %slot-default%))))
;; Note that the last search engine is the default one. For example, in order to make python3 the default, the above code can be slightly modified as follows.
;; 
;; 
;; (defvar *my-search-engines*
;;   (list
;;    '("doi" "https://dx.doi.org/~a" "https://dx.doi.org/")
;;    '("python3" "https://docs.python.org/3/search.html?q=~a" "https://docs.python.org/3")))
;; 
;; (define-configuration buffer
;;   ((search-engines (append %slot-default%
;;                            (mapcar (lambda (engine) (apply 'make-search-engine engine))
;;                                    *my-search-engines*)))))
