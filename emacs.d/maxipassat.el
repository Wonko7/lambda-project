;;; maxipassat.el  -*- lexical-binding: t; -*-



(defun org-sql--disk-get-hashpathpairs ()
  "Get a list of hashpathpair for org files on disk.
Each hashpathpair will have it's :db-path set to nil. Only files in
`org-sql-files' will be considered."
  (cl-flet
      ((get-md5
         (fp)
         (org-sql--on-success (org-sql--run-command "md5sum" `(,fp) nil)
                              (car (s-split-up-to " " it-out 1))
                              (error "Could not get md5")))
       (expand-if-path
         (fp)
         (list fp)))
    (if (stringp org-sql-files)
        (error "`org-sql-files' must be a list of paths")
      (--map (cons (get-md5 it) it) org-sql-files))))

(setq org-sql-db-config '(postgres
                          :hostname "localhost"
                          :port 3000
                          :username "wonko"
                          :schema "org"
                          :database "maxipassat"))

;; (org-sql-user-init)

(setq org-sql-files
      '(
        ;; "here-be-dragons/wtf/20230822110052-hiking.org"
        "here-be-dragons/.www/maxipassat/en/greeting.org"
        "here-be-dragons/.www/maxipassat/fr/greeting.org"
        "here-be-dragons/.www/maxipassat/testing-123.org"
        "here-be-dragons/tech/20230412204446-shell.org"
        ;; "/data/org/here-be-dragons/tech/20201102214323-ocaml.org"
        "here-be-dragons/tech/20210621102226-postgresql.org"
        "here-be-dragons/_the-road-so-far/-archive/2025-10-01.org"
        "here-be-dragons/wtf/20210905155320-wtf.org"
        "here-be-dragons/media/20260208124347-twin_peaks.org"
        ))

(setq sql-postgres-program "/gnu/store/lgjbah69qnv6px06mkg8hgyfbksa6wrp-profile/bin/psql" )
(setq org-sql--psql-exe "/gnu/store/lgjbah69qnv6px06mkg8hgyfbksa6wrp-profile/bin/psql" )

(setq default-directory "/data/org/")

(org-sql-user-push)
(org-sql-clear-db)
