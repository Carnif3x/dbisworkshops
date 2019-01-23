from flask import Flask
from flask import render_template, request, session, flash, redirect, url_for, make_response

from functools import wraps

import forms
import models


app = Flask(__name__)
app.secret_key = 'super secret key'


def is_logged_in(f):
    @wraps(f)
    def wrap(*args, **kwargs):
        if 'logged_in' in session:
            return f(*args, **kwargs)
        else:
            flash('Unauthorized, please login', 'danger')
            return redirect(url_for('login'))
    return wrap


@app.route('/login/', methods=['GET', 'POST'])
def login():
    form = forms.LoginForm(request.form)
    if request.method == "POST" and form.validate():
        status = models.Person().login(email=form.email.data, password=form.password.data)

        if int(status) != 0:
            session['logged_in'] = True
            session['email'] = form.email.data
            resp = make_response(redirect(url_for('main')))

            resp.set_cookie('email', form.email.data)
            return resp
        else:
            flash('Wrong password or login', 'danger')

    return render_template('login.html', form=form)


@app.route('/logout/', methods=['GET', 'POST'])
def logout():
    session.clear()
    flash('You are now logged out', 'success')
    return redirect(url_for('login'))


@app.route('/register/', methods=['GET', 'POST'])
def registration():
    form = forms.RegistrationForm(request.form)
    if request.method == "POST" and form.validate():
        status = models.Person().register(
            email=form.email.data,
            password=form.password.data,
            first_name=form.first_name.data,
            last_name=form.last_name.data)
        if str(status) != '200 OK':
            flash('Error during registration', 'danger')
        else:
            flash('You have been registered successfully', 'success')
        return render_template('main.html')
    return render_template('registration.html', form=form)


@is_logged_in
@app.route('/profile/', methods=['GET', 'POST'])
def profile():
    user = models.Person().get_user(email=session['email'])
    email, first_name, last_name, _ = user[0]
    user = {'email': session['email'], 'first_name': first_name, 'last_name': last_name}
    return render_template('profile.html', user=user)


@is_logged_in
@app.route('/profile/update', methods=['GET', 'POST'])
def profile_update():
    form = forms.RegistrationForm(request.form)
    if request.method == "POST" and form.validate():
        models.Person().update_user(
            email=session['email'],
            first_name=form.first_name.data,
            last_name=form.last_name.data,
            password=form.password.data)
        return redirect(url_for('profile'))
    return render_template('profile_update.html', form=form)


@is_logged_in
@app.route('/events/')
def events():
    events = models.Event().get_all_events()
    if request.method == "GET":
        ev_title = request.args.get('title')
        if ev_title is not None:
            events = list(filter(lambda v: ev_title.lower() in v[0].lower(), events))
    return render_template('events.html', events=events)


@is_logged_in
@app.route('/new_event/', methods=['GET', 'POST'])
def new_event():
    form = forms.NewEventForm(request.form)
    if request.method == "POST" and form.validate():
        status = models.Event().new_event(
            title=form.title.data,
            theme=form.theme.data,
            cost=float(form.cost.data),
            desc=form.desc.data,
            organiser=session['email'])

        if str(status) == '200 OK':
            flash('Event has been successfully created', 'success')
        else:
            flash(f'Some error has been occurred: {status}', 'danger')

        return redirect(url_for('new_event'))
    return render_template('new_event.html', form=form)


@is_logged_in
@app.route('/my_events/', methods=['GET', 'POST'])
def my_events():
    if request.method == "GET":
        ev_id = request.args.get('cancel')
        if ev_id is not None:
            models.Event().delete_event(ev_id=ev_id, ev_email=session['email'])

    events = models.Event().get_events_by_organiser(email=session['email'])
    return render_template('my_events.html', events=events)


@is_logged_in
@app.route('/my_events/<eid>', methods=['GET', 'POST'])
def update_event(eid):
    form = forms.NewEventForm(request.form)

    if request.method == "POST" and form.validate():
        models.Event().update_event(
            ev_id=eid,
            cost=float(form.cost.data),
            email=session['email'],
            desc=form.desc.data,
            title=form.title.data,
            theme=form.theme.data)
        return redirect(url_for('my_events'))

    return render_template('update_event.html', form=form)


@app.route('/')
def main():
    return render_template('main.html')


if __name__ == '__main__':
    app.run()
