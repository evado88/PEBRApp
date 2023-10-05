import 'dart:async';

import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/R21Residency.dart';
import 'package:pebrapp/database/beans/NoChatDownloadReason.dart';
import 'package:pebrapp/database/beans/R21PhoneNumberSecurity.dart';
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
import 'package:pebrapp/database/beans/R21PreferredContactMethod.dart';
import 'package:pebrapp/database/models/R21Appointment.dart';
import 'package:pebrapp/database/models/R21Event.dart';
import 'package:pebrapp/database/models/R21Followup.dart';
import 'package:pebrapp/database/models/R21MedicationRefill.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/utils/Utils.dart';

class Patient implements IExcelExportable, IJsonExportable {
  static final tableName = 'Patient';

  // column names

  //utility columsns
  static final colUtilityId = 'id'; // primary key
  static final colUtilityEnrollmentDate = 'enrollment_date';

  //Personal information
  static final colPersonalStudyNumber = 'study_number';
  static final colPersonalBirthday = 'birthday';

  //Messenger app
  static final colMessengerDownloaded = 'downloaded_messenger';
  static final colMessengerNoDownloadReason = 'no_download_messenger_reason';

  //Contact information
  static final colContactPhoneNumber = 'phone_number';
  static final colContactOwnPhone = 'own_phone';
  static final colContactResidency = 'residency';
  static final colContactPrefferedContactMethod = 'prefered_contact_method';
  static final colContactContactFrequency = 'contact_frequency';

  //Contraception/Prep History

//contraception
  static final colHistoryContraceptionUse = 'history_modern_contraception_use';

  static final colHistoryContraceptiontMaleCondom =
      'history_contraception_male_condom';

  static final colHistoryContraceptionFemaleCondom =
      'history_contraception_female_condom';

  static final colHistoryContraceptionImplant = 'history_contraception_implant';

  static final colHistoryContraceptionInjection =
      'history_contraception_injection';

  static final colHistoryContraceptionIUD = 'history_contraception_iud';

  static final colHistoryContraceptionIUS = 'history_contraception_ius';

  static final colHistoryContraceptionPills = 'history_contraception_pills';

  static final colHistoryContraceptionOther = 'history_contraception_other';

  static final colHistoryContraceptionOtherSpecify =
      'history_contraception_other_specify';

  static final colHistoryContraceptionSatisfaction =
      'history_contraception_satisfaction';

  static final colHistoryContraceptionSatisfactionReason =
      'history_contraception_satisfaction_reason';

  //hiv status
  static final colHistoryHIVKnowStatus = 'history_hiv_know_status';

  static final colHistoryHIVLastTest = 'history_hiv_last_test';

  static final colHistoryHIVUsedPrep = 'history_hiv_used_prep';

  static final colHistoryHIVPrepLastRefil = 'history_hiv_prep_last_refil';

  static final colHistoryHIVPrepLastRefilSource =
      'history_hiv_prep_last_refil_source';

  static final colHistoryHIVPrepLastRefilSourceSpecify =
      'history_hiv_prep_last_refil_source_specify';

  static final colHistoryHIVPrepProblems = 'history_hiv_prep_problems';

  static final colHistoryHIVPrepQuestions = 'history_hiv_prep_questions';

  static final colHistoryHIVTakingART = 'history_hiv_taking_art';

  static final colHistoryHIVLastRefil = 'history_hiv_last_refil';

  static final colHistoryHIVLastRefilSource = 'history_hiv_last_refil_source';

  static final colHistoryHIVLastRefilSourceSpecify =
      'history_hiv_last_refil_source_specify';

  static final colHistoryHIVARTProblems = 'history_hiv_art_problems';

  static final colHistoryHIVARTQuestions = 'history_hiv_art_questions';

  static final colHistoryHIVDesiredSupportRemindersAppointments =
      'history_hiv_desired_support_reminders_appointments';

  static final colHistoryHIVDesiredSupportRemindersCheckins =
      'history_hiv_desired_support_reminders_checkins';

  static final colHistoryHIVDesiredSupportRefilsAccompany =
      'history_hiv_desired_support_refil_accompany';

  static final colHistoryHIVDesiredSupportRefilsPAAccompany =
      'history_hiv_desired_support_refil_pn_accompany';

  static final colHistoryHIVDesiredSupportOther =
      'history_hiv_desired_support_other';

