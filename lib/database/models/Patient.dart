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

  static final colHistoryHIVART = 'history_hiv_art';

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
  static final colSRHCPrePInterest = 'srh_prep_interest';

  static final colSRHCPrePInformationApp = 'srh_prep_information_app';

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

  String historyHIVARTProblems;

  String historyHIVARTQuestions;

  DateTime historyHIVLastTest;

  R21PrEP historyHIVUsedPrep;

  bool historyHIVDesiredSupportRemindersAppointments = false;

  bool historyHIVDesiredSupportRemindersCheckins = false;

  bool historyHIVDesiredSupportRefilsAccompany = false;

  bool historyHIVDesiredSupportRefilsPAAccompany = false;

  bool historyHIVDesiredSupportOther = false;

  String historyHIVDesiredSupportOtherSpecify;

//SRH Preferences

  //Contraception
  R21Interest srhContraceptionInterest;


  bool isEligible;
  String stickerNumber;
  bool isVLBaselineAvailable;

  String village;

  String noConsentReasonOther;
  bool isActivated;
  bool isDuplicate;

  //R21 fields
  R21SupportType supportType;

  R21SRHServicePreferred srhServicePreffered;
  R21PrEP prep;
  R21ContraceptionMethod contraceptionMethod;
  String providerLocation;
  R21ProviderType providerType;

  // The following fields are other database tables, to make access to related
  // database objects easier.
  // Will be null until the corresponding initialize... methods were called.
  List<ViralLoad> viralLoads = [];

  List<R21Appointment> appointments = [];
  List<R21Followup> followups = [];

  ARTRefill latestARTRefill; // stores the latest ART refill (done or not done)
  ARTRefill latestDoneARTRefill; // stores the latest ART refill that was done

  R21MedicationRefill latestMedicationRefil;
  R21Appointment latestAppointment;
  R21Event latestEvent;
  R21Followup latestFollowup;

  Set<RequiredAction> requiredActions = {};
  Set<RequiredAction> dueRequiredActionsAtInitialization = {};

  DateTime lastARTRefilDate;

  R21ProviderType ARTRefilCollectionClinic;

  DateTime lastPrepRefilDate;

  R21ProviderType prepRefilCollectionClinic;

  bool desiredSupportPrepRefilReminders = false;

  bool desiredSupportPrepAdherenceReminders = false;

  bool desiredSupportPrepPeerRefil = false;

  bool desiredSupportPrepPeerHIVSelfTest = false;

  bool desiredSupportPrepOther = false;



  R21Interest prepInterest;

  R21YesNo hasContraceptiveMethodInMind;

  bool interestContraceptionOther = false;

  bool interestContraceptionPills = false;

  bool interestContraceptionIUS = false;

  bool interestContraceptionIUD = false;

  bool interestContraceptionInjection = false;

  bool interestContraceptionImplant = false;

  bool interestContraceptionFemaleCondoms = false;

  bool interestContraceptionMaleCondoms = false;

  R21YesNo interestContraceptionLikeMoreInfo;

  R21YesNoUnsure interestContraceptionLikeFindFacilitySchedule;

  R21YesNo interestContraceptionLikePNAAccompany;

  R21Week interestContraceptionNotNowDate;

  R21YesNo interestContraceptionNotNowPickFacility;

  R21YesNo interestContraceptionLikeInformationOnApp;

  R21YesNo interestContraceptionLikeInformationOnMethods;

  bool contraceptionMethodOther = false;

  R21YesNo interestContraceptionNotLikeInformationOnMethods;

  R21YesNo interestContraceptionNotLikeInformationOnApp;

  R21YesNo interestPrepVeryLikeInformation;

  R21YesNoUnsure interestPrepVeryLikeFindFacilitySchedule;

  R21YesNo interestPrepVeryLikePNAAccompany;

  R21Week interestPrepNotNowDate;

  R21YesNo interestPrepVeryNotNowPickFacility;

  R21YesNo interestPrepVeryLikeInformationOnApp;

  R21YesNo interestPrepMaybeLikeInformation;

  R21YesNoUnsure interestPrepMaybeLikeFindFacilitySchedule;

  R21YesNo interestPrepMaybeLikePNAAccompany;

  R21Week interestPrepMaybeNotNowDate;

  var interestPrepMaybeNotNowPickFacility;

  R21YesNo interestPrepMaybeLikeInformationOnApp;

  R21YesNo interestPrepNotLikeInformation;

  R21YesNo interestPrepNotLikeInformationOnApp;

  // Constructors
  // ------------

  Patient(
      {this.utilityEnrollmentDate,
      this.personalStudyNumber,
      this.stickerNumber,
      this.personalBirthday,
      this.isEligible,
      this.isVLBaselineAvailable,
      this.personalResidency,
      this.personalPreferredContactMethod,
      this.village,
      this.personalPhoneNumberAvailability,
      this.personalPhoneNumber,
      this.messengerDownloaded,
      this.messengerNoDownloadReason,
      this.noConsentReasonOther,
      this.isActivated,
      this.isDuplicate,
      this.supportType, //R21
      this.personalContactFrequency,
      this.srhServicePreffered,
      this.prep,
      this.contraceptionMethod,
      this.providerLocation,
      this.providerType});

  Patient.fromMap(map) {
    this.personalStudyNumber = map[colPersonalStudyNumber];

    if (map[colPersonalBirthday] != null) {
      this.isActivated = map[colPersonalBirthday] == 1;
    }

    //R21
    this.supportType = R21SupportType.fromCode(map[colPersonalBirthday]);
  }

  // Other
  // -----

  toMap() {
    var map = Map<String, dynamic>();

    map[colPersonalBirthday] = personalBirthday.toIso8601String();
    // nullables:
    map[colPersonalBirthday] = isVLBaselineAvailable;
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
    row[8] = noConsentReasonOther;
    row[9] = personalResidency?.description;
    row[10] = personalPreferredContactMethod?.description;
    row[11] = stickerNumber;
    row[12] = village;
    row[13] = personalPhoneNumberAvailability?.description;
    row[14] = personalPhoneNumber;
    row[15] = isVLBaselineAvailable;
    row[16] = isActivated;
    row[17] = isEligible;
    row[18] = isDuplicate;
    //R21
    row[19] = supportType?.description;
    row[20] = personalContactFrequency?.description;
    row[21] = srhServicePreffered?.description;
    row[22] = prep?.description;
    row[23] = contraceptionMethod?.description;
    row[24] = providerLocation;
    row[25] = providerType?.description;
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
        "\"noConsentReasonOther\"": "\"$noConsentReasonOther\"",
        "\"gender\"": personalResidency == null
            ? null
            : "\"${personalResidency.description}\"",
        "\"sexualOrientation\"": personalPreferredContactMethod == null
            ? null
            : "\"${personalPreferredContactMethod.description}\"",
        "\"stickerNumber\"": "\"$stickerNumber\"",
        "\"village\"": "\"$village\"",
        "\"phoneAvailability\"": personalPhoneNumberAvailability == null
            ? null
            : "\"${personalPhoneNumberAvailability.description}\"",
        "\"phoneNumber\"": "\"$personalPhoneNumber\"",
        "\"isVLBaselineAvailable\"": isVLBaselineAvailable,
        "\"isActivated\"": isActivated,
        "\"isEligible\"": isEligible,
        "\"isDuplicate\"": isDuplicate,
        "\"supportType\"":
            supportType == null ? null : "\"${supportType.description}\"",
        "\"contactFrequency\"": personalContactFrequency == null
            ? null
            : "\"${personalContactFrequency.description}\"",
        "\"srhServicePreffered\"": srhServicePreffered == null
            ? null
            : "\"${srhServicePreffered.description}\"",
        "\"prep\"": prep == null ? null : "\"${prep.description}\"",
        "\"contraceptionMethod\"": contraceptionMethod == null
            ? null
            : "\"${contraceptionMethod.description}\"",
        "\"providerLocation\"": "\"$providerLocation\"",
        "\"providerType\"":
            providerType == null ? null : "\"${providerType.description}\"",
      };

  /// Initializes the field [viralLoads] with the latest data from the database.
  Future<void> initializeViralLoadsField() async {
    this.viralLoads = await DatabaseProvider()
        .retrieveViralLoadsForPatient(personalStudyNumber);
  }

  /// Initializes the field [appointments] with the latest data from the database.
  Future<void> initializeAppointmentsField() async {
    this.appointments = await DatabaseProvider()
        .retrieveAppointmentsForPatient(personalStudyNumber);
  }

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

  /// Initializes the fields [latestARTRefill] and [latestDoneARTRefill] with
  /// the latest data from the database.
  Future<void> initializeARTRefillField() async {
    ARTRefill artRefill = await DatabaseProvider()
        .retrieveLatestARTRefillForPatient(personalStudyNumber);
    this.latestARTRefill = artRefill;
    ARTRefill doneARTRefill = await DatabaseProvider()
        .retrieveLatestDoneARTRefillForPatient(personalStudyNumber);
    this.latestDoneARTRefill = doneARTRefill;
  }

  Future<void> initializeRecentFields() async {
    R21MedicationRefill refill = await DatabaseProvider()
        .retrieveLatestMedicationRefillForPatient(personalStudyNumber);
    this.latestMedicationRefil = refill;

    R21Appointment appointment = await DatabaseProvider()
        .retrieveLatestAppointmentForPatient(personalStudyNumber);
    this.latestAppointment = appointment;

    R21Followup followup = await DatabaseProvider()
        .retrieveLatestFollowupForPatient(personalStudyNumber);
    this.latestFollowup = followup;

    R21Event event = await DatabaseProvider()
        .retrieveLatestEventForPatient(personalStudyNumber);
    this.latestEvent = event;
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
    this.dueRequiredActionsAtInitialization = calculateDueRequiredActions();
  }

  /// Returns the viral load with the latest blood draw date.
  ///
  /// Might return null if no viral loads are available for this patient or the
  /// viral load fields have not been initialized by calling
  /// [initializeViralLoadsField].
  ViralLoad get mostRecentViralLoad {
    ViralLoad mostRecent;
    for (ViralLoad vl in viralLoads) {
      if (mostRecent == null ||
          !vl.createdDate.isBefore(mostRecent.createdDate)) {
        mostRecent = vl;
      }
    }
    return mostRecent;
  }

  R21MedicationRefill get mostRecentMedicationRefil {
    R21MedicationRefill mostRecent;
    /*
    for (R21MedicationRefill vl in medicationRefils) {
      if (mostRecent == null ||
          !vl.createdDate.isBefore(mostRecent.createdDate)) {
        mostRecent = vl;
      }
    }*/
    return mostRecent;
  }

  R21Appointment get mostRecentAppointment {
    R21Appointment mostRecent;
    for (R21Appointment ev in appointments) {
      if (mostRecent == null ||
          !ev.createdDate.isBefore(mostRecent.createdDate)) {
        mostRecent = ev;
      }
    }
    return mostRecent;
  }

  R21Event get mostRecentEvent {
    R21Event mostRecent;
    /* for (R21Event ev in events) {
      if (mostRecent == null ||
          !ev.createdDate.isBefore(mostRecent.createdDate)) {
        mostRecent = ev;
      }
    }*/
    return mostRecent;
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
    if (!this.isEligible) {
      this.personalResidency = null;
      this.personalPreferredContactMethod = null;
      this.village = null;
      this.personalPhoneNumberAvailability = null;
      this.personalPhoneNumber = null;
      this.messengerDownloaded = null;
      this.messengerNoDownloadReason = null;
      this.noConsentReasonOther = null;
      this.isActivated = null;
      this.isDuplicate = null;

      //R21
      this.supportType = null;
      this.personalContactFrequency = null;
      this.srhServicePreffered = null;
      this.prep = null;
      this.contraceptionMethod = null;
      this.providerLocation = null;
      this.providerType = null;
    }
    if (this.messengerDownloaded != null && !this.messengerDownloaded) {
      this.personalResidency = null;
      this.personalPreferredContactMethod = null;
      this.village = null;
      this.personalPhoneNumberAvailability = null;
      this.personalPhoneNumber = null;
      this.isActivated = null;

      //R21
      this.supportType = null;
      this.personalContactFrequency = null;
      this.srhServicePreffered = null;
      this.prep = null;
      this.contraceptionMethod = null;
      this.providerLocation = null;
      this.providerType = null;

      if (this.messengerNoDownloadReason != NoChatDownloadReason.OTHER()) {
        this.noConsentReasonOther = null;
      }
    }
    if (this.personalPhoneNumberAvailability != null &&
        this.personalPhoneNumberAvailability != R21PhoneNumberSecurity.YES()) {
      this.personalPhoneNumber = null;
    }
    if (this.messengerDownloaded != null && this.messengerDownloaded) {
      this.messengerNoDownloadReason = null;
      this.noConsentReasonOther = null;
    }
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
    visibleRequiredActions.addAll(requiredActions);
    visibleRequiredActions
        .removeWhere((RequiredAction a) => a.dueDate.isAfter(now));
    return visibleRequiredActions;
  }

  void addViralLoads(List<ViralLoad> newViralLoads) {
    for (ViralLoad vl in newViralLoads) {
      if (!viralLoads.contains(vl)) {
        viralLoads.add(vl);
      }
    }
    sortViralLoads(viralLoads);
  }

  void addEvents(List<R21Event> newEvents) {
    /* for (R21Event ev in newEvents) {
      if (!events.contains(ev)) {
        events.add(ev);
      }
    }*/
  }

  void addMedicationRefils(List<R21MedicationRefill> newRefils) {
    /* for (R21MedicationRefill ev in newRefils) {
      if (!medicationRefils.contains(ev)) {
        medicationRefils.add(ev);
      }
    }*/
  }
}
