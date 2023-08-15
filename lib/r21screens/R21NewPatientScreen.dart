import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
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
import 'package:pebrapp/database/beans/R21Interest.dart';
import 'package:pebrapp/database/beans/R21Prep.dart';
import 'package:pebrapp/database/beans/R21ProviderType.dart';
import 'package:pebrapp/database/beans/R21SRHServicePreferred.dart';
import 'package:pebrapp/database/beans/R21Satisfaction.dart';
import 'package:pebrapp/database/beans/R21SupportType.dart';
import 'package:pebrapp/database/beans/R21Week.dart';
import 'package:pebrapp/database/beans/R21YesNo.dart';
import 'package:pebrapp/database/beans/R21YesNoUnsure.dart';
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

  static final DateTime minARTRefilDate =
      DateTime(now.year - minAgeForEligibility, now.month, now.day);

  TextEditingController _specifyPrepRefilCollectionClinicCtr =
      TextEditingController();

  TextEditingController _problemsTakingPrepCtr = TextEditingController();

  TextEditingController _questionsAboutPrepMedicationCtr =
      TextEditingController();

  TextEditingController _reasonPrepStopReasonCtr = TextEditingController();

  bool get _eligible =>
      _newPatient.birthday != null &&
      !_newPatient.birthday.isBefore(minBirthdayForEligibility) &&
      !_newPatient.birthday.isAfter(maxBirthdayForEligibility);
  bool get _notEligibleAfterBirthdaySpecified =>
      _newPatient.birthday != null && !_eligible;

  Patient _newPatient = Patient(isActivated: true);
  ViralLoad _viralLoadBaseline =
      ViralLoad(source: ViralLoadSource.MANUAL_INPUT(), failed: false);

  TextEditingController _reasonStopContraceptionCtr = TextEditingController();
  TextEditingController _reasonNoContraceptionCtr = TextEditingController();
  TextEditingController _specifyContraceptionMethodCtr =
      TextEditingController();
  TextEditingController _reasonNoContraceptionSatisfactionCtr =
      TextEditingController();

  TextEditingController _problemsTakingARTCtr = TextEditingController();
  TextEditingController _specifyARTRefilCollectionClinicCtr =
      TextEditingController();

  TextEditingController _questionsAboutARTMedicationCtr =
      TextEditingController();

  TextEditingController _artNumberCtr = TextEditingController();
  TextEditingController _stickerNumberCtr = TextEditingController();
  TextEditingController _villageCtr = TextEditingController();
  TextEditingController _phoneNumberCtr = TextEditingController();
  TextEditingController _noChatDownloadReasonOtherCtr = TextEditingController();

  TextEditingController _interestContraceptionMethodOtherCtr =
      TextEditingController();

  TextEditingController _interestContraceptionSelectedFacilityCodeCtr =
      TextEditingController();

  TextEditingController _interestContraceptionNotNowDateOtherCtr =
      TextEditingController();

  TextEditingController _interestContraceptionMaybeMethodSpecifyCtr =
      TextEditingController();

  // this field is used to display an error when the form is validated and if
  // the viral load baseline date is not selected
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
        children: [_contraceptionCard(), _hivCard()],
      ),
    );

    final Form patientSrhServicePreferenceStep = Form(
      key: _formParticipantSrhPreferenceKey,
      child: Column(
        children: [_contraceptionInterestCard(), _prepInterestCard()],
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
          content: patientSrhServicePreferenceStep),
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
          _contraceptionUse(),
          _contraceptiveMethod(),
          _specifyContraceptionMethod(),
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
          _takingART(),
          _lastARTRefilDateQuestion(),
          _ARTRefilCollectionClinic(),
          _specifyARTRefilCollectionClinic(),
          _problemsTakingART(),
          _questionsAboutARTMedication(),
          _desiredARTSupport(),
          _specifyARTDesiredSupportOther(),
          _lastHIVTestDateQuestion(),
          _clientEverUsedPrep(),
          _specifyPrepStopReason(),
          _lastPrepRefilDateQuestion(),
          _prepRefilCollectionClinic(),
          _specifyPrepRefilCollectionClinic(),
          _problemsTakingPrep(),
          _questionsAboutPrepMedication(),
          _desiredPrepSupport(),
          _specifyPrepDesiredSupportOther()
        ],
      ),
    );
  }

  Widget _contraceptionInterestCard() {
    return _buildCard(
      'Contraception',
      withTopPadding: true,
      child: Column(
        children: [
          _contraceptionInterest(),
          _hasMethodInMind(),
          _particularMethodInMind(),
          _specifyInterestContraceptionMethodOther(),
          _interestContraceptionLikeInfoMethods(),
          _interestContraceptionOpenCounselingInfoPage(),
          _interestContraceptionLikeFacilitySchedule(),
          _interestContraceptionLikeFacilityScheduleDate(),
          _interestContraceptionLikePNAccompany(),
          _interestContraceptionOpenFacilitiesPage(),
          _interestContraceptionSelectedFacility(),
          _interestContraceptionNotNowDate(),
          _interestContraceptionNotNowDateOther(),
          _interestContraceptionNotNowPickFacility(),
          _interestContraceptionNotNowPickFacilityShow(),
          _interestContraceptionNotNowPickFacilitySelected(),
          _interestContraceptionLikeInformationOnApp(),
          _interestContraceptionMaybeMethod(),
          _interestContraceptionMaybeMethodSpecify()
        ],
      ),
    );
  }

  Widget _prepInterestCard() {
    return _buildCard(
      'PrEP',
      withTopPadding: true,
      child: Column(
        children: [
          _prepInterest(),
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

  Widget _contraceptionInterest() {
    return _makeQuestion(
      'Interest in using contraception ',
      answer: DropdownButtonFormField<R21Interest>(
        value: _newPatient.contraceptionInterest,
        onChanged: (R21Interest newValue) {
          setState(() {
            _newPatient.contraceptionInterest = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21Interest.allValues
            .map<DropdownMenuItem<R21Interest>>((R21Interest value) {
          return DropdownMenuItem<R21Interest>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _hasMethodInMind() {
    if (_newPatient.contraceptionInterest == null ||
        _newPatient.contraceptionInterest != R21Interest.VeryInterested()) {
      return SizedBox();
    }
    return _makeQuestion(
      'Does she have a particular method in mind?',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _newPatient.hasContraceptiveMethodInMind,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _newPatient.hasContraceptiveMethodInMind = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21YesNo.allValues
            .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
          return DropdownMenuItem<R21YesNo>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _particularMethodInMind() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.hasContraceptiveMethodInMind == null ||
            _newPatient.hasContraceptiveMethodInMind == R21YesNo.NO())) {
      return SizedBox();
    }

    return _makeQuestion('Which method',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionMaleCondoms,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionMaleCondoms = value;
                });
              },
            ),
            Text(
              'Male Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionFemaleCondoms,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionFemaleCondoms = value;
                });
              },
            ),
            Text(
              'Female Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionImplant,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionImplant = value;
                });
              },
            ),
            Text(
              'Implant',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionInjection,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionInjection = value;
                });
              },
            ),
            Text(
              'Injection',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionIUD,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionIUD = value;
                });
              },
            ),
            Text(
              'IUD (intrauterine Device or Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionIUS,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionIUS = value;
                });
              },
            ),
            Text(
              'IUS (intrauterine System or Hormonal Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionPills,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionPills = value;
                });
              },
            ),
            Text(
              'Contraception Pills (combined or progestogen-only)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionOther = value;
                });
              },
            ),
            Text(
              'Other (specify)',
            ),
          ])
        ]),
        forceColumn: true,
        makeBold: true);
  }

  Widget _specifyInterestContraceptionMethodOther() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.hasContraceptiveMethodInMind == null ||
            _newPatient.hasContraceptiveMethodInMind == R21YesNo.NO()) ||
        (_newPatient.interestContraceptionOther == null ||
            _newPatient.interestContraceptionOther == false)) {
      return Container();
    }
    return _makeQuestion(
      'Specify other method',
      answer: TextFormField(
        controller: _interestContraceptionMethodOtherCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify the method';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionLikeInfoMethods() {
    if (_newPatient.contraceptionInterest == null ||
        _newPatient.contraceptionInterest != R21Interest.VeryInterested()) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like more information about different methods right now?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.interestContraceptionLikeMoreInfo,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.interestContraceptionLikeMoreInfo = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionOpenCounselingInfoPage() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.interestContraceptionLikeMoreInfo == null ||
            _newPatient.interestContraceptionLikeMoreInfo == R21YesNo.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information Page', onPressed: () {
      print('~~~ OPENING COUNSELLING INFO PAGE =>');
    });
  }

  Widget _interestContraceptionLikeFacilitySchedule() {
    if (_newPatient.contraceptionInterest == null ||
        _newPatient.contraceptionInterest != R21Interest.VeryInterested()) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly a method of her choice NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _newPatient.interestContraceptionLikeFindFacilitySchedule,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _newPatient.interestContraceptionLikeFindFacilitySchedule =
                  newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNoUnsure.allValues
              .map<DropdownMenuItem<R21YesNoUnsure>>((R21YesNoUnsure value) {
            return DropdownMenuItem<R21YesNoUnsure>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionLikeFacilityScheduleDate() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.interestContraceptionLikeFindFacilitySchedule == null ||
            _newPatient.interestContraceptionLikeFindFacilitySchedule ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'When would she like to go',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _newPatient.lastARTRefilDate == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.lastARTRefilDate)}',
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
              initialDate: now,
              firstDate: minARTRefilDate,
              lastDate: now,
            );
            if (date != null) {
              setState(() {
                _newPatient.lastARTRefilDate = date;
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

  Widget _interestContraceptionLikePNAccompany() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.interestContraceptionLikeFindFacilitySchedule == null ||
            _newPatient.interestContraceptionLikeFindFacilitySchedule ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }
    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.interestContraceptionLikePNAAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.interestContraceptionLikePNAAccompany = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: false);
  }

  Widget _interestContraceptionOpenFacilitiesPage() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.interestContraceptionLikeFindFacilitySchedule == null ||
            _newPatient.interestContraceptionLikeFindFacilitySchedule ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ OPENING FACILITIES PAGE =>');
    });
  }

  Widget _interestContraceptionSelectedFacility() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.interestContraceptionLikeFindFacilitySchedule == null ||
            _newPatient.interestContraceptionLikeFindFacilitySchedule ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }
    return _makeQuestion(
      'Selected Facility Code',
      answer: TextFormField(
        controller: _interestContraceptionSelectedFacilityCodeCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify selected facility';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionNotNowDate() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.interestContraceptionLikeFindFacilitySchedule == null ||
            _newPatient.interestContraceptionLikeFindFacilitySchedule ==
                R21YesNoUnsure.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
        'When would she like to go for counseling and possibly a method of her choice?',
        answer: DropdownButtonFormField<R21Week>(
          value: _newPatient.interestContraceptionNotNowDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _newPatient.interestContraceptionNotNowDate = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items:
              R21Week.allValues.map<DropdownMenuItem<R21Week>>((R21Week value) {
            return DropdownMenuItem<R21Week>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionNotNowDateOther() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.interestContraceptionLikeFindFacilitySchedule == null ||
            _newPatient.interestContraceptionLikeFindFacilitySchedule ==
                R21YesNoUnsure.YES()) ||
        (_newPatient.interestContraceptionNotNowDate == null ||
            _newPatient.interestContraceptionNotNowDate != R21Week.Other())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other date',
      answer: TextFormField(
        controller: _interestContraceptionNotNowDateOtherCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify date';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionNotNowPickFacility() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.interestContraceptionLikeFindFacilitySchedule == null ||
            _newPatient.interestContraceptionLikeFindFacilitySchedule ==
                R21YesNoUnsure.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _newPatient.interestContraceptionNotNowPickFacility,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _newPatient.interestContraceptionNotNowPickFacility = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21YesNo.allValues
            .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
          return DropdownMenuItem<R21YesNo>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _interestContraceptionNotNowPickFacilityShow() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.interestContraceptionLikeFindFacilitySchedule == null ||
            _newPatient.interestContraceptionLikeFindFacilitySchedule ==
                R21YesNoUnsure.YES()) ||
        (_newPatient.interestContraceptionNotNowPickFacility == null ||
            _newPatient.interestContraceptionNotNowPickFacility ==
                R21YesNo.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ OPENING FACILITIES PAGE =>');
    });
  }

  Widget _interestContraceptionNotNowPickFacilitySelected() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.interestContraceptionLikeFindFacilitySchedule == null ||
            _newPatient.interestContraceptionLikeFindFacilitySchedule ==
                R21YesNoUnsure.YES()) ||
        (_newPatient.interestContraceptionNotNowPickFacility == null ||
            _newPatient.interestContraceptionNotNowPickFacility ==
                R21YesNo.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code',
      answer: TextFormField(
        controller: _interestContraceptionSelectedFacilityCodeCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify selected facility';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionLikeInformationOnApp() {
    if (_newPatient.contraceptionInterest == null ||
        _newPatient.contraceptionInterest != R21Interest.VeryInterested()) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.interestContraceptionLikeInformationOnApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.interestContraceptionLikeInformationOnApp = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionMaybeMethod() {
    if (_newPatient.contraceptionInterest == null ||
        _newPatient.contraceptionInterest != R21Interest.MaybeInterested()) {
      return SizedBox();
    }

    return _makeQuestion('What method(s) is the client possibly interested in',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionMaleCondoms,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionMaleCondoms = value;
                });
              },
            ),
            Text(
              'Male Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionFemaleCondoms,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionFemaleCondoms = value;
                });
              },
            ),
            Text(
              'Female Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionImplant,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionImplant = value;
                });
              },
            ),
            Text(
              'Implant',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionInjection,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionInjection = value;
                });
              },
            ),
            Text(
              'Injection',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionIUD,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionIUD = value;
                });
              },
            ),
            Text(
              'IUD (intrauterine Device or Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionIUS,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionIUS = value;
                });
              },
            ),
            Text(
              'IUS (intrauterine System or Hormonal Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionPills,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionPills = value;
                });
              },
            ),
            Text(
              'Contraception Pills (combined or progestogen-only)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.interestContraceptionOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.interestContraceptionOther = value;
                });
              },
            ),
            Text(
              'Other (specify)',
            ),
          ])
        ]),
        forceColumn: true,
        makeBold: true);
  }

  Widget _interestContraceptionMaybeMethodSpecify() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        !_newPatient.interestContraceptionOther) {
      return SizedBox();
    }
    return _makeQuestion(
      'Specify other method',
      answer: TextFormField(
        controller: _interestContraceptionMaybeMethodSpecifyCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify the method';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionMaybeLikeFacilitySchedule() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        !_newPatient.interestContraceptionOther) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly a method of her choice NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _newPatient.interestContraceptionLikeFindFacilitySchedule,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _newPatient.interestContraceptionLikeFindFacilitySchedule =
                  newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNoUnsure.allValues
              .map<DropdownMenuItem<R21YesNoUnsure>>((R21YesNoUnsure value) {
            return DropdownMenuItem<R21YesNoUnsure>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionMaybeLikeFacilityScheduleDate() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        !_newPatient.interestContraceptionOther) {
      return SizedBox();
    }

    return _makeQuestion(
      'When would she like to go',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _newPatient.lastARTRefilDate == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.lastARTRefilDate)}',
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
              initialDate: now,
              firstDate: minARTRefilDate,
              lastDate: now,
            );
            if (date != null) {
              setState(() {
                _newPatient.lastARTRefilDate = date;
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

  Widget _interestContraceptionMaybeLikePNAccompany() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        !_newPatient.interestContraceptionOther) {
      return SizedBox();
    }
    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.interestContraceptionLikePNAAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.interestContraceptionLikePNAAccompany = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: false);
  }

  Widget _interestContraceptionMaybeOpenFacilitiesPage() {
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        !_newPatient.interestContraceptionOther) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ OPENING FACILITIES PAGE =>');
    });
  }

  Widget _interestContraceptionMaybeSelectedFacility() {
    
    if ((_newPatient.contraceptionInterest == null ||
            _newPatient.contraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        !_newPatient.interestContraceptionOther) {
      return SizedBox();
    }
    return _makeQuestion(
      'Selected Facility Code',
      answer: TextFormField(
        controller: _interestContraceptionSelectedFacilityCodeCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify selected facility';
          }
          return null;
        },
      ),
    );
  }

