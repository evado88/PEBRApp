import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/beans/R21MedicationType.dart';
import 'package:pebrapp/database/beans/R21RefilNotDoneReason.dart';
import 'package:pebrapp/utils/Utils.dart';

class R21MedicationRefill implements IExcelExportable {
  static final tableName = 'MedicationRefills';

  // column names
  static final colId = 'id'; // primary key
  static final colPatientART =
      'patient_art'; // foreign key to [Patient].art_number
  static final colCreatedDate = 'created_date';
  static final colRefillDone = 'refill_done';
  static final colRefillDate = 'refill_date'; // nullable
  static final colNextRefillDate = 'next_refill_date';
  static final colNotDoneReason = 'not_done_reason'; // nullable
  static final colMedication = 'medication'; // nullable
  static final colMedicationType = 'type'; // nullable
  static final colDescription = 'description'; // nullable

  String patientART;
  DateTime _createdDate;
  bool refillDone;
  DateTime refillDate;
  DateTime nextRefillDate;
  R21RefilNotDoneReason notDoneReason;
  String medication;
  R21MedicationType medicationType;
  String description;

  // Constructors
  // ------------

  R21MedicationRefill(this.patientART,
      {this.refillDone,
      this.refillDate,
      this.nextRefillDate,
      this.notDoneReason,
      this.medication,
      this.medicationType,
      this.description});

  R21MedicationRefill.uninitialized();

  R21MedicationRefill.fromMap(map) {
    this.patientART = map[colPatientART];
    this.createdDate = DateTime.parse(map[colCreatedDate]);
    this.refillDone = map[colRefillDone] == 1;
    this.refillDate =
        map[colRefillDate] == null ? null : DateTime.parse(map[colRefillDate]);
    this.nextRefillDate = DateTime.parse(map[colNextRefillDate]);
    this.notDoneReason = this.notDoneReason == null
        ? null
        : R21RefilNotDoneReason.fromCode(map[colNotDoneReason]);
    this.medication = map[colMedication];
    this.medicationType = this.medicationType == null
        ? null
        : R21MedicationType.fromCode(map[colMedicationType]);
    this.description = map[colDescription];
  }

  // Other
  // -----

  toMap() {
    var map = Map<String, dynamic>();
    map[colPatientART] = patientART;
    map[colCreatedDate] = createdDate.toIso8601String();
    map[colRefillDone] = refillDone;
    map[colRefillDate] = nextRefillDate?.toIso8601String();
    map[colNextRefillDate] = nextRefillDate?.toIso8601String();
    map[colNotDoneReason] = notDoneReason?.code;
    map[colMedication] = medication;
    map[colMedicationType] = medicationType?.code;
    map[colDescription] = description;

    return map;
  }

  static const int _numberOfColumns = 9;

  /// Column names for the header row in the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [toExcelRow] method as well!
  static List<String> get excelHeaderRow {
    List<String> row = List<String>(_numberOfColumns);
    row[0] = 'STUDY_NO';
    row[1] = 'DATE_CREATED';
    row[2] = 'REFILL_DONE';
    row[3] = 'REFILL_DATE';
    row[4] = 'NEXT_REFILL_DATE';
    row[5] = 'NOT_DONE_REASON';
    row[6] = 'MEDICATION';
    row[7] = 'TYPE';
    row[8] = 'DESCRIPTION';

    return row;
  }

  /// Turns this object into a row that can be written to the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [excelHeaderRow] method as well!
  @override
  List<dynamic> toExcelRow() {
    List<dynamic> row = List<dynamic>(_numberOfColumns);
    row[0] = patientART;
    row[1] = formatDateIso(_createdDate);
    row[2] = refillDone;
    row[3] = refillDate == null ? null : formatDateIso(refillDate);
    row[4] = formatDateIso(nextRefillDate);
    row[5] = notDoneReason?.description;
    row[6] = medication;
    row[7] = medicationType?.description;
    row[8] = description;

    return row;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  set createdDate(DateTime date) => this._createdDate = date;

  DateTime get createdDate => this._createdDate;
}
