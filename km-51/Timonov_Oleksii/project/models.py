import cx_Oracle


class Person:
    def __init__(self):
        self._db = cx_Oracle.connect('SYSTEM', '1111', 'XE')
        self._cursor = self._db.cursor()

    def register(self, email, password, first_name, last_name):
        status = self._cursor.callfunc('PERSON_PACKAGE.REGISTRATION',
                                       cx_Oracle.STRING, [email, first_name, last_name, password])
        return status

    def login(self, email, password):
        status = self._cursor.callfunc('PERSON_PACKAGE.LOG_IN',
                                       cx_Oracle.STRING, [email, password])
        return status

    def update_user(self, email, first_name, last_name, password):
        status = self._cursor.callfunc('PERSON_PACKAGE.UPDATE_USER',
                                       cx_Oracle.STRING, [email, first_name, last_name, password])
        return status

    def get_user(self, email):
        query = 'select * from table (PERSON_PACKAGE.GET_PERSON(:person_email))'
        var = self._cursor.execute(query, person_email=email)
        return var.fetchall()

    def __exit__(self, exc_type, exc_val, exc_tb):
        self._cursor.close()
        self._db.close()


class Event:
    def __init__(self):
        self._db = cx_Oracle.connect('SYSTEM', '1111', 'XE')
        self._cursor = self._db.cursor()

    def new_event(self, title, theme, desc, cost, organiser):
        status = self._cursor.callfunc('EVENT_PACKAGE.ADD_EVENT',
                                       cx_Oracle.STRING, [title, theme, desc, cost, organiser])
        return status

    def get_events_by_organiser(self, email):
        query = 'select * from table (EVENT_PACKAGE.GET_ORGANIZER_EVENT(:person_email))'
        var = self._cursor.execute(query, person_email=email)
        return var.fetchall()

    def delete_event(self, ev_id, ev_email):
        status = self._cursor.callfunc('EVENT_PACKAGE.DELETE_EVENT', cx_Oracle.STRING, [ev_id, ev_email])
        return status

    def update_event(self, ev_id, title, theme, desc, cost, email):
        return self._cursor.callfunc('EVENT_PACKAGE.UPDATE_EVENT',
                                     cx_Oracle.STRING, [title, theme, desc, cost, ev_id, email])

    def get_all_events(self):
        query = 'select * from table (EVENT_PACKAGE.GET_EVENTS)'
        var = self._cursor.execute(query)
        return var.fetchall()
