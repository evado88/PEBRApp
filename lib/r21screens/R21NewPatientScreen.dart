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
import 'package:pebrapp/r21screens/R21ChooseFacilityScreen.dart';
import 'package:pebrapp/r21screens/R21ViewResourcesScreen.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/InputFormatters.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:pebrapp/database/beans/NoChatDownloadReason.dart';

class R21NewPatientScreen extends StatefulWidget {
  final Patient patient;

  const R21NewPatientScreen(this.patient);

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

  Patient _currentPatient;

  // this field is used to display an error when the form is validated and if
  // the viral load baseline date is not selected
  bool _patientBirthdayValid = true;

  List<String> _studyNumbersInDB;
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

    if (this.widget.patient == null) {
      _currentPatient = Patient();
    } else {
      //PARTICIPANT CHARACTERISTICS

      //Personal Information
      _personalStudyNumberCtr.text = this.widget.patient.personalStudyNumber;

      //Messenger App
      _messengerNoDownloadReasonSpecifyCtr.text =
          this.widget.patient.messengerNoDownloadReasonSpecify;

      //Contact
      _personalPhoneNumberCtr.text =
          this.widget.patient.personalPhoneNumber.substring(3);

      //SRH HISTORY

      //Contraception
      _historyContraceptionOtherSpecifyCtr.text =
          this.widget.patient.historyContraceptionOtherSpecify;

      _historyContraceptionStopReasonCtr.text =
          this.widget.patient.historyContraceptionStopReason;

      _historyContraceptionSatisfactionReasonCtr.text =
          this.widget.patient.historyContraceptionSatisfactionReason;

      _historyContraceptionNoUseReasonCtr.text =
          this.widget.patient.historyContraceptionNoUseReason;

      //Hiv
      _historyHIVLastRefilSourceSpecifyCtr.text =
          this.widget.patient.historyHIVLastRefilSourceSpecify;

      _historyHIVARTProblemsCtr.text =
          this.widget.patient.historyHIVARTProblems;

      _historyHIVARTQuestionsCtr.text =
          this.widget.patient.historyHIVARTQuestions;

      _historyHIVDesiredSupportOtherSpecifyCtr.text =
          this.widget.patient.historyHIVDesiredSupportOtherSpecify;

      //Prep
      _historyHIVPrepStopReasonCtr.text =
          this.widget.patient.historyHIVPrepStopReason;

      _historyHIVPrepLastRefilSourceSpecifyCtr.text =
          this.widget.patient.historyHIVPrepLastRefilSourceSpecify;

      _historyHIVPrepProblemsCtr.text =
          this.widget.patient.historyHIVPrepProblems;

      _historyHIVPrepQuestionsCtr.text =
          this.widget.patient.historyHIVPrepQuestions;

      _historyHIVPrepDesiredSupportOtherSpecifyCtr.text =
          this.widget.patient.historyHIVPrepDesiredSupportOtherSpecify;

      //SRH PREFERENCE

      //contraception
      _srhContraceptionInterestOtherSpecifyCtr.text =
          this.widget.patient.srhContraceptionInterestOtherSpecify;

      _srhContraceptionFindScheduleFacilitySelectedVeryYesCtr.text = this
          .widget
          .patient
          .srhContraceptionFindScheduleFacilitySelected; //again

      _srhContraceptionFindScheduleFacilityNoOtherCtr.text =
          this.widget.patient.srhContraceptionFindScheduleFacilityOther;

      _srhContraceptionFindScheduleFacilitySelectedVeryNoYesCtr.text = this
          .widget
          .patient
          .srhContraceptionFindScheduleFacilitySelected; //again

      _srhContraceptionInterestOtherSpecifyMaybeCtr.text =
          this.widget.patient.srhContraceptionInterestOtherSpecify; //again

      _srhContraceptionFindScheduleFacilitySelectedMaybeCtr.text = this
          .widget
          .patient
          .srhContraceptionFindScheduleFacilitySelected; //again

      _srhContraceptionFindScheduleFacilityOtherMaybeNotNowCtr.text =
          this.widget.patient.srhContraceptionFindScheduleFacilityOther; //again

      _srhContraceptionFindScheduleFacilitySelectedMaybeNotNowCtr.text = this
          .widget
          .patient
          .srhContraceptionFindScheduleFacilitySelected; //again

      _srhContraceptionNoInterestReasonCtr.text =
          this.widget.patient.srhContraceptionNoInterestReason;

      //prep
      _srhPrepNoInterestReasonCtr.text =
          this.widget.patient.srhPrepNoInterestReason;

      _srhPrepFindScheduleFacilitySelectedVeryYesCtr.text =
          this.widget.patient.srhPrepFindScheduleFacilitySelected;

      _srhPrepFindScheduleFacilityOtherNotNowDateCtr.text =
          this.widget.patient.srhPrepFindScheduleFacilityOther;

      _srhPrepFindScheduleFacilitySelectedVeryNotNowCtr.text =
          this.widget.patient.srhPrepFindScheduleFacilitySelected;

      _srhPrepFindScheduleFacilitySelectedMaybeYesCtr.text =
          this.widget.patient.srhPrepFindScheduleFacilitySelected;

      _srhPrepFindScheduleFacilityOtherCtr.text =
          this.widget.patient.srhPrepFindScheduleFacilityOther;

      _srhPrepFindScheduleFacilitySelectedMaybeNoYesCtr.text =
          this.widget.patient.srhPrepFindScheduleFacilitySelected;

      _currentPatient = this.widget.patient;
    }

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
        subtitle: this.widget.patient == null
            ? 'Create a new participant'
            : this.widget.patient.personalStudyNumber,
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
          _artRefilCollectionClinic(),
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
          _interestPrepNotSpecifyReason(),
          _interestPrepLikeInfoOnMethods(),
          _interestPrepLikeInfoOnMethodsShowButton(),
          _interestPrepVeryLikeFacilitySchedule(),
          _interestPrepVeryLikeFacilityScheduleDate(),
          _interestPrepVeryLikePNAccompany(),
          _interestPrepVeryOpenFacilitiesPageShowButton(),
          _interestPrepSelectedFacilityVeryYes(),
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

  TextEditingController _personalStudyNumberCtr = TextEditingController();

