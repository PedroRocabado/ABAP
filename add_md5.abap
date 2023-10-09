* Calculate MD5 for string “Jerry” via ABAP

DATA: md5_160 TYPE hash160.
CALL FUNCTION 'CALCULATE_HASH_FOR_CHAR'
  EXPORTING
    alg            = 'MD5'
    data           = 'Jerry'
    length         = 0
  IMPORTING
    hash           = md5_160
  EXCEPTIONS
    unknown_alg    = 1
    param_error    = 2
    internal_error = 3
    OTHERS         = 4.
CHECK sy-subrc = 0.
WRITE: / md5_160.

* output:

* DBAF60F3A397E1D27630A459C1700EA7
