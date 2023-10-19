import 'package:pebrapp/database/DatabaseExporter.dart';
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

//SRH Preferences
  //Contraception
  static final colSRHContraceptionStarted = 'srh_contraception_started';

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
  static final colSRHPrePStarted= 'srh_prep_started';

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

  String patientART;
  DateTime createDate;

//SRH Preferences

  //Contraception
  R21YesNo srhContraceptionStarted;

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
  R21YesNo srhPrePStarted;

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

  // Constructors
  // ------------

  R21Followup({this.patientART});

  R21Followup.fromMap(map) {
    this.createdDate = DateTime.parse(map[colUtilityCreatedDate]);
    this.patientART = map[colPersonalStudyNo];
  }

  // Other
  // -----

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21Followup &&
      o.patientART == this.patientART;

  // override hashcode
  @override
  int get hashCode =>
      patientART.hashCode ^
      createDate.hashCode;

  @override
  String toString() {
    return 'R21Followup \n----------\n'
        'patient:     $patientART\n'
        'date:      $createDate\n';
  }

  @override
  Map<String, dynamic> toJson(String username) => {
        "\"username\"": "\"$username\"",
        "\"studyNo\"": "\"$patientART\"",
        "\"createdate\"": "\"${formatDateIso(createDate)}\"}\"",
      };

  toMap() {
    var map = Map<String, dynamic>();
    map[colUtilityCreatedDate] = createDate.toIso8601String();
    map[colPersonalStudyNo] = patientART;

    // nullables:
    return map;
  }

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
    row[0] = patientART;
    row[1] = formatDateIso(createDate);

    return row;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => createdDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => createdDate;
}
