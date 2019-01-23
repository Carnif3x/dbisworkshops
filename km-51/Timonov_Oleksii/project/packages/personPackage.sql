CREATE OR REPLACE PACKAGE PERSON_PACKAGE AS
  TYPE T_USER IS RECORD (
    EMAIL VARCHAR2(30 CHAR),
    FIRST_NAME VARCHAR2(30 CHAR),
    last_name VARCHAR2(30 CHAR),
    password VARCHAR2(30 CHAR)
    );

  TYPE T_USER_TABLE IS TABLE OF T_USER;

  FUNCTION LOG_IN(your_email IN PERSON.EMAIL%TYPE, PASS IN PERSON.PASSWORD%TYPE)
    RETURN NUMBER;

  FUNCTION GET_PERSON(PERSON_EMAIL IN PERSON.EMAIL%type)
    RETURN T_USER_TABLE PIPELINED;

  function REGISTRATION(new_email IN PERSON.EMAIL%TYPE,
                        new_first_name IN PERSON.FIRST_NAME%TYPE,
                        NEW_last_name IN PERSON.LAST_NAME%TYPE,
                        NEW_pass IN PERSON.PASSWORD%TYPE)
    return VARCHAR2;

  function update_user(user_email IN PERSON.EMAIL%TYPE,
                       new_first_name IN PERSON.FIRST_NAME%TYPE,
                       NEW_last_name IN PERSON.LAST_NAME%TYPE,
                       NEW_pass IN PERSON.PASSWORD%TYPE)
    return varchar2;
END;

CREATE OR REPLACE PACKAGE BODY PERSON_PACKAGE AS

  FUNCTION GET_PERSON(PERSON_EMAIL IN PERSON.EMAIL%type)
    RETURN T_USER_TABLE PIPELINED AS
    CURSOR MY_CUR IS
      SELECT *
      FROM PERSON
      WHERE PERSON.EMAIL = PERSON_EMAIL;
  BEGIN
    FOR CURR IN MY_CUR
      LOOP
        PIPE ROW (CURR);
      end loop;
  END;

  FUNCTION LOG_IN(your_email IN PERSON.EMAIL%TYPE, PASS IN PERSON.PASSWORD%TYPE)
    RETURN NUMBER AS
    rec NUMBER(1);
  BEGIN
    SELECT count(*) INTO rec
    FROM PERSON
    WHERE PERSON.EMAIL = your_email
      AND PERSON.PASSWORD = PASS;

    RETURN (rec);
  END;

  FUNCTION REGISTRATION(new_email IN PERSON.EMAIL%TYPE,
                        new_first_name IN PERSON.FIRST_NAME%TYPE,
                        NEW_last_name IN PERSON.LAST_NAME%TYPE,
                        NEW_pass IN PERSON.PASSWORD%TYPE)
    return varchar2
  AS PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO PERSON (EMAIL, FIRST_NAME, LAST_NAME, PASSWORD)
    values (new_email, new_first_name, NEW_last_name, NEW_pass);
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


  function update_user(user_email in PERSON.EMAIL%type,
                       new_first_name in PERSON.FIRST_NAME%type,
                       new_last_name in PERSON.LAST_NAME%type,
                       new_pass in PERSON.PASSWORD%type)
    return varchar2 as PRAGMA AUTONOMOUS_TRANSACTION;
  begin

    if (new_first_name is not null) and (new_last_name is not null) and (new_pass is not null) then
      update PERSON
      set FIRST_NAME = new_first_name,
          LAST_NAME  = new_last_name,
          PASSWORD   = new_pass
      where EMAIL = user_email;
      commit;
      return '200 OK';

    elsif (new_first_name is null) and (new_last_name is not null) and (new_pass is not null) then
      update PERSON
      set LAST_NAME = new_last_name,
          PASSWORD  = new_pass
      where EMAIL = user_email;
      commit;
      return '200 OK';

    elsif (new_first_name is null) and (new_last_name is null) and (new_pass is not null) then
      update PERSON
      set PASSWORD = new_pass
      where EMAIL = user_email;
      commit;
      return '200 OK';
    elsif (new_first_name is not null) and (new_last_name is null) and (new_pass is null) then
      update PERSON
      set FIRST_NAME = new_first_name
      where EMAIL = user_email;
      commit;
      return '200 OK';

    elsif (new_first_name is null) and (new_last_name is null) and (new_pass is null) then
      return '200 OK';
    end if;

    exception
    when dup_val_on_index
    then
      return '500 existed';
    when others
    then return SQLERRM;
  end;

END PERSON_PACKAGE;
/

-- select USER_PACKAGE.LOG_IN('Gray', '5116951169')
-- from dual;
-- select USER_PACKAGE.REGISTRATION('Sirko', 'fghjk', 'Serhii', 'sirko2097@outlook.com')
-- from dual;
-- select USER_PACKAGE.update_user('sd', '125963', 'Ksan', 'malyshevskyi.maxim@rambler.ru')
-- from dual;
-- select PERSON_PACKAGE.update_user('Gray', '123789Cthusq', NULL, NULL)
-- from dual;