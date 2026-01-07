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
  #:use-module (wonko packages emacs-xyz)
  #:use-module (wonko crew))

;; stateful init:
;; 1/ clone repos in repo dir.
;;   - maxipassat can be --bare
;;   - org needs to no be --bare
;;     + git config receive.denyCurrentBranch updateInstead
;;     + git config core.hooksPath hooks
;; 2/ init db from snapshot + grant priv to roles
;; 3/ mkdir maxipassat's run dirs
;; 4/ chown /data/www/maxipassat/staging/run/local/var/run/maxi_passat-cmd
;; 5/ sometimes postgres uid changes and you need to rechown db.

(define base-dir "/data/www/maxipassat/staging")
(define ci-dir (string-append base-dir "/ci"))
(define git-dir ci-dir)
(define db-dir (string-append base-dir "/db"))
(define org-repo (string-append git-dir "/org"))
(define mp-repo (string-append git-dir "/maxipassat"))
(define run-dir (string-append base-dir "/run")) ;; mkdir -p local/var/log/maxi_passat local/var/run/
(define guix-prof-dir (string-append run-dir "/guix-profile"))
(define mp-prof-dir (string-append run-dir "/mp-profile"))

(define forge-dir (string-append ci-dir "/forge")) ;; has to exist otherwise forge does not start

(define update-db
  (with-imported-modules
      '((guix build utils)
        (ice-9 ports))
    #~(begin
        (use-modules (ice-9 ports)
                     (guix build utils))
        (system "echo yes >> /tmp/ci.log")
        (system "ssh yggdrasill.local DISPLAY=:9 dunstify db-update started")
        (invoke
         (string-append #$guix-prof-dir "/bin/guix")
         "shell"
         "findutils" "postgresql"
         "emacs-minimal" "emacs-org-sql" "emacs-org-ml" "emacs-dash" "emacs-s" "emacs-f"
         "--"
         "emacs"
         "-Q" "--script" ".ci/update-db.el")
        (system "echo done >> /tmp/ci.log")
        (system "ssh yggdrasill.local DISPLAY=:9 dunstify db-update done")
        (let ((port (open-file (string-append #$run-dir "/local/var/run/maxi_passat-cmd")
                               "w")))
          (display "maxi-passat:preprocess_org\n" port)
          (close-port port)))))

(define update-mp
  (with-imported-modules
      '((guix build utils))
    #~(begin
        (use-modules (ice-9 ports)
                     (guix build utils))
        (invoke
         "/run/current-system/profile/bin/guix"
         "pull" "--allow-downgrades" "-p" #$guix-prof-dir "-C"
         (string-append #$run-dir "/maxipassat-staging-channel.scm"))
        (invoke
         (string-append #$guix-prof-dir "/bin/guix")
         "install" "-p" #$mp-prof-dir "maxipassat")
        (let ((port (open-file (string-append #$run-dir "/local/var/run/maxi_passat-cmd")
                               "w")))
          (display "maxi-passat:kys\n" port)
          (close-port port)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; services:

(define-public maxipassat-services
  (list

   (service postgresql-service-type
            (postgresql-configuration
              (postgresql postgresql)
              (data-directory db-dir)
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
                    ("log_directory"    "/var/log/postgresql")))))))
   (service postgresql-role-service-type
            (postgresql-role-configuration
             (roles
              (list (postgresql-role
                      (name "www")
                      (create-database? #t))
                    (postgresql-role
                      (name "wonko")
                      (create-database? #t))))))

   (simple-service 'maxipassat-service
                   shepherd-root-service-type
                   (list
                    (shepherd-service
                      (provision '(maxipassat))
                      (requirement '(user-processes networking))
                      (documentation "maxipassat")
                      ;; (respawn-delay 1)
                      (respawn-limit #~'(1 . 5000))
                      (start #~(make-forkexec-constructor
                                (list (string-append #$mp-prof-dir "/bin/maxi_passat"))
                                #:user "www"
                                #:environment-variables (cons*
                                                         "DBPORT=5432"
                                                         "DBUSER=www"
                                                         (default-environment-variables))
                                #:directory #$run-dir))
                      (stop #~(make-kill-destructor)))))

   (extra-special-file (string-append mp-repo "/hooks/post-receive")
                       (program-file "mp_post-receive" update-mp))

   (extra-special-file (string-append org-repo "/hooks/post-receive")
                       (program-file "org_post-receive" update-db))))
