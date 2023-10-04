class R21Residency {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Gender, int> _encoding = {
    _Gender.UNZA: 1,
    _Gender.ADDRESS: 2,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Gender, String> _description = {
    _Gender.UNZA: 'UNZA Hostel',
    _Gender.ADDRESS: 'Address',
  };

  _Gender _gender;

  // Constructors
  // ------------

  // make default constructor private
  R21Residency._();

  R21Residency.UNZA() {
    _gender = _Gender.UNZA;
  }

  R21Residency.ADDRESS() {
    _gender = _Gender.ADDRESS;
  }

  static R21Residency fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Gender gender =
        _encoding.entries.firstWhere((MapEntry<_Gender, int> entry) {
      return entry.value == code;
    }).key;
    R21Residency object = R21Residency._();
    object._gender = gender;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is R21Residency && o._gender == _gender;

  // override hashcode
  @override
  int get hashCode => _gender.hashCode;

  static List<R21Residency> get allValues => [
        R21Residency.UNZA(),
        R21Residency.ADDRESS(),
      ];

  /// Returns the text description of this gender.
  String get description => _description[_gender];

  /// Returns the code that represents this gender.
  int get code => _encoding[_gender];
}

enum _Gender { UNZA, ADDRESS}
