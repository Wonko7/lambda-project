(define-module (wonko services mail)
  #:use-module (gnu)
  #:use-module (guix packages)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages mail)
  #:use-module (gnu services mail)
  #:use-module (gnu services certbot)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (wonko packages mail)
  #:export (exim-deploy-hook))

(define exim-deploy-hook
  (program-file
   "exim-deploy-hook"
   #~(begin
       (unless (file-exists? "/etc/exim")
         (mkdir "/etc/exim"))
       (let* ((cert-directory (getenv "RENEWED_LINEAGE"))
              (user (getpw "exim"))
              (uid (passwd:uid user))
              (gid (passwd:gid user)))
         (copy-file (string-append cert-directory "/"
                                   (readlink (string-append cert-directory "/fullchain.pem")))
                    "/etc/exim/exim.crt")
         (copy-file (string-append cert-directory "/"
                                   (readlink (string-append cert-directory "/privkey.pem")))
                    "/etc/exim/exim.pem")
         (chown "/etc/exim" uid gid)
         (chown "/etc/exim/exim.crt" uid gid)
         (chown "/etc/exim/exim.pem" uid gid)
         (invoke
          #$(file-append psmisc "/bin/killall")
          #$(file-append exim-content-scan "/bin/exim"))))))
