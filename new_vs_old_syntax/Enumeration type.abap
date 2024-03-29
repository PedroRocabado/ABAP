*"> We all used to work with constant variables when we want to access static data.
*"> Now, we can make use of "ENUMERATION" to achieve the same.

*New stype
TYPES:
  BEGIN OF ENUM scrum_status_type,  "Usando enum, cada parametro de este tipo tendra un valor secuencial
    open,                           "1
    in_progress,                    "2
    blocked,                        "3
    done,                           "4
  END OF ENUM scrum_status_type.

DATA(scrum_status) = open.          "Se le asignara 1

*"Old style
CONSTANTS scrum_status_open       TYPE i VALUE 1.
CONSTANTS scrum_status_in_process TYPE i VALUE 2.
CONSTANTS scrum_status_blocked    TYPE i VALUE 3.
CONSTANTS scrum_status_done       TYPE i VALUE 4.

DATA scrum status TYPE i.
scrum_status = scrum_status_open.
