import 'dart:async';

import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/R21Residency.dart';
import 'package:pebrapp/database/beans/NoChatDownloadReason.dart';
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
import 'package:pebrapp/database/models/R21Followup.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
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
  static final colMessengerNoDownloadReasonSpecify =
      'no_download_messenger_reason_specify'; 

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

  static final colHistoryContraceptionStopReason =
      'history_contraception_stop_reason'; 

  static final colHistoryContraceptionNoUseReason =
      'history_contraception_no_use_reason'; 

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

  static final colHistoryHIVPrepStopReason = 'history_hiv_prep_stop_reason';

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
  static final colSRHPrepInterest = 'srh_prep_interest';

  static final colSRHPrepNoInterestReason = 'srh_prep_no_interest_reason'; //new

  static final colSRHPrepInformationApp = 'srh_prep_information_app';

  static final colSRHPrepFindScheduleFacility =
      'srh_prep_find_schedule_facility';

  static final colSRHPrepFindScheduleFacilityYesDate =
      'srh_prep_find_schedule_facility_yes_date';

  static final colSRHPrepFindScheduleFacilityYesPNAccompany =
      'srh_prep_find_schedule_facility_yes_pn_accompany';

  static final colSRHPrepFindScheduleFacilityNoDate =
      'srh_prep_find_schedule_facility_no_date';

  static final colSRHPrepFindScheduleFacilityNoPick =
      'srh_prep_find_schedule_facility_no_pick';

  static final colSRHPrepFindScheduleFacilitySelected =
      'srh_prep_find_schedule_facility_selected';

  static final colSRHPrepFindScheduleFacilityOther =
      'srh_prep_find_schedule_facility_other';

  static final colSRHPrepLikeMoreInformation = 'srh_prep_information_read';

  //utility columsns
  DateTime utilityEnrollmentDate;

