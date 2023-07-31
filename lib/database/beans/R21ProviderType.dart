class R21ProviderType {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_R21ProviderType, int> _encoding = {
    _R21ProviderType.GovernmentClinic: 1,
    _R21ProviderType.PrivateClinic: 2,
    _R21ProviderType.Other: 3,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_R21ProviderType, String> _description = {
    _R21ProviderType.GovernmentClinic: 'Government Clinic',
    _R21ProviderType.PrivateClinic: 'Private Clinic',
    _R21ProviderType.Other: 'Other',
  };

  _R21ProviderType _providerype;

  // Constructors
  // ------------

  // make default constructor private
  R21ProviderType._();

  R21ProviderType.GovernmentClinic() {
    _providerype = _R21ProviderType.GovernmentClinic;
  }

  R21ProviderType.PrivateClinic() {
    _providerype = _R21ProviderType.PrivateClinic;
  }

  R21ProviderType.Other() {
    _providerype = _R21ProviderType.Other;
  }

  static R21ProviderType fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _R21ProviderType providerType =
        _encoding.entries.firstWhere((MapEntry<_R21ProviderType, int> entry) {
      return entry.value == code;
    }).key;
    R21ProviderType object = R21ProviderType._();
    object._providerype = providerType;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21ProviderType && o._providerype == _providerype;

  // override hashcode
  @override
  int get hashCode => _providerype.hashCode;

  static List<R21ProviderType> get allValues => [
        R21ProviderType.GovernmentClinic(),
        R21ProviderType.PrivateClinic(),
        R21ProviderType.Other(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_providerype];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_providerype];
}

enum _R21ProviderType { GovernmentClinic, PrivateClinic, Other }
