import 'package:pebrapp/database/DatabaseExporter.dart';

import 'package:pebrapp/utils/Utils.dart';

class R21SentResource implements IJsonExportable {
  static final tableName = 'SentResources';

  // column names
  static final colId = 'id'; // primary key
  static final colCreatedDate = 'created_date';
  static final colUser = 'user';
  static final colParticipant = 'participant';
  static final colResource = 'resource';
  static final colDate = 'date';

  DateTime _createdDate;
  String user;
  String participant;
  int resource;
  DateTime date;

  // Constructors
  // ------------

  R21SentResource({this.user, this.resource, this.date});

  R21SentResource.fromMap(map) {
    this._createdDate = DateTime.parse(map[colCreatedDate]);
    this.user = map[colUser];
    this.participant = map[colParticipant];
    this.resource = map[colResource];
    this.date = DateTime.parse(map[colDate]);
  }

  // Other
  // -----

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21SentResource &&
      o.user == this.user &&
      o.participant == this.participant &&
      o.resource == this.resource &&
      o.date == this.date;

  // override hashcode
  @override
  int get hashCode =>
      user.hashCode ^
      participant.hashCode ^
      resource.hashCode ^
      date.hashCode;

  @override
  String toString() {
    return 'SentResource::: user: $user, participant: $participant, resource: $resource,date: $date';
  }

  toMap() {
    var map = Map<String, dynamic>();
    map[colCreatedDate] = _createdDate.toIso8601String();
    map[colUser] = user;
    map[colParticipant] = participant;
    map[colUser] = user;
    map[colResource] = resource;
    map[colDate] = date.toIso8601String();

    return map;
  }



  @override
  Map<String, dynamic> toJson(String username) => {
        "\"username\"": "\"$username\"",
        "\"create_date\"": "\"${formatDateIso(_createdDate)}\"",
        "\"user\"": "\"$user\"",
        "\"participant\"": "\"$participant\"",
        "\"resource\"": "\"$resource\"",
        "\"date\"": "\"${formatDateIso(date)}\""
      };

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => _createdDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => _createdDate;
}
