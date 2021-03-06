CREATE OR REPLACE PACKAGE PLACE_PACKAGE AS
  TYPE T_PLACE IS RECORD (
    ADDRESS VARCHAR2(30 CHAR),
    DATETIME DATE
    );

  TYPE T_PLACE_TABLE IS TABLE OF T_PLACE;

  FUNCTION GET_PLACE(ev_address IN PLACE.ADDRESS%TYPE)
    RETURN T_PLACE_TABLE PIPELINED;
  FUNCTION GET_PLACES
    RETURN T_PLACE_TABLE PIPELINED;
  FUNCTION ADD_PLACE(ev_address IN PLACE.ADDRESS%TYPE,
                     datetime IN PLACE.DATETIME%TYPE)
    return VARCHAR2;
END;


CREATE OR REPLACE PACKAGE BODY PLACE_PACKAGE AS
  function ADD_PLACE(ev_address IN PLACE.ADDRESS%TYPE,
                     datetime IN PLACE.DATETIME%TYPE)
    RETURN VARCHAR2 AS PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    insert into PLACE (ADDRESS, DATETIME) VALUES (ev_address, datetime);

    commit;
    return '200 OK';
    exception
    WHEN DUP_VAL_ON_INDEX
    THEN
      return '500 already existed';
    WHEN OTHERS
    THEN
      return SQLERRM;
  end;

  FUNCTION GET_PLACE(ev_address IN PLACE.ADDRESS%type)
    RETURN T_PLACE_TABLE PIPELINED AS
    CURSOR MY_CUR IS
      SELECT *
      FROM PLACE
      WHERE PLACE.ADDRESS = ev_address;
  BEGIN
    FOR CURR IN MY_CUR
      LOOP
        PIPE ROW (CURR);
      end loop;
  END;

  FUNCTION GET_PLACES
    RETURN T_PLACE_TABLE PIPELINED AS
    CURSOR MY_CURSOR IS
      SELECT *
      FROM PLACE;
  BEGIN
    FOR REC IN MY_CURSOR
      LOOP
        PIPE ROW (REC);
      END LOOP;
  END;
END;