//PREP
  Widget _prepInterest() {
    return _makeQuestion(
      'Interest in using PrEP',
      answer: DropdownButtonFormField<R21Interest>(
        value: _newPatient.contraceptionInterest,
        onChanged: (R21Interest newValue) {
          setState(() {
            _newPatient.prepInterest = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21Interest.allValues
            .map<DropdownMenuItem<R21Interest>>((R21Interest value) {
          return DropdownMenuItem<R21Interest>(
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
            .map<DropdownMenuItem<R21HIVStatus>>((R21HIVStatus value) {
          return DropdownMenuItem<R21HIVStatus>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _takingART() {
    if (_newPatient.hivStatus == null ||
        _newPatient.hivStatus != R21HIVStatus.YesPositive()) {
      return SizedBox();
    }

    return _makeQuestion(
      'is she currently taking ART',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _newPatient.takingART,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _newPatient.takingART = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21YesNo.allValues
            .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
          return DropdownMenuItem<R21YesNo>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _lastARTRefilDateQuestion() {
    if ((_newPatient.hivStatus == null ||
            _newPatient.hivStatus != R21HIVStatus.YesPositive()) ||
        (_newPatient.takingART == null ||
            _newPatient.takingART != R21YesNo.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Date of last refill ',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _newPatient.lastARTRefilDate == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.lastARTRefilDate)}',
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
              initialDate: now,
              firstDate: minARTRefilDate,
              lastDate: now,
            );
            if (date != null) {
              setState(() {
                _newPatient.lastARTRefilDate = date;
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

  Widget _ARTRefilCollectionClinic() {
    if ((_newPatient.hivStatus == null ||
            _newPatient.hivStatus != R21HIVStatus.YesPositive()) ||
        (_newPatient.takingART == null ||
            _newPatient.takingART != R21YesNo.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Where refill was collected from',
      answer: DropdownButtonFormField<R21ProviderType>(
        value: _newPatient.ARTRefilCollectionClinic,
        onChanged: (R21ProviderType newValue) {
          setState(() {
            _newPatient.ARTRefilCollectionClinic = newValue;
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

  Widget _specifyARTRefilCollectionClinic() {
    if ((_newPatient.hivStatus == null ||
            _newPatient.hivStatus != R21HIVStatus.YesPositive()) ||
        (_newPatient.takingART == null ||
            _newPatient.takingART != R21YesNo.YES()) ||
        (_newPatient.ARTRefilCollectionClinic == null ||
            _newPatient.ARTRefilCollectionClinic != R21ProviderType.Other())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify refil collection source',
      answer: TextFormField(
        controller: _specifyARTRefilCollectionClinicCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _problemsTakingART() {
    if (_newPatient.hivStatus == null ||
        _newPatient.hivStatus != R21HIVStatus.YesPositive()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Any problems taking?',
      answer: TextFormField(
        controller: _problemsTakingARTCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _questionsAboutARTMedication() {
    if (_newPatient.hivStatus == null ||
        _newPatient.hivStatus != R21HIVStatus.YesPositive()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Any questions about the medication',
      answer: TextFormField(
        controller: _questionsAboutARTMedicationCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _desiredARTSupport() {
    if (_newPatient.hivStatus == null ||
        _newPatient.hivStatus != R21HIVStatus.YesPositive()) {
      return SizedBox();
    }

    return _makeQuestion('Desired support ',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _newPatient.desiredSupportRefilReminders,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.desiredSupportRefilReminders = value;
                });
              },
            ),
            Text(
              'Reminders about refill/appointment dates',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.desiredSupportAdherenceReminders,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.desiredSupportAdherenceReminders = value;
                });
              },
            ),
            Text(
              'Check-in/reminders about adherence',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.desiredSupportRefilCollectionReminders,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.desiredSupportRefilCollectionReminders = value;
                });
              },
            ),
            Text(
              'Coming with her to get refills',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.desiredSupportReerCollectionRefilReminders,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.desiredSupportReerCollectionRefilReminders =
                      value;
                });
              },
            ),
            Text(
              'Peer navigator coming with her to get refills (or for other clinic visits)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.desiredSupportOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.desiredSupportOther = value;
                });
              },
            ),
            Text(
              'Other (specify)',
            ),
          ])
        ]),
        forceColumn: true,
        makeBold: true);
  }

  Widget _specifyARTDesiredSupportOther() {
    if ((_newPatient.hivStatus == null ||
            _newPatient.hivStatus != R21HIVStatus.YesPositive()) ||
        (_newPatient.takingART == null ||
            _newPatient.takingART == R21YesNo.NO()) ||
        !_newPatient.desiredSupportOther) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other support',
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

  Widget _lastHIVTestDateQuestion() {
    if ((_newPatient.hivStatus == null ||
        _newPatient.hivStatus == R21HIVStatus.YesPositive())) {
      return SizedBox();
    }

    return _makeQuestion(
      'When was last test ',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _newPatient.lastHIVTestDate == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.lastHIVTestDate)}',
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
              initialDate: now,
              firstDate: minARTRefilDate,
              lastDate: now,
            );
            if (date != null) {
              setState(() {
                _newPatient.lastHIVTestDate = date;
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

  Widget _clientEverUsedPrep() {
    if ((_newPatient.hivStatus == null ||
        _newPatient.hivStatus == R21HIVStatus.YesPositive())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Has she ever used PrEP ',
      answer: DropdownButtonFormField<R21PrEP>(
        value: _newPatient.everUsedPrep,
        onChanged: (R21PrEP newValue) {
          setState(() {
            _newPatient.everUsedPrep = newValue;
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

  Widget _specifyPrepStopReason() {
    if ((_newPatient.hivStatus == null ||
            _newPatient.hivStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.everUsedPrep == null ||
            _newPatient.everUsedPrep != R21PrEP.YesNotCurrently())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Why did she stop',
      answer: TextFormField(
        controller: _reasonPrepStopReasonCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _lastPrepRefilDateQuestion() {
    if ((_newPatient.hivStatus == null ||
            _newPatient.hivStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.everUsedPrep == null ||
            _newPatient.everUsedPrep != R21PrEP.YesCurrently())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Date of last PrEp refill ',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _newPatient.lastPrepRefilDate == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.lastPrepRefilDate)}',
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
              initialDate: now,
              firstDate: minARTRefilDate,
              lastDate: now,
            );
            if (date != null) {
              setState(() {
                _newPatient.lastPrepRefilDate = date;
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

  Widget _prepRefilCollectionClinic() {
    if ((_newPatient.hivStatus == null ||
            _newPatient.hivStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.everUsedPrep == null ||
            _newPatient.everUsedPrep != R21PrEP.YesCurrently())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Where PrEp refill was collected from',
      answer: DropdownButtonFormField<R21ProviderType>(
        value: _newPatient.ARTRefilCollectionClinic,
        onChanged: (R21ProviderType newValue) {
          setState(() {
            _newPatient.prepRefilCollectionClinic = newValue;
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

  Widget _specifyPrepRefilCollectionClinic() {
    if ((_newPatient.hivStatus == null ||
            _newPatient.hivStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.everUsedPrep == null ||
            _newPatient.everUsedPrep != R21PrEP.YesCurrently())) {
      return SizedBox();
    }
    return _makeQuestion(
      'Specify refil collection source',
      answer: TextFormField(
        controller: _specifyPrepRefilCollectionClinicCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _problemsTakingPrep() {
    if ((_newPatient.hivStatus == null ||
            _newPatient.hivStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.everUsedPrep == null ||
            _newPatient.everUsedPrep != R21PrEP.YesCurrently())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Any problems taking PrEP?',
      answer: TextFormField(
        controller: _problemsTakingPrepCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _questionsAboutPrepMedication() {
    if ((_newPatient.hivStatus == null ||
            _newPatient.hivStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.everUsedPrep == null ||
            _newPatient.everUsedPrep != R21PrEP.YesCurrently())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Any questions about the medication',
      answer: TextFormField(
        controller: _questionsAboutPrepMedicationCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _desiredPrepSupport() {
    if ((_newPatient.hivStatus == null ||
            _newPatient.hivStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.everUsedPrep == null ||
            _newPatient.everUsedPrep != R21PrEP.YesCurrently())) {
      return SizedBox();
    }

    return _makeQuestion('Desired PrEP support ',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _newPatient.desiredSupportPrepRefilReminders,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.desiredSupportPrepRefilReminders = value;
                });
              },
            ),
            Text(
              'Reminders about refill/appointment dates',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.desiredSupportPrepAdherenceReminders,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.desiredSupportPrepAdherenceReminders = value;
                });
              },
            ),
            Text(
              'Check-in/reminders about adherence',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.desiredSupportPrepPeerRefil,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.desiredSupportPrepPeerRefil = value;
                });
              },
            ),
            Text(
              'Peer navigator coming with her to get refills',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.desiredSupportPrepPeerHIVSelfTest,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.desiredSupportPrepPeerHIVSelfTest = value;
                });
              },
            ),
            Text(
              'Peer navigator providing HIV self testing ',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.desiredSupportPrepOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.desiredSupportPrepOther = value;
                });
              },
            ),
            Text(
              'Other (specify)',
            ),
          ])
        ]),
        forceColumn: true,
        makeBold: true);
  }

  Widget _specifyPrepDesiredSupportOther() {
    if ((_newPatient.hivStatus == null ||
            _newPatient.hivStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.everUsedPrep == null ||
            _newPatient.everUsedPrep != R21PrEP.YesCurrently()) ||
        !_newPatient.desiredSupportPrepOther) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other PrEP support',
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

  Widget _contraceptionUse() {
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

  Widget _specifyContraceptionMethod() {
    if ((_newPatient.contraceptionUse == null ||
            _newPatient.contraceptionUse == R21ContraceptionUse.HasNever()) ||
        (_newPatient.contraceptionMethod == null ||
            _newPatient.contraceptionMethod !=
                R21ContraceptionMethod.Other())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify method',
      answer: TextFormField(
        controller: _specifyContraceptionMethodCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify method';
          }
        },
      ),
    );
  }

  Widget _whyNoContraception() {
    if (_newPatient.contraceptionUse == null ||
        _newPatient.contraceptionUse != R21ContraceptionUse.HasNever()) {
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

  Widget _makeQuestion(String question,
      {@required Widget answer,
      bool forceColumn = false,
      bool makeBold = false}) {
    if (_screenWidth < NARROW_DESIGN_WIDTH || forceColumn) {
      final double _spacingBetweenQuestions = 4.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: _spacingBetweenQuestions),
          Text(question,
              style: TextStyle(
                  fontWeight: makeBold ? FontWeight.bold : FontWeight.normal)),
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
        SizedBox(width: 5.0),
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
