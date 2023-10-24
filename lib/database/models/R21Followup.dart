import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/beans/R21ContraceptionMethod.dart';
import 'package:pebrapp/database/beans/R21Interest.dart';
import 'package:pebrapp/database/beans/R21Week.dart';
import 'package:pebrapp/database/beans/R21YesNo.dart';
import 'package:pebrapp/database/beans/R21YesNoUnsure.dart';
import 'package:pebrapp/utils/Utils.dart';

class R21Followup implements IExcelExportable, IJsonExportable {
  static final tableName = 'Followups';

  // column names
  static final colUtilityId = 'id'; // primary key
  static final colUtilityCreatedDate = 'created_date';
  static final colPersonalStudyNo = 'art_number';

//follow up
  static final colFollowNextDate = 'next_date';

//SRH Preferences
  //Contraception
  static final colSRHContraceptionStarted = 'srh_contraception_started';

  static final colSRHContraceptionStartedMethod =
      'srh_contraception_started_method';

  static final colSRHContraceptionStartedProblems =
      'srh_contraception_started_problems';

  static final colSRHContraceptionStartedSideffects =
      'srh_contraception_started_side_effects';

  static final colSRHContraceptionStartedOther =
      'srh_contraception_started_other';

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
  static final colSRHPrepStarted = 'srh_prep_started';

  static final colSRHPrepStartedProblems = 'srh_prep_started_problems';

  static final colSRHPrepStartedSideffects = 'srh_prep_started_side_effects';

  static final colSRHPrepStartedOther = 'srh_prep_started_other';

  static final colSRHPrepInterest = 'srh_prep_interest';

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

  String studyNo;
  DateTime createDate;
  DateTime nextDate;

//SRH Preferences

  //Contraception
  R21YesNo srhContraceptionStarted;

  R21ContraceptionMethod srhContraceptionStartedMethod;

  R21YesNo srhContraceptionStartedProblems;

  String srhContraceptionStartedSideeffects;

  String srhContraceptionStartedOther;

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
  R21YesNo srhPrepStarted;

  R21YesNo srhPrepStartedProblems;

  String srhPrepStartedSideeffects;

  String srhPrepStartedOther;

  R21Interest srhPrepInterest;

  R21YesNo srhPrepInformationApp;

  R21YesNoUnsure srhPrepFindScheduleFacilitySchedule;

  DateTime srhPrepFindScheduleFacilityYesDate;

  R21YesNo srhPrepFindScheduleFacilityYesPNAccompany;

  R21Week srhPrepFindScheduleFacilityNoDate;

  R21YesNo srhPrepFindScheduleFacilityNoPick;

  String srhPrepFindScheduleFacilitySelected;

  String srhPrepFindScheduleFacilityOther;

  R21YesNo srhPrepLikeMoreInformation;

  // Constructors
  // ------------

  R21Followup({this.studyNo});

  R21Followup.fromMap(map) {
    this.createdDate = DateTime.parse(map[colUtilityCreatedDate]);

    this.studyNo = map[colPersonalStudyNo];

    this.nextDate = map[colFollowNextDate] == null ? null : DateTime.parse(map[colFollowNextDate]);

    //srh contraception
    this.srhContraceptionStarted = map[colSRHContraceptionStarted] == null
        ? null
        : R21YesNo.fromCode(map[colSRHContraceptionStarted]);

    this.srhContraceptionStartedMethod =
        map[colSRHContraceptionStartedMethod] == null
            ? null
            : R21ContraceptionMethod.fromCode(
                map[colSRHContraceptionStartedMethod]);

    this.srhContraceptionStartedProblems =
        map[colSRHContraceptionStartedProblems] == null
            ? null
            : R21YesNo.fromCode(map[colSRHContraceptionStartedProblems]);

    this.srhContraceptionStartedSideeffects =
        map[colSRHContraceptionStartedSideffects];

    this.srhContraceptionStartedOther = map[colSRHContraceptionStartedOther];

    this.srhContraceptionInterest = map[colSRHContraceptionInterest] == null
        ? null
        : R21Interest.fromCode(map[colSRHContraceptionInterest]);

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
    this.srhPrepStarted = map[colSRHPrepStarted] == null
        ? null
        : R21YesNo.fromCode(map[colSRHPrepStarted]);

    this.srhPrepStartedProblems = map[colSRHPrepStartedProblems] == null
        ? null
        : R21YesNo.fromCode(map[colSRHPrepStartedProblems]);

    this.srhPrepStartedSideeffects = map[colSRHPrepStartedSideffects];

    this.srhPrepStartedOther = map[colSRHPrepStartedOther];

    this.srhPrepInterest = R21Interest.fromCode(map[colSRHPrepInterest]);

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

  toMap() {
    var map = Map<String, dynamic>();

    map[colUtilityCreatedDate] = createDate.toIso8601String();
    map[colPersonalStudyNo] = studyNo;

    map[colFollowNextDate] = this.nextDate.toIso8601String();

    //srh contraception
    map[colSRHContraceptionStarted] = this.srhContraceptionStarted.code;

    map[colSRHContraceptionStartedMethod] =
        this.srhContraceptionStartedMethod?.code;

    map[colSRHContraceptionStartedProblems] =
        this.srhContraceptionStartedProblems?.code;

    map[colSRHContraceptionStartedSideffects] =
        this.srhContraceptionStartedSideeffects;

    map[colSRHContraceptionStartedOther] = this.srhContraceptionStartedOther;

    map[colSRHContraceptionInterest] = this.srhContraceptionInterest?.code;

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
    map[colSRHPrepStarted] = this.srhPrepStarted.code;

    map[colSRHPrepStartedProblems] = this.srhPrepStartedProblems?.code;

    map[colSRHPrepStartedSideffects] = this.srhPrepStartedSideeffects;

    map[colSRHPrepStartedOther] = this.srhPrepStartedOther;

    map[colSRHPrepInterest] = this.srhPrepInterest?.code;

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

    // nullables:
    return map;
  }
  // Other
  // -----

  // override the equality operator
  @override
  bool operator ==(o) => o is R21Followup && o.studyNo == this.studyNo;

  // override hashcode
  @override
  int get hashCode => studyNo.hashCode ^ createDate.hashCode;

  @override
  String toString() {
    return 'R21Followup \n----------\n'
        'patient:     $studyNo\n'
        'date:      $createDate\n';
  }

  @override
  Map<String, dynamic> toJson(String username) => {
        "\"username\"": "\"$username\"",
        "\"studyNo\"": "\"$studyNo\"",
        "\"createdate\"": "\"${formatDateIso(createDate)}\"}\"",
      };

  static const int _numberOfColumns = 7;

  /// Column names for the header row in the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [toExcelRow] method as well!
  static List<String> get excelHeaderRow {
    List<String> row = List<String>(_numberOfColumns);
    row[0] = 'STUDY_NO';
    row[1] = 'DATE_CREATED';
    row[2] = 'DATE';
    row[3] = 'DESCRIPTION';
    row[4] = 'OCCURED';
    row[5] = 'NO_OCCUR_REASON';
    row[6] = 'NEXT_DATE';

    return row;
  }

  /// Turns this object into a row that can be written to the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [excelHeaderRow] method as well!
  @override
  List<dynamic> toExcelRow() {
    List<dynamic> row = List<dynamic>(_numberOfColumns);
    row[0] = studyNo;
    row[1] = formatDateIso(createDate);

    return row;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => createDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => createdDate;
}
