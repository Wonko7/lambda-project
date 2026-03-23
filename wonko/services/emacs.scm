(define-module (wonko services emacs)
  #:use-module (gnu)
  #:use-module (guix build utils)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11))

(use-package-modules emacs)
(use-service-modules guix shepherd)

(define-public export-agenda-service-type
  (let ((sync-and-export
         (program-file
          "export-agenda"
          #~(system
             (string-append
              ;; use the emacs packages from home profile:
              "source /home/wonko/.guix-home/profile/etc/profile; "
              "echo /data/www/static-org/www/so/ag.html | "
              ;; if we're relying on home profile, might as well use its emacs.
              ;; also, if the script fails and spews the agenda on stdout shepherd crashes.
              ;; utf8 or quantity?
              "emacs -Q --script /data/org/emacs/export-agenda.el 2>&1 > /dev/null")))))
    (shepherd-service-type
     'export-agenda
     (lambda _
       (shepherd-service
         (documentation "export emacs org agenda")
         (provision '(export-agenda))
         (requirement '(user-processes guix-daemon))
         (modules '((shepherd service timer)))
         (start
          #~(make-timer-constructor
             (calendar-event #:minutes '(2)
                             #:hours '(4))
             (command
              (list #$sync-and-export)
              #:user "wonko")
             #:wait-for-termination? #t))
         (stop #~(make-timer-destructor))))
     #t
     (description "export emacs org agenda"))))