  static final colHistoryHIVDesiredSupportOtherSpecify =
      'history_hiv_desired_support_other_specify';

  static final colHistoryHIVPrepDesiredSupportRemindersAppointments =
      'history_hiv_prep_desired_support_reminders_appointments';

  static final colHistoryHIVPrepDesiredSupportRemindersAdherence =
      'history_hiv_prep_desired_support_reminders_adherence';

  static final colHistoryHIVPrepDesiredSupportRefilsPNAccompany =
      'history_hiv_prep_desired_support_refil_pn_accompany';

  static final colHistoryHIVPrepDesiredSupportPNHIVKit =
      'history_hiv_prep_desired_support_pn_hiv_kit';

  static final colHistoryHIVPrepDesiredSupportOther =
      'history_hiv_prep_desired_support_other';

  static final colHistoryHIVPrepDesiredSupportOtherSpecify =
      'history_hiv_prep_desired_support_other_specify';

//SRH Preferences
  //Contraception
  static final colSRHContraceptionInterest = 'srh_contraception_interest';

  static final colSRHContraceptionNoInterestReason =
      'srh_contraception_no_interest_reason';

  static final colSRHContraceptionInterestMaleCondom =
      'srh_contraception_interest_male_condom';

  static final colSRHContraceptionInterestFemaleCondom =
      'srh_contraception_interest_female_condom';

  static final colSRHContraceptionInterestImplant =
      'srh_contraception_interest_implant';

  static final colSRHContraceptionInterestInjection =
      'srh_contraception_interest_injection';

  static final colSRHContraceptionInterestIUD =
      'srh_contraception_interest_iud';

  static final colSRHContraceptionInterestIUS =
      'srh_contraception_interest_ius';

  static final colSRHContraceptionInterestPills =
      'srh_contraception_interest_pills';

  static final colSRHContraceptionInterestOther =
      'srh_contraception_interest_other';

  static final colSRHContraceptionInterestOtherSpecify =
      'srh_contraception_interest_other_specify';

  static final colSRHContraceptionMethodInMind =
      'srh_contraception_method_in_mind';

  static final colSRHContraceptionInformationMethods =
      'srh_contraception_information_methods';

  static final colSRHContraceptionFindScheduleFacility =
      'srh_contraception_find_schedule_facility';

  static final colSRHContraceptionFindScheduleFacilityYesDate =
      'srh_contraception_find_schedule_facility_yes_date';

  static final colSRHContraceptionFindScheduleFacilityYesPNAccompany =
      'srh_contraception_find_schedule_facility_yes_pn_accompany';

  static final colSRHContraceptionFindScheduleFacilityNoDate =
      'srh_contraception_find_schedule_facility_no_date';

  static final colSRHContraceptionFindScheduleFacilityNoPick =
      'srh_contraception_find_schedule_facility_no_pick';

  static final colSRHContraceptionFindScheduleFacilitySelected =
      'srh_contraception_find_schedule_facility_selected';

  static final colSRHContraceptionFindScheduleFacilityOther =
      'srh_contraception_find_schedule_facility_other';

  static final colSRHContraceptionInformationApp =
      'srh_contraception_information_app';

  static final colSRHContraceptionLearnMethods =
      'srh_contraception_learn_methods';

  //prep
  static final colSRHPrePInterest = 'srh_prep_interest';

  static final colSRHPrePInformationApp = 'srh_prep_information_app';

  static final colSRHPrePFindScheduleFacility =
      'srh_prep_find_schedule_facility';

  static final colSRHPrePFindScheduleFacilityYesDate =
      'srh_prep_find_schedule_facility_yes_date';

  static final colSRHPrePFindScheduleFacilityYesPNAccompany =
      'srh_prep_find_schedule_facility_yes_pn_accompany';

  static final colSRHPrePFindScheduleFacilityNoDate =
      'srh_prep_find_schedule_facility_no_date';

  static final colSRHPrePFindScheduleFacilityNoPick =
      'srh_prep_find_schedule_facility_no_pick';

  static final colSRHPrePFindScheduleFacilitySelected =
      'srh_prep_find_schedule_facility_selected';

  static final colSRHPrePFindScheduleFacilityOther =
      'srh_prep_find_schedule_facility_other';

  static final colSRHPrePInformationRead = 'srh_prep_information_read';

