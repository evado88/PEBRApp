class R21YesNo {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Answer, int> _encoding = {
    _Answer.YES: 1,
    _Answer.NO: 2,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Answer, String> _description = {
    _Answer.YES: 'Yes',
    _Answer.NO: 'No',
  };

  _Answer _answer;

  // Constructors
  // ------------

  // make default constructor private
  R21YesNo._();

  R21YesNo.YES() {
    _answer = _Answer.YES;
  }

   R21YesNo.NO() {
    _answer = _Answer.NO;
  }



  static R21YesNo fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Answer answer =
        _encoding.entries.firstWhere((MapEntry<_Answer, int> entry) {
      return entry.value == code;
    }).key;
    R21YesNo object = R21YesNo._();
    object._answer = answer;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is R21YesNo && o._answer == _answer;

  // override hashcode
  @override
  int get hashCode => _answer.hashCode;

  static List<R21YesNo> get allValues => [
        R21YesNo.YES(),
        R21YesNo.NO(),
      ];

  /// Returns the text description of this answer.
  String get description => _description[_answer];

  /// Returns the code that represents this answer.
  int get code => _encoding[_answer];
}

enum _Answer { YES, NO}
