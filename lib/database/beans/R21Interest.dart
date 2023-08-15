class R21Interest {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_PrEP, int> _encoding = {
    _PrEP.VeryInterested: 1,
    _PrEP.MaybeInterested: 2,
    _PrEP.NoInterested: 3,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_PrEP, String> _description = {
    _PrEP.VeryInterested: 'Very interested in starting/switching now',
    _PrEP.MaybeInterested: 'Maybe interested',
    _PrEP.NoInterested: 'Not at all interested',
  };

  _PrEP _prep;

  // Constructors
  // ------------

  // make default constructor private
  R21Interest._();

  R21Interest.VeryInterested() {
    _prep = _PrEP.VeryInterested;
  }

  R21Interest.MaybeInterested() {
    _prep = _PrEP.MaybeInterested;
  }


  R21Interest.NoInterested() {
    _prep = _PrEP.NoInterested;
  }

  static R21Interest fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _PrEP prep =
        _encoding.entries.firstWhere((MapEntry<_PrEP, int> entry) {
      return entry.value == code;
    }).key;
    R21Interest object = R21Interest._();
    object._prep = prep;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21Interest && o._prep == _prep;

  // override hashcode
  @override
  int get hashCode => _prep.hashCode;

  static List<R21Interest> get allValues => [
        R21Interest.VeryInterested(),
        R21Interest.MaybeInterested(),
        R21Interest.NoInterested(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_prep];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_prep];
}

enum _PrEP {VeryInterested,  MaybeInterested, NoInterested }
