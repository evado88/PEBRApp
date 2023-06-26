class R21PrEP {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_PrEP, int> _encoding = {
    _PrEP.Yes: 1,
    _PrEP.No: 2,
    _PrEP.Stopped: 3,
    _PrEP.NotSpecified: 4,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_PrEP, String> _description = {
    _PrEP.Yes: 'Yes',
    _PrEP.No: 'No',
    _PrEP.Stopped: 'Stopped',
    _PrEP.NotSpecified: 'Not Specified',
  };

  _PrEP _prep;

  // Constructors
  // ------------

  // make default constructor private
  R21PrEP._();

  R21PrEP.Yes() {
    _prep = _PrEP.Yes;
  }

  R21PrEP.No() {
    _prep = _PrEP.No;
  }

  R21PrEP.Stopped() {
    _prep = _PrEP.Stopped;
  }

  R21PrEP.NotSpecified() {
    _prep = _PrEP.NotSpecified;
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
        R21PrEP.Yes(),
        R21PrEP.No(),
        R21PrEP.Stopped(),
        R21PrEP.NotSpecified(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_prep];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_prep];
}

enum _PrEP { Yes, No, Stopped, NotSpecified }
