class R21PhoneNumberSecurity {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_PhoneAvailability, int> _encoding = {
    _PhoneAvailability.PRIVATE: 1,
    _PhoneAvailability.SHARED: 2,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_PhoneAvailability, String> _description = {
    _PhoneAvailability.PRIVATE: 'Used only by the participant and can receive confidential information',
    _PhoneAvailability.SHARED: 'Shared and should not be used to send confidential information ',
  };

  _PhoneAvailability _availability;

  // Constructors
  // ------------

  // make default constructor private
  R21PhoneNumberSecurity._();

  R21PhoneNumberSecurity.YES() {
    _availability = _PhoneAvailability.PRIVATE;
  }

  R21PhoneNumberSecurity.NO_NO_PHONE() {
    _availability = _PhoneAvailability.SHARED;
  }

  static R21PhoneNumberSecurity fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _PhoneAvailability availability =
        _encoding.entries.firstWhere((MapEntry<_PhoneAvailability, int> entry) {
      return entry.value == code;
    }).key;
    R21PhoneNumberSecurity object = R21PhoneNumberSecurity._();
    object._availability = availability;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21PhoneNumberSecurity && o._availability == _availability;

  // override hashcode
  @override
  int get hashCode => _availability.hashCode;

  static List<R21PhoneNumberSecurity> get allValues => [
        R21PhoneNumberSecurity.YES(),
        R21PhoneNumberSecurity.NO_NO_PHONE(),
      ];

  /// Returns the text description of this availability.
  String get description => _description[_availability];

  /// Returns the code that represents this availability.
  int get code => _encoding[_availability];
}

enum _PhoneAvailability { PRIVATE, SHARED }
