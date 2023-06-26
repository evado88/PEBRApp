import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/R21MedicationType.dart';
import 'package:pebrapp/database/beans/R21RefilNotDoneReason.dart';
import 'package:pebrapp/database/beans/R21ScreenType.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/R21MedicationRefill.dart';
import 'package:pebrapp/database/models/R21ScreenAnalytic.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/Utils.dart';

class R21AddMedicationRefillScreen extends StatelessWidget {
  final Patient _patient;
  final R21ScreenAnalytic _analytic =
      new R21ScreenAnalytic(type: R21ScreenType.AddMedicationRefil());

  R21AddMedicationRefillScreen(
    this._patient,
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
        title: 'Add Medication Refil',
        subtitle: _patient.artNumber,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _onPressCancel(context);
              })
        ],
        child: R21AddMedicationRefillForm(_patient, _analytic));
  }
}

class R21AddMedicationRefillForm extends StatefulWidget {
  final Patient _patient;
  final R21ScreenAnalytic _analytic;

  R21AddMedicationRefillForm(this._patient, this._analytic);

  @override
  createState() => _R21AddMedicationRefillFormState(_patient, _analytic);
}

class _R21AddMedicationRefillFormState
    extends State<R21AddMedicationRefillForm> {
  // fields
  final _formKey = GlobalKey<FormState>();
  final int _questionsFlex = 1;
  final int _answersFlex = 1;
  double _screenWidth = double.infinity;

  final Patient _patient;
  final R21ScreenAnalytic _analytic;

  R21MedicationRefill _medicationRefil;

  TextEditingController _descriptionCtr = TextEditingController();

  // constructor
  _R21AddMedicationRefillFormState(this._patient, this._analytic) {
    _medicationRefil = R21MedicationRefill(this._patient.artNumber);
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
            _typeQuestion(),
            _dateQuestion(),
            _descriptionQuestion(),
            _occurQuestion(),
            _medicationRefil.refillDone != null && !_medicationRefil.refillDone
                ? _noOccurReasonQuestion()
                : Container(),
            _nextDateQuestion(),
          ],
        ),
      ),
    );
  }

  Widget _typeQuestion() {
    return _makeQuestion(
      'Type of medication',
      answer: DropdownButtonFormField<R21MedicationType>(
        value: _medicationRefil.medicationType,
        onChanged: (R21MedicationType newValue) {
          setState(() {
            _medicationRefil.medicationType = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21MedicationType.allValues
            .map<DropdownMenuItem<R21MedicationType>>(
                (R21MedicationType value) {
          return DropdownMenuItem<R21MedicationType>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _noOccurReasonQuestion() {
    return _makeQuestion(
      'Reason why the refill was not done',
      answer: DropdownButtonFormField<R21RefilNotDoneReason>(
        value: _medicationRefil.notDoneReason,
        onChanged: (R21RefilNotDoneReason newValue) {
          setState(() {
            _medicationRefil.notDoneReason = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21RefilNotDoneReason.allValues
            .map<DropdownMenuItem<R21RefilNotDoneReason>>(
                (R21RefilNotDoneReason value) {
          return DropdownMenuItem<R21RefilNotDoneReason>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _dateQuestion() {
    return _makeQuestion(
      'Refil Date',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _medicationRefil.refillDate == null
                  ? 'Select Date'
                  : formatDateConsistent(_medicationRefil.refillDate),
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
                cinitialDate: _medicationRefil.refillDate ??
                    DateTime(now.year, now.month, now.day));
            if (date != null) {
              setState(() {
                _medicationRefil.refillDate = date;
              });
            }
          },
        ),
        Divider(
          color: CUSTOM_FORM_FIELD_UNDERLINE,
          height: 1.0,
        ),
        _medicationRefil.refillDate != null
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
      'Date of next refil',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _medicationRefil.nextRefillDate == null
                  ? 'Select Date'
                  : formatDateConsistent(_medicationRefil.nextRefillDate),
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
                cinitialDate: _medicationRefil.nextRefillDate ??
                    DateTime(now.year, now.month, now.day));
            if (date != null) {
              setState(() {
                _medicationRefil.nextRefillDate = date;
              });
            }
          },
        ),
        Divider(
          color: CUSTOM_FORM_FIELD_UNDERLINE,
          height: 1.0,
        ),
        _medicationRefil.nextRefillDate != null
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
      'Was the refil done?',
      answer: DropdownButtonFormField<bool>(
        value: _medicationRefil.refillDone,
        onChanged: (bool newValue) {
          setState(() {
            _medicationRefil.refillDone = newValue;
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
                _medicationRefil.description = value;
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
        _medicationRefil.refillDate != null &&
        _medicationRefil.nextRefillDate != null) {
      print('***Saving to db' + _medicationRefil.toString());

      await DatabaseProvider().insertMedicationRefil(_medicationRefil);
      _patient.medicationRefils.add(_medicationRefil);
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
