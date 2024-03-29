class R21PrEP {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_PrEP, int> _encoding = {
    _PrEP.No: 1,
    _PrEP.YesNotCurrently: 2,
    _PrEP.YesCurrently: 3,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_PrEP, String> _description = {
    _PrEP.No: 'No',
    _PrEP.YesNotCurrently: 'Yes, but not using currently ',
    _PrEP.YesCurrently: 'Yes, currently using PrEP',
  };

  _PrEP _prep;

  // Constructors
  // ------------

  // make default constructor private
  R21PrEP._();

  R21PrEP.No() {
    _prep = _PrEP.No;
  }

  R21PrEP.YesNotCurrently() {
    _prep = _PrEP.YesNotCurrently;
  }


  R21PrEP.YesCurrently() {
    _prep = _PrEP.YesCurrently;
  }

  static R21PrEP fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _PrEP prep =
        _encoding.entries.firstWhere((MapEntry<_PrEP, int> entry) {
      return entry.value == code;
    }).key;
    R21PrEP object = R21PrEP._();
    object._prep = prep;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21PrEP && o._prep == _prep;

  // override hashcode
  @override
  int get hashCode => _prep.hashCode;

  static List<R21PrEP> get allValues => [
        R21PrEP.No(),
        R21PrEP.YesNotCurrently(),
        R21PrEP.YesCurrently(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_prep];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_prep];
}

enum _PrEP {No,  YesNotCurrently, YesCurrently }