  Widget _studyNumberQuestion() {
    return _makeQuestion(
      'Study Number',
      answer: TextFormField(
        autocorrect: false,
        controller: _personalStudyNumberCtr,
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(5),
          StudyNumberTextInputFormatter(),
        ],
        validator: (String value) {
          if (this.widget.patient == null && _studyNumberExists(value)) {
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
              _currentPatient.personalBirthday == null
                  ? ''
                  : '${formatDateConsistent(_currentPatient.personalBirthday)} (age ${calculateAge(_currentPatient.personalBirthday)})',
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
                  _currentPatient.personalBirthday ?? minBirthdayForEligibility,
              firstDate: minBirthdayForEligibility,
              lastDate: maxBirthdayForEligibility,
            );
            if (date != null) {
              setState(() {
                _currentPatient.personalBirthday = date;
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
        value: _currentPatient.messengerDownloaded,
        onChanged: (bool newValue) {
          setState(() {
            _currentPatient.messengerDownloaded = newValue;
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
    if (_currentPatient.messengerDownloaded == null ||
        _currentPatient.messengerDownloaded) {
      return Container();
    }
    return _makeQuestion(
      'Why',
      answer: DropdownButtonFormField<NoChatDownloadReason>(
        value: _currentPatient.messengerNoDownloadReason,
        onChanged: (NoChatDownloadReason newValue) {
          setState(() {
            _currentPatient.messengerNoDownloadReason = newValue;
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

  TextEditingController _messengerNoDownloadReasonSpecifyCtr =
      TextEditingController();

  Widget _specifyNoDownloadReasonQuestion() {
    if (_currentPatient.messengerDownloaded == null ||
        _currentPatient.messengerDownloaded ||
        _currentPatient.messengerNoDownloadReason == null ||
        _currentPatient.messengerNoDownloadReason !=
            NoChatDownloadReason.OTHER()) {
      return Container();
    }
    return _makeQuestion(
      'Other, specify',
      answer: TextFormField(
        controller: _messengerNoDownloadReasonSpecifyCtr,
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

  TextEditingController _personalPhoneNumberCtr = TextEditingController();
  Widget _phoneNumberQuestion() {
    return _makeQuestion(
      'Phone Number',
      answer: TextFormField(
        decoration: InputDecoration(
          prefixText: '+260',
        ),
        controller: _personalPhoneNumberCtr,
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
        value: _currentPatient.personalPhoneNumberAvailability,
        onChanged: (R21PhoneNumberSecurity newValue) {
          setState(() {
            _currentPatient.personalPhoneNumberAvailability = newValue;
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
        value: _currentPatient.personalResidency,
        onChanged: (R21Residency newValue) {
          setState(() {
            _currentPatient.personalResidency = newValue;
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
        value: _currentPatient.personalPreferredContactMethod,
        onChanged: (R21PreferredContactMethod newValue) {
          setState(() {
            _currentPatient.personalPreferredContactMethod = newValue;
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
        value: _currentPatient.personalContactFrequency,
        onChanged: (R21ContactFrequency newValue) {
          setState(() {
            _currentPatient.personalContactFrequency = newValue;
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
        value: _currentPatient.historyContraceptionUse,
        onChanged: (R21ContraceptionUse newValue) {
          setState(() {
            _currentPatient.historyContraceptionUse = newValue;
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
    if (_currentPatient.historyContraceptionUse == null ||
        _currentPatient.historyContraceptionUse ==
            R21ContraceptionUse.HasNever()) {
      return SizedBox();
    }

    return _makeQuestion('Contraceptive Method',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _currentPatient.historyContraceptionMaleCondoms,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyContraceptionMaleCondoms = value;
                });
              },
            ),
            Text(
              'Male Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.historyContraceptionFemaleCondoms,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyContraceptionFemaleCondoms = value;
                });
              },
            ),
            Text(
              'Female Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestImplant,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestImplant = value;
                });
              },
            ),
            Text(
              'Implant',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.historyContraceptionInjection,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyContraceptionInjection = value;
                });
              },
            ),
            Text(
              'Injection',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.historyContraceptionIUD,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyContraceptionIUD = value;
                });
              },
            ),
            Text(
              'IUD (intrauterine Device or Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.historyContraceptionIUS,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyContraceptionIUS = value;
                });
              },
            ),
            Text(
              'IUS (intrauterine System or Hormonal Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.historyContraceptionPills,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyContraceptionPills = value;
                });
              },
            ),
            Text(
              'Contraception Pills (combined or progestogen-only)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.historyContraceptionOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyContraceptionOther = value;
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

  TextEditingController _historyContraceptionOtherSpecifyCtr =
      TextEditingController();

  Widget _contraceptiveMethodOtherSpecify() {
    if (_currentPatient.historyContraceptionUse == null ||
        _currentPatient.historyContraceptionUse ==
            R21ContraceptionUse.HasNever() ||
        !_currentPatient.historyContraceptionOther) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify method',
      answer: TextFormField(
        controller: _historyContraceptionOtherSpecifyCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  TextEditingController _historyContraceptionStopReasonCtr =
      TextEditingController();

  Widget _whyStopContraception() {
    if (_currentPatient.historyContraceptionUse == null ||
        _currentPatient.historyContraceptionUse !=
            R21ContraceptionUse.NotCurrentButPast()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Why did she stop using ',
      answer: TextFormField(
        controller: _historyContraceptionStopReasonCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _contraceptionSatisfaction() {
    if (_currentPatient.historyContraceptionUse == null ||
        _currentPatient.historyContraceptionUse !=
            R21ContraceptionUse.CurrentlyUsing()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Satisfaction with current method',
      answer: DropdownButtonFormField<R21Satisfaction>(
        value: _currentPatient.historyContraceptionSatisfaction,
        onChanged: (R21Satisfaction newValue) {
          setState(() {
            _currentPatient.historyContraceptionSatisfaction = newValue;
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

  TextEditingController _historyContraceptionSatisfactionReasonCtr =
      TextEditingController();

  Widget _whyNoContraceptionSatisfaction() {
    if (_currentPatient.historyContraceptionUse == null ||
        _currentPatient.historyContraceptionUse !=
            R21ContraceptionUse.CurrentlyUsing()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Why',
      answer: TextFormField(
        controller: _historyContraceptionSatisfactionReasonCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  TextEditingController _historyContraceptionNoUseReasonCtr =
      TextEditingController();

  Widget _whyNoContraception() {
    if (_currentPatient.historyContraceptionUse == null ||
        _currentPatient.historyContraceptionUse !=
            R21ContraceptionUse.HasNever()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Why not',
      answer: TextFormField(
        controller: _historyContraceptionNoUseReasonCtr,
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
        value: _currentPatient.historyHIVStatus,
        onChanged: (R21HIVStatus newValue) {
          setState(() {
            _currentPatient.historyHIVStatus = newValue;
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
    if (_currentPatient.historyHIVStatus == null ||
        _currentPatient.historyHIVStatus != R21HIVStatus.YesPositive()) {
      return SizedBox();
    }

    return _makeQuestion(
      'is she currently taking ART',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _currentPatient.historyHIVTakingART,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _currentPatient.historyHIVTakingART = newValue;
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
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus != R21HIVStatus.YesPositive()) ||
        (_currentPatient.historyHIVTakingART == null ||
            _currentPatient.historyHIVTakingART != R21YesNo.YES())) {
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
              _currentPatient.historyHIVLastRefil == null
                  ? ''
                  : '${formatDateConsistent(_currentPatient.historyHIVLastRefil)}',
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
                _currentPatient.historyHIVLastRefil = date;
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

  Widget _artRefilCollectionClinic() {
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus != R21HIVStatus.YesPositive()) ||
        (_currentPatient.historyHIVTakingART == null ||
            _currentPatient.historyHIVTakingART != R21YesNo.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Where was refill was collected from',
      answer: DropdownButtonFormField<R21ProviderType>(
        value: _currentPatient.historyHIVLastRefilSource,
        onChanged: (R21ProviderType newValue) {
          setState(() {
            _currentPatient.historyHIVLastRefilSource = newValue;
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

  TextEditingController _historyHIVLastRefilSourceSpecifyCtr =
      TextEditingController();

  Widget _specifyARTRefilCollectionClinic() {
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus != R21HIVStatus.YesPositive()) ||
        (_currentPatient.historyHIVTakingART == null ||
            _currentPatient.historyHIVTakingART != R21YesNo.YES()) ||
        (_currentPatient.historyHIVLastRefilSource == null ||
            _currentPatient.historyHIVLastRefilSource !=
                R21ProviderType.Other())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify refil collection source',
      answer: TextFormField(
        controller: _historyHIVLastRefilSourceSpecifyCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  TextEditingController _historyHIVARTProblemsCtr = TextEditingController();

  Widget _problemsTakingART() {
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus != R21HIVStatus.YesPositive()) ||
        (_currentPatient.historyHIVTakingART == null ||
            _currentPatient.historyHIVTakingART != R21YesNo.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Any problems taking?',
      answer: TextFormField(
        controller: _historyHIVARTProblemsCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  TextEditingController _historyHIVARTQuestionsCtr = TextEditingController();

  Widget _questionsAboutARTMedication() {
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus != R21HIVStatus.YesPositive()) ||
        (_currentPatient.historyHIVTakingART == null ||
            _currentPatient.historyHIVTakingART != R21YesNo.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Any questions about the medication',
      answer: TextFormField(
        controller: _historyHIVARTQuestionsCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _desiredARTSupport() {
    if (_currentPatient.historyHIVStatus == null ||
        _currentPatient.historyHIVStatus != R21HIVStatus.YesPositive()) {
      return SizedBox();
    }

    return _makeQuestion('Desired support ',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value:
                  _currentPatient.historyHIVDesiredSupportRemindersAppointments,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient
                      .historyHIVDesiredSupportRemindersAppointments = value;
                });
              },
            ),
            Text(
              'Reminders about refill/appointment dates',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.historyHIVDesiredSupportRemindersCheckins,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyHIVDesiredSupportRemindersCheckins =
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
              value: _currentPatient.historyHIVDesiredSupportRefilsAccompany,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyHIVDesiredSupportRefilsAccompany =
                      value;
                });
              },
            ),
            Text(
              'Coming with her to get refills',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.historyHIVDesiredSupportRefilsPAAccompany,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyHIVDesiredSupportRefilsPAAccompany =
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
              value: _currentPatient.historyHIVDesiredSupportOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyHIVDesiredSupportOther = value;
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

  TextEditingController _historyHIVDesiredSupportOtherSpecifyCtr =
      TextEditingController();

  Widget _specifyARTDesiredSupportOther() {
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus != R21HIVStatus.YesPositive()) ||
        (_currentPatient.historyHIVTakingART == null ||
            _currentPatient.historyHIVTakingART == R21YesNo.NO()) ||
        !_currentPatient.historyHIVDesiredSupportOther) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other support',
      answer: TextFormField(
        controller: _historyHIVDesiredSupportOtherSpecifyCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _lastHIVTestDateQuestion() {
    if ((_currentPatient.historyHIVStatus == null ||
        _currentPatient.historyHIVStatus == R21HIVStatus.YesPositive())) {
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
              _currentPatient.historyHIVLastTest == null
                  ? ''
                  : '${formatDateConsistent(_currentPatient.historyHIVLastTest)}',
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
                _currentPatient.historyHIVLastTest = date;
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
    if ((_currentPatient.historyHIVStatus == null ||
        _currentPatient.historyHIVStatus == R21HIVStatus.YesPositive())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Has she ever used PrEP ',
      answer: DropdownButtonFormField<R21PrEP>(
        value: _currentPatient.historyHIVUsedPrep,
        onChanged: (R21PrEP newValue) {
          setState(() {
            _currentPatient.historyHIVUsedPrep = newValue;
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

  TextEditingController _historyHIVPrepStopReasonCtr = TextEditingController();

  Widget _specifyPrepStopReason() {
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_currentPatient.historyHIVUsedPrep == null ||
            _currentPatient.historyHIVUsedPrep != R21PrEP.YesNotCurrently())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Why did she stop',
      answer: TextFormField(
        controller: _historyHIVPrepStopReasonCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _lastPrepRefilDateQuestion() {
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_currentPatient.historyHIVUsedPrep == null ||
            _currentPatient.historyHIVUsedPrep != R21PrEP.YesCurrently())) {
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
              _currentPatient.historyHIVPrepLastRefil == null
                  ? ''
                  : '${formatDateConsistent(_currentPatient.historyHIVPrepLastRefil)}',
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
                _currentPatient.historyHIVPrepLastRefil = date;
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
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus != R21HIVStatus.YesNegative()) ||
        (_currentPatient.historyHIVUsedPrep == null ||
            _currentPatient.historyHIVUsedPrep != R21PrEP.YesCurrently())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Where PrEp refill was collected from',
      answer: DropdownButtonFormField<R21ProviderType>(
        value: _currentPatient.historyHIVPrepLastRefilSource,
        onChanged: (R21ProviderType newValue) {
          setState(() {
            _currentPatient.historyHIVPrepLastRefilSource = newValue;
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

  TextEditingController _historyHIVPrepLastRefilSourceSpecifyCtr =
      TextEditingController();

  Widget _specifyPrepRefilCollectionClinic() {
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus != R21HIVStatus.YesNegative()) ||
        (_currentPatient.historyHIVUsedPrep == null ||
            _currentPatient.historyHIVUsedPrep != R21PrEP.YesCurrently()) ||
        (_currentPatient.historyHIVPrepLastRefilSource == null ||
            _currentPatient.historyHIVPrepLastRefilSource !=
                R21ProviderType.Other())) {
      return SizedBox();
    }
    return _makeQuestion(
      'Specify refil collection source',
      answer: TextFormField(
        controller: _historyHIVPrepLastRefilSourceSpecifyCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  TextEditingController _historyHIVPrepProblemsCtr = TextEditingController();

  Widget _problemsTakingPrep() {
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_currentPatient.historyHIVUsedPrep == null ||
            _currentPatient.historyHIVUsedPrep != R21PrEP.YesCurrently())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Any problems taking PrEP?',
      answer: TextFormField(
        controller: _historyHIVPrepProblemsCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  TextEditingController _historyHIVPrepQuestionsCtr = TextEditingController();

  Widget _questionsAboutPrepMedication() {
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_currentPatient.historyHIVUsedPrep == null ||
            _currentPatient.historyHIVUsedPrep != R21PrEP.YesCurrently())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Any questions about the medication',
      answer: TextFormField(
        controller: _historyHIVPrepQuestionsCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a reason';
          }
        },
      ),
    );
  }

  Widget _desiredPrepSupport() {
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_currentPatient.historyHIVUsedPrep == null ||
            _currentPatient.historyHIVUsedPrep != R21PrEP.YesCurrently())) {
      return SizedBox();
    }

    return _makeQuestion('Desired PrEP support ',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _currentPatient
                  .historyHIVPrepDesiredSupportReminderssAppointments,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient
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
              value: _currentPatient
                  .historyHIVPrepDesiredSupportRemindersAdherence,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient
                      .historyHIVPrepDesiredSupportRemindersAdherence = value;
                });
              },
            ),
            Text(
              'Check-in/reminders about adherence',
            ),
          ]),
          Row(children: [
            Checkbox(
              value:
                  _currentPatient.historyHIVPrepDesiredSupportRefilsPNAccompany,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient
                      .historyHIVPrepDesiredSupportRefilsPNAccompany = value;
                });
              },
            ),
            Text(
              'Peer navigator coming with her to get refills',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.historyHIVPrepDesiredSupportPNHIVKit,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyHIVPrepDesiredSupportPNHIVKit = value;
                });
              },
            ),
            Text(
              'Peer navigator providing HIV self testing ',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.historyHIVPrepDesiredSupportOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.historyHIVPrepDesiredSupportOther = value;
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

  TextEditingController _historyHIVPrepDesiredSupportOtherSpecifyCtr =
      TextEditingController();

  Widget _specifyPrepDesiredSupportOther() {
    if ((_currentPatient.historyHIVStatus == null ||
            _currentPatient.historyHIVStatus == R21HIVStatus.YesPositive()) ||
        (_currentPatient.historyHIVUsedPrep == null ||
            _currentPatient.historyHIVUsedPrep != R21PrEP.YesCurrently()) ||
        !_currentPatient.historyHIVPrepDesiredSupportOther) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other PrEP support',
      answer: TextFormField(
        controller: _historyHIVPrepDesiredSupportOtherSpecifyCtr,
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
        value: _currentPatient.srhContraceptionInterest,
        onChanged: (R21Interest newValue) {
          setState(() {
            _currentPatient.srhContraceptionInterest = newValue;
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
    if (_currentPatient.srhContraceptionInterest == null ||
        _currentPatient.srhContraceptionInterest !=
            R21Interest.VeryInterested()) {
      return SizedBox();
    }
    return _makeQuestion(
      'Does she have a particular method in mind?',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _currentPatient.srhContraceptionMethodInMind,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _currentPatient.srhContraceptionMethodInMind = newValue;
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_currentPatient.srhContraceptionMethodInMind == null ||
            _currentPatient.srhContraceptionMethodInMind == R21YesNo.NO())) {
      return SizedBox();
    }

    return _makeQuestion('Which method',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestMaleCondom,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestMaleCondom = value;
                });
              },
            ),
            Text(
              'Male Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestFemaleCondom,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestFemaleCondom = value;
                });
              },
            ),
            Text(
              'Female Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestImplant,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestImplant = value;
                });
              },
            ),
            Text(
              'Implant',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestInjection,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestInjection = value;
                });
              },
            ),
            Text(
              'Injection',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestIUD,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestIUD = value;
                });
              },
            ),
            Text(
              'IUD (intrauterine Device or Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestIUS,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestIUS = value;
                });
              },
            ),
            Text(
              'IUS (intrauterine System or Hormonal Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestPills,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestPills = value;
                });
              },
            ),
            Text(
              'Contraception Pills (combined or progestogen-only)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestOther = value;
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

  TextEditingController _srhContraceptionInterestOtherSpecifyCtr =
      TextEditingController();

  Widget _specifyInterestContraceptionMethodOther() {
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_currentPatient.srhContraceptionMethodInMind == null ||
            _currentPatient.srhContraceptionMethodInMind == R21YesNo.NO()) ||
        (_currentPatient.srhContraceptionInterestOther == null ||
            _currentPatient.srhContraceptionInterestOther == false)) {
      return Container();
    }
    return _makeQuestion(
      'Specify other method',
      answer: TextFormField(
        controller: _srhContraceptionInterestOtherSpecifyCtr,
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
    if (_currentPatient.srhContraceptionInterest == null ||
        _currentPatient.srhContraceptionInterest !=
            R21Interest.VeryInterested()) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like more information about different methods right now?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhContraceptionInformationMethods,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhContraceptionInformationMethods = newValue;
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_currentPatient.srhContraceptionInformationMethods == null ||
            _currentPatient.srhContraceptionInformationMethods ==
                R21YesNo.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information Page', onPressed: () {
      print('~~~ OPENING COUNSELLING INFO PAGE =>');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestContraceptionLikeFacilitySchedule() {
    if (_currentPatient.srhContraceptionInterest == null ||
        _currentPatient.srhContraceptionInterest !=
            R21Interest.VeryInterested()) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly a method of her choice NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _currentPatient.srhContraceptionFindScheduleFacility,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _currentPatient.srhContraceptionFindScheduleFacility = newValue;
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility ==
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
              _currentPatient.srhContraceptionFindScheduleFacilityYesDate ==
                      null
                  ? ''
                  : '${formatDateConsistent(_currentPatient.srhContraceptionFindScheduleFacilityYesDate)}',
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
                _currentPatient.srhContraceptionFindScheduleFacilityYesDate =
                    date;
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }
    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient
              .srhContraceptionFindScheduleFacilityYesPNAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient
                      .srhContraceptionFindScheduleFacilityYesPNAccompany =
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page [[VeryYes]]]]', onPressed: () {
      print('~~~ 1. OPENING FACILITIES PAGE NOW =>');
      _pushChooseFacilityScreen();
    });
  }

  TextEditingController
      _srhContraceptionFindScheduleFacilitySelectedVeryYesCtr =
      TextEditingController();

  Widget _interestContraceptionSelectedFacility() {
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }
    return _makeQuestion(
      'Selected Facility Code [[VeryYes]]',
      answer: TextFormField(
        controller: _srhContraceptionFindScheduleFacilitySelectedVeryYesCtr,
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
        'When would she like to go for counseling and possibly a method of her choice?',
        answer: DropdownButtonFormField<R21Week>(
          value: _currentPatient.srhContraceptionFindScheduleFacilityNoDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _currentPatient.srhContraceptionFindScheduleFacilityNoDate =
                  newValue;
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

  TextEditingController _srhContraceptionFindScheduleFacilityNoOtherCtr =
      TextEditingController();

  Widget _interestContraceptionNotNowDateOther() {
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_currentPatient.srhContraceptionFindScheduleFacilityNoDate == null ||
            _currentPatient.srhContraceptionFindScheduleFacilityNoDate !=
                R21Week.Other())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other date [[VeryNoOther]]',
      answer: TextFormField(
        controller: _srhContraceptionFindScheduleFacilityNoOtherCtr,
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _currentPatient.srhContraceptionFindScheduleFacilityNoPick,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _currentPatient.srhContraceptionFindScheduleFacilityNoPick =
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
    );
  }

  Widget _interestContraceptionNotNowPickFacilityShowButton() {
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES()) ||
        (_currentPatient.srhContraceptionFindScheduleFacilityNoPick == null ||
            _currentPatient.srhContraceptionFindScheduleFacilityNoPick ==
                R21YesNo.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page [[VeryNoYes]]', onPressed: () {
      print('~~~ 2. OPENING FACILITIES PAGE =>');
    });
  }

  TextEditingController
      _srhContraceptionFindScheduleFacilitySelectedVeryNoYesCtr =
      TextEditingController();

  Widget _interestContraceptionNotNowPickFacilitySelected() {
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.VeryInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_currentPatient.srhContraceptionFindScheduleFacilityNoPick == null ||
            _currentPatient.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code [[VeryNoYes]]',
      answer: TextFormField(
        controller: _srhContraceptionFindScheduleFacilitySelectedVeryNoYesCtr,
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
    if (_currentPatient.srhContraceptionInterest == null ||
        _currentPatient.srhContraceptionInterest !=
            R21Interest.VeryInterested()) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhContraceptionInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhContraceptionInformationApp = newValue;
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
    if (_currentPatient.srhContraceptionInterest == null ||
        _currentPatient.srhContraceptionInterest !=
            R21Interest.MaybeInterested()) {
      return SizedBox();
    }

    return _makeQuestion('What method(s) is the client possibly interested in',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestMaleCondom,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestMaleCondom = value;
                });
              },
            ),
            Text(
              'Male Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestFemaleCondom,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestFemaleCondom = value;
                });
              },
            ),
            Text(
              'Female Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestImplant,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestImplant = value;
                });
              },
            ),
            Text(
              'Implant',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestInjection,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestInjection = value;
                });
              },
            ),
            Text(
              'Injection',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestIUD,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestIUD = value;
                });
              },
            ),
            Text(
              'IUD (intrauterine Device or Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestIUS,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestIUS = value;
                });
              },
            ),
            Text(
              'IUS (intrauterine System or Hormonal Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestPills,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestPills = value;
                });
              },
            ),
            Text(
              'Contraception Pills (combined or progestogen-only)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _currentPatient.srhContraceptionInterestOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _currentPatient.srhContraceptionInterestOther = value;
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

  TextEditingController _srhContraceptionInterestOtherSpecifyMaybeCtr =
      TextEditingController();

  Widget _interestContraceptionMaybeMethodSpecify() {
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        !_currentPatient.srhContraceptionInterestOther) {
      return SizedBox();
    }
    return _makeQuestion(
      'Specify other method [[Maybe]]',
      answer: TextFormField(
        controller: _srhContraceptionInterestOtherSpecifyMaybeCtr,
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
    if ((_currentPatient.srhContraceptionInterest == null ||
        _currentPatient.srhContraceptionInterest !=
            R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly a method of her choice NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _currentPatient.srhContraceptionFindScheduleFacility,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _currentPatient.srhContraceptionFindScheduleFacility = newValue;
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility ==
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
              _currentPatient.srhContraceptionFindScheduleFacilityYesDate ==
                      null
                  ? ''
                  : '${formatDateConsistent(_currentPatient.srhContraceptionFindScheduleFacilityYesDate)}',
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
                _currentPatient.srhContraceptionFindScheduleFacilityYesDate =
                    date;
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }
    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient
              .srhContraceptionFindScheduleFacilityYesPNAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient
                      .srhContraceptionFindScheduleFacilityYesPNAccompany =
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page [[MaybeYes]]', onPressed: () {
      print('~~~ 3. OPENING FACILITIES PAGE =>');
    });
  }

  TextEditingController _srhContraceptionFindScheduleFacilitySelectedMaybeCtr =
      TextEditingController();

  Widget _interestContraceptionMaybeSelectedFacility() {
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.YES())) {
      return SizedBox();
    }
    return _makeQuestion(
      'Selected Facility Code [[MaybeYes]]',
      answer: TextFormField(
        controller: _srhContraceptionFindScheduleFacilitySelectedMaybeCtr,
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
        'When would she like to go for counseling and possibly a method of her choice?-',
        answer: DropdownButtonFormField<R21Week>(
          value: _currentPatient.srhContraceptionFindScheduleFacilityNoDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _currentPatient.srhContraceptionFindScheduleFacilityNoDate =
                  newValue;
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

  TextEditingController
      _srhContraceptionFindScheduleFacilityOtherMaybeNotNowCtr =
      TextEditingController();

  Widget _interestContraceptionMaybeNotNowDateOther() {
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_currentPatient.srhContraceptionFindScheduleFacilityNoDate == null ||
            _currentPatient.srhContraceptionFindScheduleFacilityNoDate !=
                R21Week.Other())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other date',
      answer: TextFormField(
        controller: _srhContraceptionFindScheduleFacilityOtherMaybeNotNowCtr,
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?-',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _currentPatient.srhContraceptionFindScheduleFacilityNoPick,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _currentPatient.srhContraceptionFindScheduleFacilityNoPick =
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
    );
  }

  Widget _interestContraceptionMaybeNotNowPickFacilityShowButton() {
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_currentPatient.srhContraceptionFindScheduleFacilityNoPick == null ||
            _currentPatient.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page [[MaybeNoYes]]',
        onPressed: () {
      print('4. Opening facilities page');
    });
  }

  TextEditingController
      _srhContraceptionFindScheduleFacilitySelectedMaybeNotNowCtr =
      TextEditingController();

  Widget _interestContraceptionMaybeNotNowPickFacilitySelected() {
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_currentPatient.srhContraceptionFindScheduleFacility == null ||
            _currentPatient.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_currentPatient.srhContraceptionFindScheduleFacilityNoPick == null ||
            _currentPatient.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code [[MaybeNoYes]]',
      answer: TextFormField(
        controller: _srhContraceptionFindScheduleFacilitySelectedMaybeNotNowCtr,
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
    if ((_currentPatient.srhContraceptionInterest == null ||
        _currentPatient.srhContraceptionInterest !=
            R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhContraceptionInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhContraceptionInformationApp = newValue;
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
    if ((_currentPatient.srhContraceptionInterest == null ||
        _currentPatient.srhContraceptionInterest !=
            R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to learn more about different contraceptive methods right now?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhContraceptionLearnMethods,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhContraceptionLearnMethods = newValue;
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.MaybeInterested()) ||
        (_currentPatient.srhContraceptionLearnMethods == null ||
            _currentPatient.srhContraceptionLearnMethods != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      _pushViewResourcesScreen();
    });
  }

  TextEditingController _srhContraceptionNoInterestReasonCtr =
      TextEditingController();

  Widget _interestContraceptionNotSpecifyReason() {
    if ((_currentPatient.srhContraceptionInterest == null ||
        _currentPatient.srhContraceptionInterest !=
            R21Interest.NoInterested())) {
      return SizedBox();
    }
    return _makeQuestion(
      'Why not interest in contraception?',
      answer: TextFormField(
        controller: _srhContraceptionNoInterestReasonCtr,
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
    if ((_currentPatient.srhContraceptionInterest == null ||
        _currentPatient.srhContraceptionInterest !=
            R21Interest.NoInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to learn more about different contraceptive methods right now?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhContraceptionInformationMethods,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhContraceptionInformationMethods = newValue;
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
    if ((_currentPatient.srhContraceptionInterest == null ||
            _currentPatient.srhContraceptionInterest !=
                R21Interest.NoInterested()) ||
        (_currentPatient.srhContraceptionInformationMethods == null ||
            _currentPatient.srhContraceptionInformationMethods !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestContraceptionNotLikeInformationOnApp() {
    if ((_currentPatient.srhContraceptionInterest == null ||
        _currentPatient.srhContraceptionInterest !=
            R21Interest.NoInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhContraceptionInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhContraceptionInformationApp = newValue;
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
        value: _currentPatient.srhPrepInterest,
        onChanged: (R21Interest newValue) {
          setState(() {
            _currentPatient.srhPrepInterest = newValue;
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

  TextEditingController _srhPrepNoInterestReasonCtr = TextEditingController();

  Widget _interestPrepNotSpecifyReason() {
    if ((_currentPatient.srhPrepInterest == null ||
        _currentPatient.srhPrepInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }
    return _makeQuestion(
      'Why not interest in PreP?',
      answer: TextFormField(
        controller: _srhPrepNoInterestReasonCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify reason';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestPrepLikeInfoOnMethods() {
    if ((_currentPatient.srhPrepInterest == null ||
        _currentPatient.srhPrepInterest != R21Interest.VeryInterested())) {
      return SizedBox();
    }

    return _makeQuestion('Would she like more information now about PrEP',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhPrepLikeMoreInformation,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhPrepLikeMoreInformation = newValue;
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        (_currentPatient.srhPrepLikeMoreInformation == null ||
            _currentPatient.srhPrepLikeMoreInformation != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestPrepVeryLikeFacilitySchedule() {
    if ((_currentPatient.srhPrepInterest == null ||
        _currentPatient.srhPrepInterest != R21Interest.VeryInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly get PrEP NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _currentPatient.srhPrepFindScheduleFacilitySchedule,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _currentPatient.srhPrepFindScheduleFacilitySchedule = newValue;
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        ((_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
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
              _currentPatient.srhPrepFindScheduleFacilityYesDate == null
                  ? ''
                  : '${formatDateConsistent(_currentPatient.srhPrepFindScheduleFacilityYesDate)}',
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
                _currentPatient.srhPrepFindScheduleFacilityYesDate = date;
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        ((_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhPrepFindScheduleFacilityYesPNAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhPrepFindScheduleFacilityYesPNAccompany =
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

  Widget _interestPrepVeryOpenFacilitiesPageShowButton() {
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        ((_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page ee', onPressed: () {
      print('~~~ 3. OPENING FACILITIES PAGE =>');
    });
  }

  TextEditingController _srhPrepFindScheduleFacilitySelectedVeryYesCtr =
      TextEditingController();

  Widget _interestPrepSelectedFacilityVeryYes() {
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        ((_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code [[VeryYes]]',
      answer: TextFormField(
        controller: _srhPrepFindScheduleFacilitySelectedVeryYesCtr,
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        (_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
        'If no, when would she like to go for counseling and possibly get PrEP?',
        answer: DropdownButtonFormField<R21Week>(
          value: _currentPatient.srhPrepFindScheduleFacilityNoDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _currentPatient.srhPrepFindScheduleFacilityNoDate = newValue;
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

  TextEditingController _srhPrepFindScheduleFacilityOtherNotNowDateCtr =
      TextEditingController();

  Widget _interestPrepVeryNotNowDateOther() {
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        (_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_currentPatient.srhPrepFindScheduleFacilityNoDate == null ||
            _currentPatient.srhPrepFindScheduleFacilityNoDate !=
                R21Week.Other())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other date',
      answer: TextFormField(
        controller: _srhPrepFindScheduleFacilityOtherNotNowDateCtr,
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        (_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?-',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _currentPatient.srhPrepFindScheduleFacilityNoPick,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _currentPatient.srhPrepFindScheduleFacilityNoPick = newValue;
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        (_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_currentPatient.srhPrepFindScheduleFacilityNoPick == null ||
            _currentPatient.srhPrepFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page [[VeryNoYes]]', onPressed: () {
      print('4. Opening facilities page');
    });
  }

  TextEditingController _srhPrepFindScheduleFacilitySelectedVeryNotNowCtr =
      TextEditingController();

  Widget _interestPrepVeryNotNowPickFacilitySelected() {
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.VeryInterested()) ||
        (_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_currentPatient.srhPrepFindScheduleFacilityNoPick == null ||
            _currentPatient.srhPrepFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code [[VeryNoYes]]',
      answer: TextFormField(
        controller: _srhPrepFindScheduleFacilitySelectedVeryNotNowCtr,
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
    if ((_currentPatient.srhPrepInterest == null ||
        _currentPatient.srhPrepInterest != R21Interest.VeryInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information about PrEP sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhPrepInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhPrepInformationApp = newValue;
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
    if ((_currentPatient.srhPrepInterest == null ||
        _currentPatient.srhPrepInterest != R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion('Would she like more information now about PrEP',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhPrepLikeMoreInformation,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhPrepLikeMoreInformation = newValue;
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        (_currentPatient.srhPrepLikeMoreInformation == null ||
            _currentPatient.srhPrepLikeMoreInformation != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestPrepMaybeLikeFacilitySchedule() {
    if ((_currentPatient.srhPrepInterest == null ||
        _currentPatient.srhPrepInterest != R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly get PrEP NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _currentPatient.srhPrepFindScheduleFacilitySchedule,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _currentPatient.srhPrepFindScheduleFacilitySchedule = newValue;
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        ((_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
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
              _currentPatient.srhContraceptionFindScheduleFacilityYesDate ==
                      null
                  ? ''
                  : '${formatDateConsistent(_currentPatient.srhContraceptionFindScheduleFacilityYesDate)}',
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
                _currentPatient.srhContraceptionFindScheduleFacilityYesDate =
                    date;
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        ((_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhPrepFindScheduleFacilityYesPNAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhPrepFindScheduleFacilityYesPNAccompany =
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

  Widget _interestPrepMaybeOpenFacilitiesPageShowButton() {
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        ((_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page [[MaybeYes]]', onPressed: () {
      print('~~~ 3. OPENING FACILITIES PAGE =>');
    });
  }

  TextEditingController _srhPrepFindScheduleFacilitySelectedMaybeYesCtr =
      TextEditingController();

  Widget _interestPrepMaybeSelectedFacility() {
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        ((_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code [[MaybeYes]]',
      answer: TextFormField(
        controller: _srhPrepFindScheduleFacilitySelectedMaybeYesCtr,
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        (_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
        'If no, when would she like to go for counseling and possibly get PrEP?',
        answer: DropdownButtonFormField<R21Week>(
          value: _currentPatient.srhPrepFindScheduleFacilityNoDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _currentPatient.srhPrepFindScheduleFacilityNoDate = newValue;
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

  TextEditingController _srhPrepFindScheduleFacilityOtherCtr =
      TextEditingController();

  Widget _interestPrepMaybeNotNowDateOther() {
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        (_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_currentPatient.srhPrepFindScheduleFacilityNoDate == null ||
            _currentPatient.srhPrepFindScheduleFacilityNoDate !=
                R21Week.Other())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other date',
      answer: TextFormField(
        controller: _srhPrepFindScheduleFacilityOtherCtr,
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        (_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?-',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _currentPatient.srhPrepFindScheduleFacilityNoPick,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _currentPatient.srhPrepFindScheduleFacilityNoPick = newValue;
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        (_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_currentPatient.srhPrepFindScheduleFacilityNoPick == null ||
            _currentPatient.srhPrepFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page [[MaybeNoYes]]',
        onPressed: () {
      print('4. Opening facilities page');
    });
  }

  TextEditingController _srhPrepFindScheduleFacilitySelectedMaybeNoYesCtr =
      TextEditingController();

  Widget _interestPrepMaybeNotNowPickFacilitySelected() {
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.MaybeInterested()) ||
        (_currentPatient.srhPrepFindScheduleFacilitySchedule == null ||
            _currentPatient.srhPrepFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_currentPatient.srhPrepFindScheduleFacilityNoPick == null ||
            _currentPatient.srhPrepFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code [[MaybeNoYes]]',
      answer: TextFormField(
        controller: _srhPrepFindScheduleFacilitySelectedMaybeNoYesCtr,
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
    if ((_currentPatient.srhPrepInterest == null ||
        _currentPatient.srhPrepInterest != R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information about PrEP sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhPrepInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhPrepInformationApp = newValue;
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
    if ((_currentPatient.srhPrepInterest == null ||
        _currentPatient.srhPrepInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }

    return _makeQuestion('Would she like more information now about PrEP',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhPrepLikeMoreInformation,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhPrepLikeMoreInformation = newValue;
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
    if ((_currentPatient.srhPrepInterest == null ||
            _currentPatient.srhPrepInterest != R21Interest.NoInterested()) ||
        (_currentPatient.srhPrepLikeMoreInformation == null ||
            _currentPatient.srhPrepLikeMoreInformation != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestPrepNotLikeInformationOnApp() {
    if ((_currentPatient.srhPrepInterest == null ||
        _currentPatient.srhPrepInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information about PrEP sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _currentPatient.srhPrepLikeMoreInformation,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _currentPatient.srhPrepLikeMoreInformation = newValue;
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

      //UTILITY
      _currentPatient.utilityEnrollmentDate = now;

      //PARTICIPANT CHARACTERISTICS

      //Personal Information
      _currentPatient.personalStudyNumber = _personalStudyNumberCtr.text;

      //Messenger App
      //only set other reason for not downloading when they vent downloaded and reason is other
      if (_currentPatient.messengerDownloaded) {
        _currentPatient.messengerNoDownloadReasonSpecify = null;
      } else {
        if (_currentPatient.messengerNoDownloadReason ==
            NoChatDownloadReason.OTHER()) {
          _currentPatient.messengerNoDownloadReasonSpecify =
              _messengerNoDownloadReasonSpecifyCtr.text;
        } else {
          _currentPatient.messengerNoDownloadReasonSpecify = null;
        }
      }

      //Contact
      _currentPatient.personalPhoneNumber =
          '260${_personalPhoneNumberCtr.text}';

      //SRH HISTORY

      //Contraception
      //only set other contraception method if they re currently using or have used in past
      //and they ve said selected other method
      if ((_currentPatient.historyContraceptionUse ==
                  R21ContraceptionUse.CurrentlyUsing() ||
              _currentPatient.historyContraceptionUse ==
                  R21ContraceptionUse.NotCurrentButPast()) &&
          _currentPatient.historyContraceptionOther) {
        _currentPatient.historyContraceptionOtherSpecify =
            _historyContraceptionOtherSpecifyCtr.text;
      } else {
        _currentPatient.historyContraceptionOtherSpecify = null;
      }

      //only set stop reason if used in the past but has stopped
      if (_currentPatient.historyContraceptionUse ==
          R21ContraceptionUse.NotCurrentButPast()) {
        _currentPatient.historyContraceptionStopReason =
            _historyContraceptionStopReasonCtr.text;
      } else {
        _currentPatient.historyContraceptionStopReason = null;
      }

      //only set stop reason if used in the past but has stopped
      if (_currentPatient.historyContraceptionUse ==
          R21ContraceptionUse.NotCurrentButPast()) {
        _currentPatient.historyContraceptionStopReason =
            _historyContraceptionStopReasonCtr.text;
      } else {
        _currentPatient.historyContraceptionStopReason = null;
      }

      //only set satisfaction reason if currently using
      if (_currentPatient.historyContraceptionUse ==
          R21ContraceptionUse.CurrentlyUsing()) {
        _currentPatient.historyContraceptionSatisfactionReason =
            _historyContraceptionSatisfactionReasonCtr.text;
      } else {
        _currentPatient.historyContraceptionSatisfactionReason = null;
      }

      //only set satisfaction reason if currently using
      if (_currentPatient.historyContraceptionUse ==
          R21ContraceptionUse.HasNever()) {
        _currentPatient.historyContraceptionNoUseReason =
            _historyContraceptionNoUseReasonCtr.text;
      } else {
        _currentPatient.historyContraceptionNoUseReason = null;
      }

      //Hiv
      //only set other art refil source if positive and taking art and source is other
      if (_currentPatient.historyHIVStatus == R21HIVStatus.YesPositive() &&
          _currentPatient.historyHIVTakingART == R21YesNo.YES() &&
          _currentPatient.historyHIVLastRefilSource ==
              R21ProviderType.Other()) {
        _currentPatient.historyHIVLastRefilSourceSpecify =
            _historyHIVLastRefilSourceSpecifyCtr.text;
      } else {
        _currentPatient.historyHIVLastRefilSourceSpecify = null;
      }

      //only set art problems and art questions if positive and taking art
      if (_currentPatient.historyHIVStatus == R21HIVStatus.YesPositive() &&
          _currentPatient.historyHIVTakingART == R21YesNo.YES()) {
        _currentPatient.historyHIVARTProblems = _historyHIVARTProblemsCtr.text;

        _currentPatient.historyHIVARTQuestions =
            _historyHIVARTQuestionsCtr.text;
      } else {
        _currentPatient.historyHIVARTProblems = null;

        _currentPatient.historyHIVARTQuestions = null;
      }

      //only set other desired support when other is selected
      if (_currentPatient.historyHIVDesiredSupportOther) {
        _currentPatient.historyHIVDesiredSupportOtherSpecify =
            _historyHIVDesiredSupportOtherSpecifyCtr.text;
      } else {
        _currentPatient.historyHIVDesiredSupportOtherSpecify = null;
      }

      //Prep

      //only set prep stop reason if client is negative and used to take prep
      if (_currentPatient.historyHIVStatus == R21HIVStatus.YesNegative() &&
          _currentPatient.historyHIVUsedPrep == R21PrEP.YesNotCurrently()) {
        _currentPatient.historyHIVPrepStopReason =
            _historyHIVPrepStopReasonCtr.text;
      } else {
        _currentPatient.historyHIVPrepStopReason = null;
      }

      //only set date of last repr refil, problems taking prep, questions taking prep
      //if client is negative and takinbg prep
      if (_currentPatient.historyHIVStatus == R21HIVStatus.YesNegative() &&
          _currentPatient.historyHIVUsedPrep == R21PrEP.YesCurrently()) {
        _currentPatient.historyHIVPrepProblems =
            _historyHIVPrepProblemsCtr.text;

        _currentPatient.historyHIVPrepQuestions =
            _historyHIVPrepQuestionsCtr.text;
      } else {
        _currentPatient.historyHIVPrepProblems = null;
        _currentPatient.historyHIVPrepQuestions = null;
      }

      //only set specify prep collection source if
      //if client is negative and taking prep and collection source is other
      if (_currentPatient.historyHIVStatus == R21HIVStatus.YesNegative() &&
          _currentPatient.historyHIVUsedPrep == R21PrEP.YesCurrently() &&
          _currentPatient.historyHIVPrepLastRefilSource ==
              R21ProviderType.Other()) {
        _currentPatient.historyHIVPrepLastRefilSourceSpecify =
            _historyHIVPrepLastRefilSourceSpecifyCtr.text;
      } else {
        _currentPatient.historyHIVPrepLastRefilSourceSpecify = null;
      }

      //only set prep desired support if
      //if client is negative and taking prep and needs other support
      if (_currentPatient.historyHIVStatus == R21HIVStatus.YesNegative() &&
          _currentPatient.historyHIVUsedPrep == R21PrEP.YesCurrently() &&
          _currentPatient.historyHIVDesiredSupportOther) {
        _currentPatient.historyHIVPrepDesiredSupportOtherSpecify =
            _historyHIVPrepDesiredSupportOtherSpecifyCtr.text;
      } else {
        _currentPatient.historyHIVPrepDesiredSupportOtherSpecify = null;
      }

      //SRH PREFERENCE

      //contraception
      //only specify no contraception interest if no interested in contraception
      if (_currentPatient.srhContraceptionInterest ==
          R21Interest.NoInterested()) {
        _currentPatient.srhContraceptionInterestOtherSpecify =
            _srhContraceptionInterestOtherSpecifyCtr.text;
      } else {
        _currentPatient.srhContraceptionInterestOtherSpecify = null;
      }

      //only specify selected facility if client is very interested and
      //wants to pick facility now
      if (_currentPatient.srhContraceptionInterest ==
              R21Interest.VeryInterested() &&
          _currentPatient.srhContraceptionFindScheduleFacility ==
              R21YesNoUnsure.YES()) {
        _currentPatient.srhContraceptionFindScheduleFacilitySelected =
            _srhContraceptionFindScheduleFacilitySelectedVeryYesCtr.text;
      }

      //only set specify other date if client is very intested,
      //doesnt not want to pick facility and chooses other on date
      if (_currentPatient.srhContraceptionInterest ==
              R21Interest.VeryInterested() &&
          _currentPatient.srhContraceptionFindScheduleFacility ==
              R21YesNoUnsure.NO() &&
          _currentPatient.srhContraceptionFindScheduleFacilityNoDate ==
              R21Week.Other()) {
        _currentPatient.srhContraceptionFindScheduleFacilityOther =
            _srhContraceptionFindScheduleFacilityNoOtherCtr.text;
      } else {
        _currentPatient.srhContraceptionFindScheduleFacilityOther = null;
      }

      //only set slected facility if client is very intested,
      //doesnt not want to pick facility and chooses yes on pick facility
      if (_currentPatient.srhContraceptionInterest ==
              R21Interest.VeryInterested() &&
          _currentPatient.srhContraceptionFindScheduleFacility ==
              R21YesNoUnsure.NO() &&
          _currentPatient.srhContraceptionFindScheduleFacilityNoPick ==
              R21YesNo.YES()) {
        _currentPatient.srhContraceptionFindScheduleFacilitySelected =
            _srhContraceptionFindScheduleFacilitySelectedVeryNoYesCtr
                .text; //again
      }

      //only set specify contraception other if client is very intested,
      //doesnt not want to pick facility and chooses yes on pick facility
      if (_currentPatient.srhContraceptionInterest ==
              R21Interest.MaybeInterested() &&
          _currentPatient.srhContraceptionInterestOther) {
        _currentPatient.srhContraceptionInterestOtherSpecify =
            _srhContraceptionInterestOtherSpecifyMaybeCtr.text;
      }

      //only set selected facility if contraception interest is maybe
      //and find schedule facility is yes
      if (_currentPatient.srhContraceptionInterest ==
              R21Interest.MaybeInterested() &&
          _currentPatient.srhContraceptionFindScheduleFacility ==
              R21YesNoUnsure.YES()) {
        _currentPatient.srhContraceptionFindScheduleFacilitySelected =
            _srhContraceptionFindScheduleFacilitySelectedMaybeCtr.text;
      }

      //only set selected facility if contraception interest is maybe
      //and find schedule facility is no and selected date is other
      if (_currentPatient.srhContraceptionInterest ==
              R21Interest.MaybeInterested() &&
          _currentPatient.srhContraceptionFindScheduleFacility ==
              R21YesNoUnsure.NO() &&
          _currentPatient.srhContraceptionFindScheduleFacilityNoDate ==
              R21Week.Other()) {
        _currentPatient.srhContraceptionFindScheduleFacilityOther =
            _srhContraceptionFindScheduleFacilityOtherMaybeNotNowCtr.text;
      }

      //only set selected facility if contraception interest is maybe
      //and find schedule facility is no and pick facility is yes
      if (_currentPatient.srhContraceptionInterest ==
              R21Interest.MaybeInterested() &&
          _currentPatient.srhContraceptionFindScheduleFacility ==
              R21YesNoUnsure.NO() &&
          _currentPatient.srhContraceptionFindScheduleFacilityNoPick ==
              R21YesNo.YES()) {
        _currentPatient.srhContraceptionFindScheduleFacilitySelected =
            _srhContraceptionFindScheduleFacilitySelectedMaybeNotNowCtr.text;
      }

      //only set reason for no interest in contraception if
      //contraception interest is not interested
      if (_currentPatient.srhContraceptionInterest ==
          R21Interest.NoInterested()) {
        _currentPatient.srhContraceptionNoInterestReason =
            _srhContraceptionNoInterestReasonCtr.text;
      } else {
        _currentPatient.srhContraceptionNoInterestReason = null;
      }

      //prep

      //only set reason for no interest in prep if
      //prep interest is not interested
      if (_currentPatient.srhPrepInterest == R21Interest.NoInterested()) {
        _currentPatient.srhPrepNoInterestReason =
            _srhPrepNoInterestReasonCtr.text;
      } else {
        _currentPatient.srhPrepNoInterestReason = null;
      }

      //only set selected facility if very interested in prep and schedule
      //facility is yes
      if (_currentPatient.srhPrepInterest == R21Interest.VeryInterested() &&
          _currentPatient.srhPrepFindScheduleFacilitySchedule ==
              R21YesNoUnsure.YES()) {
        _currentPatient.srhPrepFindScheduleFacilitySelected =
            _srhPrepFindScheduleFacilitySelectedVeryYesCtr.text;
      }

      //only set sschedule date if very interested in prep and schedule
      //facility is no and pick date is no
      if (_currentPatient.srhPrepInterest == R21Interest.VeryInterested() &&
          _currentPatient.srhPrepFindScheduleFacilitySchedule ==
              R21YesNoUnsure.NO() &&
          _currentPatient.srhPrepFindScheduleFacilityNoDate ==
              R21Week.Other()) {
        _currentPatient.srhPrepFindScheduleFacilityOther =
            _srhPrepFindScheduleFacilityOtherNotNowDateCtr.text;
      }

      //only set sschedule date if very interested in prep and schedule
      //facility is no and pick facility is yes
      if (_currentPatient.srhPrepInterest == R21Interest.VeryInterested() &&
          _currentPatient.srhPrepFindScheduleFacilitySchedule ==
              R21YesNoUnsure.NO() &&
          _currentPatient.srhPrepFindScheduleFacilityNoPick == R21YesNo.YES()) {
        _currentPatient.srhPrepFindScheduleFacilitySelected =
            _srhPrepFindScheduleFacilitySelectedVeryNotNowCtr.text;
      }

      //only set selected facility if maybe interested in prep and schedule
      //facility is yes
      if (_currentPatient.srhPrepInterest == R21Interest.MaybeInterested() &&
          _currentPatient.srhPrepFindScheduleFacilitySchedule ==
              R21YesNoUnsure.YES()) {
        _currentPatient.srhPrepFindScheduleFacilitySelected =
            _srhPrepFindScheduleFacilitySelectedMaybeYesCtr.text;
      }

      //only set specify date if maybe interested in prep and schedule
      //facility is no and selected date is other
      if (_currentPatient.srhPrepInterest == R21Interest.MaybeInterested() &&
          _currentPatient.srhPrepFindScheduleFacilitySchedule ==
              R21YesNoUnsure.NO() &&
          _currentPatient.srhPrepFindScheduleFacilityNoDate ==
              R21Week.Other()) {
        _currentPatient.srhPrepFindScheduleFacilityOther =
            _srhPrepFindScheduleFacilityOtherCtr.text;
      }

      //only set selected facilkity if maybe interested in prep and schedule
      //facility is no and pick facility is yes
      if (_currentPatient.srhPrepInterest == R21Interest.MaybeInterested() &&
          _currentPatient.srhPrepFindScheduleFacilitySchedule ==
              R21YesNoUnsure.NO() &&
          _currentPatient.srhPrepFindScheduleFacilityNoPick == R21YesNo.YES()) {
        _currentPatient.srhPrepFindScheduleFacilitySelected =
            _srhPrepFindScheduleFacilitySelectedMaybeNoYesCtr.text;
      }

      //Save process

      await _currentPatient.initializeRequiredActionsField();

      await DatabaseProvider().insertPatient(_currentPatient);
      await PatientBloc.instance.sinkNewPatientData(_currentPatient);
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
