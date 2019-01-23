create table EVENT
(
  TITLE     VARCHAR2(30 char),
  TOPIC     VARCHAR2(30 char),
  "desc"    VARCHAR2(1000 char),
  PRICE     BINARY_DOUBLE,
  ORGANIZER VARCHAR2(30 char)
    constraint EVENT_PERSON_EMAIL_FK
      references PERSON
        on delete cascade,
  ID        NUMBER not null
    constraint EVENT_PK
      primary key,
  DELETED   VARCHAR2(30 char)
)
/
CREATE SEQUENCE event_seq START WITH 1;

create trigger EVENT_TR
  before insert
  on EVENT
  for each row
BEGIN
  SELECT event_seq.nextval INTO :NEW.id
  FROM dual;
end;
/
