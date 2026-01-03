(define-module (wonko systems fleet)
  #:use-module (gnu)
  #:use-module (guix)
  #:use-module (guix build utils)
  #:use-module (guix gexp)
  #:use-module (gnu machine)
  #:use-module (gnu machine ssh)
  #:use-module (gnu services base)
  #:use-module (ice-9 match)
  #:use-module (wonko fleet)
  #:use-module (wonko systems daban-urnud)
  #:use-module (wonko systems discovery)
  #:use-module (wonko systems yggdrasill)
  #:use-module (wonko systems rocinante)
  #:use-module (wonko systems enterprise))

(use-package-modules bootloaders)

(map
 (match-lambda ((hostname os key)
                (machine
                  (operating-system os)
                  (environment managed-host-environment-type)
                  (configuration (machine-ssh-configuration
                                   (host-name
                                    (string-append hostname ".local"))
                                   (allow-downgrades? #t)
                                   (host-key key)
                                   (system "x86_64-linux")
                                   (user "root")
                                   (identity "/root/.ssh/id_guix")
                                   (port 22))))))
 (filter
  (match-lambda ((hn os key)
                 (and (not (string= hn (gethostname)))
                      (or (member hn '(;; just to make it easier to pick deployment:
                                       ;; "daban-urnud.star-fleet"
                                       "rocinante.star-fleet"
                                       "enterprise.star-fleet"
                                       "yggdrasill.star-fleet"
                                       "discovery.star-fleet"
                                       ))))))
  `(("discovery.star-fleet" ,%discovery-os
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEziBYp0d5ekUGRyY/yYayFz1y54t7QuXm4YE0DcmGyY")
    ("daban-urnud.star-fleet" ,%daban-urnud-os
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGP9vPQIofNGYfOT7AOqqmZ6TiM06f/84wYsHPDrKLVr")
    ("enterprise.star-fleet" ,%enterprise-os
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIx0IZ0N7CqF431lNvKGzmX4la95DRo25AirEeB+YkyH")
    ("yggdrasill.star-fleet" ,%yggdrasill-os
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBy585dRrMhGrilQX03YBntgKPGcUlP7WM1ET+uknMus")
    ("rocinante.star-fleet" ,%rocinante-os
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE0IndtUDb/hlus4gfsySCoRrN+qR1LTkDT1UXzVu42h"))))
