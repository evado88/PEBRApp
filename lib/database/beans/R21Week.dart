class R21Week {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_R21Week, int> _encoding = {
    _R21Week.NextWeek: 1,
    _R21Week.In2Weeks: 2,
    _R21Week.In3Weeks: 3,
    _R21Week.Other: 4,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_R21Week, String> _description = {
    _R21Week.NextWeek: 'Next week',
    _R21Week.In2Weeks: 'In 2 weeks',
    _R21Week.In3Weeks: 'In 3 weeks',
    _R21Week.Other: 'Other',
  };

  _R21Week _r21week;

  // Constructors
  // ------------

  // make default constructor private
  R21Week._();

  R21Week.NextWeek() {
    _r21week = _R21Week.NextWeek;
  }

  R21Week.In2Weeks() {
    _r21week = _R21Week.In2Weeks;
  }

  R21Week.In3Weeks() {
    _r21week = _R21Week.In3Weeks;
  }

  R21Week.Other() {
    _r21week = _R21Week.Other;
  }

  static R21Week fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _R21Week prep =
        _encoding.entries.firstWhere((MapEntry<_R21Week, int> entry) {
      return entry.value == code;
    }).key;
    R21Week object = R21Week._();
    object._r21week = prep;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is R21Week && o._r21week == _r21week;

  // override hashcode
  @override
  int get hashCode => _r21week.hashCode;

  static List<R21Week> get allValues => [
        R21Week.NextWeek(),
        R21Week.In2Weeks(),
        R21Week.In3Weeks(),
        R21Week.Other(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_r21week];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_r21week];
}

enum _R21Week { NextWeek, In2Weeks, In3Weeks, Other }
