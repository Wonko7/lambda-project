;;; maxipassat.el  -*- lexical-binding: t; -*-

(org-ql-sparse-tree '(org-ql-query

                       :select nil
                       :from   '("/data/org/here-be-dragons/20210825151927-mont_ussy.org"
                                 "/data/org/here-be-dragons/the-road-so-far/2024-05-28.org")
                       :where '(and (tags "pub")
                                    (tags "mp"))))

(let ((maxi-passat (org-ql-query
                     :select nil
                     :from   '("/data/org/here-be-dragons/20210825151927-mont_ussy.org"
                               "/data/org/here-be-dragons/the-road-so-far/2024-05-28.org")
                     :where '(and (tags "pub")
                                  (tags "mp")
                                  (not (tags "is" "crypt"))))))
  (object-print

   maxi-passat))
(org-ql-select (org-agenda-files)
  '(todo "WAITING")
  :action 'element)
(let ((maxi-passat (org-ql-select
                     '("/data/org/here-be-dragons/20210825151927-mont_ussy.org"
                       "/data/org/here-be-dragons/the-road-so-far/2024-05-28.org")
                     '(and (tags "pub")
                           (tags "mp")
                           (not (tags "is" "crypt")))
:action 'element
                     )))
  (object-print maxi-passat))


(require 'org-element)

(setq-local org-use-tag-inheritance nil)

(tt-print-heading-has-id
 (get-file-buffer "/data/org/here-be-dragons/the-road-so-far/2024-05-28.org"))


(tt-print-heading-has-id ())
(defun tt-print-heading-has-id (b)
  "print headings that have property named :ID: and print the property value.
2019-01-14"
  (interactive)
  (with-current-buffer b
    (with-output-to-temp-buffer "what"
      (org-element-map (org-element-parse-buffer) 'headline
        (lambda (x)
          (let ((myid (org-element-property :ID x)))
            (when t
              (princ "heading: " )
              (princ (org-element-property :raw-value x))
              ;;(terpri )
              ;; (princ "ID value is: " )
              ;; (princ myid )
              (princ (org-element-interpret-data x))
              (terpri )
              (princ "children: " )
              (princ (org-element-contents x) )
              (mapc (lambda (x)
                      (princ "child: " )
                      (princ x)
                      (terpri))
                    (org-element-map (org-element-contents x) 'org-element-all-elements
                      #'org-element-interpret-data ))
              (terpri )
              )))))))


(defun tt-print-heading-has-id (b)
  "print headings that have property named :ID: and print the property value.
2019-01-14"
  (interactive)
  (display (org-element-parse-buffer)))

;; dev
(add-to-list 'load-path "/code/emacs/org-ml")
(add-to-list 'load-path "/code/emacs/org-sql")
(require 'org-ml)
(require 'org-sql)

(setq org-sql-db-config '(postgres
                         :hostname "localhost"
                         :port 3000
                         :username "wonko"
                         :schema "org"
                         :database "maxi_passat"))

(org-sql-user-init)

(defun my/tmp-files ()
  (org-ql-search-directories-files
   :recurse t
   :directories (list org-roam-directory)
   ))

(setq org-sql-async nil)
(setq org-sql-debug t)
(setq org-sql-files
      '("/data/org/here-be-dragons/20210825151927-mont_ussy.org"
        "/data/org/here-be-dragons/the-road-so-far/_archive/2024-05-28.org"
        "/data/org/here-be-dragons/test.org"
        "/data/org/here-be-dragons/20211031184333-gorges_du_houx.org"
        ))

(setq org-sql-files (my/tmp-files ))
(org-sql-user-push)