//Personal information
  String personalStudyNumber;
  DateTime personalBirthday;

  //Messenger app
  bool messengerDownloaded;
  NoChatDownloadReason messengerNoDownloadReason;
  String messengerNoDownloadReasonSpecify;

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

  String historyContraceptionSatisfactionReason;

  String historyContraceptionStopReason;

  String historyContraceptionNoUseReason;

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

  String historyHIVPrepStopReason;

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
  R21Interest srhPrepInterest;

  String srhPrepNoInterestReason;

  R21YesNo srhPrepLikeMoreInformation;

  R21YesNoUnsure srhPrepFindScheduleFacilitySchedule;

  DateTime srhPrepFindScheduleFacilityYesDate;

  R21YesNo srhPrepFindScheduleFacilityYesPNAccompany;

  R21Week srhPrepFindScheduleFacilityNoDate;

  R21YesNo srhPrepFindScheduleFacilityNoPick;

  String srhPrepFindScheduleFacilitySelected;

  String srhPrepFindScheduleFacilityOther;

  R21YesNo srhPrepInformationApp;

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
      this.personalPhoneNumber});

  Patient.fromMap(map) {
    //personal info

    this.personalStudyNumber = map[colPersonalStudyNumber];

    this.personalBirthday = DateTime.parse(map[colPersonalBirthday]);

    this.messengerDownloaded = map[colMessengerDownloaded] == 1;
    this.messengerNoDownloadReason = map[colMessengerNoDownloadReason] == null
        ? null
        : NoChatDownloadReason.fromCode(map[colMessengerNoDownloadReason]);

    this.messengerNoDownloadReasonSpecify =
        map[colMessengerNoDownloadReasonSpecify];

    this.personalPhoneNumber = map[colContactPhoneNumber];

    this.personalPhoneNumberAvailability =
        R21PhoneNumberSecurity.fromCode(map[colContactOwnPhone]);

    this.personalResidency = R21Residency.fromCode(map[colContactResidency]);

    this.personalPreferredContactMethod = R21PreferredContactMethod.fromCode(
        map[colContactPrefferedContactMethod]);

    this.personalContactFrequency =
        R21ContactFrequency.fromCode(map[colContactContactFrequency]);

    //history contraception
    this.historyContraceptionUse =
        R21ContraceptionUse.fromCode(map[colHistoryContraceptionUse]);

    this.historyContraceptionMaleCondoms =
        map[colHistoryContraceptiontMaleCondom] == 1;

    this.historyContraceptionFemaleCondoms =
        map[colHistoryContraceptionFemaleCondom] == 1;

    this.historyContraceptionImplant = map[colHistoryContraceptionImplant] == 1;

    this.historyContraceptionInjection =
        map[colHistoryContraceptionInjection] == 1;

    this.historyContraceptionIUD = map[colHistoryContraceptionIUD] == 1;

    this.historyContraceptionIUS = map[colHistoryContraceptionIUS] == 1;

    this.historyContraceptionPills = map[colHistoryContraceptionPills] == 1;

    this.historyContraceptionOther = map[colHistoryContraceptionOther] == 1;

    this.historyContraceptionSatisfaction =
        map[colHistoryContraceptionSatisfaction] ??
            R21Satisfaction.fromCode(map[colHistoryContraceptionSatisfaction]);

    this.historyContraceptionSatisfactionReason =
        map[colHistoryContraceptionSatisfactionReason];

    this.historyContraceptionStopReason =
        map[colHistoryContraceptionStopReason];

    this.historyContraceptionNoUseReason =
        map[colHistoryContraceptionNoUseReason];

    //srh hiv
    this.historyHIVStatus = R21HIVStatus.fromCode(map[colHistoryHIVKnowStatus]);

    String lastTest = map[colHistoryHIVLastTest];

    this.historyHIVLastTest =
        lastTest == null ? null : DateTime.parse(lastTest);

    this.historyHIVUsedPrep = map[colHistoryHIVUsedPrep] == null
        ? null
        : R21PrEP.fromCode(map[colHistoryHIVUsedPrep]);

    this.historyHIVPrepLastRefil = map[colHistoryHIVPrepLastRefil] == null
        ? null
        : DateTime.parse(map[colHistoryHIVPrepLastRefil]);

    this.historyHIVPrepLastRefilSource =
        map[colHistoryHIVPrepLastRefilSource] == null
            ? null
            : R21ProviderType.fromCode(map[colHistoryHIVPrepLastRefilSource]);

    this.historyHIVPrepLastRefilSourceSpecify =
        map[colHistoryHIVPrepLastRefilSourceSpecify];

    this.historyHIVPrepProblems = map[colHistoryHIVPrepProblems];

    this.historyHIVPrepQuestions = map[colHistoryHIVPrepQuestions];

    this.historyHIVTakingART = map[colHistoryHIVTakingART] == null
        ? null
        : R21YesNo.fromCode(map[colHistoryHIVTakingART]);

    this.historyHIVLastRefil = map[colHistoryHIVLastRefil] == null
        ? null
        : DateTime.parse(map[colHistoryHIVLastRefil]);

    this.historyHIVLastRefilSource = map[colHistoryHIVLastRefilSource] == null
        ? null
        : R21ProviderType.fromCode(map[colHistoryHIVLastRefilSource]);

    this.historyHIVLastRefilSourceSpecify =
        map[historyHIVLastRefilSourceSpecify];

    this.historyHIVARTProblems = map[colHistoryHIVARTProblems];

    this.historyHIVARTQuestions = map[colHistoryHIVARTQuestions];

    this.historyHIVDesiredSupportRemindersAppointments =
        map[colHistoryHIVDesiredSupportRemindersAppointments] == 1;

    this.historyHIVDesiredSupportRemindersCheckins =
        map[colHistoryHIVDesiredSupportRemindersCheckins] == 1;

    this.historyHIVDesiredSupportRefilsAccompany =
        map[colHistoryHIVDesiredSupportRefilsAccompany] == 1;

    this.historyHIVDesiredSupportRefilsPAAccompany =
        map[colHistoryHIVDesiredSupportRefilsPAAccompany] == 1;

    this.historyHIVDesiredSupportOther =
        map[colHistoryHIVDesiredSupportOther] == 1;

    this.historyHIVDesiredSupportOtherSpecify =
        map[colHistoryHIVDesiredSupportOtherSpecify];

    this.historyHIVPrepDesiredSupportReminderssAppointments =
        map[colHistoryHIVPrepDesiredSupportRemindersAppointments] == 1;

    this.historyHIVPrepDesiredSupportRemindersAdherence =
        map[colHistoryHIVPrepDesiredSupportRemindersAdherence] == 1;

    this.historyHIVPrepDesiredSupportRefilsPNAccompany =
        map[colHistoryHIVPrepDesiredSupportRefilsPNAccompany] == 1;

    this.historyHIVPrepDesiredSupportPNHIVKit =
        map[colHistoryHIVPrepDesiredSupportPNHIVKit] == 1;

    this.historyHIVPrepDesiredSupportOther =
        map[colHistoryHIVPrepDesiredSupportOther] == 1;

    this.historyHIVPrepDesiredSupportOtherSpecify =
        map[colHistoryHIVPrepDesiredSupportOtherSpecify];

    this.historyHIVPrepStopReason = map[colHistoryHIVPrepStopReason];

    //srh contraception
    this.srhContraceptionInterest =
        R21Interest.fromCode(map[colSRHContraceptionInterest]);

    this.srhContraceptionNoInterestReason =
        map[colSRHContraceptionNoInterestReason];

    this.srhContraceptionInterestMaleCondom =
        map[colSRHContraceptionInterestMaleCondom] == 1;

    this.srhContraceptionInterestFemaleCondom =
        map[colSRHContraceptionInterestFemaleCondom] == 1;

    this.srhContraceptionInterestImplant =
        map[colSRHContraceptionInterestImplant] == 1;

    this.srhContraceptionInterestMaleCondom =
        map[colSRHContraceptionInterestMaleCondom] == 1;

    this.srhContraceptionInterestInjection =
        map[colSRHContraceptionInterestInjection] == 1;

    this.srhContraceptionInterestIUD = map[colSRHContraceptionInterestIUD] == 1;

    this.srhContraceptionInterestIUS = map[colSRHContraceptionInterestIUS] == 1;

    this.srhContraceptionInterestPills =
        map[colSRHContraceptionInterestPills] == 1;

    this.srhContraceptionInterestOther =
        map[colSRHContraceptionInterestOther] == 1;

    this.srhContraceptionInterestOtherSpecify =
        map[colSRHContraceptionInterestOtherSpecify];

    this.srhContraceptionMethodInMind =
        map[colSRHContraceptionMethodInMind] == null
            ? null
            : R21YesNo.fromCode(map[colSRHContraceptionMethodInMind]);

    this.srhContraceptionInformationMethods =
        map[colSRHContraceptionInformationMethods] == null
            ? null
            : R21YesNo.fromCode(map[colSRHContraceptionInformationMethods]);

    this.srhContraceptionFindScheduleFacility =
        map[colSRHContraceptionFindScheduleFacility] == null
            ? null
            : R21YesNoUnsure.fromCode(
                map[colSRHContraceptionFindScheduleFacility]);

    this.srhContraceptionFindScheduleFacilityYesDate =
        map[colSRHContraceptionFindScheduleFacilityYesDate] == null
            ? null
            : DateTime.parse(
                map[colSRHContraceptionFindScheduleFacilityYesDate]);

    this.srhContraceptionFindScheduleFacilityYesPNAccompany =
        map[colSRHContraceptionFindScheduleFacilityYesPNAccompany] == null
            ? null
            : R21YesNo.fromCode(
                map[colSRHContraceptionFindScheduleFacilityYesPNAccompany]);

    this.srhContraceptionFindScheduleFacilityNoDate =
        map[colSRHContraceptionFindScheduleFacilityNoDate] == null
            ? null
            : R21Week.fromCode(
                map[colSRHContraceptionFindScheduleFacilityNoDate]);

    this.srhContraceptionFindScheduleFacilityNoPick =
        map[colSRHContraceptionFindScheduleFacilityNoPick] == null
            ? null
            : R21YesNo.fromCode(
                map[colSRHContraceptionFindScheduleFacilityNoPick]);

    this.srhContraceptionFindScheduleFacilitySelected =
        map[colSRHContraceptionFindScheduleFacilitySelected];

    this.srhContraceptionFindScheduleFacilityOther =
        map[colSRHContraceptionFindScheduleFacilityOther];

    this.srhContraceptionInformationApp =
        map[colSRHContraceptionInformationApp] == null
            ? null
            : R21YesNo.fromCode(map[colSRHContraceptionInformationApp]);

    this.srhContraceptionLearnMethods =
        map[colSRHContraceptionLearnMethods] == null
            ? null
            : R21YesNo.fromCode(map[colSRHContraceptionLearnMethods]);

    //srh prep
    this.srhPrepInterest = R21Interest.fromCode(map[colSRHPrepInterest]);

    this.srhPrepNoInterestReason =
        map[colSRHPrepNoInterestReason];

    this.srhPrepInformationApp = map[colSRHPrepInformationApp] == null
        ? null
        : R21YesNo.fromCode(map[colSRHPrepInformationApp]);

    this.srhPrepFindScheduleFacilitySchedule =
        map[colSRHPrepFindScheduleFacility] == null
            ? null
            : R21YesNoUnsure.fromCode(map[colSRHPrepFindScheduleFacility]);

    this.srhPrepFindScheduleFacilityYesDate =
        map[colSRHPrepFindScheduleFacilityYesDate] == null
            ? null
            : DateTime.parse(map[colSRHPrepFindScheduleFacilityYesDate]);

    this.srhPrepFindScheduleFacilityYesPNAccompany =
        map[colSRHPrepFindScheduleFacilityYesPNAccompany] == null
            ? null
            : R21YesNo.fromCode(
                map[colSRHPrepFindScheduleFacilityYesPNAccompany]);

    this.srhPrepFindScheduleFacilityNoDate =
        map[colSRHPrepFindScheduleFacilityNoDate] == null
            ? null
            : R21Week.fromCode(map[colSRHPrepFindScheduleFacilityNoDate]);

    this.srhPrepFindScheduleFacilityNoPick =
        map[colSRHPrepFindScheduleFacilityNoPick] == null
            ? null
            : R21YesNo.fromCode(map[colSRHPrepFindScheduleFacilityNoPick]);

    this.srhPrepFindScheduleFacilitySelected =
        map[colSRHPrepFindScheduleFacilitySelected];

    this.srhPrepFindScheduleFacilityOther =
        map[colSRHPrepFindScheduleFacilityOther];

    this.srhPrepLikeMoreInformation = map[colSRHPrepLikeMoreInformation] == null
        ? null
        : R21YesNo.fromCode(map[colSRHPrepLikeMoreInformation]);
  }

  // -----

  toMap() {
    var map = Map<String, dynamic>();

//utility
    map[colUtilityEnrollmentDate] = utilityEnrollmentDate.toIso8601String();

//personal infor
    map[colPersonalStudyNumber] = personalStudyNumber;
    map[colPersonalBirthday] = personalBirthday.toIso8601String();

    map[colMessengerDownloaded] = messengerDownloaded ? 1 : 0;
    map[colMessengerNoDownloadReason] = messengerNoDownloadReason?.code;

    map[colMessengerNoDownloadReasonSpecify] = messengerNoDownloadReasonSpecify;

    map[colContactPhoneNumber] = personalPhoneNumber;
    map[colContactOwnPhone] = personalPhoneNumberAvailability.code;
    map[colContactResidency] = personalResidency.code;
    map[colContactPrefferedContactMethod] = personalPreferredContactMethod.code;
    map[colContactContactFrequency] = personalContactFrequency.code;

//history contraception
    map[colHistoryContraceptionUse] = this.historyContraceptionUse.code;

    map[colHistoryContraceptiontMaleCondom] =
        this.historyContraceptionMaleCondoms ? 1 : 0;

    map[colHistoryContraceptionFemaleCondom] =
        this.historyContraceptionFemaleCondoms ? 1 : 0;

    map[colHistoryContraceptionImplant] =
        this.historyContraceptionImplant ? 1 : 0;

    map[colHistoryContraceptionInjection] =
        this.historyContraceptionInjection ? 1 : 0;

    map[colHistoryContraceptionIUD] = this.historyContraceptionIUD ? 1 : 0;

    map[colHistoryContraceptionIUS] = this.historyContraceptionIUS ? 1 : 0;

    map[colHistoryContraceptionPills] = this.historyContraceptionPills ? 1 : 0;

    map[colHistoryContraceptionOther] = this.historyContraceptionOther ? 1 : 0;

    map[colHistoryContraceptionSatisfaction] =
        this.historyContraceptionSatisfaction?.code;

    map[colHistoryContraceptionSatisfactionReason] =
        this.historyContraceptionSatisfactionReason;

    map[colHistoryContraceptionStopReason] =
        this.historyContraceptionStopReason;

    map[colHistoryContraceptionNoUseReason] =
        this.historyContraceptionNoUseReason;

    //history hiv
    map[colHistoryHIVKnowStatus] = this.historyHIVStatus.code;

    map[colHistoryHIVLastTest] = this.historyHIVLastTest.toIso8601String();

    map[colHistoryHIVUsedPrep] = this.historyHIVUsedPrep?.code;

    map[colHistoryHIVPrepLastRefil] =
        this.historyHIVPrepLastRefil?.toIso8601String();

    map[colHistoryHIVPrepLastRefilSource] =
        this.historyHIVPrepLastRefilSource?.code;

    map[colHistoryHIVPrepLastRefilSourceSpecify] =
        this.historyHIVPrepLastRefilSourceSpecify;

    map[colHistoryHIVPrepProblems] = this.historyHIVPrepProblems;

    map[colHistoryHIVPrepQuestions] = this.historyHIVPrepQuestions;

    map[colHistoryHIVTakingART] = this.historyHIVTakingART?.code;

    map[colHistoryHIVLastRefil] = this.historyHIVLastRefil?.toIso8601String();

    map[colHistoryHIVLastRefilSource] = this.historyHIVLastRefilSource?.code;

    map[colHistoryHIVLastRefilSourceSpecify] =
        this.historyHIVLastRefilSourceSpecify;

    map[colHistoryHIVARTProblems] = this.historyHIVARTProblems;

    map[colHistoryHIVARTQuestions] = this.historyHIVARTQuestions;

    map[colHistoryHIVDesiredSupportRemindersAppointments] =
        this.historyHIVDesiredSupportRemindersAppointments ? 1 : 0;

    map[colHistoryHIVDesiredSupportRemindersCheckins] =
        this.historyHIVDesiredSupportRemindersCheckins ? 1 : 0;

    map[colHistoryHIVDesiredSupportRefilsAccompany] =
        this.historyHIVDesiredSupportRefilsAccompany ? 1 : 0;

    map[colHistoryHIVDesiredSupportRefilsPAAccompany] =
        this.historyHIVDesiredSupportRefilsPAAccompany ? 1 : 0;

    map[colHistoryHIVDesiredSupportOther] =
        this.historyHIVDesiredSupportOther ? 1 : 0;

    map[colHistoryHIVDesiredSupportOtherSpecify] =
        this.historyHIVDesiredSupportOtherSpecify;

    map[colHistoryHIVPrepDesiredSupportRemindersAppointments] =
        this.historyHIVPrepDesiredSupportReminderssAppointments ? 1 : 0;

    map[colHistoryHIVPrepDesiredSupportRemindersAdherence] =
        this.historyHIVPrepDesiredSupportRemindersAdherence ? 1 : 0;

    map[colHistoryHIVPrepDesiredSupportRefilsPNAccompany] =
        this.historyHIVPrepDesiredSupportRefilsPNAccompany ? 1 : 0;

    map[colHistoryHIVPrepDesiredSupportPNHIVKit] =
        this.historyHIVPrepDesiredSupportPNHIVKit ? 1 : 0;

    map[colHistoryHIVPrepDesiredSupportOther] =
        this.historyHIVPrepDesiredSupportOther ? 1 : 0;

    map[colHistoryHIVPrepDesiredSupportOtherSpecify] =
        this.historyHIVPrepDesiredSupportOtherSpecify;

    map[colHistoryHIVPrepStopReason] = this.historyHIVPrepStopReason;

    //srh contraception
    map[colSRHContraceptionInterest] = this.srhContraceptionInterest.code;

    map[colSRHContraceptionNoInterestReason] =
        this.srhContraceptionNoInterestReason;

    map[colSRHContraceptionInterestMaleCondom] =
        this.srhContraceptionInterestMaleCondom ? 1 : 0;

    map[colSRHContraceptionInterestFemaleCondom] =
        this.srhContraceptionInterestFemaleCondom ? 1 : 0;

    map[colSRHContraceptionInterestImplant] =
        this.srhContraceptionInterestImplant ? 1 : 0;

    map[colSRHContraceptionInterestMaleCondom] =
        this.srhContraceptionInterestMaleCondom ? 1 : 0;

    map[colSRHContraceptionInterestInjection] =
        this.srhContraceptionInterestInjection ? 1 : 0;

    map[colSRHContraceptionInterestIUD] =
        this.srhContraceptionInterestIUD ? 1 : 0;

    map[colSRHContraceptionInterestIUS] =
        this.srhContraceptionInterestIUS ? 1 : 0;

    map[colSRHContraceptionInterestPills] =
        this.srhContraceptionInterestPills ? 1 : 0;

    map[colSRHContraceptionInterestOther] =
        this.srhContraceptionInterestOther ? 1 : 0;

    map[colSRHContraceptionInterestOtherSpecify] =
        this.srhContraceptionInterestOtherSpecify;

    map[colSRHContraceptionMethodInMind] =
        this.srhContraceptionMethodInMind?.code;

    map[colSRHContraceptionInformationMethods] =
        this.srhContraceptionInformationMethods?.code;

    map[colSRHContraceptionFindScheduleFacility] =
        this.srhContraceptionFindScheduleFacility?.code;

    map[colSRHContraceptionFindScheduleFacilityYesDate] =
        this.srhContraceptionFindScheduleFacilityYesDate?.toIso8601String();

    map[colSRHContraceptionFindScheduleFacilityYesPNAccompany] =
        this.srhContraceptionFindScheduleFacilityYesPNAccompany?.code;

    map[colSRHContraceptionFindScheduleFacilityNoDate] =
        this.srhContraceptionFindScheduleFacilityNoDate?.code;

    map[colSRHContraceptionFindScheduleFacilityNoPick] =
        this.srhContraceptionFindScheduleFacilityNoPick?.code;

    map[colSRHContraceptionFindScheduleFacilitySelected] =
        this.srhContraceptionFindScheduleFacilitySelected;

    map[colSRHContraceptionFindScheduleFacilityOther] =
        this.srhContraceptionFindScheduleFacilityOther;

    map[colSRHContraceptionInformationApp] =
        this.srhContraceptionInformationApp?.code;

    map[colSRHContraceptionLearnMethods] =
        this.srhContraceptionLearnMethods?.code;

    //srh prep
    map[colSRHPrepInterest] = this.srhPrepInterest.code;

    map[colSRHPrepInformationApp] = this.srhPrepInformationApp?.code;

    map[colSRHPrepFindScheduleFacility] =
        this.srhPrepFindScheduleFacilitySchedule?.code;

    map[colSRHPrepFindScheduleFacilityYesDate] =
        this.srhPrepFindScheduleFacilityYesDate?.toIso8601String();

    map[colSRHPrepFindScheduleFacilityYesPNAccompany] =
        this.srhPrepFindScheduleFacilityYesPNAccompany?.code;

    map[colSRHPrepFindScheduleFacilityNoDate] =
        this.srhPrepFindScheduleFacilityNoDate?.code;

    map[colSRHPrepFindScheduleFacilityNoPick] =
        this.srhPrepFindScheduleFacilityNoPick?.code;

    map[colSRHPrepFindScheduleFacilitySelected] =
        this.srhPrepFindScheduleFacilitySelected;

    map[colSRHPrepFindScheduleFacilityOther] =
        this.srhPrepFindScheduleFacilityOther;

    map[colSRHPrepLikeMoreInformation] = this.srhPrepLikeMoreInformation?.code;

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
    /*
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
    */
  }

  R21Followup get mostRecentFollowup {
    R21Followup mostRecent;
    for (R21Followup ev in followups) {
      if (mostRecent == null ||
          !ev.createDate.isBefore(mostRecent.createDate)) {
        mostRecent = ev;
      }
    }
    return mostRecent;
  }

  /// Sets fields to null if they are not used. E.g. sets [personalPhoneNumber] to null
  /// if [personalPhoneNumberAvailability] is not YES.
  void checkLogicAndResetUnusedFields() {}

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
