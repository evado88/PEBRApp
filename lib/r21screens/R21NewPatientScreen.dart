import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/database/beans/PhoneNumberSecurity.dart';
import 'package:pebrapp/database/beans/R21ContactFrequency.dart';
import 'package:pebrapp/database/beans/R21ContraceptionMethod.dart';
import 'package:pebrapp/database/beans/R21ContraceptionUse.dart';
import 'package:pebrapp/database/beans/R21HIVStatus.dart';
import 'package:pebrapp/database/beans/R21Prep.dart';
import 'package:pebrapp/database/beans/R21ProviderType.dart';
import 'package:pebrapp/database/beans/R21SRHServicePreferred.dart';
import 'package:pebrapp/database/beans/R21Satisfaction.dart';
import 'package:pebrapp/database/beans/R21SupportType.dart';
import 'package:pebrapp/database/beans/SexualOrientation.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/InputFormatters.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:pebrapp/database/beans/NoChatDownloadReason.dart';
import 'package:pebrapp/utils/VisibleImpactUtils.dart';

class R21NewPatientScreen extends StatefulWidget {
  @override
  _R21NewPatientFormState createState() {
    return _R21NewPatientFormState();
  }
}

class _R21NewPatientFormState extends State<R21NewPatientScreen> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  final _formParticipantCharacteristicsKey = GlobalKey<FormState>();
  final _formParticipantHistoryKey = GlobalKey<FormState>();
  final _formParticipantSrhPreferenceKey = GlobalKey<FormState>();

  final _questionsFlex = 1;
  final _answersFlex = 1;

  static final int minAgeForEligibility = 15;
  static final int maxAgeForEligibility = 24;
  static final DateTime now = DateTime.now();
  static final DateTime minBirthdayForEligibility =
      DateTime(now.year - maxAgeForEligibility - 1, now.month, now.day + 1);
  static final DateTime maxBirthdayForEligibility =
      DateTime(now.year - minAgeForEligibility, now.month, now.day);
  bool get _eligible =>
      _newPatient.birthday != null &&
      !_newPatient.birthday.isBefore(minBirthdayForEligibility) &&
      !_newPatient.birthday.isAfter(maxBirthdayForEligibility);
  bool get _notEligibleAfterBirthdaySpecified =>
      _newPatient.birthday != null && !_eligible;

  Patient _newPatient = Patient(isActivated: true);
  ViralLoad _viralLoadBaseline =
      ViralLoad(source: ViralLoadSource.MANUAL_INPUT(), failed: false);
  bool _isLowerThanDetectable;

  TextEditingController _reasonStopContraceptionCtr = TextEditingController();
  TextEditingController _reasonNoContraceptionCtr = TextEditingController();
  TextEditingController _reasonNoContraceptionSatisfactionCtr =
      TextEditingController();

  TextEditingController _artNumberCtr = TextEditingController();
  TextEditingController _stickerNumberCtr = TextEditingController();
  TextEditingController _villageCtr = TextEditingController();
  TextEditingController _phoneNumberCtr = TextEditingController();
  TextEditingController _noChatDownloadReasonOtherCtr = TextEditingController();
  TextEditingController _viralLoadBaselineResultCtr = TextEditingController();
  TextEditingController _viralLoadBaselineLabNumberCtr =
      TextEditingController();

  // this field is used to display an error when the form is validated and if
  // the viral load baseline date is not selected
  bool _viralLoadBaselineDateValid = true;
  bool _patientBirthdayValid = true;

  List<String> _artNumbersInDB;
  List<String> _stickerNumbersInDB;
  bool _isLoading = true;

  double _screenWidth;

  // stepper state
  bool _patientSaved = false;
  bool _kobocollectOpened = false;
  bool _stepperFinished = false;
  int currentStep = 0;

  @override
  initState() {
    super.initState();
    DatabaseProvider()
        .retrieveLatestPatients(
            retrieveNonEligibles: false, retrieveNonConsents: false)
        .then((List<Patient> patients) {
      setState(() {
        _artNumbersInDB = patients.map((Patient p) => p.artNumber).toList();
        _stickerNumbersInDB =
            patients.map((Patient p) => p.stickerNumber).toList();
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;

    final Form patientCharacteristicsStep = Form(
      key: _formParticipantCharacteristicsKey,
      child: Column(
        children: [
          _personalInformationCard(),
          _eligibilityDisclaimer(),
          _messengerAppCard(),
          _contactInformationCard(),
          _notEligibleDisclaimer(),
        ],
      ),
    );

    final Form patientHistoryStep = Form(
      key: _formParticipantHistoryKey,
      child: Column(
        children: [
          _contraceptionCard(),
          _hivCard()
        ],
      ),
    );

    final Form patientSrhServicePreferenceStep = Form(
      key: _formParticipantSrhPreferenceKey,
      child: Column(
        children: [
          _contraceptionInterestCard(),
        ],
      ),
    );

    Widget finishStep() {
      if (_patientSaved) {
        print('~~~ PATIENT SAVED=>');
      } else {
        print('~~~ PATIENT NOT SAVED=>');
      }

      if (_patientSaved &&
          (_kobocollectOpened || !(_newPatient.downloadedChatAPp ?? true))) {
        return Container(
          width: double.infinity,
          child:
              Text("All done! You can close this screen by tapping ✓ below."),
        );
      }
      return Container(
          width: double.infinity,
          child: Text('Please complete the previous steps!'));
    }

    List<Step> steps = [
      Step(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Participant Characteristics',
                style: TextStyle(
                    fontWeight: currentStep == 0
                        ? FontWeight.bold
                        : FontWeight.normal)),
            SizedBox(width: 10.0),
            _isLoading
                ? SizedBox(
                    height: 10.0,
                    width: 10.0,
                    child: CircularProgressIndicator())
                : Container(),
          ],
        ),
        isActive: _patientSaved,
        state: _patientSaved ? StepState.complete : StepState.indexed,
        content: patientCharacteristicsStep,
      ),
      Step(
        title: Text('Contraception/PREP History And Preferences',
            style: TextStyle(
                fontWeight:
                    currentStep == 1 ? FontWeight.bold : FontWeight.normal)),
        isActive: _kobocollectOpened,
        state: _kobocollectOpened || !(_newPatient.downloadedChatAPp ?? true)
            ? StepState.complete
            : StepState.indexed,
        content: patientHistoryStep,
      ),
      Step(
          title: Text('SRH Service Preferences',
              style: TextStyle(
                  fontWeight:
                      currentStep == 1 ? FontWeight.bold : FontWeight.normal)),
          isActive: _kobocollectOpened,
          state: _kobocollectOpened || !(_newPatient.downloadedChatAPp ?? true)
              ? StepState.complete
              : StepState.indexed,
          content: Column()),
      Step(
        title: Text('Finish',
            style: TextStyle(
                fontWeight:
                    currentStep == 2 ? FontWeight.bold : FontWeight.normal)),
        isActive: _stepperFinished,
        state: _stepperFinished ? StepState.complete : StepState.indexed,
        content: finishStep(),
      ),
    ];

    goTo(int step) {
      if (step == 0 && _patientSaved) {
        // do not allow going back to first step if the patient has already
        // been saved
        return;
      }
      if (step == 1 && !(_newPatient.downloadedChatAPp ?? true)) {
        // skip going to step 'baseline assessment' if no consent is given and
        // we are coming from step 'patient characteristics'
        if (currentStep == 0) {
          setState(() => currentStep = step + 1);
        }
        // do not allow going to step 'baseline assessment' if no consent is
        // given
        return;
      }
      setState(() => currentStep = step);
    }

    next() async {
      switch (currentStep) {
        // patient characteristics form
        case 0:
          if (await _onSubmitForm()) {
            setState(() {
              _patientSaved = true;
            });
            goTo(1);
          }
          break;
        // baseline assessment
        case 1:
          goTo(2);
          break;
        // finish
        case 2:
          if (_patientSaved) {
            setState(() {
              _stepperFinished = true;
            });
            _closeScreen();
          }
      }
    }

    cancel() {
      if (currentStep > 0) {
        goTo(currentStep - 1);
      } else if (currentStep == 0) {
        _closeScreen();
      }
    }

    Widget stepper() {
      return Stepper(
        steps: steps,
//      type: StepperType.horizontal,
        currentStep: currentStep,
        onStepTapped: goTo,
        onStepContinue: (_isLoading ||
                (currentStep == 2 &&
                    (!_patientSaved ||
                        (!_kobocollectOpened &&
                            (_newPatient.downloadedChatAPp ?? false)))))
            ? null
            : next,
        onStepCancel: (currentStep == 1 && _patientSaved ||
                (currentStep == 2 && !(_newPatient.downloadedChatAPp ?? true)))
            ? null
            : cancel,
        controlsBuilder: (BuildContext context,
            {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          final Color navigationButtonsColor = Colors.blue;
          return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                currentStep == 0 || currentStep == 1
                    ? SizedBox()
                    : Container(
                        decoration: BoxDecoration(
                          color: onStepCancel == null
                              ? BUTTON_INACTIVE
                              : (currentStep == 0
                                  ? STEPPER_ABORT
                                  : navigationButtonsColor),
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: IconButton(
                          color: Colors.white,
                          onPressed: onStepCancel,
                          icon: Icon(currentStep == 0
                              ? Icons.close
                              : Icons.keyboard_arrow_up),
                        ),
                      ),
                SizedBox(width: 20.0),
                Container(
                  decoration: BoxDecoration(
                    color: onStepContinue == null
                        ? BUTTON_INACTIVE
                        : (currentStep == 2
                            ? STEPPER_FINISH
                            : navigationButtonsColor),
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: onStepContinue,
                    icon: Icon(currentStep == 2
                        ? Icons.check
                        : Icons.keyboard_arrow_down),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return PopupScreen(
      title: 'New Participant',
      actions: _patientSaved ? [] : null,
      child: stepper(),
      scrollable: false,
    );
  }

  // ----------
  // CARDS
  // ----------

  Widget _personalInformationCard() {
    return _buildCard(
      'Personal Information',
      withTopPadding: false,
      child: Column(
        children: [
          _studyNumberQuestion(),
          _birthdayQuestion(),
        ],
      ),
    );
  }

  Widget _contraceptionCard() {
    return _buildCard(
      'Contraception',
      withTopPadding: true,
      child: Column(
        children: [
          _isusingContraception(),
          _contraceptiveMethod(),
          _contraception(),
          _whyStopContraception(),
          _contraceptionSatisfaction(),
          _whyNoContraceptionSatisfaction(),
          _whyNoContraception(),
        ],
      ),
    );
  }

    Widget _hivCard() {
    return _buildCard(
      'HIV Status',
      withTopPadding: true,
      child: Column(
        children: [
          _hivStatus(),
        ],
      ),
    );
  }


  Widget _contraceptionInterestCard() {
    return _buildCard(
      'Desired Support',
      withTopPadding: true,
      child: Column(
        children: [
          _isusingContraception(),
          _srhServicePreferred(),
          _prep(),
          _contraceptiveMethod(),
          _whyNoContraceptionSatisfaction(),
          _providerType()
        ],
      ),
    );
  }

  Widget _messengerAppCard() {
    if (_notEligibleAfterBirthdaySpecified) {
      return Container();
    }
    return _buildCard(
      'Messenger App',
      child: Column(
        children: [
          _consentGivenQuestion(),
          _noConsentReasonQuestion(),
          _noConsentReasonOtherQuestion(),
        ],
      ),
    );
  }

  Widget _contactInformationCard() {
    return _buildCard(
      'Contact Information',
      child: Column(
        children: [
          _phoneNumberQuestion(),
          _phoneAvailabilityQuestion(),
          _residencyQuestion(),
          _preferredContactMethodQuestion(),
          _contactFrequency(),
        ],
      ),
    );
  }

  // ----------
  // QUESTIONS
  // ----------

  //R21

  Widget _isusingContraception() {
    return _makeQuestion(
      'Is the client currently using modern contraception or has used in the past?',
      answer: DropdownButtonFormField<R21ContraceptionUse>(
        value: _newPatient.contraceptionUse,
        onChanged: (R21ContraceptionUse newValue) {
          setState(() {
            _newPatient.contraceptionUse = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21ContraceptionUse.allValues
            .map<DropdownMenuItem<R21ContraceptionUse>>(
                (R21ContraceptionUse value) {
          return DropdownMenuItem<R21ContraceptionUse>(
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
        value: _newPatient.contactFrequency,
        onChanged: (R21ContactFrequency newValue) {
          setState(() {
            _newPatient.contactFrequency = newValue;
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
        value: _newPatient.srhServicePreffered,
        onChanged: (R21SRHServicePreferred newValue) {
          setState(() {
            _newPatient.srhServicePreffered = newValue;
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
        value: _newPatient.prep,
        onChanged: (R21PrEP newValue) {
          setState(() {
            _newPatient.prep = newValue;
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

  Widget _hivStatus() {

    return _makeQuestion(
      'Does the client know her HIV status? ',
      answer: DropdownButtonFormField<R21HIVStatus>(
        value: _newPatient.hivStatus,
        onChanged: (R21HIVStatus newValue) {
          setState(() {
            _newPatient.hivStatus = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21HIVStatus.allValues
            .map<DropdownMenuItem<R21HIVStatus>>(
                (R21HIVStatus value) {
          return DropdownMenuItem<R21HIVStatus>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _contraceptiveMethod() {
    if (_newPatient.contraceptionUse == null ||
        _newPatient.contraceptionUse == R21ContraceptionUse.HasNever()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Contraceptive Method',
      answer: DropdownButtonFormField<R21ContraceptionMethod>(
        value: _newPatient.contraceptionMethod,
        onChanged: (R21ContraceptionMethod newValue) {
          setState(() {
            _newPatient.contraceptionMethod = newValue;
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

  Widget _contraceptionSatisfaction() {
    if (_newPatient.contraceptionUse == null ||
        _newPatient.contraceptionUse != R21ContraceptionUse.CurrentlyUsing()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Satisfaction with current method',
      answer: DropdownButtonFormField<R21Satisfaction>(
        value: _newPatient.contraceptionSatisfaction,
        onChanged: (R21Satisfaction newValue) {
          setState(() {
            _newPatient.contraceptionSatisfaction = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21Satisfaction.allValues
            .map<DropdownMenuItem<R21Satisfaction>>((R21Satisfaction value) {
          return DropdownMenuItem<R21Satisfaction>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _whyNoContraceptionSatisfaction() {
    if (_newPatient.contraceptionUse == null ||
        _newPatient.contraceptionUse != R21ContraceptionUse.CurrentlyUsing()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Why',
      answer: TextFormField(
        controller: _reasonNoContraceptionSatisfactionCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _whyNoContraception() {

    if (_newPatient.contraceptionUse == null ||
        _newPatient.contraceptionUse !=
            R21ContraceptionUse.HasNever()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Why not',
      answer: TextFormField(
        controller: _reasonNoContraceptionCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _whyStopContraception() {
    if (_newPatient.contraceptionUse == null ||
        _newPatient.contraceptionUse !=
            R21ContraceptionUse.NotCurrentButPast()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Why did she stop using ',
      answer: TextFormField(
        controller: _reasonStopContraceptionCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _providerType() {
    return _makeQuestion(
      'Type of Provider',
      answer: DropdownButtonFormField<R21ProviderType>(
        value: _newPatient.providerType,
        onChanged: (R21ProviderType newValue) {
          setState(() {
            _newPatient.providerType = newValue;
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

  //Main
  Widget _residencyQuestion() {
    return _makeQuestion(
      'Residence',
      answer: DropdownButtonFormField<Gender>(
        value: _newPatient.gender,
        onChanged: (Gender newValue) {
          setState(() {
            _newPatient.gender = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: Gender.allValues.map<DropdownMenuItem<Gender>>((Gender value) {
          return DropdownMenuItem<Gender>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _studyNumberQuestion() {
    return _makeQuestion(
      'Study Number',
      answer: TextFormField(
        autocorrect: false,
        controller: _artNumberCtr,
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(5),
          StudyNumberTextInputFormatter(),
        ],
        validator: (String value) {
          if (_artNumberExists(value)) {
            return 'Participant with this study number already exists';
          }
          return validateStudyNumber(value);
        },
      ),
    );
  }

  Widget _stickerNumberQuestion() {
    return _makeQuestion(
      'Sticker Number',
      answer: TextFormField(
        autocorrect: false,
        decoration: InputDecoration(
          errorMaxLines: 2,
          prefixText: 'P',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        controller: _stickerNumberCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter the sticker number';
          } else if (value.length != 3) {
            return 'Exactly 3 digits required';
          } else if (_stickerNumberExists('P$value')) {
            return 'Participant with this sticker number already exists';
          }
          return null;
        },
      ),
    );
  }

  Widget _birthdayQuestion() {
    return _makeQuestion(
      'Birthday',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _newPatient.birthday == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.birthday)} (age ${calculateAge(_newPatient.birthday)})',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          onPressed: () async {
            DateTime date = await showDatePicker(
              context: context,
              initialDate: _newPatient.birthday ?? minBirthdayForEligibility,
              firstDate: minBirthdayForEligibility,
              lastDate: maxBirthdayForEligibility,
            );
            if (date != null) {
              setState(() {
                _newPatient.birthday = date;
              });
            }
          },
        ),
        Divider(
          color: CUSTOM_FORM_FIELD_UNDERLINE,
          height: 1.0,
        ),
        _patientBirthdayValid
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

  Widget _preferredContactMethodQuestion() {
    return _makeQuestion(
      'Preferred way to contact',
      answer: DropdownButtonFormField<SexualOrientation>(
        value: _newPatient.sexualOrientation,
        onChanged: (SexualOrientation newValue) {
          setState(() {
            _newPatient.sexualOrientation = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: SexualOrientation.allValues
            .map<DropdownMenuItem<SexualOrientation>>(
                (SexualOrientation value) {
          return DropdownMenuItem<SexualOrientation>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _phoneAvailabilityQuestion() {
    return _makeQuestion(
      'Is your phone',
      answer: DropdownButtonFormField<PhoneNumberSecurity>(
        value: _newPatient.phoneAvailability,
        onChanged: (PhoneNumberSecurity newValue) {
          setState(() {
            _newPatient.phoneAvailability = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: PhoneNumberSecurity.allValues
            .map<DropdownMenuItem<PhoneNumberSecurity>>(
                (PhoneNumberSecurity value) {
          return DropdownMenuItem<PhoneNumberSecurity>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _phoneNumberQuestion() {
    return _makeQuestion(
      'Phone Number',
      answer: TextFormField(
        decoration: InputDecoration(
          prefixText: '+260',
        ),
        controller: _phoneNumberCtr,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
          ZambiaPhoneNumberTextInputFormatter(),
        ],
        validator: validatePhoneNumber,
      ),
    );
  }

  Widget _consentGivenQuestion() {
    return _makeQuestion(
      'Has the client downloaded the messenger app?',
      answer: DropdownButtonFormField<bool>(
        value: _newPatient.downloadedChatAPp,
        onChanged: (bool newValue) {
          setState(() {
            _newPatient.downloadedChatAPp = newValue;
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

  Widget _noConsentReasonQuestion() {
    if (_newPatient.downloadedChatAPp == null ||
        _newPatient.downloadedChatAPp) {
      return Container();
    }
    return _makeQuestion(
      'Why',
      answer: DropdownButtonFormField<NoChatDownloadReason>(
        value: _newPatient.noConsentReason,
        onChanged: (NoChatDownloadReason newValue) {
          setState(() {
            _newPatient.noConsentReason = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: NoChatDownloadReason.allValues
            .map<DropdownMenuItem<NoChatDownloadReason>>(
                (NoChatDownloadReason value) {
          return DropdownMenuItem<NoChatDownloadReason>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _noConsentReasonOtherQuestion() {
    if (_newPatient.downloadedChatAPp == null ||
        _newPatient.downloadedChatAPp ||
        _newPatient.noConsentReason == null ||
        _newPatient.noConsentReason != NoChatDownloadReason.OTHER()) {
      return Container();
    }
    return _makeQuestion(
      'Other, specify',
      answer: TextFormField(
        controller: _noChatDownloadReasonOtherCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify the reasons';
          }
          return null;
        },
      ),
    );
  }

  // ----------
  // OTHER
  // ----------

  Widget _eligibilityDisclaimer() {
    if (_newPatient.birthday != null) {
      return Container();
    }
    return Padding(
      padding: EdgeInsets.only(top: 15.0),
      child: Text(
        'Only candidates between ages $minAgeForEligibility and $maxAgeForEligibility are eligible.',
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _notEligibleDisclaimer() {
    if (_newPatient.birthday == null || _eligible) {
      return Container();
    }
    return Padding(
      padding: EdgeInsets.only(top: 15.0),
      child: Text(
        'This candidate is not eligible for the study. Only candidates born '
        'between ${formatDateConsistent(minBirthdayForEligibility)} and '
        '${formatDateConsistent(maxBirthdayForEligibility)} are '
        'eligible. The candidate will not appear in the PEBRApp.',
        textAlign: TextAlign.left,
      ),
    );
  }

  bool _validatePatientBirthday() {
    // if the birthday is not specified show the error message under the
    // birthday field and return false.
    if (_newPatient.birthday == null) {
      setState(() {
        _patientBirthdayValid = false;
      });
      return false;
    }
    setState(() {
      _patientBirthdayValid = true;
    });
    return true;
  }

  /// Returns true if the form validation succeeds and the patient was saved
  /// successfully.
  Future<bool> _onSubmitForm() async {
    setState(() {
      _isLoading = true;
    });
    if (_formParticipantCharacteristicsKey.currentState.validate() &
            _validatePatientBirthday()
        // &_validateViralLoadBaselineDate()
        ) {
      final DateTime now = DateTime.now();

      _newPatient.enrollmentDate = now;
      _newPatient.isEligible = _eligible;
      _newPatient.artNumber = _artNumberCtr.text;
      _newPatient.stickerNumber = (_newPatient.downloadedChatAPp ?? false)
          ? 'P${_stickerNumberCtr.text}'
          : null;
      _newPatient.village = _villageCtr.text;
      _newPatient.phoneNumber = '+266-${_phoneNumberCtr.text}';
      _newPatient.noConsentReasonOther = _noChatDownloadReasonOtherCtr.text;
      _newPatient.village = _villageCtr.text;
      _newPatient.village = _villageCtr.text;
      _newPatient.village = _villageCtr.text;
      _newPatient.checkLogicAndResetUnusedFields();

      _newPatient.providerLocation = (_newPatient.downloadedChatAPp ?? false)
          ? _reasonNoContraceptionCtr.text
          : null;

      if (_newPatient.isEligible && _newPatient.downloadedChatAPp) {
        await DatabaseProvider().insertRequiredAction(RequiredAction(
            _newPatient.artNumber,
            RequiredActionType.ADHERENCE_QUESTIONNAIRE_2P5M_REQUIRED,
            addMonths(now, 2, addHalfMonth: true)));
        await DatabaseProvider().insertRequiredAction(RequiredAction(
            _newPatient.artNumber,
            RequiredActionType.ADHERENCE_QUESTIONNAIRE_5M_REQUIRED,
            addMonths(now, 5)));
        await DatabaseProvider().insertRequiredAction(RequiredAction(
            _newPatient.artNumber,
            RequiredActionType.ADHERENCE_QUESTIONNAIRE_9M_REQUIRED,
            addMonths(now, 9)));
        await DatabaseProvider().insertRequiredAction(RequiredAction(
            _newPatient.artNumber,
            RequiredActionType.QUALITY_OF_LIFE_QUESTIONNAIRE_5M_REQUIRED,
            addMonths(now, 5)));
        await DatabaseProvider().insertRequiredAction(RequiredAction(
            _newPatient.artNumber,
            RequiredActionType.QUALITY_OF_LIFE_QUESTIONNAIRE_9M_REQUIRED,
            addMonths(now, 9)));
        await DatabaseProvider().insertRequiredAction(RequiredAction(
            _newPatient.artNumber,
            RequiredActionType.VIRAL_LOAD_9M_REQUIRED,
            addMonths(now, 9)));
      }

      if (_newPatient.isEligible && _newPatient.downloadedChatAPp) {
        _viralLoadBaseline.patientART = _artNumberCtr.text;
      }

      await _newPatient.initializeRequiredActionsField();
      await DatabaseProvider().insertPatient(_newPatient);
      await PatientBloc.instance.sinkNewPatientData(_newPatient);
      setState(() {
        _isLoading = false;
      });
      uploadPatientCharacteristics(_newPatient, showNotification: false);
      return true;
    }
    setState(() {
      _isLoading = false;
    });
    return false;
  }

  void _closeScreen() {
    Navigator.of(context).popUntil((Route<dynamic> route) {
      return (route.settings.name == '/');
    });
  }

  Future<void> _onOpenKoboCollectPressed() async {
    setState(() {
      _kobocollectOpened = true;
    });
    await openKoboCollectApp();
  }

  Widget _buildCard(String title,
      {@required Widget child, bool withTopPadding: true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: withTopPadding ? 20.0 : 0.0),
        _buildTitle(title),
        SizedBox(height: 10.0),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 0.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
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
        SizedBox(width: 10.0),
        Expanded(
          flex: _answersFlex,
          child: answer,
        ),
      ],
    );
  }

  bool _artNumberExists(artNumber) {
    return _artNumbersInDB.contains(artNumber);
  }

  bool _stickerNumberExists(stickerNumber) {
    return _stickerNumbersInDB.contains(stickerNumber);
  }

  void _showDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            FlatButton(
              child: Row(children: [Text('OK', textAlign: TextAlign.center)]),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
