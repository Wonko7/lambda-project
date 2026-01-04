(define-module (wonko systems maxipassat)
  #:use-module (gnu)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages databases)
  #:use-module (gnu services ci)
  #:use-module (gnu services databases)
  #:use-module (forge forge)
  #:use-module (forge laminar)
  #:use-module (forge utils)
  #:use-module (wonko crew))

(use-package-modules rsync)

(define base-dir "/data/www/maxi-passat/")
(define git-dir (string-append base-dir "ci/"))
(define db-dir (string-append base-dir "db/"))
(define org-repo (string-append git-dir "org/"))

(define update-db
  (with-imported-modules
      '((guix build utils))
    (with-packages
     (list autoconf automake coreutils
           gawk git-minimal gnu-make grep
           guile-3.0 sed pkg-config)
     #~(begin
         (use-modules
          (guix build utils))
         (invoke "git" "-c"
                 (string-append "safe.directory=" #$org-repo)
                 "clone" #$org-repo ".")
         (invoke "ls" "-l" )
         (invoke "git" "log" "-n1")
         (invoke "git" "branch")))))

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

;; sudo $(guix system container --network --share=/data/www/org wonko/ci.scm)
(define-public mp-dev-ci
  (operating-system
    (host-name "ci.maxi-pass.at")
    (timezone "UTC")
    (bootloader
      (bootloader-configuration
        (bootloader grub-bootloader)))
    (file-systems %base-file-systems)
    (users
     (append (map crew->user-account %crew)
             %base-user-accounts))
    (packages %base-packages)
    (services
     (cons*
      (service forge-service-type
               (forge-configuration
                (web-domain "of-course-i-still-love-you.star-fleet.local")
                (projects
                 (list org-project))))
      (service laminar-service-type
               (laminar-configuration
                 (bind-http "192.168.1.7:7777")))
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
host	all	all	192.168.1.1/32	trust
host	all	all	10.42.0.1/32	trust"))
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