  //utility columsns
  DateTime utilityEnrollmentDate;

//Personal information
  String personalStudyNumber;
  DateTime personalBirthday;

  //Messenger app
  bool messengerDownloaded;
  NoChatDownloadReason messengerNoDownloadReason;

  //Contact information
  String personalPhoneNumber;
  R21PhoneNumberSecurity personalPhoneNumberAvailability;
  R21Residency personalResidency;
  R21PreferredContactMethod personalPreferredContactMethod;
  R21ContactFrequency personalContactFrequency;

  //Contraception/Prep History
  //contraception

  R21ContraceptionUse historyContraceptionUse;

  bool historyContraceptionMaleCondoms = false;

  bool historyContraceptionFemaleCondoms = false;

  bool historyContraceptionImplant = false;

  bool historyContraceptionInjection = false;

  bool historyContraceptionIUD = false;

  bool historyContraceptionIUS = false;

  bool historyContraceptionPills = false;

  bool historyContraceptionOther = false;

  String historyContraceptionOtherSpecify;

  R21Satisfaction historyContraceptionSatisfaction;

  //hiv status
  R21HIVStatus historyHIVStatus;

  R21YesNo historyHIVTakingART;

  DateTime historyHIVLastRefil;

  R21ProviderType historyHIVLastRefilSource;

  String historyHIVLastRefilSourceSpecify;

  String historyHIVARTProblems;

  String historyHIVARTQuestions;

  DateTime historyHIVLastTest;

  R21PrEP historyHIVUsedPrep;

  DateTime historyHIVPrepLastRefil;

  R21ProviderType historyHIVPrepLastRefilSource;

  String historyHIVPrepLastRefilSourceSpecify;

  String historyHIVPrepProblems;

  String historyHIVPrepQuestions;

  bool historyHIVDesiredSupportRemindersAppointments = false;

  bool historyHIVDesiredSupportRemindersCheckins = false;

  bool historyHIVDesiredSupportRefilsAccompany = false;

  bool historyHIVDesiredSupportRefilsPAAccompany = false;

  bool historyHIVDesiredSupportOther = false;

  String historyHIVDesiredSupportOtherSpecify;

  bool historyHIVPrepDesiredSupportReminderssAppointments = false;

  bool historyHIVPrepDesiredSupportRemindersAdherence = false;

  bool historyHIVPrepDesiredSupportRefilsPNAccompany = false;

  bool historyHIVPrepDesiredSupportPNHIVKit = false;

  bool historyHIVPrepDesiredSupportOther = false;

  String historyHIVPrepDesiredSupportOtherSpecify;

//SRH Preferences

  //Contraception
  R21Interest srhContraceptionInterest;

  String srhContraceptionNoInterestReason;

  bool srhContraceptionInterestMaleCondom = false;

  bool srhContraceptionInterestFemaleCondom = false;

  bool srhContraceptionInterestImplant = false;

  bool srhContraceptionInterestInjection = false;

  bool srhContraceptionInterestIUD = false;

  bool srhContraceptionInterestIUS = false;

  bool srhContraceptionInterestPills = false;

  bool srhContraceptionInterestOther = false;

  String srhContraceptionInterestOtherSpecify;

  R21YesNo srhContraceptionMethodInMind;

  R21YesNo srhContraceptionInformationMethods;

  R21YesNoUnsure srhContraceptionFindScheduleFacility;

  DateTime srhContraceptionFindScheduleFacilityYesDate;

  R21YesNo srhContraceptionFindScheduleFacilityYesPNAccompany;

  R21Week srhContraceptionFindScheduleFacilityNoDate;

  R21YesNo srhContraceptionFindScheduleFacilityNoPick;

  String srhContraceptionFindScheduleFacilitySelected;

  String srhContraceptionFindScheduleFacilityOther;

  R21YesNo srhContraceptionInformationApp;

  R21YesNo srhContraceptionLearnMethods;

//prep
  R21Interest srhPrePInterest;

  R21YesNo srhPrepLikeMoreInformation;

  R21YesNoUnsure srhPrePFindScheduleFacilitySchedule;

  DateTime srhPrepFindScheduleFacilityYesDate;

  R21YesNo srhPrePFindScheduleFacilityYesPNAccompany;

  R21Week srhPrePFindScheduleFacilityNoDate;

  R21YesNo srhPrePFindScheduleFacilityNoPick;

