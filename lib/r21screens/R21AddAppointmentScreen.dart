import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/R21EventNoOccurReason.dart';
import 'package:pebrapp/database/beans/R21ScreenType.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/R21Appointment.dart';
import 'package:pebrapp/database/models/R21ScreenAnalytic.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/Utils.dart';

class R21AddAppointmentScreen extends StatelessWidget {
  final Patient _patient;
  final String _title;
  final R21ScreenAnalytic _analytic =
      new R21ScreenAnalytic(type: R21ScreenType.AddAppointment());

  R21AddAppointmentScreen(
    this._patient,
    this._title,
  );

  _onPressCancel(BuildContext context) {
    Navigator.of(context).popUntil((Route<dynamic> route) {
      //end anlytics

      _analytic.stopAnalytics(
          resultAction: 'Cancel', subjectEntity: this._patient.artNumber);

      return route.settings.name == '/patient';
    });
  }

  @override
  Widget build(BuildContext context) {
    //start analytics
    _analytic.startAnalytics();

    return PopupScreen(
        title: 'Add ${this._title}',
        subtitle: _patient.artNumber,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _onPressCancel(context);
              })
        ],
        child: R21AddAppointmentForm(_patient, _analytic));
  }
}

class R21AddAppointmentForm extends StatefulWidget {
  final Patient _patient;
  final R21ScreenAnalytic _analytic;

  R21AddAppointmentForm(this._patient, this._analytic);

  @override
  createState() => _R21AddAppointmentFormState(_patient, _analytic);
}

class _R21AddAppointmentFormState extends State<R21AddAppointmentForm> {
  // fields
  final _formKey = GlobalKey<FormState>();
  final int _questionsFlex = 1;
  final int _answersFlex = 1;
  double _screenWidth = double.infinity;

  final Patient _patient;
  final R21ScreenAnalytic _analytic;

  R21Appointment _event;

  TextEditingController _descriptionCtr = TextEditingController();

  // constructor
  _R21AddAppointmentFormState(this._patient, this._analytic) {
    _event = R21Appointment(patientART: this._patient.artNumber);
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;

    const double _spacing = 20.0;
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: _spacing),
          _buildQuestionCard(),
          SizedBox(height: _spacing),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            PEBRAButtonRaised(
              'Save',
              onPressed: () {
                _onSubmitForm(context);
              },
            )
          ]),
          SizedBox(height: _spacing),
        ],
      ),
    );
  }

  _buildQuestionCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            _dateQuestion(),
            _descriptionQuestion(),
            _occurQuestion(),
            _event.occured != null && !_event.occured
                ? _noOccurReasonQuestion()
                : Container(),
            _nextDateQuestion(),
          ],
        ),
      ),
    );
  }

  Widget _noOccurReasonQuestion() {
    return _makeQuestion(
      'Reason why appointment did not occur',
      answer: DropdownButtonFormField<R21EventNoOccurReason>(
        value: _event.noOccurReason,
        onChanged: (R21EventNoOccurReason newValue) {
          setState(() {
            _event.noOccurReason = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21EventNoOccurReason.allValues
            .map<DropdownMenuItem<R21EventNoOccurReason>>(
                (R21EventNoOccurReason value) {
          return DropdownMenuItem<R21EventNoOccurReason>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _dateQuestion() {
    return _makeQuestion(
      'Date',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _event.date == null
                  ? 'Select Date'
                  : formatDateConsistent(_event.date),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          onPressed: () async {
            final now = DateTime.now();
            DateTime date = await _showDatePicker(context,
                cinitialDate:
                    _event.date ?? DateTime(now.year, now.month, now.day));
            if (date != null) {
              setState(() {
                _event.date = date;
              });
            }
          },
        ),
        Divider(
          color: CUSTOM_FORM_FIELD_UNDERLINE,
          height: 1.0,
        ),
        _event.date != null
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'Please select a date',
                  style: TextStyle(
                    color: CUSTOM_FORM_FIELD_ERROR_TEXT,
                    fontSize: 12.0,
                  ),
                ),
              ),
      ]),
    );
  }

  Widget _nextDateQuestion() {
    return _makeQuestion(
      'Date of next appointment',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _event.nextDate == null
                  ? 'Select Date'
                  : formatDateConsistent(_event.nextDate),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          onPressed: () async {
            final now = DateTime.now();
            DateTime date = await _showDatePicker(context,
                cinitialDate:
                    _event.nextDate ?? DateTime(now.year, now.month, now.day));
            if (date != null) {
              setState(() {
                _event.nextDate = date;
              });
            }
          },
        ),
        Divider(
          color: CUSTOM_FORM_FIELD_UNDERLINE,
          height: 1.0,
        ),
        _event.nextDate != null
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'Please select a date',
                  style: TextStyle(
                    color: CUSTOM_FORM_FIELD_ERROR_TEXT,
                    fontSize: 12.0,
                  ),
                ),
              ),
      ]),
    );
  }

  Widget _occurQuestion() {
    return _makeQuestion(
      'Did the appointment take place?',
      answer: DropdownButtonFormField<bool>(
        value: _event.occured,
        onChanged: (bool newValue) {
          setState(() {
            _event.occured = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: [true, false].map<DropdownMenuItem<bool>>((bool value) {
          String description = value ? 'Yes' : 'No';
          return DropdownMenuItem<bool>(
            value: value,
            child: Text(description),
          );
        }).toList(),
      ),
    );
  }

  Widget _descriptionQuestion() {
    return _makeQuestion(
      'Comments',
      answer: TextFormField(
          autocorrect: false,
          controller: _descriptionCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter description';
            } else {
              setState(() {
                _event.description = value;
              });
              return null;
            }
          }),
    );
  }

  Widget _makeQuestion(String question, {@required Widget answer}) {
    if (_screenWidth < NARROW_DESIGN_WIDTH) {
      final double _spacingBetweenQuestions = 8.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: _spacingBetweenQuestions),
          Text(question),
          answer,
          SizedBox(height: _spacingBetweenQuestions),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: _questionsFlex,
          child: Text(question),
        ),
        Expanded(
          flex: _answersFlex,
          child: answer,
        ),
      ],
    );
  }

  Future<DateTime> _showDatePicker(BuildContext context,
      {DateTime cinitialDate}) async {
    DateTime now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: cinitialDate == null ? now : cinitialDate,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime(2023, 12, 31),
    );
  }

  _onSubmitForm(BuildContext context) async {
    if (_formKey.currentState.validate() &&
        _event.date != null &&
        _event.nextDate != null) {
      print('***Saving appointment to db' + _event.toString());

      await DatabaseProvider().insertAppointment(_event);
      _patient.appointments.add(_event);
      _patient.initializeRecentFields();

      // we will also have to sink a PatientData event in case the patient's isActivated state changes
      Navigator.of(context).popUntil((Route<dynamic> route) {
        //end anlytics
        _analytic.stopAnalytics(
            resultAction: 'Saved', subjectEntity: this._patient.artNumber);

        return route.settings.name == '/patient';
      });
    }
  }
}
