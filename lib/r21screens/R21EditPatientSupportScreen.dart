import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/R21ContraceptionMethod.dart';
import 'package:pebrapp/database/beans/R21Prep.dart';
import 'package:pebrapp/database/beans/R21ProviderType.dart';
import 'package:pebrapp/database/beans/R21SRHServicePreferred.dart';
import 'package:pebrapp/database/beans/R21SupportType.dart';
import 'package:pebrapp/database/beans/R21ContactFrequency.dart';
import 'package:pebrapp/database/models/Patient.dart';

class R21EditPatientSupportScreen extends StatefulWidget {
  final Patient _existingPatient;

  R21EditPatientSupportScreen(this._existingPatient);

  @override
  _R21EditPatientSupportFormState createState() {
    return _R21EditPatientSupportFormState(_existingPatient);
  }
}

class _R21EditPatientSupportFormState
    extends State<R21EditPatientSupportScreen> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  final _formKey = GlobalKey<FormState>();

  final _questionsFlex = 1;
  final _answersFlex = 1;
  Patient _patientBeforeEditing;
  double _screenWidth = double.infinity;

  final Patient _patientToBeEdited;

  TextEditingController _providerLocationCtr = TextEditingController();

  _R21EditPatientSupportFormState(this._patientToBeEdited) {
    // Note: toMap -> fromMap copy operation copies all boolean variables as
    // false (isEligible, consentGiven, isActivated...)
    _patientBeforeEditing = Patient.fromMap(_patientToBeEdited.toMap());
    _providerLocationCtr.text = _patientToBeEdited.providerLocation;
    if (_patientToBeEdited.providerLocation != null) {
      _providerLocationCtr.text = _patientToBeEdited.providerLocation;
    }
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return PopupScreen(
      title: 'Edit Participant',
      subtitle: _patientToBeEdited.personalStudyNumber,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _personalInformationCard(),
            SizedBox(height: 16.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              PEBRAButtonRaised(
                'Save',
                onPressed: _isLoading ? null : _onSubmitForm,
              ),
            ]),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  // ----------
  // CARDS
  // ----------

  Widget _personalInformationCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Desired Support'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                _supportTypeQuestion(),
                _contactFrequency(),
                _srhServicePreferred(),
                _prep(),
                _contraceptiveMethod(),
                _providerLocation(),
                _providerType()
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ----------
  // QUESTIONS
  // ----------

  Widget _supportTypeQuestion() {
  
    return _makeQuestion(
      'Type of Support',
      answer: DropdownButtonFormField<R21SupportType>(
        value: _patientToBeEdited.supportType,
        onChanged: (R21SupportType newValue) {
          setState(() {
            _patientToBeEdited.supportType = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21SupportType.allValues
            .map<DropdownMenuItem<R21SupportType>>((R21SupportType value) {
          return DropdownMenuItem<R21SupportType>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _contactFrequency() {
    return _makeQuestion(
      'Frequency of Contact',
      answer: DropdownButtonFormField<R21ContactFrequency>(
        value: _patientToBeEdited.personalContactFrequency,
        onChanged: (R21ContactFrequency newValue) {
          setState(() {
            _patientToBeEdited.personalContactFrequency = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21ContactFrequency.allValues
            .map<DropdownMenuItem<R21ContactFrequency>>(
                (R21ContactFrequency value) {
          return DropdownMenuItem<R21ContactFrequency>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _srhServicePreferred() {
    return _makeQuestion(
      'SRH Service Preferred',
      answer: DropdownButtonFormField<R21SRHServicePreferred>(
        value: _patientToBeEdited.srhServicePreffered,
        onChanged: (R21SRHServicePreferred newValue) {
          setState(() {
            _patientToBeEdited.srhServicePreffered = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21SRHServicePreferred.allValues
            .map<DropdownMenuItem<R21SRHServicePreferred>>(
                (R21SRHServicePreferred value) {
          return DropdownMenuItem<R21SRHServicePreferred>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _prep() {
    return _makeQuestion(
      'PrEP',
      answer: DropdownButtonFormField<R21PrEP>(
        value: _patientToBeEdited.prep,
        onChanged: (R21PrEP newValue) {
          setState(() {
            _patientToBeEdited.prep = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items:
            R21PrEP.allValues.map<DropdownMenuItem<R21PrEP>>((R21PrEP value) {
          return DropdownMenuItem<R21PrEP>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

   Widget _contraceptiveMethod() {
    return _makeQuestion(
      'Contraceptive Method',
      answer: DropdownButtonFormField<R21ContraceptionMethod>(
        value: _patientToBeEdited.contraceptionMethod,
        onChanged: (R21ContraceptionMethod newValue) {
          setState(() {
            _patientToBeEdited.contraceptionMethod = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21ContraceptionMethod.allValues
            .map<DropdownMenuItem<R21ContraceptionMethod>>(
                (R21ContraceptionMethod value) {
          return DropdownMenuItem<R21ContraceptionMethod>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _providerLocation() {
    return _makeQuestion(
      'Location of Provider',
      answer: TextFormField(
        controller: _providerLocationCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a location';
          }
        },
      ),
    );
  }

  Widget _providerType() {
    return _makeQuestion(
      'Type of Provider',
      answer: DropdownButtonFormField<R21ProviderType>(
        value: _patientToBeEdited.providerType,
        onChanged: (R21ProviderType newValue) {
          setState(() {
            _patientToBeEdited.providerType = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21ProviderType.allValues
            .map<DropdownMenuItem<R21ProviderType>>((R21ProviderType value) {
          return DropdownMenuItem<R21ProviderType>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }
  // ----------
  // OTHER
  // ----------

  _onSubmitForm() async {
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_formKey.currentState.validate()) {
      _patientToBeEdited.providerLocation = _providerLocationCtr.text;
      
      await DatabaseProvider().insertPatient(_patientToBeEdited);
     
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return (route.settings.name == '/patient' ||
            route.settings.name == '/');
      });
    }
  }

  _buildTitle(String title) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
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
}