  String srhPrePFindScheduleFacilitySelected;

  String srhPrePFindScheduleFacilityOther;

  R21YesNo srhPrePInformationRead;

  List<R21Followup> followups = [];

  R21Followup latestFollowup;

  Set<RequiredAction> requiredActions = {};
  Set<RequiredAction> dueRequiredActionsAtInitialization = {};

  // Constructors
  // ------------

  Patient(
      {this.utilityEnrollmentDate,
      this.personalStudyNumber,
      this.personalBirthday,
      this.personalResidency,
      this.personalPreferredContactMethod,
      this.personalPhoneNumberAvailability,
      this.personalPhoneNumber,
      this.messengerDownloaded,
      this.messengerNoDownloadReason});

  Patient.fromMap(map) {
    this.personalStudyNumber = map[colPersonalStudyNumber];
  }

  // Other
  // -----

  toMap() {
    var map = Map<String, dynamic>();

    map[colPersonalBirthday] = personalBirthday.toIso8601String();
    // nullables:
    map[colPersonalBirthday] = personalPreferredContactMethod?.code;

    return map;
  }

  static const int _numberOfColumns = 26;

  /// Column names for the header row in the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [toExcelRow] method as well!
  static List<String> get excelHeaderRow {
    List<String> row = List<String>(_numberOfColumns);
    row[0] = 'DATE_CREATED';
    row[1] = 'TIME_CREATED';
    row[2] = 'DATE_ENROL';
    row[3] = 'TIME_ENROL';
    row[4] = 'IND_ID';
    row[5] = 'BIRTHDAY';
    row[6] = 'CONSENT';
    row[7] = 'CONSENT_NO';
    row[8] = 'CONSENT_OTHER';
    row[9] = 'GENDER';
    row[10] = 'SEX_ORIENT';
    row[11] = 'STICKER_ID';
    row[12] = 'VILLAGE';
    row[13] = 'CELL_GIVEN';
    row[14] = 'CELL';
    row[15] = 'VL_BASELINE_AVAILABLE';
    row[16] = 'ACTIVATED';
    row[17] = 'ELIGIBLE';
    row[18] = 'DUPLICATE';
    //R21
    row[19] = 'SUPPORT_TYPE';
    row[20] = 'CONTACT_FREQUENCY';
    row[21] = 'SRH_SERVICE_PREFFERED';
    row[22] = 'PREP';
    row[23] = 'CONTRACEPTION_METHOD';
    row[24] = 'PROVIDER_LOCATION';
    row[25] = 'PROVIDER_TYPE';

    return row;
  }

  /// Turns this object into a row that can be written to the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [excelHeaderRow] method as well!
  @override
  List<dynamic> toExcelRow() {
    List<dynamic> row = List<dynamic>(_numberOfColumns);
    //row[0] = formatDateIso(_createdDate);
    //row[1] = formatTimeIso(_createdDate);
    row[2] = formatDateIso(utilityEnrollmentDate);
    row[3] = formatTimeIso(utilityEnrollmentDate);
    row[4] = personalStudyNumber;
    row[5] = formatDateIso(personalBirthday);
    row[6] = messengerDownloaded;
    row[7] = messengerNoDownloadReason?.description;
    row[9] = personalResidency?.description;
    row[10] = personalPreferredContactMethod?.description;

    row[13] = personalPhoneNumberAvailability?.description;
    row[14] = personalPhoneNumber;

    //R21

    row[20] = personalContactFrequency?.description;

    return row;
  }

  @override
  Map<String, dynamic> toJson(String username) => {
        "\"username\"": "\"$username\"",
        "\"studyNo\"": "\"$personalStudyNumber\"",
        //"\"createDate\"": "\"${formatDateIso(_createdDate)}\"",
        "\"enrollDate\"": "\"${formatDateIso(utilityEnrollmentDate)}\"",
        "\"birthDate\"": "\"${formatDateIso(personalBirthday)}\"",
        "\"consentGiven\"": messengerDownloaded,
        "\"noConsentReason\"": messengerNoDownloadReason == null
            ? null
            : "\"${messengerNoDownloadReason.description}\"",
        "\"gender\"": personalResidency == null
            ? null
            : "\"${personalResidency.description}\"",
        "\"sexualOrientation\"": personalPreferredContactMethod == null
            ? null
            : "\"${personalPreferredContactMethod.description}\"",
        "\"phoneAvailability\"": personalPhoneNumberAvailability == null
            ? null
            : "\"${personalPhoneNumberAvailability.description}\"",
        "\"phoneNumber\"": "\"$personalPhoneNumber\"",
        "\"contactFrequency\"": personalContactFrequency == null
            ? null
            : "\"${personalContactFrequency.description}\"",
      };

