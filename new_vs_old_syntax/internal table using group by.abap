**ABAPers have been using control break statement's like AT NEW, AT LAST, AT END OF for grouping the data or processing some logic at specific conditions.
**Now SAP has introduced new ABAP syntax for grouping an internal table rows based on specified key's just like an OPEN-SQL syntax "GROUP BY"

CLASS zdemo_internal_table_group DEFINITION.

PUBLIC SECTION.
    METHODS:  GET_GROUP_BY_DATA.
    
PRIVATE SECTION.
    DATA: wa_vbap TYPE  vbap,
          member  TYPE  vbap,
          members TYPE  STANDARD TABLE OF vbap WITH EMPTY KEY.
          
ENDCLASS.

CLASS zdemo_internal_table_group IMPLEMENTAION.

  METHOD get_group_by_data.
    
    SELECT * 
            FROM vbap INTO TABLE @DATA(lt_vbap)
            UP TO 50 ROWS.
            
    "Grouping an internal table rows based on Key criteria
    "Grouping also can be done by more than one column.
    
    LOOP AT lt_vbap INTO wa_vbap
                    GROUP BY wa_vbap-vbeln.
         WRITE :/ wa_vbap-vbeln.             
    ENDLOOP.
    
    "Grouping of one column by Representative Binding
    LOOP AT lt_vbap INTO wa_vbap
                    GROUP BY wa_vbap-vbeln.
        CLEAR members.
        LOOP AT GROUP wa_vbap INTO MEMBER.
            members = VALUE #( BASE members ( member ) ).
        ENDLOOP.
    ENDLOOP.
      
      CL_DEMO_OUTPUT=>DISPLAY( members ).
    
  ENDMETHOD.

ENDCLASS.
