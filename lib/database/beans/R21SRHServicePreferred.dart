class R21SRHServicePreferred {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_R21SRHServicePreferred, int> _encoding = {
    _R21SRHServicePreferred.All: 1,
    _R21SRHServicePreferred.FamilyPlanning: 2,
    _R21SRHServicePreferred.MaternalChildHealthCare: 3,
    _R21SRHServicePreferred.GBVPreventionManagement: 4,
    _R21SRHServicePreferred.STIPreventionManagement: 5,
    _R21SRHServicePreferred.NotSpecified: 6,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_R21SRHServicePreferred, String> _description = {
    _R21SRHServicePreferred.All: 'All',
    _R21SRHServicePreferred.FamilyPlanning: 'Family Planning',
    _R21SRHServicePreferred.MaternalChildHealthCare:
        'Maternal and Child Health Care',
    _R21SRHServicePreferred.GBVPreventionManagement:
        'GBV Prevention and Management',
    _R21SRHServicePreferred.STIPreventionManagement:
        'STI Prevention and Management',
    _R21SRHServicePreferred.NotSpecified: 'Not Specified',
  };

  _R21SRHServicePreferred _srhServicePreferred;

  // Constructors
  // ------------

  // make default constructor private
  R21SRHServicePreferred._();

  R21SRHServicePreferred.All() {
    _srhServicePreferred = _R21SRHServicePreferred.All;
  }

  R21SRHServicePreferred.FamilyPlanning() {
    _srhServicePreferred = _R21SRHServicePreferred.FamilyPlanning;
  }

  R21SRHServicePreferred.MaternalChildHealthCare() {
    _srhServicePreferred = _R21SRHServicePreferred.MaternalChildHealthCare;
  }

  R21SRHServicePreferred.GBVPreventionManagement() {
    _srhServicePreferred = _R21SRHServicePreferred.GBVPreventionManagement;
  }

  R21SRHServicePreferred.STIPreventionManagement() {
    _srhServicePreferred = _R21SRHServicePreferred.STIPreventionManagement;
  }
  R21SRHServicePreferred.NotSpecified() {
    _srhServicePreferred = _R21SRHServicePreferred.NotSpecified;
  }

  static R21SRHServicePreferred fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _R21SRHServicePreferred srchServicePreferred = _encoding.entries
        .firstWhere((MapEntry<_R21SRHServicePreferred, int> entry) {
      return entry.value == code;
    }).key;
    R21SRHServicePreferred object = R21SRHServicePreferred._();
    object._srhServicePreferred = srchServicePreferred;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21SRHServicePreferred && o._srhServicePreferred == _srhServicePreferred;

  // override hashcode
  @override
  int get hashCode => _srhServicePreferred.hashCode;

  static List<R21SRHServicePreferred> get allValues => [
        R21SRHServicePreferred.All(),
        R21SRHServicePreferred.FamilyPlanning(),
        R21SRHServicePreferred.MaternalChildHealthCare(),
        R21SRHServicePreferred.GBVPreventionManagement(),
        R21SRHServicePreferred.STIPreventionManagement(),
        R21SRHServicePreferred.NotSpecified(),
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_srhServicePreferred];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_srhServicePreferred];
}


enum _R21SRHServicePreferred {
  All,
  FamilyPlanning,
  MaternalChildHealthCare,
  GBVPreventionManagement,
  STIPreventionManagement,
  NotSpecified
}
