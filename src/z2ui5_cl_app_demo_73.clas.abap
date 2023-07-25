CLASS z2ui5_cl_app_demo_73 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_73 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      product  = 'tomato'.
      quantity = '500'.

      DATA(view) = z2ui5_cl_xml_view=>factory( client ).
      client->view_display( view->shell(
            )->page(
                    title          = 'abap2UI5 - First Example'
                    navbuttonpress = client->_event( val = 'BACK' check_view_destroy = abap_true )
                    shownavbutton  = abap_true
                )->header_content(
                    )->link(
                        text = 'Source_Code'
                        href = view->hlp_get_source_code_url(  )
                        target = '_blank'
                )->get_parent(
                )->simple_form( title = 'Form Title' editable = abap_true
                    )->content( 'form'
                        )->button(
                            text  = 'open new tab'
                            press = client->_event( val = 'BUTTON_OPEN_NEW_TAB' )
             )->stringify( ) ).

    ENDIF.

    CASE client->get( )-event.

      WHEN 'BUTTON_OPEN_NEW_TAB'.
        client->timer_set(
            interval_ms    = `0`
            event_finished = client->_event_client( action = client->cs_event-open_new_tab
                                              t_arg = value #( ( `https://www.google.com/search?q=abap2ui5&oq=abap2ui5` )  )
      ) ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack  ) ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.