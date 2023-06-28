import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/beans/R21EventNoOccurReason.dart';
import 'package:pebrapp/utils/Utils.dart';

class R21Event implements IExcelExportable, IJsonExportable {
  static final tableName = 'Events';

  // column names
  static final colId = 'id'; // primary key
  static final colCreatedDate = 'created_date';
  static final colPatientART =
      'patient_art'; // foreign key to [Patient].art_number
  static final colType = 'type';
  static final colDate = 'date';
  static final colDescription = 'description';
  static final colOccured = 'occcured';
  static final colNoOccurReason = 'no_occur_reason';
  static final colNextDate = 'next_date';

  DateTime _createdDate;
  String patientART;
  DateTime date;
  String description;
  bool occured;
  R21EventNoOccurReason noOccurReason;
  DateTime nextDate;

  // Constructors
  // ------------

  R21Event(
      {this.patientART,
      this.date,
      this.description,
      this.occured,
      this.noOccurReason,
      this.nextDate});

  R21Event.fromMap(map) {
    this._createdDate = DateTime.parse(map[colCreatedDate]);
    this.patientART = map[colPatientART];
    this.date = DateTime.parse(map[colDate]);
    this.description = map[colDescription];
    this.occured = map[colOccured] == 1;
    this.noOccurReason = R21EventNoOccurReason.fromCode(map[colNoOccurReason]);
    this.nextDate = DateTime.parse(map[colNextDate]);
  }

  // Other
  // -----

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21Event &&
      o.patientART == this.patientART &&
      o.date == this.date &&
      o.description == this.description &&
      o.occured == this.occured &&
      o.noOccurReason == this.noOccurReason &&
      o.nextDate == this.nextDate;

  // override hashcode
  @override
  int get hashCode =>
      patientART.hashCode ^
      date.hashCode ^
      description.hashCode ^
      occured.hashCode ^
      noOccurReason.hashCode ^
      nextDate.hashCode;

  @override
  String toString() {
    return 'R21Event \n----------\n'
        'patient:     $patientART\n'
        'date:      $date\n'
        'description:  $description\n'
        'occured:     $occured\n'
        'noOccurReason: ${noOccurReason == null ? '-' : noOccurReason.description}\n'
        'nextDate: $nextDate';
  }

  toMap() {
    var map = Map<String, dynamic>();
    map[colCreatedDate] = _createdDate.toIso8601String();
    map[colPatientART] = patientART;
    map[colDate] = date.toIso8601String();
    map[colDescription] = description;
    map[colOccured] = occured;
    map[colNoOccurReason] = noOccurReason?.code;
    map[colNextDate] = nextDate.toIso8601String();

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
    row[1] = formatDateIso(_createdDate);
    row[2] = formatDateIso(date);
    row[3] = description;
    row[4] = occured;
    row[5] = noOccurReason?.description;
    row[6] = formatDateIso(nextDate);

    return row;
  }

  @override
  Map<String, dynamic> toJson(String username) => {
        "\"username\"": "\"$username\"",
        "\"studyNo\"": "\"$patientART\"",
        "\"createdate\"": "\"${formatDateIso(_createdDate)}\"",
        "\"date\"": "\"${formatDateIso(date)}\"",
        "\"description\"": "\"$description\"",
        "\"occured\"": occured,
        "\"noOccurReason\"":
            noOccurReason == null ? null : "\"${noOccurReason.description}\"",
        "\"nextDate\"": "\"${formatDateIso(nextDate)}\"",
      };

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => _createdDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => _createdDate;
}
