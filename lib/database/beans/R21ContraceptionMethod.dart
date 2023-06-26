class R21ContraceptionMethod {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_ContraceptionMethod, int> _encoding = {
    _ContraceptionMethod.CapsDiaphragms: 1,
    _ContraceptionMethod.Condoms: 2,
    _ContraceptionMethod.FemaleCondoms: 3,
    _ContraceptionMethod.Implant: 4,
    _ContraceptionMethod.Injection: 5,
    _ContraceptionMethod.Patch: 6,
    _ContraceptionMethod.IUD: 7,
    _ContraceptionMethod.IUS: 8,
    _ContraceptionMethod.Natural: 9,
    _ContraceptionMethod.CombinedPill: 10,
    _ContraceptionMethod.ProgestogenPill: 11,
    _ContraceptionMethod.VaginalRing: 12,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_ContraceptionMethod, String> _description = {
    _ContraceptionMethod.CapsDiaphragms: 'Caps or Diaphragms',
    _ContraceptionMethod.Condoms: 'Condoms',
    _ContraceptionMethod.FemaleCondoms: 'Female Condoms',
    _ContraceptionMethod.Implant: 'Contraceptive Implant',
    _ContraceptionMethod.Injection: 'Contraceptive Injection',
    _ContraceptionMethod.Patch: 'Contraceptive Patch',
    _ContraceptionMethod.IUD: 'IUD (intrauterine Device or Coil)',
    _ContraceptionMethod.IUS: 'IUS (intrauterine System or Hormonal Coil)',
    _ContraceptionMethod.Natural: 'Natural (Fertility Awareness)',
    _ContraceptionMethod.CombinedPill: 'Combined Pill',
    _ContraceptionMethod.ProgestogenPill: 'Progestogen-only Pill',
    _ContraceptionMethod.VaginalRing: 'Vaginal Ring',
  };

  _ContraceptionMethod _contraceptiveMethod;

  // Constructors
  // ------------

  // make default constructor private
  R21ContraceptionMethod._();

  R21ContraceptionMethod.CapsDiaphragms() {
    _contraceptiveMethod = _ContraceptionMethod.CapsDiaphragms;
  }

  R21ContraceptionMethod.Condoms() {
    _contraceptiveMethod = _ContraceptionMethod.Condoms;
  }

  R21ContraceptionMethod.FemaleCondoms() {
    _contraceptiveMethod = _ContraceptionMethod.FemaleCondoms;
  }

  R21ContraceptionMethod.Implant() {
    _contraceptiveMethod = _ContraceptionMethod.Implant;
  }

  R21ContraceptionMethod.Injection() {
    _contraceptiveMethod = _ContraceptionMethod.Injection;
  }

  R21ContraceptionMethod.Patch() {
    _contraceptiveMethod = _ContraceptionMethod.Patch;
  }

  R21ContraceptionMethod.IUD() {
    _contraceptiveMethod = _ContraceptionMethod.IUD;
  }

  R21ContraceptionMethod.IUS() {
    _contraceptiveMethod = _ContraceptionMethod.IUS;
  }

  R21ContraceptionMethod.Natural() {
    _contraceptiveMethod = _ContraceptionMethod.Natural;
  }
  R21ContraceptionMethod.CombinedPill() {
    _contraceptiveMethod = _ContraceptionMethod.CombinedPill;
  }
  R21ContraceptionMethod.ProgestogenPill() {
    _contraceptiveMethod = _ContraceptionMethod.ProgestogenPill;
  }
  R21ContraceptionMethod.VaginalRing() {
    _contraceptiveMethod = _ContraceptionMethod.VaginalRing;
  }

  static R21ContraceptionMethod fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _ContraceptionMethod contraceptiveMethod = _encoding.entries
        .firstWhere((MapEntry<_ContraceptionMethod, int> entry) {
      return entry.value == code;
    }).key;
    R21ContraceptionMethod object = R21ContraceptionMethod._();
    object._contraceptiveMethod = contraceptiveMethod;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21ContraceptionMethod && o._contraceptiveMethod == _contraceptiveMethod;

  // override hashcode
  @override
  int get hashCode => _contraceptiveMethod.hashCode;

  static List<R21ContraceptionMethod> get allValues => [
        R21ContraceptionMethod.CapsDiaphragms(),
        R21ContraceptionMethod.Condoms(),
        R21ContraceptionMethod.FemaleCondoms(),
        R21ContraceptionMethod.Implant(),
        R21ContraceptionMethod.Injection(),
        R21ContraceptionMethod.Patch(),
        R21ContraceptionMethod.IUD(),
        R21ContraceptionMethod.IUS(),
        R21ContraceptionMethod.Natural(),
        R21ContraceptionMethod.CombinedPill(),
        R21ContraceptionMethod.ProgestogenPill(),
        R21ContraceptionMethod.VaginalRing()
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_contraceptiveMethod];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_contraceptiveMethod];
}

enum _ContraceptionMethod {
  CapsDiaphragms,
  Condoms,
  FemaleCondoms,
  Implant,
  Injection,
  Patch,
  IUD,
  IUS,
  Natural,
  CombinedPill,
  ProgestogenPill,
  VaginalRing
}
