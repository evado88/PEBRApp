class R21PreferredContactMethod {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_SexualOrientation, int> _encoding = {
    _SexualOrientation.TWYSHE: 1,
    _SexualOrientation.PHONECALL: 2,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_SexualOrientation, String> _description = {
    _SexualOrientation.TWYSHE: 'TwySHE Messenger App',
    _SexualOrientation.PHONECALL: 'Phone Call',
  };

  _SexualOrientation _orientation;

  // Constructors
  // ------------

  // make default constructor private
  R21PreferredContactMethod._();

  R21PreferredContactMethod.HETEROSEXUAL() {
    _orientation = _SexualOrientation.TWYSHE;
  }

  R21PreferredContactMethod.BISEXUAL() {
    _orientation = _SexualOrientation.PHONECALL;
  }


  static R21PreferredContactMethod fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _SexualOrientation orientation =
        _encoding.entries.firstWhere((MapEntry<_SexualOrientation, int> entry) {
      return entry.value == code;
    }).key;
    R21PreferredContactMethod object = R21PreferredContactMethod._();
    object._orientation = orientation;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21PreferredContactMethod && o._orientation == _orientation;

  // override hashcode
  @override
  int get hashCode => _orientation.hashCode;

  static List<R21PreferredContactMethod> get allValues => [
        R21PreferredContactMethod.HETEROSEXUAL(),
        R21PreferredContactMethod.BISEXUAL(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_orientation];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_orientation];
}

enum _SexualOrientation { TWYSHE, PHONECALL }
