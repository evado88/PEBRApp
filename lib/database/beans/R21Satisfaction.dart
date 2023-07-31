class R21Satisfaction {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_PrEP, int> _encoding = {
    _PrEP.HighlySatisfied: 1,
    _PrEP.SomewhatSatisfied: 2,
    _PrEP.SomewatDissatisfied: 3,
    _PrEP.HighlyDisatisfied: 4,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_PrEP, String> _description = {
    _PrEP.HighlySatisfied: 'Highly satisfied',
    _PrEP.SomewhatSatisfied: 'Somewhat satisfied',
    _PrEP.SomewatDissatisfied: 'Somewhat dissatisfied ',
    _PrEP.HighlyDisatisfied: 'Highly dissatisfied',
  };

  _PrEP _prep;

  // Constructors
  // ------------

  // make default constructor private
  R21Satisfaction._();

  R21Satisfaction.HighlySatisfied() {
    _prep = _PrEP.HighlySatisfied;
  }

  R21Satisfaction.SomewhatSatisfied() {
    _prep = _PrEP.SomewhatSatisfied;
  }

  R21Satisfaction.SomewatDissatisfied() {
    _prep = _PrEP.SomewatDissatisfied;
  }

  R21Satisfaction.HighlyDisatisfied() {
    _prep = _PrEP.HighlyDisatisfied;
  }

  static R21Satisfaction fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _PrEP prep =
        _encoding.entries.firstWhere((MapEntry<_PrEP, int> entry) {
      return entry.value == code;
    }).key;
    R21Satisfaction object = R21Satisfaction._();
    object._prep = prep;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is R21Satisfaction && o._prep == _prep;

  // override hashcode
  @override
  int get hashCode => _prep.hashCode;

  static List<R21Satisfaction> get allValues => [
        R21Satisfaction.HighlySatisfied(),
        R21Satisfaction.SomewhatSatisfied(),
        R21Satisfaction.SomewatDissatisfied(),
        R21Satisfaction.HighlyDisatisfied(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_prep];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_prep];
}

enum _PrEP { HighlySatisfied, SomewhatSatisfied, SomewatDissatisfied, HighlyDisatisfied }
