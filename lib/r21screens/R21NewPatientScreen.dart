import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAppBottomSheet.dart';
import 'package:pebrapp/components/TransparentHeaderPage.dart';
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/R21Residency.dart';
import 'package:pebrapp/database/beans/R21PhoneNumberSecurity.dart';
import 'package:pebrapp/database/beans/R21ContactFrequency.dart';
import 'package:pebrapp/database/beans/R21ContraceptionUse.dart';
import 'package:pebrapp/database/beans/R21HIVStatus.dart';
import 'package:pebrapp/database/beans/R21Interest.dart';
import 'package:pebrapp/database/beans/R21Prep.dart';
import 'package:pebrapp/database/beans/R21ProviderType.dart';
import 'package:pebrapp/database/beans/R21Satisfaction.dart';
import 'package:pebrapp/database/beans/R21Week.dart';
import 'package:pebrapp/database/beans/R21YesNo.dart';
import 'package:pebrapp/database/beans/R21YesNoUnsure.dart';
import 'package:pebrapp/database/beans/R21PreferredContactMethod.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/r21screens/R21ChooseFacilityScreen.dart';
import 'package:pebrapp/r21screens/R21ViewResourcesScreen.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/InputFormatters.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:pebrapp/database/beans/NoChatDownloadReason.dart';

class R21NewPatientScreen extends StatefulWidget {
  @override
  _R21NewFlatPatientFormState createState() {
    return _R21NewFlatPatientFormState();
  }
}

class _R21NewFlatPatientFormState extends State<R21NewPatientScreen> {

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

  Patient _newPatient = Patient();



  TextEditingController _contraceptiveMethodOtherSpecifyCtr =
      TextEditingController();

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

  TextEditingController _studyNumberCtr = TextEditingController();
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

  List<String> _studyNumbersInDB;
  List<String> _stickerNumbersInDB;
  bool _isLoading = true;

  double _screenWidth;

  // stepper state
  bool _patientSaved = false;
  bool _historySaved = false;
  bool _srhSaved = false;
  bool _stepperFinished = false;

  int _currentStep = 0;

