(define-module (spock)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (ice-9 format))

(define (string-center-pad s)
  (let ((l (string-length s)))
    (if (> l 35)
        (substring s 0 35)
        (let-values (((q r) (euclidean/ (- 35 l) 2)))
          (let* ((pl (list->string (make-list q #\ )))
                 (pr (string-append pl (if (eq? r 1) " " ""))))
            (string-append pl s pr))))))

(define-public spock
  (let ((spock '("                                      :                                 :       \n"
                 "                                    :                                   :       \n"
                 "                                    :  RRVIttIti+==iiii++iii++=;:,       :      \n"
                 "                                    : IBMMMMWWWWMMMMMBXXVVYYIi=;:,        :     \n"
                 "                                    : tBBMMMWWWMMMMMMBXXXVYIti;;;:,,      :     \n"
                 "                                    t YXIXBMMWMMBMBBRXVIi+==;::;::::       ,    \n"
                 "                                   ;t IVYt+=+iIIVMBYi=:,,,=i+=;:::::,      ;;   \n"
                 "                                   YX=YVIt+=,,:=VWBt;::::=,,:::;;;:;:     ;;;   \n"
                 "                                   VMiXRttItIVRBBWRi:.tXXVVYItiIi==;:   ;;;;    \n"
                 "                                   =XIBWMMMBBBMRMBXi;,tXXRRXXXVYYt+;;: ;;;;;    \n"
                 "                                    =iBWWMMBBMBBWBY;;;,YXRRRRXXVIi;;;:;,;;;=    \n"
                 "                                     iXMMMMMWWBMWMY+;=+IXRRXXVYIi;:;;:,,;;=     \n"
                 "                                     iBRBBMMMMYYXV+:,:;+XRXXVIt+;;:;++::;;;     \n"
                 "                                     =MRRRBMMBBYtt;::::;+VXVIi=;;;:;=+;;;;=     \n"
                 "                                      XBRBBBBBMMBRRVItttYYYYt=;;;;;;==:;=       \n"
                 "                                       VRRRRRBRRRRXRVYYIttiti=::;:::=;=         \n"
                 "                                        YRRRRXXVIIYIiitt+++ii=:;:::;==          \n"
                 "                                        +XRRXIIIIYVVI;i+=;=tt=;::::;:;          \n"
                 "                                         tRRXXVYti++==;;;=iYt;:::::,;;          \n"
                 "                                          IXRRXVVVVYYItiitIIi=:::;,::;          \n"
                 "                                           tVXRRRBBRXVYYYIti;::::,::::          \n"
                 "                                            YVYVYYYYYItti+=:,,,,,:::::;         \n"
                 "                                            YRVI+==;;;;;:,,,,,,,:::::::         \n")))
    (apply string-append spock)))

(define-public (spock-say s)
  "make Spock say things"
  (let ((spock (list "                                      :                                 :       \n"
                     "                                    :                                   :       \n"
                     "                                    :  RRVIttIti+==iiii++iii++=;:,       :      \n"
                     "                                    : IBMMMMWWWWMMMMMBXXVVYYIi=;:,        :     \n"
                     "                                    : tBBMMMWWWMMMMMMBXXXVYIti;;;:,,      :     \n"
                     "                                    t YXIXBMMWMMBMBBRXVIi+==;::;::::       ,    \n"
                     (string-center-pad s)              ";t IVYt+=+iIIVMBYi=:,,,=i+=;:::::,      ;;   \n"
                     "                                   YX=YVIt+=,,:=VWBt;::::=,,:::;;;:;:     ;;;   \n"
                     "                                   VMiXRttItIVRBBWRi:.tXXVVYItiIi==;:   ;;;;    \n"
                     "                                   =XIBWMMMBBBMRMBXi;,tXXRRXXXVYYt+;;: ;;;;;    \n"
                     "                                    =iBWWMMBBMBBWBY;;;,YXRRRRXXVIi;;;:;,;;;=    \n"
                     "                                     iXMMMMMWWBMWMY+;=+IXRRXXVYIi;:;;:,,;;=     \n"
                     "                                     iBRBBMMMMYYXV+:,:;+XRXXVIt+;;:;++::;;;     \n"
                     "                                     =MRRRBMMBBYtt;::::;+VXVIi=;;;:;=+;;;;=     \n"
                     "                                      XBRBBBBBMMBRRVItttYYYYt=;;;;;;==:;=       \n"
                     "                                       VRRRRRBRRRRXRVYYIttiti=::;:::=;=         \n"
                     "                                        YRRRRXXVIIYIiitt+++ii=:;:::;==          \n"
                     "                                        +XRRXIIIIYVVI;i+=;=tt=;::::;:;          \n"
                     "                                         tRRXXVYti++==;;;=iYt;:::::,;;          \n"
                     "                                          IXRRXVVVVYYItiitIIi=:::;,::;          \n"
                     "                                           tVXRRRBBRXVYYYIti;::::,::::          \n"
                     "                                            YVYVYYYYYItti+=:,,,,,:::::;         \n"
                     "                                            YRVI+==;;;;;:,,,,,,,:::::::         \n")))
    (apply string-append spock)))
