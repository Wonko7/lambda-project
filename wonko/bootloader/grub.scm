;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020 Ludovic Courtès <ludo@gnu.org>
;;; Copyright © 2016 Chris Marusich <cmmarusich@gmail.com>
;;; Copyright © 2017 Leo Famulari <leo@famulari.name>
;;; Copyright © 2017, 2020 Mathieu Othacehe <m.othacehe@gmail.com>
;;; Copyright © 2019, 2020, 2023, 2024 Janneke Nieuwenhuizen <janneke@gnu.org>
;;; Copyright © 2019, 2020 Miguel Ángel Arruga Vivas <rosen644835@gmail.com>
;;; Copyright © 2020 Maxim Cournoyer <maxim.cournoyer@gmail.com>
;;; Copyright © 2020 Stefan <stefan-guix@vodafonemail.de>
;;; Copyright © 2022 Karl Hallsby <karl@hallsby.com>
;;; Copyright © 2022 Denis 'GNUtoo' Carikli <GNUtoo@cyberdimension.org>
;;; Copyright © 2024 Tomas Volf <~@wolfsden.cz>
;;; Copyright © 2024 Herman Rimm <herman@rimm.ee>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (wonko bootloader grub)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (gnu bootloader)
  #:use-module (gnu packages bootloaders)
  #:use-module (gnu bootloader grub)
  #:use-module (ice-9 match)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-2)
  #:use-module (srfi srfi-26)
  #:export (my-grub-efi-bootloader))

(define-public my-grub-efi
  (package
    (inherit grub-efi)
    (name "my-grub-efi")
    (synopsis "GRand Unified Boot loader (UEFI version) + s/F5/Return")
    (arguments
     (substitute-keyword-arguments (package-arguments grub-efi)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'patch-stuff 'patch-keyboard
              (lambda _
                ;; FIXME: if I modify more than one C file I get bad elf magic. should try
                ;; to fix this, I've got a ton more of these prompts I'd like to change:
                ;; (substitute* "grub-core/disk/cryptodisk.c"
                ;;   (("Enter passphrase for") "Press any key if you are gay /"))

                ;; Broken enter key hack: makes insert act as return in luks open prompt.
                (substitute* "grub-core/kern/term.c"
                  (("return key;")
                   "return (key == GRUB_TERM_KEY_INSERT ? '\\r' : key);"))))))))))

(define-public my-grub-efi-bootloader
  (bootloader
    (inherit grub-efi-bootloader)
    (name "my-grub-efi")
    (package my-grub-efi)))
