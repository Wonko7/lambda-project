(define-module (wonko systems fleet)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (guix build utils)
  #:use-module (guix gexp)
  #:use-module (gnu machine)
  #:use-module (gnu machine ssh)
  #:use-module (gnu services base)
  #:use-module (wonko systems enterprise))

(use-package-modules bootloaders)

(list (machine
       (operating-system %enterprise-os)
       (environment managed-host-environment-type)
       (configuration (machine-ssh-configuration
                       (host-name "enterprise.local")
                       (system "x86_64-linux")
                       (user "root")
                       (identity "/root/.ssh/id_guix")
                       (port 22)))))
