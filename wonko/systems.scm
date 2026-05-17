(define-module (wonko systems)
  #:use-module (gnu)
  #:use-module (guix gexp)
  #:use-module (guix build utils)
  #:use-module (guix channels)
  #:use-module (guix packages)
  #:use-module (guix profiles)
  #:use-module (guix monads)
  #:use-module (guix store)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (nongnu packages firmware)
  #:use-module (gnu system privilege)
  #:use-module (gnu services)
  ;; my stuff
  #:use-module (wonko defs)
  #:use-module (wonko misc)
  #:use-module (wonko spock)
  #:use-module (wonko crew)
  #:use-module (wonko fleet)
  #:use-module (wonko pkgs)
  #:use-module (wonko services xorg)
  #:use-module (wonko services file-sharing)
  #:use-module (wonko services networking)
  #:use-module (wonko bootloader grub)
  #:export (%laptop-os
            wonko-slim-config
            %laptop-services
            %laptop-fstab))

(use-service-modules dbus xorg sddm desktop
                     networking ssh file-sharing
                     linux shepherd
                     ;; service redef:
                     avahi sound)
(use-package-modules base linux
                     emacs emacs-xyz shells bash
                     networking display-managers xdisorg suckless fonts
                     package-management
                     xorg
                     ;; dev
                     android
                     ;; service redef:
                     libusb nfs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; channels

(define %channels ;; this will pull latest
  (cons*
   (channel
    (name 'nonguix)
    (url "https://gitlab.com/nonguix/nonguix")
    (introduction
     (make-channel-introduction
      "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
      (openpgp-fingerprint
       "2A39 3FFF 68F4 EF7A 3D29 12AF 6F51 20A0 22FB B2D5"))))
   %default-channels))

(define %channels ;; this is pinned, generated with `guix describe -f channels`
  (list (channel
          (name 'maxipassat)
          (url "https://codeberg.org/wonko/maxipassat")
          (branch "master")
          (commit "7deb3e11aacdf3854e2c54d3d782bce8cf7ddc00"))
        (channel
          (name 'nonguix)
          (url "https://gitlab.com/nonguix/nonguix")
          (branch "master")
          (commit "5f2630e69fbbe9e79c350a67545f0fef7e93e223")
          (introduction
           (make-channel-introduction
            "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
            (openpgp-fingerprint
             "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
        (channel
          (name 'guix)
          (url "https://codeberg.org/guix/guix")
          (branch "master")
          (commit "b391b7aeaa08951450aa88c654074ed6d5dbd80a")
          (introduction
           (make-channel-introduction
            "9edb3f66fd807b096b48283debdcddccfea34bad"
            (openpgp-fingerprint
             "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; vault subvolumes

(define-public (make-vault-subvolumes mapped-devices)
  (cons*
   (file-system
     (mount-point "/mnt/vault")
     (device "/dev/mapper/vault")
     (type "btrfs")
     (dependencies mapped-devices))
   (file-system
     (mount-point "/swap")
     (device "/dev/mapper/vault")
     (type "btrfs")
     (dependencies mapped-devices)
     (options "subvol=_live/@swap,compress=no,space_cache=v2"))
   (map (lambda (args)
          (let-values (((mount-p sv-name) (car+cdr args)))
            (file-system
              (device "/dev/mapper/vault")
              (mount-point mount-p)
              (type "btrfs")
              (options (string-append "subvol=_live/@"
                                      sv-name))
              (needed-for-boot? (equal? "/" mount-p))
              (dependencies mapped-devices))))
        `(("/" . "guix-root")
          ("/home" . "guix-home")
          ("/code" . "code")
          ("/data" . "data")
          ("/work" . "work")
          ("/junkyard" . "junkyard")))))

(define-public (make-default-swap file-systems)
  (swap-space
    (target "/swap/swapfile")
    (dependencies (filter (file-system-mount-point-predicate "/swap")
                          file-systems))))

(define btrfs-snapshot-service-type
  (shepherd-service-type
   'btrfs-snapshot
   (lambda (subvol)
     (let* ((name (substring subvol 1))
            (snap (program-file
                   (string-append "btrfs-snapshot-" name)
                   (with-imported-modules '((guix build utils))
                     #~(begin
                         (use-modules (guix build utils))
                         (let ((dest-dir (string-append
                                          "/mnt/vault/_ro/" #$subvol "_"
                                          (strftime "%F" (localtime (current-time))))))
                           (when (not (directory-exists? dest-dir))
                             (system*
                              #$(file-append btrfs-progs "/bin/btrfs")
                              "subvolume" "snapshot" "-r"
                              (string-append "/mnt/vault/_live/" #$subvol)
                              dest-dir))))))))
       (shepherd-service
         (documentation (string-append "periodically snapshot " subvol))
         (provision
          (list (string->symbol (string-append "btrfs-snapshot-" subvol))))
         (requirement '(networking user-processes guix-daemon))
         (modules '((shepherd service timer)))
         (start
          #~(make-timer-constructor
             (calendar-event #:minutes '(37)
                             #:hours '#$(range 0 23)
                             ;; tries once per hour, only once a day will work
                             #:days-of-month '#$(range 1 31))
             (command
              (list #$snap))
             #:wait-for-termination? #t))
         (stop #~(make-timer-destructor)))))
   #t
   (description "daily subvolume snapshot")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; slim services:

(define-public wonko-slim-config
  (slim-configuration
    (display ":9")
    (vt "vt9")
    (auto-login? #t)
    (default-user (crew-name %wonko))
    ;; FIXME: this should break nothing, xsession does setxkbmap.
    (xorg-configuration (xorg-configuration
                          (keyboard-layout %us-kb)))))

(define-public media-station-slim-config
  (slim-configuration
    (display ":11")
    (vt "vt11")
    (auto-login? #t)
    (default-user (crew-name %media))
    (xorg-configuration (xorg-configuration
                          (keyboard-layout %us-kb)))))

(define-public noamdgpu-xorg-config
  (xorg-configuration
    (keyboard-layout %us-kb)
    (modules (filter
              (lambda (p)
                ;; remove amdgpu and non supported by current-system
                (and (not (equal? p xf86-video-amdgpu))
                     (member (%current-system)
                             (package-supported-systems p))))
              %default-xorg-modules))))

(define-public noamdgpu-noflip-xorg-config
  (xorg-configuration
    (inherit noamdgpu-xorg-config)
    (extra-config '("Section \"Device\""
                    "  Identifier \"Card1\""
                    "  Option \"SWcursor\""
                    "  Option \"AsyncFlipSecondaries\" \"false\""
                    "EndSection"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; extra-profiles-service:

(define (make-extra-profile-service-type profile-name)
  ;; The service that populates the system's profile---i.e.,
  ;; /run/current-system/profile-name.  It is extended by package lists.
  (define (packages->profile-entry packages)
    "Return a system entry for the profile containing PACKAGES."
    ;; XXX: 'mlet' is needed here for one reason: to get the proper
    ;; '%current-target' and '%current-target-system' bindings when
    ;; 'packages->manifest' is called, and thus when the 'package-inputs'
    ;; etc. procedures are called on PACKAGES.  That way, conditionals in those
    ;; inputs see the "correct" value of these two parameters.  See
    ;; <https://issues.guix.gnu.org/44952>.
    (mlet %store-monad ((_ (current-target-system)))
      (return `((,(string-append profile-name "-profile")
                 ,(profile
                    (content (packages->manifest packages))))))))
  (service-type (name (string->symbol
                       (string-append profile-name "-extra-profile")))
                (extensions
                 (list (service-extension system-service-type
                                          packages->profile-entry)))
                (compose concatenate)
                (extend append)
                (default-value '())
                (description
                 "This is @dfn{extra profile}, available as
@file{/run/gep/profile}.  It contains packages that you like.")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; laptop services

(define-public %leaner-desktop-services
  ;; same as %desktop-services w/o network manager nor gdm/sddm
  (remove
   (lambda (s)
     ;; FIXME: https://codeberg.org/guix/guix/issues/6424
     (or (eq? (service-type-name (service-kind s)) 'gdm-file-system)
         (eq? (service-type-name (service-kind s)) 'network-manager-applet)))
   (modify-services
       %desktop-services
     (delete gdm-service-type)
     (delete network-manager-service-type)
     (delete wpa-supplicant-service-type))))

(define-public %laptop-services
  (cons*
   (simple-service 'dbus-fwupd
                   dbus-root-service-type
                   (list fwupd-nonfree))
   (simple-service 'polkit-fwupd
                   polkit-service-type
                   (list fwupd-nonfree))

   (service bluetooth-service-type
            (bluetooth-configuration (auto-enable? #t)))

   (service guix-publish-service-type
            (guix-publish-configuration
              (host "0.0.0.0")
              (port 1337)
              (advertise? #t)))

   (simple-service 'fleet-hosts-entries hosts-service-type %fleet-hosts)

   (service openssh-service-type
            (openssh-configuration
              (authorized-keys
               (cons*
                (list
                 "root"
                 (local-file
                  (string-append %lambda-project
                                 "/wonko/data/ssh/one-ring-to-rule-them-all.pub")))
                (append-map (lambda (user)
                              (map (lambda (hn)
                                     (list user (local-file
                                                 (string-append %lambda-project
                                                                "/wonko/data/ssh/"
                                                                hn ".pub"))))
                                   (cons "discovery" %fleet-names)))
                            '("wonko" "media"))))
              (x11-forwarding? #t)
              (password-authentication? #f)
              (permit-root-login #t)))

   (service tor-service-type)

   (service noautostart-transmission-daemon-service-type
            (transmission-daemon-configuration
              (rpc-authentication-required? #f)
              (rpc-whitelist-enabled? #t)
              (rpc-host-whitelist (fleet-canonical-names-from-hosts %fleet-hosts))
              (rpc-whitelist '("::1" "127.0.0.1" "192.168.1.*" "10.42.0.*"))
              (umask #o000)
              (download-dir "/junkyard/downloads/inbox")))

   (service earlyoom-service-type
            (earlyoom-configuration
              (avoid-regexp "emacs|exwm")
              (prefer-regexp "firefox|icecat|chromium")))

   (service fstrim-service-type)

   (service (make-extra-profile-service-type "comms")   %comms-world)
   ;; I want this to be used rather than the old utils in extra-profiles
   ;; ... which is still a useful fallback, but isn't often updated.
   (service (make-extra-profile-service-type "utils")   (append
                                                         %dev-world
                                                         %git-world
                                                         %utils-world))
   (service (make-extra-profile-service-type "desktop") %desktop-world)
   (service (make-extra-profile-service-type "web")     %web-world)
   (service (make-extra-profile-service-type "img")     %image-edition-world)
   (service (make-extra-profile-service-type "fonts")   %fonts-world)

   (udev-rules-service 'android android-udev-rules #:groups '("adbusers"))

   (append
    (map (lambda (h)
           (service fleet-keep-alive-service-type (host-canonical-name h)))
         %fleet-hosts)

    (map (lambda (sv)
           (service btrfs-snapshot-service-type sv))
         '("@code" "@data" "@guix-home" "@guix-root" "@junkyard" "@work"))

    (modify-services
        %leaner-desktop-services
      ;; %desktop-services
      ;; (delete gdm-service-type)
      (console-font-service-type config => ;; TODO: separate services for highdpi?
                                 (map (lambda (tty)
                                        `(,tty
                                          . ,(file-append font-terminus
                                                          "/share/consolefonts/ter-132n")))
                                      '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6")))

      (elogind-service-type
       config =>
       (elogind-configuration
         (system-sleep-hook-files
          `(,(program-file
              "wake-up"
              #~(let ((arg (cadr (program-arguments))))
                  (when (string= arg "post")
                    (let ((port (open-file #$%wake-up-notification-file "w")))
                      (display "WAKE UP GRAB A BRUSH AND PUT A LITTLE MAKE UP\n" port)
                      (close-port port)))))
            ,(program-file
              "lock-up"
              #~(let ((arg (cadr (program-arguments))))
                  (when (string= arg "pre")
                    (system
                     #$(string-concatenate
                        (append '("(/run/privileged/bin/sudo -u wonko DISPLAY=:9 ")
                                (map (lambda (s)
                                       (string-append s " "))
                                     (drop-right %lock-cmd 2))
                                '("&)")))))))))
         (handle-power-key 'hibernate)
         (handle-lid-switch 'suspend)
         (handle-lid-switch-docked  'suspend)
         (handle-lid-switch-external-power 'suspend)))

      (guix-service-type config =>
                         (guix-configuration
                           (discover? #t)
                           (channels %channels)
                           (guix (guix-for-channels %channels))
                           (substitute-urls
                            (cons* "https://substitutes.nonguix.org"
                                   "http://of-course-i-still-love-you.star-fleet.local:1337"
                                   %default-substitute-urls))
                           (authorized-keys
                            (append
                             (map (lambda (hn)
                                    (local-file
                                     (string-append %lambda-project
                                                    "/wonko/data/substitutes/" hn
                                                    ".pub")))
                                  (cons "nonguix" %fleet-names))
                             %default-authorized-guix-keys))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; laptop-os and friends

(define-public %laptop-os
  (operating-system
    (locale "en_GB.utf8")
    (timezone "Europe/Paris")
    (keyboard-layout %us-kb)

    (kernel linux)
    (kernel-arguments
     (append
      '("net.ifnames=0" "biosdevname=0" "resume=/dev/mapper/vault")
      ;; [2026-05-09 Sat 12:33] CVE-2026-31431 + dirty frag cve-fuckyou
      (let ((bad (string-join (cons*
                               "algif_aead" "esp4" "esp6" "rxrpc"
                               (@@ (gnu system) %default-modprobe-blacklist))
                              ",")))
        (list
         (string-append "module_blacklist=" bad)
         (string-append "modprobe.blacklist=" bad)
         "quiet"))))

    (initrd microcode-initrd)
    (firmware (list linux-firmware))
    (bootloader
      (bootloader-configuration
        ;; choose wisely:
        ;; grub-efi-removable-bootloader =>
        ;;   use when installing on external device:
        ;;   expects /mnt/boot/efi to exist & be mounted
        ;; grub-efi-bootloader => for local machine
        ;;
        ;; (bootloader grub-efi-removable-bootloader)
        ;; (targets '("/mnt/tmp-efi/"))
        (bootloader grub-efi-bootloader)
        (targets    '("/boot"))
        (keyboard-layout keyboard-layout)))

    (host-name "discovery")
    (issue (string-append (spock-say "live long & prosper!") "\n\n"))
    (users (append (map crew->user-account %crew)
                   %base-user-accounts))

    (packages
     (append
      %git-world
      %utils-world
      %os-disk-world
      %os-net-world
      %os-misc-world
      %os-nonfree
      %xorg-world
      %guile-world
      %base-packages))

    (services %laptop-services)

    (privileged-programs
     (cons*
      (privileged-program
        (program (file-append
                  (@ (gnu packages linux) brightnessctl)
                  "/bin/brightnessctl"))
        (setuid? #t))
      %default-privileged-programs))

    (file-systems '())))

(define-public %removable-laptop-os
  (operating-system
    (inherit %laptop-os)
    (bootloader
      (bootloader-configuration
        (bootloader my-grub-efi-removable-bootloader)
        (targets    '("/boot"))))))

(define-public %removable-laptop-os-init-from-external
  (operating-system
    (inherit %laptop-os)
    (bootloader
      (bootloader-configuration
        (bootloader my-grub-efi-removable-bootloader)
        (targets '("/mnt/tmp-efi/"))
        (keyboard-layout %us-kb)))))

(define-public %media-station-os-services
  (modify-services %laptop-services
    (noautostart-transmission-daemon-service-type
     config =>
     (transmission-daemon-configuration
       (inherit config)
       (download-dir "/mnt/trantor/media/inbox")))
    (elogind-service-type config =>
                          (elogind-configuration
                            (inherit config)
                            (handle-lid-switch 'ignore)
                            (handle-lid-switch-docked 'ignore)
                            (handle-lid-switch-external-power 'ignore)))))

(define-public %media-station-os
  (operating-system
    (inherit %laptop-os)
    (services %media-station-os-services)))
