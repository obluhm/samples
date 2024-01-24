CLASS z2ui5_cl_demo_app_162 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_tab,
        selkz            TYPE abap_bool,
        product          TYPE string,
        create_date      TYPE string,
        create_by        TYPE string,
        storage_location TYPE string,
        quantity         TYPE i,
      END OF ty_s_tab.
    TYPES ty_t_table TYPE STANDARD TABLE OF ty_s_tab WITH EMPTY KEY.

    DATA mt_table TYPE ty_t_table.
    DATA mt_sql TYPE z2ui5_cl_util_func=>ty_t_sql_multi.
*    DATA mt_token TYPE z2ui5_cl_util_func=>ty_t_token.

*    DATA mt_tokens_added TYPE z2ui5_cl_util_func=>ty_t_token.
*    DATA mt_tokens_removed TYPE z2ui5_cl_util_func=>ty_t_token.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    DATA mv_check_initialized TYPE abap_bool.
    METHODS on_event.
    METHODS view_display.
    METHODS set_data.

  PRIVATE SECTION.
*    DATA mt_range TYPE z2ui5_cl_util_func=>ty_t_sql_multi.
ENDCLASS.



CLASS z2ui5_cl_demo_app_162 IMPLEMENTATION.


  METHOD on_event.

    CASE client->get( )-event.

      WHEN `BUTTON_START`.
        set_data( ).
        client->view_model_update( ).

*      WHEN `UPDATE_TOKENS`.
*        LOOP AT mt_tokens_removed INTO DATA(ls_token).
*          DELETE mt_token WHERE key = ls_token-key.
*        ENDLOOP.
*
*        LOOP AT mt_tokens_added INTO ls_token.
*          INSERT VALUE #( key = ls_token-key text = ls_token-text visible = abap_true editable = abap_true ) INTO TABLE mt_token.
*        ENDLOOP.
*
*        CLEAR mt_tokens_removed.
*        CLEAR mt_tokens_added.
*
*        mt_range = z2ui5_cl_util_func=>get_range_t_by_token_t( mt_token ).
*        client->view_model_update( ).

      WHEN `PREVIEW_FILTER`.
        client->nav_app_call( z2ui5_cl_popup_get_range_multi=>factory( mt_sql ) ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ENDCASE.

  ENDMETHOD.


  METHOD set_data.

    "replace this with a db select here...
    mt_table = VALUE #(
        ( product = 'table'    create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'chair'    create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'sofa'     create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'computer' create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'oven'     create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'table2'   create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
    ).

    DATA lt_result LIKE mt_table.
    "put the range in the where clause of your abap sql command
    "here we use an internal table instead
    LOOP AT mt_sql INTO DATA(ls_tab).

      DATA(lv_clause) = ls_tab-name && ` not in ls_tab-t_range`.
      DELETE mt_table WHERE (lv_clause).

    ENDLOOP.

  ENDMETHOD.


  METHOD view_display.

    DATA(view) = z2ui5_cl_xml_view=>factory( ).

    view = view->shell( )->page( id = `page_main`
             title          = 'abap2UI5 - Select-Options'
             navbuttonpress = client->_event( 'BACK' )
             shownavbutton  = abap_true
         )->header_content(
             )->link(
                 text = 'Source_Code' target = '_blank' href = z2ui5_cl_demo_utility=>factory( client )->app_get_url_source_code( )
        )->get_parent( ).

    DATA(vbox) = view->vbox( ).


    DATA(tab) = vbox->table(
        items = client->_bind( val = mt_table )
           )->header_toolbar(
             )->overflow_toolbar(
                 )->toolbar_spacer(
                 )->button( text = `Filter` press = client->_event( `PREVIEW_FILTER` ) icon = `sap-icon://filter`
           )->button(  text = `Go` press = client->_event( `BUTTON_START` ) type = `Emphasized`
            )->get_parent( )->get_parent( ).

    DATA(lo_columns) = tab->columns( ).
    lo_columns->column( )->text( text = `Product` ).
    lo_columns->column( )->text( text = `Date` ).
    lo_columns->column( )->text( text = `Name` ).
    lo_columns->column( )->text( text = `Location` ).
    lo_columns->column( )->text( text = `Quantity` ).

    DATA(lo_cells) = tab->items( )->column_list_item( ).
    lo_cells->text( `{PRODUCT}` ).
    lo_cells->text( `{CREATE_DATE}` ).
    lo_cells->text( `{CREATE_BY}` ).
    lo_cells->text( `{STORAGE_LOCATION}` ).
    lo_cells->text( `{QUANTITY}` ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF mv_check_initialized = abap_false.
      mv_check_initialized = abap_true.
      mt_sql = z2ui5_cl_util_func=>get_sql_multi_by_data( mt_table ).
      view_display( ).
      RETURN.
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.
      TRY.
          DATA(lo_value_help) = CAST z2ui5_cl_popup_get_range_multi( client->get_app( client->get( )-s_draft-id_prev_app ) ).
          IF lo_value_help->result( )-check_confirmed = abap_false.
            mt_sql = lo_value_help->result( )-t_sql.
            set_data( ).
            client->view_model_update( ).
          ENDIF.
        CATCH cx_root.
      ENDTRY.
      RETURN.
    ENDIF.

    IF client->get( )-event IS NOT INITIAL.
      on_event( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.