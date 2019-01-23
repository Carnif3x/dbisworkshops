from wtforms import Form, StringField, PasswordField, TextAreaField, FloatField, validators
from wtforms.fields.html5 import EmailField

DATETIME_REGEX = '^(\d{4})-((0[1-9])|(1[0-2]))-(0[1-9]|[12][0-9]|3[01]) ' \
                 '((0[0-9])|(1[0-9])|(2[0-3])):' \
                 '((0[0-9])|(1[0-9])|(2[0-9])|(3[0-9])|(4[0-9])|(5[0-9])):' \
                 '((0[0-9])|(1[0-9])|(2[0-9])|(3[0-9])|(4[0-9])|(5[0-9]))$'


class LoginForm(Form):
    email = EmailField(
        'Email', validators=[
            validators.Length(min=4, max=30),
            validators.Email()])
    password = PasswordField(
        'Password', validators=[
            validators.Length(min=4, max=40)])


class RegistrationForm(Form):
    email = EmailField("Email", validators=[
        validators.DataRequired(),
        validators.Email(),
        validators.Length(min=4, max=40)])
    first_name = StringField('First name', validators=[
        validators.Length(min=4, max=40)])
    last_name = StringField('Last name', validators=[
        validators.Length(min=4, max=40)])
    password = PasswordField('Password', validators=[
        validators.EqualTo('confirm', message="Passwords must match")])
    confirm = PasswordField('Repeat Password')


class NewEventForm(Form):
    title = StringField(
        'Event title', validators=[
            validators.DataRequired(),
            validators.Length(min=4, max=40)])
    theme = StringField(
        'Event theme', validators=[
            validators.DataRequired(),
            validators.Length(min=4, max=40)])
    desc = TextAreaField(
        'Event description', validators=[
            validators.DataRequired(),
            validators.Length(min=1, max=400)])
    datetime = StringField(
        'Event date and time', validators=[
            validators.DataRequired(),
            validators.Regexp(DATETIME_REGEX, message="Date format 'YYYY-MM-DD HH:mm:SS'")])
    cost = StringField(
        "Price for event (UAH)", validators=[
            validators.DataRequired(),
            validators.Length(min=0, max=100),
            validators.Regexp('^\d*.\d*$', message="Only float numbers is accepted")])
