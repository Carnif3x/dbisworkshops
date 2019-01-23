create trigger EVENT_TR
  before insert
  on EVENT
  for each row
BEGIN
  SELECT event_seq.nextval INTO :NEW.id
  FROM dual;
end;
/