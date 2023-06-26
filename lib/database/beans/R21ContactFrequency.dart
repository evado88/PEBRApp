class R21ContactFrequency {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_ContactFrequency, int> _encoding = {
    _ContactFrequency.Weekly: 7,
    _ContactFrequency.BIWeekly: 14,
    _ContactFrequency.Monthly: 30,
    _ContactFrequency.Quarterly: 90,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_ContactFrequency, String> _description = {
    _ContactFrequency.Weekly: 'Weekly',
    _ContactFrequency.BIWeekly: 'Bi-Weekly',
    _ContactFrequency.Monthly: 'Monthly',
    _ContactFrequency.Quarterly: 'Quarterly',
  };

  _ContactFrequency _contactFrequuency;

  // Constructors
  // ------------

  // make default constructor private
  R21ContactFrequency._();

  R21ContactFrequency.Weekly() {
    _contactFrequuency = _ContactFrequency.Weekly;
  }

  R21ContactFrequency.BIWeekly() {
    _contactFrequuency = _ContactFrequency.BIWeekly;
  }

  R21ContactFrequency.Monthly() {
    _contactFrequuency = _ContactFrequency.Monthly;
  }

  R21ContactFrequency.Quarterly() {
    _contactFrequuency = _ContactFrequency.Quarterly;
  }

  static R21ContactFrequency fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _ContactFrequency contactFrequuency =
        _encoding.entries.firstWhere((MapEntry<_ContactFrequency, int> entry) {
      return entry.value == code;
    }).key;
    R21ContactFrequency object = R21ContactFrequency._();
    object._contactFrequuency = contactFrequuency;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21ContactFrequency && o._contactFrequuency == _contactFrequuency;

  // override hashcode
  @override
  int get hashCode => _contactFrequuency.hashCode;

  static List<R21ContactFrequency> get allValues => [
        R21ContactFrequency.Weekly(),
        R21ContactFrequency.BIWeekly(),
        R21ContactFrequency.Monthly(),
        R21ContactFrequency.Quarterly(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_contactFrequuency];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_contactFrequuency];
}

enum _ContactFrequency { Weekly, BIWeekly, Monthly, Quarterly }
