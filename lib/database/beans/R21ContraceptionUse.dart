
class R21ContraceptionUse{
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_PrEP, int> _encoding = {
    _PrEP.CurrentlyUsing: 1,
    _PrEP.NotCurrentButPast: 2,
    _PrEP.HasNever: 3,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_PrEP, String> _description = {
    _PrEP.CurrentlyUsing: 'Currently using ',
    _PrEP.NotCurrentButPast: 'Not currently using but has used in the past',
    _PrEP.HasNever: 'Has never used contraception',
  };

  _PrEP _prep;

  // Constructors
  // ------------

  // make default constructor private
  R21ContraceptionUse._();

  R21ContraceptionUse.CurrentlyUsing() {
    _prep = _PrEP.CurrentlyUsing;
  }

  R21ContraceptionUse.NotCurrentButPast() {
    _prep = _PrEP.NotCurrentButPast;
  }

  R21ContraceptionUse.HasNever() {
    _prep = _PrEP.HasNever;
  }


  static R21ContraceptionUsefromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _PrEP prep =
        _encoding.entries.firstWhere((MapEntry<_PrEP, int> entry) {
      return entry.value == code;
    }).key;
    R21ContraceptionUse object = R21ContraceptionUse._();
    object._prep = prep;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21ContraceptionUse&& o._prep == _prep;

  // override hashcode
  @override
  int get hashCode => _prep.hashCode;

  static List<R21ContraceptionUse> get allValues => [
        R21ContraceptionUse.CurrentlyUsing(),
        R21ContraceptionUse.NotCurrentButPast(),
        R21ContraceptionUse.HasNever(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_prep];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_prep];
}

enum _PrEP { CurrentlyUsing, NotCurrentButPast, HasNever }
