(cons*
 (channel
  (name 'guix-forge)
  (url "https://git.systemreboot.net/guix-forge/")
  (branch "main")
  (introduction
   (make-channel-introduction
    "0432e37b20dd678a02efee21adf0b9525a670310"
    (openpgp-fingerprint
     "7F73 0343 F2F0 9F3C 77BF  79D3 2E25 EE8B 6180 2BB3"))))
 (channel
  (name 'nonguix)
  (url "https://gitlab.com/nonguix/nonguix")
  (introduction
   (make-channel-introduction
    "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
    (openpgp-fingerprint
     "2A39 3FFF 68F4 EF7A 3D29 12AF 6F51 20A0 22FB B2D5"))))
 ;; mirror:
 (list
  (channel
   (name 'guix)
   (url "https://codeberg.org/guix/guix-mirror")
   (branch "master")
   (introduction
    (make-channel-introduction
     "9edb3f66fd807b096b48283debdcddccfea34bad"
     (openpgp-fingerprint
      "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))
 ;; %default-channels
 )
