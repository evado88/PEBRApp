class R21MedicationType {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_MedicationType, int> _encoding = {
    _MedicationType.PrEP: 1,
    _MedicationType.Contraceptive: 2,
    _MedicationType.STITreatment: 3,
    _MedicationType.NotSpecified: 4,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_MedicationType, String> _description = {
    _MedicationType.PrEP: 'PrEP',
    _MedicationType.Contraceptive: 'Contraceptive',
    _MedicationType.STITreatment: 'STI Treatment',
    _MedicationType.NotSpecified: 'Not Specified',
  };

  _MedicationType _medicationType;

  // Constructors
  // ------------

  // make default constructor private
  R21MedicationType._();

  R21MedicationType.PrEP() {
    _medicationType = _MedicationType.PrEP;
  }

  R21MedicationType.Contraceptive() {
    _medicationType = _MedicationType.Contraceptive;
  }

  R21MedicationType.STITreatment() {
    _medicationType = _MedicationType.STITreatment;
  }

  R21MedicationType.NotSpecified() {
    _medicationType = _MedicationType.NotSpecified;
  }

  static R21MedicationType fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _MedicationType supportType =
        _encoding.entries.firstWhere((MapEntry<_MedicationType, int> entry) {
      return entry.value == code;
    }).key;
    R21MedicationType object = R21MedicationType._();
    object._medicationType = supportType;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21MedicationType && o._medicationType == _medicationType;

  // override hashcode
  @override
  int get hashCode => _medicationType.hashCode;

  static List<R21MedicationType> get allValues => [
        R21MedicationType.PrEP(),
        R21MedicationType.Contraceptive(),
        R21MedicationType.STITreatment(),
        R21MedicationType.NotSpecified(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_medicationType];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_medicationType];
}

enum _MedicationType { PrEP, Contraceptive, STITreatment, NotSpecified }
