class R21EventType {
  // Class Variables
  // ---------------t

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_R21EventType, int> _encoding = {
    _R21EventType.Appointment: 1,
    _R21EventType.Followup: 2,
    _R21EventType.Event: 3,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_R21EventType, String> _description = {
    _R21EventType.Appointment: 'Appointment',
    _R21EventType.Followup: 'Followup',
    _R21EventType.Event: 'Event',
  };

  _R21EventType _eventType;

  // Constructors
  // ------------

  // make default constructor private
  R21EventType._();

  R21EventType.Appointment() {
    _eventType = _R21EventType.Appointment;
  }

  R21EventType.Followup() {
    _eventType = _R21EventType.Followup;
  }

  R21EventType.Event() {
    _eventType = _R21EventType.Event;
  }

  static R21EventType fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _R21EventType eventType =
        _encoding.entries.firstWhere((MapEntry<_R21EventType, int> entry) {
      return entry.value == code;
    }).key;
    R21EventType object = R21EventType._();
    object._eventType = eventType;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21EventType && o._eventType == _eventType;

  // override hashcode
  @override
  int get hashCode => _eventType.hashCode;

  static List<R21EventType> get allValues => [
        R21EventType.Appointment(),
        R21EventType.Followup(),
        R21EventType.Event(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_eventType];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_eventType];
}

enum _R21EventType { Appointment, Followup, Event }
