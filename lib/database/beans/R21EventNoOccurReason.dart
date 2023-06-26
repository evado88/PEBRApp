class R21EventNoOccurReason {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Reason, int> _encoding = {
    _Reason.PARTICIPANT_LEFT_STUDY: 1,
    _Reason.PARTICIPANT_SICK: 2,
    _Reason.PARTICIPANT_OUT_TOWN: 3,
    _Reason.PEER_NAVIGOTOR_SICK: 4,
    _Reason.PEER_NAVIGOTOR_OUT_TOWN: 5,
    _Reason.FACILITY_UNAVAILABLE: 6,
    _Reason.NO_INFORMATION: 7,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Reason, String> _description = {
    _Reason.PARTICIPANT_LEFT_STUDY: "Participant Left Study",
    _Reason.PARTICIPANT_SICK: "Participant Sick",
    _Reason.PARTICIPANT_OUT_TOWN: "Participant Out of TOwn",
    _Reason.PEER_NAVIGOTOR_SICK:"Peer Navigator Sick",
    _Reason.PEER_NAVIGOTOR_OUT_TOWN: "Peer Navigator Out of Town",
    _Reason.FACILITY_UNAVAILABLE: "Facility Unavailable",
    _Reason.NO_INFORMATION: "No information found about the participant at all",
  };

  _Reason _reason;

  // Constructors
  // ------------

  // make default constructor private
  R21EventNoOccurReason._();

  R21EventNoOccurReason.PARTICIPANT_LEFT_STUDY() {
    _reason = _Reason.PARTICIPANT_LEFT_STUDY;
  }

  R21EventNoOccurReason.PARTICIPANT_SICK() {
    _reason = _Reason.PARTICIPANT_SICK;
  }

  R21EventNoOccurReason.PARTICIPANT_OUT_TOWN() {
    _reason = _Reason.PARTICIPANT_OUT_TOWN;
  }

  R21EventNoOccurReason.PEER_NAVIGOTOR_SICK() {
    _reason = _Reason.PEER_NAVIGOTOR_SICK;
  }

  R21EventNoOccurReason.PEER_NAVIGOTOR_OUT_TOWN() {
    _reason = _Reason.PEER_NAVIGOTOR_OUT_TOWN;
  }

  R21EventNoOccurReason.FACILITY_UNAVAILABLE() {
    _reason = _Reason.FACILITY_UNAVAILABLE;
  }

  R21EventNoOccurReason.NO_INFORMATION() {
    _reason = _Reason.NO_INFORMATION;
  }

  static R21EventNoOccurReason fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Reason reason =
        _encoding.entries.firstWhere((MapEntry<_Reason, int> entry) {
      return entry.value == code;
    }).key;
    R21EventNoOccurReason object = R21EventNoOccurReason._();
    object._reason = reason;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is R21EventNoOccurReason && o._reason == _reason;

  // override hashcode
  @override
  int get hashCode => _reason.hashCode;

  static List<R21EventNoOccurReason> get allValues => [
        R21EventNoOccurReason.PARTICIPANT_LEFT_STUDY(),
        R21EventNoOccurReason.PARTICIPANT_SICK(),
        R21EventNoOccurReason.PARTICIPANT_OUT_TOWN(),
        R21EventNoOccurReason.PEER_NAVIGOTOR_SICK(),
        R21EventNoOccurReason.PEER_NAVIGOTOR_OUT_TOWN(),
        R21EventNoOccurReason.FACILITY_UNAVAILABLE(),
        R21EventNoOccurReason.NO_INFORMATION(),
      ];

  /// Returns the text description of this reason.
  String get description => _description[_reason];

  /// Returns the code that represents this reason.
  int get code => _encoding[_reason];
}

enum _Reason {
  PARTICIPANT_LEFT_STUDY,
  PARTICIPANT_SICK,
  PARTICIPANT_OUT_TOWN,
  PEER_NAVIGOTOR_SICK,
  PEER_NAVIGOTOR_OUT_TOWN,
  FACILITY_UNAVAILABLE,
  NO_INFORMATION
}
