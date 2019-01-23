create table PERSON
(
  EMAIL      VARCHAR2(30 char) not null
    constraint PERSON_PK
      primary key,
  FIRST_NAME VARCHAR2(30 char),
  LAST_NAME  VARCHAR2(30 char),
  PASSWORD   VARCHAR2(30 char)
)
/
