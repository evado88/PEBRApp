class R21SupportType {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_SupportType, int> _encoding = {
    _SupportType.Counselling: 1,
    _SupportType.Medication: 2,
    _SupportType.All: 3,
    _SupportType.NotSpecified: 4,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_SupportType, String> _description = {
    _SupportType.Counselling: 'Counselling',
    _SupportType.Medication: 'Medication',
    _SupportType.All: 'All',
    _SupportType.NotSpecified: 'Not Specified',
  };

  _SupportType _supportType;

  // Constructors
  // ------------

  // make default constructor private
  R21SupportType._();

  R21SupportType.Counselling() {
    _supportType = _SupportType.Counselling;
  }

  R21SupportType.Medication() {
    _supportType = _SupportType.Medication;
  }

  R21SupportType.All() {
    _supportType = _SupportType.All;
  }

  R21SupportType.NotSpecified() {
    _supportType = _SupportType.NotSpecified;
  }

  static R21SupportType fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _SupportType supportType =
        _encoding.entries.firstWhere((MapEntry<_SupportType, int> entry) {
      return entry.value == code;
    }).key;
    R21SupportType object = R21SupportType._();
    object._supportType = supportType;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21SupportType && o._supportType == _supportType;

  // override hashcode
  @override
  int get hashCode => _supportType.hashCode;

  static List<R21SupportType> get allValues => [
        R21SupportType.Counselling(),
        R21SupportType.Medication(),
        R21SupportType.All(),
        R21SupportType.NotSpecified(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_supportType];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_supportType];
}

enum _SupportType { Counselling, Medication, All, NotSpecified }
