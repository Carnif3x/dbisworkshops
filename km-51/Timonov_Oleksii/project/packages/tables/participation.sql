create table PARTICIPATION
(
  REGISTRATION_TIME DATE              not null,
  PERSON_EMAIL      VARCHAR2(30 char) not null
    constraint PARTICIPATION_PERSON_EMAIL_FK
      references PERSON
        on delete cascade,
  EVENT_ID          NUMBER            not null
    constraint PARTICIPATION_EVENT_ID_FK
      references EVENT
        on delete cascade,
  constraint PARTICIPATION_PK
    primary key (REGISTRATION_TIME, PERSON_EMAIL, EVENT_ID)
)
/
