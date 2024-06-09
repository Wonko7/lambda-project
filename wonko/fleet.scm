(define-module (wonko fleet)
  #:use-module (guix build utils)
  #:use-module (guix gexp)
  #:use-module (gnu services base)
  #:export (%fleet-hosts
            %fleet-names))

(define-public %fleet-hosts
  (list
   (host "192.168.1.1" "daban-urnud.local")
   (host "192.168.1.3" "yggdrasill.local")
   (host "192.168.1.4" "rocinante.local")
   (host "192.168.1.6" "enterprise.local")
   (host "192.168.1.9" "nispe.local")))

(define-public %fleet-names (list "enterprise"
                                  "rocinante"
                                  "yggdrasill"
                                  "daban-urnud"))
