
class R21HIVStatus {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_PrEP, int> _encoding = {
    _PrEP.YesPositive: 1,
    _PrEP.YesNegative: 2,
    _PrEP.NotSure: 3,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_PrEP, String> _description = {
    _PrEP.YesPositive: 'Yes, Positive',
    _PrEP.YesNegative: 'Yes, Negative',
    _PrEP.NotSure: 'Not Sure',
  };

  _PrEP _prep;

  // Constructors
  // ------------

  // make default constructor private
  R21HIVStatus._();

  R21HIVStatus.YesPositive() {
    _prep = _PrEP.YesPositive;
  }

  R21HIVStatus.YesNegative() {
    _prep = _PrEP.YesNegative;
  }

  R21HIVStatus.NotSure() {
    _prep = _PrEP.NotSure;
  }


  static R21HIVStatus fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _PrEP prep =
        _encoding.entries.firstWhere((MapEntry<_PrEP, int> entry) {
      return entry.value == code;
    }).key;
    R21HIVStatus object = R21HIVStatus._();
    object._prep = prep;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21HIVStatus && o._prep == _prep;

  // override hashcode
  @override
  int get hashCode => _prep.hashCode;

  static List<R21HIVStatus> get allValues => [
        R21HIVStatus.YesPositive(),
        R21HIVStatus.YesNegative(),
        R21HIVStatus.NotSure(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_prep];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_prep];
}

enum _PrEP { YesPositive, YesNegative, NotSure }
