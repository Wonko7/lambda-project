;; this is no longer deployed, leaving this for copy/paste convenience.
(list
 (channel
   (name 'maxipassat)
   (url "https://codeberg.org/wonko/maxipassat"))
 (channel
   (name 'nonguix)
   (url "https://gitlab.com/nonguix/nonguix")
   (introduction
    (make-channel-introduction
     "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
     (openpgp-fingerprint
      "2A39 3FFF 68F4 EF7A 3D29 12AF 6F51 20A0 22FB B2D5"))))
 (channel
   (name 'divya-lambda)
   (url "https://codeberg.org/divyaranjan/divya-lambda.git")
   (branch "master")
   (introduction
    (make-channel-introduction
     "fe2010125fcbe003de42436b1a73ab53cc5e8288"
     (openpgp-fingerprint
      "F0B3 1A69 8006 8FB8 096A  2F12 B245 10C6 108C 8D4A"))))
 (channel
   (name 'guix)
   (url "https://codeberg.org/guix/guix")
   (branch "master")
   (introduction
    (make-channel-introduction
     "9edb3f66fd807b096b48283debdcddccfea34bad"
     (openpgp-fingerprint
      "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))
