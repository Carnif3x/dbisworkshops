CREATE OR REPLACE PACKAGE EVENT_PACKAGE AS
  TYPE T_EVENT IS RECORD (
    EV_TITLE VARCHAR2(30 CHAR),
    EV_TOPIC VARCHAR2(30 CHAR),
    EV_DESC VARCHAR2(1000 CHAR),
    EV_PRICE BINARY_DOUBLE,
    EV_ORG varchar2(30 char),
    ID_EVENT NUMBER,
    deleted varchar2(30 char)
    );

  TYPE T_EVENT_TABLE IS TABLE OF T_EVENT;

  FUNCTION GET_EVENT(EV_ID IN EVENT.ID%TYPE)
    RETURN T_EVENT_TABLE PIPELINED;
  FUNCTION GET_EVENTS_BY_TITLE(EV_TITLE IN EVENT.TITLE%TYPE)
    RETURN T_EVENT_TABLE PIPELINED;
  FUNCTION GET_EVENTS
    RETURN T_EVENT_TABLE PIPELINED;
  function ADD_EVENT(ev_title IN EVENT.TITLE%TYPE,
                     ev_topic IN EVENT.TOPIC%TYPE,
                     ev_desc IN EVENT."desc"%TYPE,
                     ev_price IN EVENT.PRICE%type,
                     ev_org IN EVENT.ORGANIZER%type)
    return VARCHAR2;
  function update_event(ev_title in EVENT.TITLE%type,
                        ev_topic in EVENT.TOPIC%type,
                        ev_desc in EVENT."desc"%type,
                        ev_price in EVENT.PRICE%type,
                        ev_id in EVENT.ID%type,
                        ev_email in EVENT.ORGANIZER%TYPE)
    return varchar2;

  FUNCTION GET_ORGANIZER_EVENT(EMAIL IN EVENT.ORGANIZER%TYPE)
    RETURN T_EVENT_TABLE PIPELINED ;

  function delete_event(ev_id in EVENT.ID%type, ev_email in EVENT.ORGANIZER%TYPE)
    return VARCHAR2;
END;

CREATE OR REPLACE PACKAGE BODY EVENT_PACKAGE AS
  FUNCTION GET_ORGANIZER_EVENT(email IN EVENT.ORGANIZER%TYPE)
    RETURN T_EVENT_TABLE PIPELINED AS
    cursor my_cur is select *
                     from EVENT
                     where ORGANIZER = email and DELETED is null;
  BEGIN
    for curr in my_cur
      loop
        pipe row ( curr );
      end loop;
  END;

  FUNCTION GET_EVENT(EV_ID IN EVENT.ID%type)
    RETURN T_EVENT_TABLE PIPELINED AS
    CURSOR MY_CUR IS
      SELECT *
      FROM EVENT
      WHERE EVENT.ID = EV_ID
        AND EVENT.DELETED is null ;
  BEGIN
    FOR CURR IN MY_CUR
      LOOP
        PIPE ROW (CURR);
      end loop;
  END;

  FUNCTION GET_EVENTS_BY_TITLE(EV_TITLE IN EVENT.TITLE%type)
    RETURN T_EVENT_TABLE PIPELINED AS
    CURSOR MY_CUR IS
      SELECT *
      FROM EVENT
      WHERE EVENT.TITLE = EV_TITLE
        AND EVENT.DELETED is null ;
  BEGIN
    FOR CURR IN MY_CUR
      LOOP
        PIPE ROW (CURR);
      end loop;
  END;

  FUNCTION GET_EVENTS
    RETURN T_EVENT_TABLE PIPELINED AS
    CURSOR MY_CURSOR IS
      SELECT *
      FROM EVENT
      where EVENT.DELETED is null ;
  BEGIN
    FOR REC IN MY_CURSOR
      LOOP
        PIPE ROW (REC);
      END LOOP;
  END;

  function ADD_EVENT(ev_title IN EVENT.TITLE%TYPE,
                     ev_topic IN EVENT.TOPIC%TYPE,
                     ev_desc IN EVENT."desc"%TYPE,
                     ev_price in EVENT.PRICE%type,
                     ev_org IN EVENT.ORGANIZER%TYPE)
    RETURN VARCHAR2 AS PRAGMA AUTONOMOUS_TRANSACTION;
    is_exists NUMBER := 0;
  BEGIN
    select count(*) into is_exists
    from dual
    where exists(select TITLE, ORGANIZER from EVENT where TITLE = ev_title AND ORGANIZER = ev_org);
    if is_exists > 0 then
      update EVENT set DELETED = NULL where TITLE = ev_title and ORGANIZER = ev_org;
      commit;
      return '200 OK';
    else
      INSERT INTO EVENT (TITLE, TOPIC, "desc", PRICE, ORGANIZER) VALUES (ev_title,  ev_topic, ev_desc, ev_price, ev_org);
      commit;
      return '200 OK';
    end if;

    exception
    WHEN DUP_VAL_ON_INDEX
    THEN
      return '500 already existed';
    WHEN OTHERS
    THEN
      return SQLERRM;
  END;

  function delete_event(ev_id in EVENT.ID%type, ev_email in EVENT.ORGANIZER%TYPE)
    return varchar2 AS PRAGMA AUTONOMOUS_TRANSACTION;

    currStatus varchar2(1000);
    s_band varchar2(1000);
    s_name varchar2(1000);
  BEGIN
    currStatus := 'del';

    --     if (song_id is not null) then
    --       UPDATE SONG
    --       set DELETED = currStatus
    --       where ID = song_id;
    --       commit;
    --       return '200 OK';
    if (ev_id is not null) then
      update EVENT
      set DELETED = currStatus
      where ID = ev_id and ORGANIZER = ev_email;
      commit;
      return '200 OK';
    end if;

    exception
    when no_data_found then return '404 not found';
    when others then return SQLERRM;
  END;

  function update_event(ev_title in EVENT.TITLE%type,
                        ev_topic in EVENT.TOPIC%type,
                        ev_desc in EVENT."desc"%type,
                        ev_price in EVENT.PRICE%type,
                        ev_id in EVENT.ID%type,
                        ev_email in EVENT.ORGANIZER%TYPE)
    return varchar2 as PRAGMA AUTONOMOUS_TRANSACTION;
  begin

    if (ev_title is not null) then
      update EVENT
        set TITLE = ev_title
      where ID = ev_id and ORGANIZER = ev_email;
    end if;
    if (ev_topic is not null) then
      update EVENT
        set TOPIC = ev_topic
      where ID = ev_id and ORGANIZER = ev_email;
    end if;
    if (ev_desc is not null) then
      update EVENT
        set "desc" = ev_desc
      where ID = ev_id and ORGANIZER = ev_email;
    end if;
    if (ev_price is not null) then
      update EVENT
        set PRICE = ev_price
      where ID = ev_id and ORGANIZER = ev_email;
    end if;
    commit;
    return '200 OK';

    exception
    when dup_val_on_index
    then
      return '500 existed';
    when others
    then return SQLERRM;
  end;
END EVENT_PACKAGE;
/

-- select *
-- from table (SONG_PACKAGE.GET_SONGS());
-- select SONG_PACKAGE.delete_song(null, 'Hater','Davis') from dual;
-- select SONG_PACKAGE.GET_SONGS_BY_GENRE('Metal') from dual;

-- select count(*)
-- from dual
-- where exists(select name, BAND from SONG where NAME = 'AOV' AND BAND = 'Slipknot');
-- select SONG_PACKAGE.ADD_SONG('Hater', 2.22, 'Davis', 'Metal')
-- from dual;