  @override
  initState() {
    super.initState();

    DatabaseProvider()
        .retrieveLatestPatients(
            retrieveNonEligibles: false, retrieveNonConsents: false)
        .then((List<Patient> patients) {

      setState(() {
        _studyNumbersInDB =
            patients.map((Patient p) => p.personalStudyNumber).toList();
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
          _messengerAppCard(),
          _contactInformationCard(),
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

      if (_patientSaved) {

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
        title: Text('Participant Characteristics',
            style: TextStyle(
                fontWeight:
                    _currentStep == 0 ? FontWeight.bold : FontWeight.normal)),
        isActive: _currentStep == 0,
        state: _patientSaved ? StepState.complete : StepState.indexed,
        content: patientCharacteristicsStep,
      ),
      Step(
        title: Text('Contraception/PREP History And Preferences',
            style: TextStyle(
                fontWeight:
                    _currentStep == 1 ? FontWeight.bold : FontWeight.normal)),
        isActive: _currentStep == 1,
        state: _historySaved ? StepState.complete : StepState.indexed,
        content: patientHistoryStep,
      ),
      Step(
          title: Text('SRH Service Preferences',
              style: TextStyle(
                  fontWeight:
                      _currentStep == 2 ? FontWeight.bold : FontWeight.normal)),
          isActive: _currentStep == 2,
          state: _srhSaved ? StepState.complete : StepState.indexed,
          content: patientSrhServicePreferenceStep),
      Step(
        title: Text('Finish',
            style: TextStyle(
                fontWeight:
                    _currentStep == 3 ? FontWeight.bold : FontWeight.normal)),
        isActive: _currentStep == 3,
        state: _stepperFinished ? StepState.complete : StepState.indexed,
        content: finishStep(),
      ),
    ];

    goTo(int step) {
   
        //allow going back to any setp
      

      setState(() => _currentStep = step);
    }

    next() async {
      switch (_currentStep) {
        // patient characteristics form
        case 0:
          if (await _onSubmitPersonalDataForm()) {
            setState(() {
              _patientSaved = true;
            });
            goTo(1);
          }
          break;
        // history
        case 1:
          if (await _onSubmitHistoryForm()) {
            setState(() {
              _historySaved = true;
            });
            goTo(2);
          }
          break;
        //srch
        case 2:
          if (await _onSubmitPreferenceForm()) {
            setState(() {
              _srhSaved = true;
            });
            _closeScreen();
          }
          break;
        //finish
        case 3:
          if (_stepperFinished) {
            _closeScreen();
          }
          break;
      }
    }

    cancel() {
      if (_currentStep > 0) {
        goTo(_currentStep - 1);
      } else if (_currentStep == 0) {
        _closeScreen();
      }
    }

    Widget stepper() {
      return Stepper(
        steps: steps,
      type: StepperType.vertical,
        currentStep: _currentStep,
        onStepTapped: goTo,
        onStepContinue: _stepperFinished ? null : next,
        onStepCancel: (_currentStep < 3) ? null : cancel,
        controlsBuilder: (BuildContext context,
            {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          final Color navigationButtonsColor = Colors.blue;
          return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _currentStep == 0 || _currentStep == 1 || _currentStep == 2
                    ? SizedBox()
                    : Container(
                        decoration: BoxDecoration(
                          color: onStepCancel == null
                              ? BUTTON_INACTIVE
                              : (_currentStep == 0
                                  ? STEPPER_ABORT
                                  : navigationButtonsColor),
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: IconButton(
                          color: Colors.white,
                          onPressed: onStepCancel,
                          icon: Icon(_currentStep == 0
                              ? Icons.close
                              : Icons.keyboard_arrow_up),
                        ),
                      ),
                SizedBox(width: 20.0),
                Container(
                  decoration: BoxDecoration(
                    color: onStepContinue == null
                        ? BUTTON_INACTIVE
                        : (_currentStep == 2
                            ? STEPPER_FINISH
                            : navigationButtonsColor),
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: onStepContinue,
                    icon: Icon(_currentStep == 2
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

    return Scaffold(
      bottomSheet: PEBRAppBottomSheet(),
      backgroundColor: BACKGROUND_COLOR,
      body: TransparentHeaderPage(
        title: 'Participant',
        subtitle: 'Create a new participant',
        scrollable: false,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
          )
        ],
        child: stepper(),
      ),
    );
  }

  // ----------
  // CARDS FOR PATIENT
  // ----------

//PERSONAL INFORMATION
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

  
//MESSENGER
  Widget _messengerAppCard() {
    return _buildCard(
      'Messenger App',
      child: Column(
        children: [
          _downloadedMessengerApp(),
          _noDownloadReasonQuestion(),
          _specifyNoDownloadReasonQuestion(),
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


  Widget _contraceptionCard() {
    return _buildCard(
      'Contraception',
      withTopPadding: true,
      child: Column(
        children: [
          _contraceptionUse(),
          _contraceptiveMethod(),
          _contraceptiveMethodOtherSpecify(),
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
          _interestContraceptionOpenCounselingInfoPageButton(),
          _interestContraceptionLikeFacilitySchedule(),
          _interestContraceptionLikeFacilityScheduleDate(),
          _interestContraceptionLikePNAccompany(),
          _interestContraceptionOpenFacilitiesPageButton(),
          _interestContraceptionSelectedFacility(),
          _interestContraceptionNotNowDate(),
          _interestContraceptionNotNowDateOther(),
          _interestContraceptionNotNowPickFacility(),
          _interestContraceptionNotNowPickFacilityShowButton(),
          _interestContraceptionNotNowPickFacilitySelected(),
          _interestContraceptionLikeInformationOnApp(),
          _interestContraceptionMaybeMethod(),
          _interestContraceptionMaybeMethodSpecify(),
          _interestContraceptionMaybeLikeFacilitySchedule(),
          _interestContraceptionMaybeLikeFacilityScheduleDate(),
          _interestContraceptionMaybeLikePNAccompany(),
          _interestContraceptionMaybeOpenFacilitiesPagebutton(),
          _interestContraceptionMaybeSelectedFacility(),
          _interestContraceptionMaybeNotNowDate(),
          _interestContraceptionMaybeNotNowDateOther(),
          _interestContraceptionMaybeNotNowPickFacility(),
          _interestContraceptionMaybeNotNowPickFacilityShowButton(),
          _interestContraceptionMaybeNotNowPickFacilitySelected(),
          _interestContraceptionMaybeLikeInformationOnApp(),
          _interestContraceptionMaybeLikeInfoOnMethods(),
          _interestContraceptionMaybeLikeInfoOnMethodsShowButton(),
          _interestContraceptionNotSpecifyReason(),
          _interestContraceptionNotLikeInfoOnMethods(),
          _interestContraceptionNotLikeInfoOnMethodsShowButton(),
          _interestContraceptionNotLikeInformationOnApp(),
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
          _interestPrep(),
          _interestPrepLikeInfoOnMethods(),
          _interestPrepLikeInfoOnMethodsShowButton(),
          _interestPrepVeryLikeFacilitySchedule(),
          _interestPrepVeryLikeFacilityScheduleDate(),
          _interestPrepVeryLikePNAccompany(),
          _interestPrepVeryOpenFacilitiesPageShowButton(),
          _interestPrepVerySelectedFacility(),
          _interestPrepVeryNotNowDate(),
          _interestPrepVeryNotNowDateOther(),
          _interestPrepVeryNotNowPickFacility(),
          _interestPrepVeryNotNowPickFacilityShowButton(),
          _interestPrepVeryNotNowPickFacilitySelected(),
          _interestPrepVeryLikeInformationOnApp(),
          _interestPrepMaybeLikeInfoOnMethods(),
          _interestPrepMaybeLikeInfoOnMethodsShowButton(),
          _interestPrepMaybeLikeFacilitySchedule(),
          _interestPrepMaybeLikeFacilityScheduleDate(),
          _interestPrepMaybeLikePNAccompany(),
          _interestPrepMaybeOpenFacilitiesPageShowButton(),
          _interestPrepMaybeSelectedFacility(),
          _interestPrepMaybeNotNowDate(),
          _interestPrepMaybeNotNowDateOther(),
          _interestPrepMaybeNotNowPickFacility(),
          _interestPrepMaybeNotNowPickFacilityShowButton(),
          _interestPrepMaybeNotNowPickFacilitySelected(),
          _interestPrepMaybeLikeInformationOnApp(),
          _interestPrepNotLikeInfoOnMethods(),
          _interestPrepNotLikeInfoOnMethodsShowButtons(),
          _interestPrepNotLikeInformationOnApp()
        ],
      ),
    );
  }


//METHODS
  Future<void> _pushChooseFacilityScreen() async {
    await _fadeInScreen(R21ChooseFacilityScreen(),
        routeName: '/choose-facility');
  }

  Future<void> _pushViewResourcesScreen() async {
    await _fadeInScreen(R21ViewResourcesScreen(), routeName: '/view-resources');
  }

  /// Pushes [newScreen] to the top of the navigation stack using a fade in
  /// transition.
  Future<T> _fadeInScreen<T extends Object>(Widget newScreen,
      {String routeName}) {
    return Navigator.of(context).push(
      PageRouteBuilder<T>(
        settings: RouteSettings(name: routeName),
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1,
            Animation<double> anim2, Widget widget) {
          return FadeTransition(
            opacity: anim1,
            child: widget, // child is the value returned by pageBuilder
          );
        },
        pageBuilder: (BuildContext context, _, __) {
          return newScreen;
        },
      ),
    );
  }


 

  // ----------
  // CARD CONTENTS
  // ----------

  //PERSONAL INFORMATION


  
 Widget _studyNumberQuestion() {
    return _makeQuestion(
      'Study Number',
      answer: TextFormField(
        autocorrect: false,
        controller: _studyNumberCtr,
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(5),
          StudyNumberTextInputFormatter(),
        ],
        validator: (String value) {
          if (_studyNumberExists(value)) {
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
              _newPatient.personalBirthday == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.personalBirthday)} (age ${calculateAge(_newPatient.personalBirthday)})',
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
              initialDate:
                  _newPatient.personalBirthday ?? minBirthdayForEligibility,
              firstDate: minBirthdayForEligibility,
              lastDate: maxBirthdayForEligibility,
            );
            if (date != null) {
              setState(() {
                _newPatient.personalBirthday = date;
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

  //MESSENGER
  Widget _downloadedMessengerApp() {
    return _makeQuestion(
      'Has the client downloaded the messenger app?',
      answer: DropdownButtonFormField<bool>(
        value: _newPatient.messengerDownloaded,
        onChanged: (bool newValue) {
          setState(() {
            _newPatient.messengerDownloaded = newValue;
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

  Widget _noDownloadReasonQuestion() {
    if (_newPatient.messengerDownloaded == null ||
        _newPatient.messengerDownloaded) {
      return Container();
    }
    return _makeQuestion(
      'Why',
      answer: DropdownButtonFormField<NoChatDownloadReason>(
        value: _newPatient.messengerNoDownloadReason,
        onChanged: (NoChatDownloadReason newValue) {
          setState(() {
            _newPatient.messengerNoDownloadReason = newValue;
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

  Widget _specifyNoDownloadReasonQuestion() {
    if (_newPatient.messengerDownloaded == null ||
        _newPatient.messengerDownloaded ||
        _newPatient.messengerNoDownloadReason == null ||
        _newPatient.messengerNoDownloadReason != NoChatDownloadReason.OTHER()) {
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

//CONTACT INFORMATION
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

    Widget _phoneAvailabilityQuestion() {
    return _makeQuestion(
      'Is your phone',
      answer: DropdownButtonFormField<R21PhoneNumberSecurity>(
        value: _newPatient.personalPhoneNumberAvailability,
        onChanged: (R21PhoneNumberSecurity newValue) {
          setState(() {
            _newPatient.personalPhoneNumberAvailability = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: R21PhoneNumberSecurity.allValues
            .map<DropdownMenuItem<R21PhoneNumberSecurity>>(
                (R21PhoneNumberSecurity value) {
          return DropdownMenuItem<R21PhoneNumberSecurity>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }


  Widget _residencyQuestion() {
    return _makeQuestion(
      'Residence',
      answer: DropdownButtonFormField<R21Residency>(
        value: _newPatient.personalResidency,
        onChanged: (R21Residency newValue) {
          setState(() {
            _newPatient.personalResidency = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: R21Residency.allValues
            .map<DropdownMenuItem<R21Residency>>((R21Residency value) {
          return DropdownMenuItem<R21Residency>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

 

  Widget _preferredContactMethodQuestion() {
    return _makeQuestion(
      'Preferred way to contact',
      answer: DropdownButtonFormField<R21PreferredContactMethod>(
        value: _newPatient.personalPreferredContactMethod,
        onChanged: (R21PreferredContactMethod newValue) {
          setState(() {
            _newPatient.personalPreferredContactMethod = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: R21PreferredContactMethod.allValues
            .map<DropdownMenuItem<R21PreferredContactMethod>>(
                (R21PreferredContactMethod value) {
          return DropdownMenuItem<R21PreferredContactMethod>(
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
        value: _newPatient.personalContactFrequency,
        onChanged: (R21ContactFrequency newValue) {
          setState(() {
            _newPatient.personalContactFrequency = newValue;
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

//CONTRACEPTION
  Widget _contraceptionUse() {
    return _makeQuestion(
      'Is the client currently using modern contraception or has used in the past?',
      answer: DropdownButtonFormField<R21ContraceptionUse>(
        value: _newPatient.historyContraceptionUse,
        onChanged: (R21ContraceptionUse newValue) {
          setState(() {
            _newPatient.historyContraceptionUse = newValue;
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
    if (_newPatient.historyContraceptionUse == null ||
        _newPatient.historyContraceptionUse == R21ContraceptionUse.HasNever()) {
      return SizedBox();
    }

    return _makeQuestion('Contraceptive Method',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _newPatient.historyContraceptionMaleCondoms,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyContraceptionMaleCondoms = value;
                });
              },
            ),
            Text(
              'Male Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyContraceptionFemaleCondoms,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyContraceptionFemaleCondoms = value;
                });
              },
            ),
            Text(
              'Female Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestImplant,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestImplant = value;
                });
              },
            ),
            Text(
              'Implant',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyContraceptionInjection,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyContraceptionInjection = value;
                });
              },
            ),
            Text(
              'Injection',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyContraceptionIUD,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyContraceptionIUD = value;
                });
              },
            ),
            Text(
              'IUD (intrauterine Device or Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyContraceptionIUS,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyContraceptionIUS = value;
                });
              },
            ),
            Text(
              'IUS (intrauterine System or Hormonal Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyContraceptionPills,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyContraceptionPills = value;
                });
              },
            ),
            Text(
              'Contraception Pills (combined or progestogen-only)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyContraceptionOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyContraceptionOther = value;
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

  Widget _contraceptiveMethodOtherSpecify() {
    if (_newPatient.historyContraceptionUse == null ||
        _newPatient.historyContraceptionUse !=
            R21ContraceptionUse.CurrentlyUsing() ||
        !_newPatient.historyContraceptionOther) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify method',
      answer: TextFormField(
        controller: _contraceptiveMethodOtherSpecifyCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  
  Widget _whyStopContraception() {
    if (_newPatient.historyContraceptionUse == null ||
        _newPatient.historyContraceptionUse !=
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

  Widget _contraceptionSatisfaction() {
    if (_newPatient.historyContraceptionUse == null ||
        _newPatient.historyContraceptionUse !=
            R21ContraceptionUse.CurrentlyUsing()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Satisfaction with current method',
      answer: DropdownButtonFormField<R21Satisfaction>(
        value: _newPatient.historyContraceptionSatisfaction,
        onChanged: (R21Satisfaction newValue) {
          setState(() {
            _newPatient.historyContraceptionSatisfaction = newValue;
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
    if (_newPatient.historyContraceptionUse == null ||
        _newPatient.historyContraceptionUse !=
            R21ContraceptionUse.CurrentlyUsing()) {
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
    if (_newPatient.historyContraceptionUse == null ||
        _newPatient.historyContraceptionUse != R21ContraceptionUse.HasNever()) {
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


//HIV

  Widget _hivStatus() {
    return _makeQuestion(
      'Does the client know her HIV status? ',
      answer: DropdownButtonFormField<R21HIVStatus>(
        value: _newPatient.historyHIVStatus,
        onChanged: (R21HIVStatus newValue) {
          setState(() {
            _newPatient.historyHIVStatus = newValue;
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
    if (_newPatient.historyHIVStatus == null ||
        _newPatient.historyHIVStatus != R21HIVStatus.YesPositive()) {
      return SizedBox();
    }

    return _makeQuestion(
      'is she currently taking ART',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _newPatient.historyHIVTakingART,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _newPatient.historyHIVTakingART = newValue;
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
    if ((_newPatient.historyHIVStatus == null ||
            _newPatient.historyHIVStatus != R21HIVStatus.YesPositive()) ||
        (_newPatient.historyHIVTakingART == null ||
            _newPatient.historyHIVTakingART != R21YesNo.YES())) {
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
              _newPatient.historyHIVLastRefil == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.historyHIVLastRefil)}',
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
                _newPatient.historyHIVLastRefil = date;
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

  Widget _specifyARTRefilCollectionClinic() {
    if ((_newPatient.historyHIVStatus == null ||
            _newPatient.historyHIVStatus != R21HIVStatus.YesPositive()) ||
        (_newPatient.historyHIVTakingART == null ||
            _newPatient.historyHIVTakingART != R21YesNo.YES()) ||
        (_newPatient.historyHIVLastRefilSource == null ||
            _newPatient.historyHIVLastRefilSource != R21ProviderType.Other())) {
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
    if (_newPatient.historyHIVStatus == null ||
        _newPatient.historyHIVStatus != R21HIVStatus.YesPositive()) {
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
    if (_newPatient.historyHIVStatus == null ||
        _newPatient.historyHIVStatus != R21HIVStatus.YesPositive()) {
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
    if (_newPatient.historyHIVStatus == null ||
        _newPatient.historyHIVStatus != R21HIVStatus.YesPositive()) {
      return SizedBox();
    }

    return _makeQuestion('Desired support ',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _newPatient.historyHIVDesiredSupportRemindersAppointments,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyHIVDesiredSupportRemindersAppointments =
                      value;
                });
              },
            ),
            Text(
              'Reminders about refill/appointment dates',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyHIVDesiredSupportRemindersCheckins,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyHIVDesiredSupportRemindersCheckins = value;
                });
              },
            ),
            Text(
              'Check-in/reminders about adherence',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyHIVDesiredSupportRefilsAccompany,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyHIVDesiredSupportRefilsAccompany = value;
                });
              },
            ),
            Text(
              'Coming with her to get refills',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyHIVDesiredSupportRefilsPAAccompany,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyHIVDesiredSupportRefilsPAAccompany = value;
                });
              },
            ),
            Text(
              'Peer navigator coming with her to get refills (or for other clinic visits)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyHIVDesiredSupportOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyHIVDesiredSupportOther = value;
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
    if ((_newPatient.historyHIVStatus == null ||
            _newPatient.historyHIVStatus != R21HIVStatus.YesPositive()) ||
        (_newPatient.historyHIVTakingART == null ||
            _newPatient.historyHIVTakingART == R21YesNo.NO()) ||
        !_newPatient.historyHIVDesiredSupportOther) {
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
    if ((_newPatient.historyHIVStatus == null ||
        _newPatient.historyHIVStatus == R21HIVStatus.YesPositive())) {
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
              _newPatient.historyHIVLastTest == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.historyHIVLastTest)}',
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
                _newPatient.historyHIVLastTest = date;
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
    if ((_newPatient.historyHIVStatus == null ||
        _newPatient.historyHIVStatus == R21HIVStatus.YesPositive())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Has she ever used PrEP ',
      answer: DropdownButtonFormField<R21PrEP>(
        value: _newPatient.historyHIVUsedPrep,
        onChanged: (R21PrEP newValue) {
          setState(() {
            _newPatient.historyHIVUsedPrep = newValue;
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
    if ((_newPatient.historyHIVStatus == null ||
            _newPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.historyHIVUsedPrep == null ||
            _newPatient.historyHIVUsedPrep != R21PrEP.YesNotCurrently())) {
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
    if ((_newPatient.historyHIVStatus == null ||
            _newPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.historyHIVUsedPrep == null ||
            _newPatient.historyHIVUsedPrep != R21PrEP.YesCurrently())) {
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
              _newPatient.historyHIVPrepLastRefil == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.historyHIVPrepLastRefil)}',
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
                _newPatient.historyHIVPrepLastRefil = date;
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
    if ((_newPatient.historyHIVStatus == null ||
            _newPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.historyHIVUsedPrep == null ||
            _newPatient.historyHIVUsedPrep != R21PrEP.YesCurrently())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Where PrEp refill was collected from',
      answer: DropdownButtonFormField<R21ProviderType>(
        value: _newPatient.historyHIVPrepLastRefilSource,
        onChanged: (R21ProviderType newValue) {
          setState(() {
            _newPatient.historyHIVPrepLastRefilSource = newValue;
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
    if ((_newPatient.historyHIVStatus == null ||
            _newPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.historyHIVUsedPrep == null ||
            _newPatient.historyHIVUsedPrep != R21PrEP.YesCurrently())) {
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
    if ((_newPatient.historyHIVStatus == null ||
            _newPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.historyHIVUsedPrep == null ||
            _newPatient.historyHIVUsedPrep != R21PrEP.YesCurrently())) {
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
    if ((_newPatient.historyHIVStatus == null ||
            _newPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.historyHIVUsedPrep == null ||
            _newPatient.historyHIVUsedPrep != R21PrEP.YesCurrently())) {
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
    if ((_newPatient.historyHIVStatus == null ||
            _newPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.historyHIVUsedPrep == null ||
            _newPatient.historyHIVUsedPrep != R21PrEP.YesCurrently())) {
      return SizedBox();
    }

    return _makeQuestion('Desired PrEP support ',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _newPatient
                  .historyHIVPrepDesiredSupportReminderssAppointments,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient
                          .historyHIVPrepDesiredSupportReminderssAppointments =
                      value;
                });
              },
            ),
            Text(
              'Reminders about refill/appointment dates',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyHIVPrepDesiredSupportRemindersAdherence,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyHIVPrepDesiredSupportRemindersAdherence =
                      value;
                });
              },
            ),
            Text(
              'Check-in/reminders about adherence',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyHIVPrepDesiredSupportRefilsPNAccompany,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyHIVPrepDesiredSupportRefilsPNAccompany =
                      value;
                });
              },
            ),
            Text(
              'Peer navigator coming with her to get refills',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyHIVPrepDesiredSupportPNHIVKit,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyHIVPrepDesiredSupportPNHIVKit = value;
                });
              },
            ),
            Text(
              'Peer navigator providing HIV self testing ',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.historyHIVPrepDesiredSupportOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.historyHIVPrepDesiredSupportOther = value;
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
    if ((_newPatient.historyHIVStatus == null ||
            _newPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_newPatient.historyHIVUsedPrep == null ||
            _newPatient.historyHIVUsedPrep != R21PrEP.YesCurrently()) ||
        !_newPatient.historyHIVPrepDesiredSupportOther) {
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

//SRH CONTRACEPTION INTEREST

  Widget _contraceptionInterest() {
    return _makeQuestion(
      'Interest in using contraception ',
      answer: DropdownButtonFormField<R21Interest>(
        value: _newPatient.srhContraceptionInterest,
        onChanged: (R21Interest newValue) {
          setState(() {
            _newPatient.srhContraceptionInterest = newValue;
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
    if (_newPatient.srhContraceptionInterest == null ||
        _newPatient.srhContraceptionInterest != R21Interest.VeryInterested()) {
      return SizedBox();
    }
    return _makeQuestion(
      'Does she have a particular method in mind?',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _newPatient.srhContraceptionMethodInMind,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _newPatient.srhContraceptionMethodInMind = newValue;
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
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.srhContraceptionMethodInMind == null ||
            _newPatient.srhContraceptionMethodInMind == R21YesNo.NO())) {
      return SizedBox();
    }

    return _makeQuestion('Which method',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestMaleCondom,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestMaleCondom = value;
                });
              },
            ),
            Text(
              'Male Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestFemaleCondom,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestFemaleCondom = value;
                });
              },
            ),
            Text(
              'Female Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestImplant,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestImplant = value;
                });
              },
            ),
            Text(
              'Implant',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestInjection,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestInjection = value;
                });
              },
            ),
            Text(
              'Injection',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestIUD,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestIUD = value;
                });
              },
            ),
            Text(
              'IUD (intrauterine Device or Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestIUS,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestIUS = value;
                });
              },
            ),
            Text(
              'IUS (intrauterine System or Hormonal Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestPills,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestPills = value;
                });
              },
            ),
            Text(
              'Contraception Pills (combined or progestogen-only)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestOther = value;
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
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.srhContraceptionMethodInMind == null ||
            _newPatient.srhContraceptionMethodInMind == R21YesNo.NO()) ||
        (_newPatient.srhContraceptionInterestOther == null ||
            _newPatient.srhContraceptionInterestOther == false)) {
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
    if (_newPatient.srhContraceptionInterest == null ||
        _newPatient.srhContraceptionInterest != R21Interest.VeryInterested()) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like more information about different methods right now?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhContraceptionInformationMethods,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhContraceptionInformationMethods = newValue;
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

  Widget _interestContraceptionOpenCounselingInfoPageButton() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.srhContraceptionInformationMethods == null ||
            _newPatient.srhContraceptionInformationMethods == R21YesNo.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information Page', onPressed: () {
      print('~~~ OPENING COUNSELLING INFO PAGE =>');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestContraceptionLikeFacilitySchedule() {
    if (_newPatient.srhContraceptionInterest == null ||
        _newPatient.srhContraceptionInterest != R21Interest.VeryInterested()) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly a method of her choice NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _newPatient.srhContraceptionFindScheduleFacility,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _newPatient.srhContraceptionFindScheduleFacility = newValue;
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
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
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
              _newPatient.srhContraceptionFindScheduleFacilityYesDate == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.srhContraceptionFindScheduleFacilityYesDate)}',
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
                _newPatient.srhContraceptionFindScheduleFacilityYesDate = date;
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
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }
    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhContraceptionFindScheduleFacilityYesPNAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhContraceptionFindScheduleFacilityYesPNAccompany =
                  newValue;
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

  Widget _interestContraceptionOpenFacilitiesPageButton() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ 1. OPENING FACILITIES PAGE NOW =>');
      _pushChooseFacilityScreen();
    });
  }
  Widget _interestContraceptionSelectedFacility() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
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
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
        'When would she like to go for counseling and possibly a method of her choice?',
        answer: DropdownButtonFormField<R21Week>(
          value: _newPatient.srhContraceptionFindScheduleFacilityNoDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _newPatient.srhContraceptionFindScheduleFacilityNoDate = newValue;
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
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES()) ||
        (_newPatient.srhContraceptionFindScheduleFacilityNoDate == null ||
            _newPatient.srhContraceptionFindScheduleFacilityNoDate !=
                R21Week.Other())) {
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
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _newPatient.srhContraceptionFindScheduleFacilityNoPick,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _newPatient.srhContraceptionFindScheduleFacilityNoPick = newValue;
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

  Widget _interestContraceptionNotNowPickFacilityShowButton() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES()) ||
        (_newPatient.srhContraceptionFindScheduleFacilityNoPick == null ||
            _newPatient.srhContraceptionFindScheduleFacilityNoPick ==
                R21YesNo.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ 2. OPENING FACILITIES PAGE =>');
    });
  }

  Widget _interestContraceptionNotNowPickFacilitySelected() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES()) ||
        (_newPatient.srhContraceptionFindScheduleFacilityNoPick == null ||
            _newPatient.srhContraceptionFindScheduleFacilityNoPick ==
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
    if (_newPatient.srhContraceptionInterest == null ||
        _newPatient.srhContraceptionInterest != R21Interest.VeryInterested()) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhContraceptionInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhContraceptionInformationApp = newValue;
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
    if (_newPatient.srhContraceptionInterest == null ||
        _newPatient.srhContraceptionInterest != R21Interest.MaybeInterested()) {
      return SizedBox();
    }

    return _makeQuestion('What method(s) is the client possibly interested in',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestMaleCondom,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestMaleCondom = value;
                });
              },
            ),
            Text(
              'Male Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestFemaleCondom,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestFemaleCondom = value;
                });
              },
            ),
            Text(
              'Female Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestImplant,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestImplant = value;
                });
              },
            ),
            Text(
              'Implant',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestInjection,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestInjection = value;
                });
              },
            ),
            Text(
              'Injection',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestIUD,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestIUD = value;
                });
              },
            ),
            Text(
              'IUD (intrauterine Device or Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestIUS,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestIUS = value;
                });
              },
            ),
            Text(
              'IUS (intrauterine System or Hormonal Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestPills,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestPills = value;
                });
              },
            ),
            Text(
              'Contraception Pills (combined or progestogen-only)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _newPatient.srhContraceptionInterestOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _newPatient.srhContraceptionInterestOther = value;
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
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        !_newPatient.srhContraceptionInterestOther) {
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
    if ((_newPatient.srhContraceptionInterest == null ||
        _newPatient.srhContraceptionInterest !=
            R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly a method of her choice NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _newPatient.srhContraceptionFindScheduleFacility,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _newPatient.srhContraceptionFindScheduleFacility = newValue;
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
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
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
              _newPatient.srhContraceptionFindScheduleFacilityYesDate == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.srhContraceptionFindScheduleFacilityYesDate)}',
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
                _newPatient.srhContraceptionFindScheduleFacilityYesDate = date;
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
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }
    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhContraceptionFindScheduleFacilityYesPNAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhContraceptionFindScheduleFacilityYesPNAccompany =
                  newValue;
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

  Widget _interestContraceptionMaybeOpenFacilitiesPagebutton() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ 3. OPENING FACILITIES PAGE =>');
    });
  }

  Widget _interestContraceptionMaybeSelectedFacility() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility ==
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

  Widget _interestContraceptionMaybeNotNowDate() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
        'When would she like to go for counseling and possibly a method of her choice?-',
        answer: DropdownButtonFormField<R21Week>(
          value: _newPatient.srhContraceptionFindScheduleFacilityNoDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _newPatient.srhContraceptionFindScheduleFacilityNoDate = newValue;
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

  Widget _interestContraceptionMaybeNotNowDateOther() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_newPatient.srhContraceptionFindScheduleFacilityNoDate == null ||
            _newPatient.srhContraceptionFindScheduleFacilityNoDate !=
                R21Week.Other())) {
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

  Widget _interestContraceptionMaybeNotNowPickFacility() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?-',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _newPatient.srhContraceptionFindScheduleFacilityNoPick,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _newPatient.srhContraceptionFindScheduleFacilityNoPick = newValue;
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

  Widget _interestContraceptionMaybeNotNowPickFacilityShowButton() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_newPatient.srhContraceptionFindScheduleFacilityNoPick == null ||
            _newPatient.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('XOpen Facilities Page-', onPressed: () {
      print('4. Opening facilities page');
    });
  }

  Widget _interestContraceptionMaybeNotNowPickFacilitySelected() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_newPatient.srhContraceptionFindScheduleFacilityNoPick == null ||
            _newPatient.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
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

  Widget _interestContraceptionMaybeLikeInformationOnApp() {
    if ((_newPatient.srhContraceptionInterest == null ||
        _newPatient.srhContraceptionInterest !=
            R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhContraceptionInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhContraceptionInformationApp = newValue;
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

  Widget _interestContraceptionMaybeLikeInfoOnMethods() {
    if ((_newPatient.srhContraceptionInterest == null ||
        _newPatient.srhContraceptionInterest !=
            R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to learn more about different contraceptive methods right now?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhContraceptionLearnMethods,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhContraceptionLearnMethods = newValue;
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

  Widget _interestContraceptionMaybeLikeInfoOnMethodsShowButton() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_newPatient.srhContraceptionLearnMethods == null ||
            _newPatient.srhContraceptionLearnMethods != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestContraceptionNotSpecifyReason() {
    if ((_newPatient.srhContraceptionInterest == null ||
        _newPatient.srhContraceptionInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }
    return _makeQuestion(
      'Why not interest in contraception?',
      answer: TextFormField(
        controller: _interestContraceptionMaybeMethodSpecifyCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify reason';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionNotLikeInfoOnMethods() {
    if ((_newPatient.srhContraceptionInterest == null ||
        _newPatient.srhContraceptionInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to learn more about different contraceptive methods right now?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhContraceptionInformationMethods,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhContraceptionInformationMethods = newValue;
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

  Widget _interestContraceptionNotLikeInfoOnMethodsShowButton() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.NoInterested()) ||
        (_newPatient.srhContraceptionInformationMethods == null ||
            _newPatient.srhContraceptionInformationMethods != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestContraceptionNotLikeInformationOnApp() {
    if ((_newPatient.srhContraceptionInterest == null ||
        _newPatient.srhContraceptionInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhContraceptionInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhContraceptionInformationApp = newValue;
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


//PREP
  Widget _interestPrep() {
    return _makeQuestion(
      'Interest in using PrEP',
      answer: DropdownButtonFormField<R21Interest>(
        value: _newPatient.srhPrepInterest,
        onChanged: (R21Interest newValue) {
          setState(() {
            _newPatient.srhPrepInterest = newValue;
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

  Widget _interestPrepLikeInfoOnMethods() {
    if ((_newPatient.srhPrepInterest == null ||
        _newPatient.srhPrepInterest != R21Interest.VeryInterested())) {
      return SizedBox();
    }

    return _makeQuestion('Would she like more information now about PrEP',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhPrepLikeMoreInformation,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhPrepLikeMoreInformation = newValue;
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

  Widget _interestPrepLikeInfoOnMethodsShowButton() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        (_newPatient.srhPrepLikeMoreInformation == null ||
            _newPatient.srhPrepLikeMoreInformation != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      _pushViewResourcesScreen();
    });
  }
  Widget _interestPrepVeryLikeFacilitySchedule() {
    if ((_newPatient.srhPrepInterest == null ||
        _newPatient.srhPrepInterest != R21Interest.VeryInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly get PrEP NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _newPatient.srhPrepFindScheduleFacilitySchedule,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _newPatient.srhPrepFindScheduleFacilitySchedule = newValue;
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
  Widget _interestPrepVeryLikeFacilityScheduleDate() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        ((_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
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
              _newPatient.srhPrepFindScheduleFacilityYesDate == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.srhPrepFindScheduleFacilityYesDate)}',
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
                _newPatient.srhPrepFindScheduleFacilityYesDate = date;
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
  Widget _interestPrepVeryLikePNAccompany() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        ((_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhPrepFindScheduleFacilityYesPNAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhPrepFindScheduleFacilityYesPNAccompany = newValue;
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
  Widget _interestPrepVeryOpenFacilitiesPageShowButton() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        ((_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ 3. OPENING FACILITIES PAGE =>');
    });
  }
  Widget _interestPrepVerySelectedFacility() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        ((_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
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
  Widget _interestPrepVeryNotNowDate() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        (_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
        'If no, when would she like to go for counseling and possibly get PrEP?',
        answer: DropdownButtonFormField<R21Week>(
          value: _newPatient.srhPrepFindScheduleFacilityNoDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _newPatient.srhPrepFindScheduleFacilityNoDate = newValue;
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
  Widget _interestPrepVeryNotNowDateOther() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        (_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_newPatient.srhPrepFindScheduleFacilityNoDate == null ||
            _newPatient.srhPrepFindScheduleFacilityNoDate != R21Week.Other())) {
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
  Widget _interestPrepVeryNotNowPickFacility() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        (_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?-',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _newPatient.srhPrepFindScheduleFacilityNoPick,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _newPatient.srhPrepFindScheduleFacilityNoPick = newValue;
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
  Widget _interestPrepVeryNotNowPickFacilityShowButton() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        (_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_newPatient.srhPrepFindScheduleFacilityNoPick == null ||
            _newPatient.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('XOpen Facilities Page-', onPressed: () {
      print('4. Opening facilities page');
    });
  }
  Widget _interestPrepVeryNotNowPickFacilitySelected() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_newPatient.srhContraceptionFindScheduleFacility == null ||
            _newPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_newPatient.srhContraceptionFindScheduleFacilityNoPick == null ||
            _newPatient.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
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
  Widget _interestPrepVeryLikeInformationOnApp() {
    if ((_newPatient.srhPrepInterest == null ||
        _newPatient.srhPrepInterest != R21Interest.VeryInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information about PrEP sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhPrepInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhPrepInformationApp = newValue;
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
//MAYBE

  Widget _interestPrepMaybeLikeInfoOnMethods() {
    if ((_newPatient.srhPrepInterest == null ||
        _newPatient.srhPrepInterest != R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion('Would she like more information now about PrEP',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhPrepLikeMoreInformation,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhPrepLikeMoreInformation = newValue;
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

  Widget _interestPrepMaybeLikeInfoOnMethodsShowButton() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        (_newPatient.srhPrepLikeMoreInformation == null ||
            _newPatient.srhPrepLikeMoreInformation != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestPrepMaybeLikeFacilitySchedule() {
    if ((_newPatient.srhPrepInterest == null ||
        _newPatient.srhPrepInterest != R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly get PrEP NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _newPatient.srhPrepFindScheduleFacilitySchedule,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _newPatient.srhPrepFindScheduleFacilitySchedule = newValue;
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

  Widget _interestPrepMaybeLikeFacilityScheduleDate() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        ((_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
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
              _newPatient.srhContraceptionFindScheduleFacilityYesDate == null
                  ? ''
                  : '${formatDateConsistent(_newPatient.srhContraceptionFindScheduleFacilityYesDate)}',
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
                _newPatient.srhContraceptionFindScheduleFacilityYesDate = date;
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

  Widget _interestPrepMaybeLikePNAccompany() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        ((_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhPrepFindScheduleFacilityYesPNAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhPrepFindScheduleFacilityYesPNAccompany = newValue;
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

  Widget _interestPrepMaybeOpenFacilitiesPageShowButton() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        ((_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ 3. OPENING FACILITIES PAGE =>');
    });
  }

  Widget _interestPrepMaybeSelectedFacility() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        ((_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
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

  Widget _interestPrepMaybeNotNowDate() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        (_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
        'If no, when would she like to go for counseling and possibly get PrEP?',
        answer: DropdownButtonFormField<R21Week>(
          value: _newPatient.srhPrepFindScheduleFacilityNoDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _newPatient.srhPrepFindScheduleFacilityNoDate = newValue;
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

  Widget _interestPrepMaybeNotNowDateOther() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        (_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_newPatient.srhPrepFindScheduleFacilityNoDate == null ||
            _newPatient.srhPrepFindScheduleFacilityNoDate != R21Week.Other())) {
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

  Widget _interestPrepMaybeNotNowPickFacility() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        (_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?-',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _newPatient.srhPrepFindScheduleFacilityNoPick,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _newPatient.srhPrepFindScheduleFacilityNoPick = newValue;
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

  Widget _interestPrepMaybeNotNowPickFacilityShowButton() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        (_newPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _newPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_newPatient.srhPrepFindScheduleFacilityNoPick == null ||
            _newPatient.srhPrepFindScheduleFacilityNoPick != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('XOpen Facilities Page-', onPressed: () {
      print('4. Opening facilities page');
    });
  }

  Widget _interestPrepMaybeNotNowPickFacilitySelected() {
    if ((_newPatient.srhContraceptionInterest == null ||
            _newPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_newPatient.srhPrepFindScheduleFacilityNoPick == null ||
            _newPatient.srhPrepFindScheduleFacilityNoPick !=
                R21YesNo.NO()) ||
        (_newPatient.srhContraceptionFindScheduleFacilityNoPick == null ||
            _newPatient.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
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

  Widget _interestPrepMaybeLikeInformationOnApp() {
    if ((_newPatient.srhPrepInterest == null ||
        _newPatient.srhPrepInterest != R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information about PrEP sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhPrepInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhPrepInformationApp = newValue;
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

//NOT INTERESTED
  Widget _interestPrepNotLikeInfoOnMethods() {
    if ((_newPatient.srhPrepInterest == null ||
        _newPatient.srhPrepInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }

    return _makeQuestion('Would she like more information now about PrEP',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhPrepLikeMoreInformation,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhPrepLikeMoreInformation = newValue;
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

  Widget _interestPrepNotLikeInfoOnMethodsShowButtons() {
    if ((_newPatient.srhPrepInterest == null ||
            _newPatient.srhPrepInterest != R21Interest.NoInterested()) ||
        (_newPatient.srhPrepLikeMoreInformation == null ||
            _newPatient.srhPrepLikeMoreInformation != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestPrepNotLikeInformationOnApp() {
    if ((_newPatient.srhPrepInterest == null ||
        _newPatient.srhPrepInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information about PrEP sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _newPatient.srhPrepLikeMoreInformation,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _newPatient.srhPrepLikeMoreInformation = newValue;
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






 





  // ----------
  // OTHER
  // ----------

  /// Returns true if the form validation succeeds and the patient was saved
  /// successfully.
  Future<bool> _onSubmitPersonalDataForm() async {
    setState(() {
      _isLoading = true;
    });
    if (_formParticipantCharacteristicsKey.currentState.validate()) {
      setState(() {
        _patientSaved = true;
      });

      return true;
    }
    setState(() {
      _isLoading = false;
    });
    return false;
  }

  /// Returns true if the form validation succeeds and the patient was saved
  /// successfully.
  Future<bool> _onSubmitHistoryForm() async {
    setState(() {
      _isLoading = true;
    });
    if (_formParticipantHistoryKey.currentState.validate()) {
      setState(() {
        _historySaved = true;
      });

      return true;
    }
    setState(() {
      _isLoading = false;
    });
    return false;
  }

  /// Returns true if the form validation succeeds and the patient was saved
  /// successfully.
  Future<bool> _onSubmitPreferenceForm() async {
    setState(() {
      _isLoading = true;
    });
    if (_formParticipantSrhPreferenceKey.currentState.validate()) {
      setState(() {
        _srhSaved = true;
      });

      final DateTime now = DateTime.now();

      _newPatient.utilityEnrollmentDate = now;
      _newPatient.personalStudyNumber = _studyNumberCtr.text;
      _newPatient.personalPhoneNumber = '+260-${_phoneNumberCtr.text}';

      _newPatient.checkLogicAndResetUnusedFields();

      await _newPatient.initializeRequiredActionsField();

      await DatabaseProvider().insertPatient(_newPatient);
      await PatientBloc.instance.sinkNewPatientData(_newPatient);
      setState(() {
        _isLoading = false;
      });

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

  bool _studyNumberExists(artNumber) {
    return _studyNumbersInDB.contains(artNumber);
  }

}
