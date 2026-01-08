(define-module (wonko systems maxipassat)
  #:use-module (ice-9 ports)
  #:use-module (gnu)
  #:use-module (gnu services databases)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages emacs-build)
  #:use-module (guix records)
  #:use-module (guix modules)
  #:use-module (wonko packages emacs-xyz)
  #:use-module (wonko crew)
  #:export (maxipassat-ci-service-type
            maxipassat-ci-configuration
            make-maxipassat-ci-configuration
            maxipassat-ci-configuration?
            maxipassat-ci-deployment-name
            maxipassat-ci-base-path
            maxipassat-ci-notify
            maxipassat-ci-db-user
            maxipassat-ci-db-port
            maxipassat-ci-db-host
            maxipassat-ci-db-pass
            maxipassat-ci-db-name
            maxipassat-ci-org-repo-origin
            maxipassat-ci-maxipassat-repo-origin
            ))

;; stateful init:
;; run in a container with maxipassat-init-ci-services
;; run base-path/init
;; init database
;; kill container and run maxipassat-services

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; paths
;;(use-modules (guix records))

(define-record-type* <maxipassat-ci-configuration>
  maxipassat-ci-configuration make-maxipassat-ci-configuration
  maxipassat-ci-configuration?
  (deployment-name maxipassat-ci-deployment-name (default "staging"))
  (base-path maxipassat-ci-base-path (default #f)) ;; you need to set this
  (notify maxipassat-ci-notify (default (lambda (title status) #~#t)))
  (db-user maxipassat-ci-db-user (default "www"))
  (db-port maxipassat-ci-db-port (default "5432"))
  (db-host maxipassat-ci-db-host (default "localhost"))
  (db-pass maxipassat-ci-db-pass (default ""))
  (db-name maxipassat-ci-db-name (default "maxi_passat"))
  (org-repo-origin maxipassat-ci-org-repo-origin (default #f))
  (maxipassat-repo-origin maxipassat-ci-maxipassat-repo-origin (default #f))
  ;; (path maxipassat-ci-path (default "/you/need/to/set/this"))
  )

(define (make-paths base-path)
  (let* ((ci-path (string-append base-path "/ci"))
         (git-path ci-path)
         (db-path (string-append base-path "/db"))
         (org-repo-path (string-append git-path "/org"))
         (mp-repo-path (string-append git-path "/maxipassat"))
         (emacs-update-db-job-path (string-append org-repo-path "/.ci/update-db.el")) ;; could be anywhere
         (run-path (string-append base-path "/run"))
         (guix-prof-root-path (string-append ci-path "/gp"))
         (guix-prof-path (string-append guix-prof-root-path "/guix-profile"))
         ;; keeping this as a profile and not an guix shell so you can rollback to previous versions:
         (mp-prof-path (string-append guix-prof-root-path "/mp-profile"))
         (mp-channel-path (string-append guix-prof-root-path "/mp-channel.scm")))
    (lambda (s)
      (assoc-ref
       `((ci                  . ,ci-path)
         (git                 . ,git-path)
         (db                  . ,db-path)
         (org-repo            . ,org-repo-path)
         (mp-repo             . ,mp-repo-path)
         (emacs-update-db-job . ,emacs-update-db-job-path)
         (run                 . ,run-path)
         (guix-prof-root      . ,guix-prof-root-path)
         (guix-prof           . ,guix-prof-path)
         (mp-prof             . ,mp-prof-path)
         (mp-channel          . ,mp-channel-path))
       s))))

(let ((paths (make-paths "/lol")))
  (paths 'db))

(define base-path "/data/www/maxipassat/staging")
(define ci-path (string-append base-path "/ci"))
(define git-path ci-path)
(define db-path (string-append base-path "/db"))
(define org-repo-path (string-append git-path "/org"))
(define mp-repo-path (string-append git-path "/maxipassat"))
(define emacs-update-db-job-path (string-append org-repo-path "/.ci/update-db.el")) ;; could be anywhere
(define run-path (string-append base-path "/run")) ;; mkdir -p local/var/log/maxi_passat local/var/run/
(define guix-prof-root-path (string-append ci-path "/gp"))
(define guix-prof-path (string-append guix-prof-root-path "/guix-profile"))
;; keeping this as a profile and not an guix shell so you can rollback to previous versions:
(define mp-prof-path (string-append guix-prof-root-path "/mp-profile"))
(define mp-channel-path (string-append guix-prof-root-path "/mp-channel.scm"))

;; repos
(define mp-origin "yggdrasill.local:/code/maxi-passat/maxi_passat/")
(define org-origin "yggdrasill.local:/data/org")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; jobs
;; maxipassat-ci-org-repo-origin
(define (make-mp-channel mp-repo-path) ;; used to guix pull & build on each git push
  #~(cons* (channel
             (name 'mp)
             (url #$mp-repo-path)
             (branch "master"))
           %default-channels))

;; (define (update-mp-guix-build-cmds chan-path)
;;   #~(begin
;;       (invoke
;;        "/run/current-system/profile/bin/guix"
;;        "pull" "--allow-downgrades" "-p" #$guix-prof-path "-C" #$chan-path)
;;       (invoke
;;        (string-append #$guix-prof-path "/bin/guix")
;;        "install" "-p" #$mp-prof-path "maxipassat")))

(define (update-mp-guix-build-cmds chan-path paths)
  #~(begin
      (invoke
       "/run/current-system/profile/bin/guix"
       "pull" "--allow-downgrades" "-p" #$(paths 'guix-prof) "-C" #$chan-path)
      (invoke
       (string-append #$(paths 'guix-prof) "/bin/guix")
       "install" "-p" #$(paths 'mp-prof) "maxipassat")))

;; (define update-mp-job
;;   (with-imported-modules
;;       '((guix build utils))
;;     #~(begin
;;         (use-modules (ice-9 ports)
;;                      (guix build utils))
;;         (system "ssh yggdrasill.local DISPLAY=:9 dunstify mp-update started")
;;         #$(update-mp-guix-build-cmds mp-channel-path)
;;         (system "ssh yggdrasill.local DISPLAY=:9 dunstify mp-update done")
;;         (let ((port (open-file (string-append #$run-path "/local/var/run/maxi_passat-cmd")
;;                                "w")))
;;           (display "maxi-passat:kys\n" port)
;;           (close-port port)))))

;; (define update-db-job
;;   (with-imported-modules
;;       '((guix build utils)
;;         (ice-9 ports))
;;     (let ((packages '("git-minimal" "findutils" "postgresql"
;;                       "emacs-minimal" "emacs-org-sql" "emacs-org-ml"
;;                       "emacs-dash" "emacs-s" "emacs-f")))
;;       #~(begin
;;           (use-modules (ice-9 ports)
;;                        (guix build utils))
;;           (system "ssh yggdrasill.local DISPLAY=:9 dunstify db-update started")
;;           (unsetenv "GIT_DIR")
;;           (chdir "../working-org")
;;           (invoke
;;            (string-append #$guix-prof-path "/bin/guix") "shell" #$@packages
;;            "--" "git" "pull" "--force")
;;           (invoke
;;            (string-append #$guix-prof-path "/bin/guix") "shell" #$@packages
;;            "--" "emacs" "-Q" "--script" #$emacs-update-db-job-path)
;;           (system "ssh yggdrasill.local DISPLAY=:9 dunstify db-update done")
;;           (let ((port (open-file (string-append #$run-path "/local/var/run/maxi_passat-cmd")
;;                                  "w")))
;;             (display "maxi-passat:preprocess_org\n" port)
;;             (close-port port))))))

;; (define emacs-update-db-job
;;   (mixed-text-file "update-db.el"
;;                    "(require 'org-sql)

;;    (defun org-sql--disk-get-hashpathpairs ()
;;      \"Get a list of hashpathpair for org files on disk.
;; Each hashpathpair will have it's :db-path set to nil. Only files in
;; `org-sql-files' will be considered.\"
;;      (cl-flet
;;       ((get-md5
;;         (fp)
;;         (org-sql--on-success (org-sql--run-command \"md5sum\" `(,fp) nil)
;;                              (car (s-split-up-to \" \" it-out 1))
;;                              (error \"Could not get md5\")))
;;        (expand-if-path
;;         (fp)
;;         (if (not (file-directory-p fp)) `(,fp)
;;             (directory-files fp t \"\\`.*\\.org\\(_archive\\)?\\'\"))))
;;       (if (stringp org-sql-files)
;;           (error \"`org-sql-files' must be a list of paths\")
;;           (->> (-mapcat #'expand-if-path org-sql-files)
;;                ;; This is why I'm redefining this: -> I want the relative path:
;;                ;; (-map #'expand-file-name)
;;                (-filter #'file-exists-p)
;;                (-uniq)
;;                (--map (cons (get-md5 it) it))))))

;;    ;; (org-sql-user-init) -> you'll need to run that once first time you're creating your db

;;    (setq org-sql-db-config '(postgres
;;                              :hostname \"localhost\"
;;                              :port 5432
;;                              :username \"wonko\"
;;                              :schema \"org\"
;;                              :database \"maxi_passat\"))

;;    (setq org-sql-files
;;          (split-string ;; this is the entry point to the org files I want in DB:
;;           (shell-command-to-string \"find here-be-dragons/ -name '*.org'\") \"\n\" t))

;;    (org-sql-user-push)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; services:

;; (define-public maxipassat-init-ci-services
;;   ;; can't run guix inside a container, this is provided as helper but still stateful :(
;;   ;; run this in your container instead of maxipassat-services, run base-path/init from outside
;;   ;; the container, might as well init db. then run maxipassat-services.
;;   (let ((tmp-chan-path (string-append base-path "/channel.scm")))
;;     (cons*
;;      (extra-special-file tmp-chan-path
;;                          (scheme-file "mp-channel.scm"
;;                                       mp-channel))
;;      (extra-special-file
;;       (string-append base-path "/init-ci")
;;       (program-file "init-ci"
;;                     (with-imported-modules '((guix build utils))
;;                       #~(begin
;;                           (use-modules (guix build utils))
;;                           (display "hello!\n")
;;                           (when (not (directory-exists? #$guix-prof-path))
;;                             (display "making paths!\n")
;;                             (mkdir-p #$ci-path)
;;                             (mkdir-p #$guix-prof-root-path)
;;                             (mkdir-p (string-append #$run-path "/local/var/run"))
;;                             (mkdir-p (string-append #$run-path "/local/var/log/maxi_passat"))
;;                             (display "git repos init!\n")
;;                             (invoke  "git" "clone" "--bare"
;;                                      #$mp-origin #$mp-repo-path)
;;                             (invoke "git" "clone" "--bare"
;;                                     #$org-origin #$org-repo-path)
;;                             (invoke "git" "clone"
;;                                     #$org-repo-path
;;                                     (string-append #$org-repo-path "/../working-org"))
;;                             (display "guix profile build!\n")
;;                             (invoke "guix" "pull" "-p" #$guix-prof-path "-C" #$tmp-chan-path)
;;                             #$(update-mp-guix-build-cmds tmp-chan-path))
;;                           #t))))
;;      database-services)))

;; (define-public maxipassat-services
;;   (cons*
;;    (simple-service 'maxipassat-service
;;                    shepherd-root-service-type
;;                    (list
;;                     (shepherd-service
;;                       (provision '(maxipassat-ownership))
;;                       (requirement '(user-processes networking))
;;                       (documentation "init ownership")
;;                       (one-shot? #t)
;;                       (start #~(lambda _
;;                                  ;; (let* ((user (getpw "wesnothd"))
;;                                  ;;        (directory "/var/run/wesnothd"))
;;                                  ;;   ;; wesnothd creates a Unix-domain socket in DIRECTORY.
;;                                  ;;   (mkdir-p directory)
;;                                  ;;   (chown directory (passwd:uid user) (passwd:gid user)))
;;                                  (invoke "chown" "postgres:postgres" "-R" #$db-path)
;;                                  (invoke "chown" "www:users" "-R" #$run-path))))))

;;    (simple-service 'maxipassat-init-ownership-service
;;                    shepherd-root-service-type
;;                    (list
;;                     (shepherd-service
;;                       (provision '(maxipassat))
;;                       (requirement '(user-processes networking maxipassat-ownership))
;;                       (documentation "maxipassat")
;;                       ;; (respawn-delay 1)
;;                       (respawn-limit #~'(1 . 5000))
;;                       (start #~(make-forkexec-constructor
;;                                 (list (string-append #$mp-prof-path "/bin/maxi_passat"))
;;                                 #:user "www"
;;                                 #:group "users"
;;                                 #:environment-variables (cons*
;;                                                          "DBPORT=5432"
;;                                                          "DBUSER=www"
;;                                                          (default-environment-variables))
;;                                 #:directory #$run-path))
;;                       (stop #~(make-kill-destructor)))))

;;    (extra-special-file (string-append mp-repo-path "/hooks/post-receive")
;;                        (program-file "mp_post-receive" update-mp-job))

;;    (extra-special-file (string-append org-repo-path "/hooks/post-receive")
;;                        (program-file "org_post-receive" update-db-job))

;;    (extra-special-file emacs-update-db-job-path
;;                        emacs-update-db-job)

;;    (extra-special-file mp-channel-path
;;                        (scheme-file "mp-channel.scm" mp-channel))

;;    database-services))

;;; new

(define-public maxipassat-ci-postgresql-service
  (match-record-lambda <maxipassat-ci-configuration>
      (base-path)
    (define paths (make-paths base-path))
    (service postgresql-service-type
             (postgresql-configuration
               (postgresql postgresql)
               (data-directory (paths 'db))
               (config-file
                (postgresql-config-file
                  (log-destination "stderr")
                  (hba-file
                   (plain-file "pg_hba.conf"
                               "\
local	all	all			trust
host	all	all	127.0.0.1/32	trust
#host	all	all	192.168.1.7/32	trust
#host	all	all	10.42.0.1/32	trust"))
                  (extra-config
                   '(("listen_addresses" "*")
                     ("log_directory"    "/var/log/postgresql")))))))))

(define maxipassat-ci-postgresql-role
  (match-record-lambda <maxipassat-ci-configuration>
      (db-user)
    (list (postgresql-role
            (name db-user)
            (create-database? #t))
          (postgresql-role
            (name "wonko")
            (create-database? #t)))))

;; (define database-services
;;   (list (service postgresql-service-type
;;                  (postgresql-configuration
;;                    (postgresql postgresql)
;;                    (data-directory db-path)
;;                    (config-file
;;                     (postgresql-config-file
;;                       (log-destination "stderr")
;;                       (hba-file
;;                        (plain-file "pg_hba.conf"
;;                                    "\
;; local	all	all			trust
;; host	all	all	127.0.0.1/32	trust
;; #host	all	all	192.168.1.7/32	trust
;; #host	all	all	10.42.0.1/32	trust"))
;;                       (extra-config
;;                        '(("listen_addresses" "*")
;;                          ("log_directory"    "/var/log/postgresql")))))))

;;         (service postgresql-role-service-type
;;                  (postgresql-role-configuration
;;                   (roles
;;                    (list (postgresql-role
;;                            (name "www")
;;                            (create-database? #t))
;;                          (postgresql-role
;;                            (name "wonko")
;;                            (create-database? #t))))))))



(define maxipassat-ci-files-service
  (match-record-lambda <maxipassat-ci-configuration>
      (base-path deployment-name db-name db-user db-pass db-port db-host notify)

    (define paths (make-paths base-path))

    (define mp-channel (make-mp-channel (paths 'mp-repo)))

    (define update-mp-job
      (with-imported-modules
          '((guix build utils))
        #~(begin
            (use-modules (ice-9 ports)
                         (guix build utils))
            #$(notify "mp-update" (string-append deployment-name ": started"))
            #$(update-mp-guix-build-cmds mp-channel-path paths)
            #$(notify "mp-update" (string-append deployment-name ": done"))
            (let ((port (open-file (string-append #$(paths 'run) "/local/var/run/maxi_passat-cmd")
                                   "w")))
              (display "maxi-passat:kys\n" port)
              (close-port port)))))

    (define update-db-job
      (with-imported-modules
          '((guix build utils)
            (ice-9 ports))
        (let ((packages '("git-minimal" "findutils" "postgresql"
                          "emacs-minimal" "emacs-org-sql" "emacs-org-ml"
                          "emacs-dash" "emacs-s" "emacs-f")))
          #~(begin
              (use-modules (ice-9 ports)
                           (guix build utils))
              (display "yes, new db update file") ;; FIXME
              #$(notify "db-update" (string-append deployment-name ": started"))
              (unsetenv "GIT_DIR")
              (chdir "../working-org")
              (invoke
               (string-append #$(paths 'guix-prof) "/bin/guix") "shell" #$@packages
               "--" "git" "pull" "--force")
              (invoke
               (string-append #$(paths 'guix-prof) "/bin/guix") "shell" #$@packages
               "--" "emacs" "-Q" "--script" #$(paths 'emacs-update-db-job))
              #$(notify "db-update" (string-append deployment-name ": done"))
              (let ((port (open-file (string-append #$run-path "/local/var/run/maxi_passat-cmd")
                                     "w")))
                (display "maxi-passat:preprocess_org\n" port)
                (close-port port))))))

    (define emacs-update-db-job
      (mixed-text-file "update-db.el"
                       "
(require 'org-sql)

(defun org-sql--disk-get-hashpathpairs ()
  \"Get a list of hashpathpair for org files on disk.
Each hashpathpair will have it's :db-path set to nil. Only files in
`org-sql-files' will be considered.\"
  (cl-flet
   ((get-md5
     (fp)
     (org-sql--on-success (org-sql--run-command \"md5sum\" `(,fp) nil)
                          (car (s-split-up-to \" \" it-out 1))
                          (error \"Could not get md5\")))
    (expand-if-path
     (fp)
     (if (not (file-directory-p fp)) `(,fp)
         (directory-files fp t \"\\`.*\\.org\\(_archive\\)?\\'\"))))
   (if (stringp org-sql-files)
       (error \"`org-sql-files' must be a list of paths\")
       (->> (-mapcat #'expand-if-path org-sql-files)
            ;; This is why I'm redefining this: -> I want the relative path:
            ;; (-map #'expand-file-name)
            (-filter #'file-exists-p)
            (-uniq)
            (--map (cons (get-md5 it) it))))))

;; (org-sql-user-init) -> you'll need to run that once first time you're creating your db

(setq org-sql-db-config '(postgres
                          :hostname \"" db-host "\"
                          :port "db-port"
                          :username \"" db-user "\"
                          :schema \"org\"
                          :database \"" db-name "\"))

(setq org-sql-files
      (split-string ;; this is the entry point to the org files I want in DB:
       (shell-command-to-string \"find here-be-dragons/ -name '*.org'\") \"\n\" t))

(org-sql-user-push)"))

    (let ((paths (make-paths base-path)))
      `((,(string-append (paths 'mp-repo) "/hooks/post-receive")
         ,(program-file "mp_post-receive" update-mp-job))
        (,(string-append (paths 'org-repo) "/hooks/post-receive")
         ,(program-file "org_post-receive" update-db-job))
        (,(paths 'emacs-update-db-job)
         ,emacs-update-db-job)
        (,(paths 'mp-channel)
         ,(scheme-file "mp-channel.scm" mp-channel))))))

(define maxipassat-ci-service-type
  (service-type
    (name 'maxipassat-ci)
    (default-value (maxipassat-ci-configuration))
    (extensions
     (list
      ;; (service-extension postgresql-service-type
      ;;                    maxipassat-ci-postgresql-service)
      (service-extension postgresql-role-service-type
                         maxipassat-ci-postgresql-role)
      ;; (service-extension shepherd-root-service-type
      ;;                    maxipassat-ci-shepherd-service)
      (service-extension special-files-service-type
                         maxipassat-ci-files-service)))
    (description "maxipassat ci")))

(special-files-service-type)
