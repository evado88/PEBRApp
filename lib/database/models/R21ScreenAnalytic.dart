import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/R21ScreenType.dart';
import 'package:pebrapp/utils/Utils.dart';

class R21ScreenAnalytic implements IExcelExportable {
  static final tableName = 'ScreenAnalytics';

  // column names
  static final colId = 'id'; // primary key
  static final colCreatedDate = 'created_date';
  static final colType = 'type';
  static final colStartDate = 'start_date';
  static final colEndDate = 'end_date';
  static final colDuration = 'duration';
  static final colResult = 'result'; // nullable
  static final colSubject = 'subject'; // nullable

  DateTime _createdDate;
  R21ScreenType type;
  DateTime startDate;
  DateTime endDate;
  int duration;
  String result;
  String subject;

  // Constructors
  // ------------

  R21ScreenAnalytic(
      {this.type,
      this.startDate,
      this.endDate,
      this.duration,
      this.result,
      this.subject});

  R21ScreenAnalytic.fromMap(map) {
    this._createdDate = DateTime.parse(map[colCreatedDate]);
    this.type = R21ScreenType.fromCode(map[colType]);
    this.startDate = DateTime.parse(map[colStartDate]);
    this.endDate = DateTime.parse(map[colEndDate]);
    this.duration = map[colDuration];
    // nullables:
    this.result = map[colResult];
    this.subject = map[colSubject];
  }

  // Other
  // -----

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21ScreenAnalytic &&
      o.type == this.type &&
      o.startDate == this.startDate &&
      o.endDate == this.endDate &&
      o.duration == this.duration &&
      o.result == this.result &&
      o.subject == this.subject;

  // override hashcode
  @override
  int get hashCode =>
      type.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      duration.hashCode ^
      result.hashCode ^
      subject.hashCode;

  @override
  String toString() {
    return 'Screen Analytic::: type: ${type.description}, start date: $startDate,' +
           'end date: $endDate, duration: $duration, result: $result, subject: $subject';
  }

  toMap() {
    var map = Map<String, dynamic>();
    map[colCreatedDate] = _createdDate.toIso8601String();
    map[colType] = type.code;
    map[colStartDate] = startDate.toIso8601String();
    map[colEndDate] = endDate.toIso8601String();
    map[colDuration] = duration;
    // nullables:
    map[colResult] = result;
    map[colSubject] = subject;
    return map;
  }

  static const int _numberOfColumns = 7;

  /// Column names for the header row in the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [toExcelRow] method as well!
  static List<String> get excelHeaderRow {
    List<String> row = List<String>(_numberOfColumns);
    row[0] = 'DATE_CREATED';
    row[1] = 'TYPE';
    row[2] = 'START_DATE';
    row[3] = 'END_DATE';
    row[4] = 'DURATION';
    row[5] = 'RESULT';
    row[6] = 'SUBJECT';

    return row;
  }

  /// Starts recording analytics for this screen
  startAnalytics() {
    this.startDate = DateTime.now();
    print(">>>>>> R21-Screen-Analytics " +
        this.type.description +
        " Started at " +
        this.startDate.toIso8601String());
  }

  /// Stops recordiing analytics for this screen
  stopAnalytics({String resultAction, String subjectEntity}) async {
    //ensure only one save is made per analytic
    if (this.endDate == null) {
      this.endDate = DateTime.now();
      this.duration = this.endDate.difference(this.startDate).inSeconds;

      this.result = resultAction;
      this.subject = subjectEntity;

      String rs = this.result == null ? "-" : this.result;
      String sb = this.subject == null ? "-" : this.subject;

      print(">>>>>> R21-Screen-Analytics " +
          this.type.description +
          " Stopped at " +
          this.startDate.toIso8601String() +
          ". Result: " +
          rs +
          ", Subject: " +
          sb +
          ". Seconds: " +
          this.duration.toString());

      //save to database
      await DatabaseProvider().insertScreenAnalytic(this);
    }
  }

  /// Turns this object into a row that can be written to the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [excelHeaderRow] method as well!
  @override
  List<dynamic> toExcelRow() {
    List<dynamic> row = List<dynamic>(_numberOfColumns);
    row[0] = formatDateIso(_createdDate);
    row[1] = type.description;
    row[2] = formatDateIso(startDate);
    row[3] = formatDateIso(endDate);
    row[4] = duration;
    row[5] = result;
    row[6] = subject;

    return row;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => _createdDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => _createdDate;
}
