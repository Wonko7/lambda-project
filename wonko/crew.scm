(define-module (wonko crew)
  #:use-module (srfi srfi-1)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (gnu packages bash)
  #:use-module (gnu)
  #:use-module (wonko defs)
  #:export (crew-name
            crew-uid
            crew-kb))

(define-record-type* <crew>
  crew make-crew
  crew?
  this-crew
  (name crew-name (sanitize (check string?)))
  (admin? crew-admin? (sanitize (check boolean?)))
  (uid crew-uid (sanitize (check number?)))
  (kb crew-kb (sanitize (check keyboard-layout?))))

(define-public %wonko
  (crew
   (name "wonko")
   (admin? #t)
   (uid 1042)
   (kb %dvorak-kb)))

(define-public %tina
  (crew
   (name "tina")
   (admin? #f)
   (uid 1069)
   (kb %fr-kb)))

(define-public %media
  (crew
   (name "media")
   (admin? #f)
   (uid 1099)
   (kb %dvorak-kb)))

(define-public (crew->user-account crew)
 (user-account
  (name (crew-name crew))
  (uid (crew-uid crew))
  (group "users")
  (home-directory (string-append "/home/" (crew-name crew)))
  (shell (file-append bash "/bin/bash"))
  (supplementary-groups
   (append '("lp" "wheel" "netdev" "audio" "video")
           (if (crew-admin? crew)
               '("wheel")
               '())))))

(define-public %crew (list %wonko %tina %media))
