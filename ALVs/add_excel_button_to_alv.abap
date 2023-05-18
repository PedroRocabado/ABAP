* To add an Excel download button to the toolbar of an ALV Grid in ABAP, 
* you can use the function module REUSE_ALV_GRID_DISPLAY and include the button in the toolbar table (i_toolbar_excluding).

* Here is an example of how you can do this:

* Copy code
DATA: g_toolbar TYPE lvc_t_toolbar.

* Add an Excel download button to the toolbar table
APPEND INITIAL LINE TO g_toolbar-button = 'EXCEL_DWNLD'
                    g_toolbar-type   = 'PUSHBUTTON'
                    g_toolbar-text   = 'Excel Download'.

* Pass the toolbar table to the function module
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program       = sy-repid
    i_structure_name         = 'YOUR_ALV_GRID_STRUCTURE'
    i_toolbar_excluding      = g_toolbar
  TABLES
    t_outtab                 = YOUR_ALV_GRID_TABLE.

* You can then define a handler method for the button in your program. This method will be called when the button is clicked.

* To do this, you can use the FORM keyword to define a local function in your program and specify the name of this function as the 
* i_callback_toolbar parameter when calling REUSE_ALV_GRID_DISPLAY.

* Here is an example of how you can define the handler method:

* Copy code
* Define the handler method for the button
FORM handle_toolbar USING r_ucomm.
  CASE r_ucomm.
    WHEN 'EXCEL_DWNLD'.
      * Your code to download the ALV grid as an Excel file goes here
  ENDCASE.
ENDFORM.

* Pass the name of the handler method as a parameter
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program       = sy-repid
    i_callback_toolbar       = 'HANDLE_TOOLBAR'
    i_structure_name         = 'YOUR_ALV_GRID_STRUCTURE'
    i_toolbar_excluding      = g_toolbar
  TABLES
    t_outtab                 = YOUR_ALV_GRID_TABLE.
