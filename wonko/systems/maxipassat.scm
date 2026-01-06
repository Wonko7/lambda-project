(define-module (wonko systems maxipassat)
  #:use-module (gnu)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages emacs)
  #:use-module (gnu services ci)
  #:use-module (gnu services databases)
  #:use-module (forge forge)
  #:use-module (forge laminar)
  #:use-module (forge utils)
  #:use-module (wonko crew)
  #:use-module (wonko packages emacs-xyz)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages emacs-build))

(use-package-modules rsync)

(define base-dir "/data/www/maxipassat/staging")
(define ci-dir (string-append base-dir "/ci"))
(define git-dir ci-dir)
(define db-dir (string-append base-dir "/db"))
(define org-repo (string-append git-dir "/org"))
(define mp-repo (string-append git-dir "/maxipassat"))
(define run-dir (string-append base-dir "/run")) ;; mkdir -p local/var/log/maxi_passat local/var/run/
(define guix-prof-dir (string-append base-dir "/run/guix-profile"))
(define mp-prof-dir (string-append base-dir "/run/mp-profile"))

(define forge-dir (string-append ci-dir "/forge")) ;; has to exist otherwise forge does not start

(define update-db
  (with-imported-modules
      '((guix build utils))
    (with-packages
     (list autoconf automake coreutils
           gawk git-minimal gnu-make grep
           guile-3.0 sed pkg-config
           findutils
           emacs emacs-org-sql emacs-org-ml
           emacs-dash emacs-s emacs-f
           postgresql)
     #~(begin
         (use-modules
          (guix build utils))
         (invoke "git" "-c"
                 (string-append "safe.directory=" #$org-repo)
                 "clone" #$org-repo ".")
         (invoke "git" "log" "-n1")
         (invoke "emacs" "-Q" "--script" ".ci/update-db.el")))))

(define update-mp
  (with-imported-modules
      '((guix build utils))
    (with-packages
     (list autoconf automake coreutils
           gawk git-minimal gnu-make grep
           guile-3.0 sed pkg-config guix)
     #~(begin
         (use-modules
          (guix build utils))
         (invoke "git" "-c"
                 (string-append "safe.directory=" #$mp-repo)
                 "clone" #$mp-repo ".")
         (invoke "pwd")
         (invoke "ls" "-la" )
         (invoke
          "guix" "pull" "-p" #$guix-prof-dir "-C"
          (string-append #$run-dir "/maxipassat-staging-channel.scm"))
         ~/.guix-extra-profiles/maxipassat/bin/guix install -p ~/.guix-extra-profiles/maxipassat-staging maxipassat
         (invoke
          (string-append #$guix-prof-dir "/bin/guix") "-p" #$mp-prof-dir "install" "maxipassat")))))

(define org-project
  (forge-project
   (name "org")
   (user "wonko")
   (repository org-repo) ;; needs to be --bare
   (description "org")
   (ci-jobs
    (list
     (forge-laminar-job
      (name "org")
      (run update-db))))))

(define org-project
  (forge-project
   (name "org")
   (user "wonko")
   (repository org-repo) ;; needs to be --bare
   (description "org")
   (ci-jobs
    (list
     (forge-laminar-job
      (name "org")
      (run update-db))))))

(define mp-project
  (forge-project
   (name "maxipassat")
   (user "wonko")
   (repository mp-repo) ;; needs to be --bare
   (description "maxipassat")
   (ci-jobs
    (list
     (forge-laminar-job
      (name "maxipassat")
      (run update-mp))))))

(define-public mp-dev-ci-services
  (list
   (service forge-service-type
            (forge-configuration
             (web-domain "")
             (websites-directory forge-dir)
             (projects
              (list org-project
                    ;; mp-project
                    ))))
   (service laminar-service-type
            (laminar-configuration
              (bind-http "192.168.1.7:7777")))))

;; sudo $(guix system container --network --share=/data/www/maxipassat/staging wonko/ci.scm)
(define-public mp-dev-ci
  (operating-system
    (host-name "ci.maxipass.at")
    (timezone "UTC")
    (bootloader
      (bootloader-configuration
        (bootloader grub-bootloader)))
    (file-systems %base-file-systems)
    (users
     (append (map crew->user-account %crew)
             %base-user-accounts))
    (packages %base-packages)
    (services (append mp-dev-ci-services
                      %base-services))))

(define-public mp-dev
  (operating-system
    ;; based on https://guix.gnu.org/cookbook/en/html_node/A-Database-Container.html
    (host-name "preprod.maxi-pass.at")
    (timezone "Europe/Paris")
    (file-systems (cons (file-system
                          (device (file-system-label "does-not-matter"))
                          (mount-point "/")
                          (type "ext4"))
                        %base-file-systems))
    (bootloader (bootloader-configuration
                  (bootloader grub-bootloader)))

    ;; (users
    ;;  (append (map crew->user-account %crew)
    ;;          %base-user-accounts))
    (services
     (cons* (service postgresql-service-type
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
                               (name "wonko")
                               (create-database? #t))))))
            %base-services))))
