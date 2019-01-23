CREATE OR REPLACE PACKAGE PARTICIPATION_PACKAGE AS
  TYPE T_PARTY IS RECORD (
    register_time date,
    user_email VARCHAR2(30 CHAR),
    ev_ID NUMBER
    );

  TYPE T_EVENT IS RECORD (
    EV_TITLE VARCHAR2(30 CHAR),
    EV_TOPIC VARCHAR2(30 CHAR),
    EV_DESC VARCHAR2(1000 CHAR),
    EV_PRICE BINARY_DOUBLE,
    EV_ORG varchar2(30 char),
    ID_EVENT NUMBER
    );

  TYPE T_EVENT_TABLE IS TABLE OF T_EVENT;

  TYPE T_PARTY_TABLE IS TABLE OF T_PARTY;

  function ADD_EVENT(ev_title IN EVENT.TITLE%TYPE, ev_org in EVENT.ORGANIZER%type, user_email IN PARTICIPATION.PERSON_EMAIL%TYPE)
    return varchar2;
  FUNCTION GET_PARTY(user_email in PARTICIPATION.PERSON_EMAIL%type)
    RETURN T_EVENT_TABLE PIPELINED;

  function delete_event_from_party(ev_title IN EVENT.TITLE%TYPE, user_email in EVENT.ORGANIZER%type)
    return varchar2;

END;

CREATE OR REPLACE PACKAGE BODY PARTICIPATION_PACKAGE AS
  function ADD_EVENT(ev_title IN EVENT.TITLE%TYPE, ev_org in EVENT.ORGANIZER%type, user_email IN PARTICIPATION.PERSON_EMAIL%TYPE)
    RETURN VARCHAR2 AS PRAGMA AUTONOMOUS_TRANSACTION;
    EVENT_ID NUMBER := 0;
  BEGIN
    select ID into EVENT_ID from EVENT where TITLE = ev_title and ORGANIZER = ev_org;
    INSERT INTO PARTICIPATION (REGISTRATION_TIME, PERSON_EMAIL, EVENT_ID) VALUES (current_date, EVENT_ID, user_email);
    commit;
    return '200 OK';
    exception
    WHEN DUP_VAL_ON_INDEX
    THEN
      return '500 already existed';
    WHEN OTHERS
    THEN
      return SQLERRM;
  END;

  FUNCTION GET_PARTY(user_email in PARTICIPATION.PERSON_EMAIL%type)
    RETURN T_EVENT_TABLE PIPELINED AS
    CURSOR MY_CURSOR IS
      SELECT title, topic, "desc", price, organizer, id
      FROM EVENT
             join PARTICIPATION on EVENT.ID = PARTICIPATION.EVENT_ID
      where PARTICIPATION.PERSON_EMAIL = user_email;
  BEGIN
    FOR REC IN MY_CURSOR
      LOOP
        PIPE ROW (REC);
      END LOOP;
  END;

  function delete_event_from_party(ev_title IN EVENT.TITLE%TYPE, user_email in EVENT.ORGANIZER%type)
   RETURN VARCHAR2 AS PRAGMA AUTONOMOUS_TRANSACTION;
   E_ID NUMBER := 0;
  BEGIN
    select ID into E_ID from EVENT where TITLE = ev_title and ORGANIZER = user_email;
    delete from PARTICIPATION where EVENT_ID = E_ID;
    commit;
    return '200 OK';
    exception
    when NO_DATA_FOUND
    then
      return '404 Not found';
    when others
    then
      return sqlerrm;
  end ;
END PARTICIPATION_PACKAGE;
/
--
-- select *
-- from table (PLAY_LIST_PACKAGE.GET_PLAY_LIST('Sirko'));
-- call PLAY_LIST_PACKAGE.ADD_SONG(29, 'Gray');
-- select PLAY_LIST_PACKAGE.delete_song_from_play_list(5)
-- from dual;

-- select PLAY_LIST_PACKAGE.ADD_SONG('Not Dead Yet', 'Ledger', 'Gray') from dual;