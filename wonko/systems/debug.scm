(define-module (wonko systems debug)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (guix monads)
  #:use-module (guix store)
  #:use-module (guix profiles)

  #:use-module (guix packages)
  #:use-module (gnu services desktop)
  #:use-module (gnu packages linux)
  #:use-module (nongnu packages linux)

  #:use-module (wonko packages emacs-xyz)
  #:use-module (wonko bootloader grub))

;; guix system vm wonko/systems/debug.scm
;; $(guix system vm wonko/systems/debug.scm) -m 1024 -smp 2 -nic user,model=virtio-net-pci

;; image=$(guix system image --image-type=qcow2 wonko/systems/debug.scm)
;; cp $image /tmp/my-image.qcow2
;; chmod +w /tmp/my-image.qcow2
;; qemu-system-x86_64 -enable-kvm -hda /tmp/my-image.qcow2 -m 1000 \
;; -bios $(guix build ovmf)/share/firmware/ovmf_x64.bin

(operating-system
  (host-name "debugme")
  (kernel linux)
  (bootloader (bootloader-configuration
                (bootloader my-grub-efi-bootloader)
                (targets '("/boot/efi"))))
  ;; (packages %base-packages)
  ;; (services %base-services)
  (packages '())
  (services '())

  (file-systems (list
                 (file-system
                   (mount-point "/")
                   (device "/dev/lol")
                   (type "btrfs")))))