  /// Initializes the field [events] with the latest data from the database.
  Future<void> initializeEventsField() async {
    // this.events = await DatabaseProvider().retrieveEventsForPatient(artNumber);
  }

  /// Initializes the field [followups] with the latest data from the database.
  Future<void> initializeFollowupsField() async {
    this.followups = await DatabaseProvider()
        .retrieveFollowupsForPatient(personalStudyNumber);
  }

  /// Initializes the field [events] with the latest data from the database.
  Future<void> initializeMedicationRefilsField() async {
    // this.medicationRefils =
    //   await DatabaseProvider().retrieveMedicationRefilsForPatient(artNumber);
  }

  /// Initializes the field [latestPreferenceAssessment] with the latest data from the database.
  Future<void> initializePreferenceAssessmentField() async {
    PreferenceAssessment pa = await DatabaseProvider()
        .retrieveLatestPreferenceAssessmentForPatient(personalStudyNumber);
    //this.latestPreferenceAssessment = pa;
  }

  Future<void> initializeRecentFields() async {
    R21Followup followup = await DatabaseProvider()
        .retrieveLatestFollowupForPatient(personalStudyNumber);
    this.latestFollowup = followup;
  }

  /// Initializes the field [requiredActions] with the latest data from the database.
  ///
  /// Before calling this, [initializeARTRefillField],
  /// [initializePreferenceAssessmentField], [initializeViralLoadsField] should
  /// be called, otherwise actions are required because the fields are not
  /// initialized (null).
  Future<void> initializeRequiredActionsField() async {
    // get required actions stored in database
    final Set<RequiredAction> actions = await DatabaseProvider()
        .retrieveRequiredActionsForPatient(personalStudyNumber);
    final DateTime now = DateTime.now();
    // calculate if ART refill is required

    /*final DateTime dueDateART =
        latestDoneARTRefill?.nextRefillDate ?? enrollmentDate;
    if (now.isAfter(dueDateART)) {
      RequiredAction artRefillRequired = RequiredAction(
          artNumber, RequiredActionType.REFILL_REQUIRED, dueDateART);
      actions.add(artRefillRequired);
    }*/
    // calculate if preference assessment is required
    final DateTime dueDatePA = utilityEnrollmentDate;
    if (now.isAfter(dueDatePA)) {
      RequiredAction assessmentRequired = RequiredAction(personalStudyNumber,
          RequiredActionType.ASSESSMENT_REQUIRED, dueDatePA);
      actions.add(assessmentRequired);
    }
    this.requiredActions = actions;
  }

  R21Followup get mostRecentFollowup {
    R21Followup mostRecent;
    for (R21Followup ev in followups) {
      if (mostRecent == null ||
          !ev.createdDate.isBefore(mostRecent.createdDate)) {
        mostRecent = ev;
      }
    }
    return mostRecent;
  }

  /// Sets fields to null if they are not used. E.g. sets [personalPhoneNumber] to null
  /// if [personalPhoneNumberAvailability] is not YES.
  void checkLogicAndResetUnusedFields() {
    if (!this.historyContraceptionIUD) {
      this.personalResidency = null;
      this.personalPreferredContactMethod = null;
      this.personalPhoneNumberAvailability = null;
      this.personalPhoneNumber = null;
      this.messengerDownloaded = null;
      this.messengerNoDownloadReason = null;
    }
    //R21
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  //set createdDate(DateTime date) => _createdDate = date;

  // ignore: unnecessary_getters_setters
  // DateTime get createdDate => _createdDate;

  /// Calculates which required actions for this patient are due based on
  /// today's date and the required actions' due date.
  Set<RequiredAction> calculateDueRequiredActions({UserData userData}) {
    final DateTime now = DateTime.now();
    Set<RequiredAction> visibleRequiredActions = {};
    visibleRequiredActions.addAll([]);
    visibleRequiredActions
        .removeWhere((RequiredAction a) => a.dueDate.isAfter(now));
    return visibleRequiredActions;
  }
}
