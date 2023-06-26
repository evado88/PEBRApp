class R21ScreenType {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_ScreenType, int> _encoding = {
    _ScreenType.Login: 1,
    _ScreenType.CreateAccount: 2,
    _ScreenType.Lock: 3,
    _ScreenType.Main: 4,
    _ScreenType.Patient: 5,
    _ScreenType.EditPatient: 6,
    _ScreenType.AddEvent: 7,
    _ScreenType.AddMedicationRefil: 8,
    _ScreenType.NewPIN: 9,
    _ScreenType.Settings: 10,
    _ScreenType.ChangePhoneNumber: 11,
    _ScreenType.IconExplanation: 12,
    _ScreenType.AddAppointment: 13,
    _ScreenType.AddFollowup: 14,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_ScreenType, String> _description = {
    _ScreenType.Login: 'Login',
    _ScreenType.CreateAccount: 'Create Account',
    _ScreenType.Lock: 'Lock:',
    _ScreenType.Main: 'Main',
    _ScreenType.Patient: 'Patient',
    _ScreenType.EditPatient: 'Edit Patient',
    _ScreenType.AddEvent: 'Add Event',
    _ScreenType.AddMedicationRefil: 'Add Medication Refil',
    _ScreenType.NewPIN: 'New PIN ',
    _ScreenType.Settings: 'Settings',
    _ScreenType.ChangePhoneNumber: 'Change Phone Number',
    _ScreenType.IconExplanation: 'Icon Explanation',
    _ScreenType.AddAppointment: 'Add Appointment',
    _ScreenType.AddFollowup: 'Add Followup',
  };

  _ScreenType _screenType;

  // Constructors
  // ------------

  // make default constructor private
  R21ScreenType._();

  R21ScreenType.Login() {
    _screenType = _ScreenType.Login;
  }

  R21ScreenType.CreateAccount() {
    _screenType = _ScreenType.CreateAccount;
  }

  R21ScreenType.Lock() {
    _screenType = _ScreenType.Lock;
  }

  R21ScreenType.Main() {
    _screenType = _ScreenType.Main;
  }

  R21ScreenType.Patient() {
    _screenType = _ScreenType.Patient;
  }

  R21ScreenType.EditPatient() {
    _screenType = _ScreenType.EditPatient;
  }

  R21ScreenType.AddEvent() {
    _screenType = _ScreenType.AddEvent;
  }

  R21ScreenType.AddMedicationRefil() {
    _screenType = _ScreenType.AddMedicationRefil;
  }

  R21ScreenType.NewPIN() {
    _screenType = _ScreenType.NewPIN;
  }
  R21ScreenType.Settings() {
    _screenType = _ScreenType.Settings;
  }
  R21ScreenType.ChangePhoneNumber() {
    _screenType = _ScreenType.ChangePhoneNumber;
  }
  R21ScreenType.IconExplanation() {
    _screenType = _ScreenType.IconExplanation;
  }
  R21ScreenType.AddAppointment() {
    _screenType = _ScreenType.AddAppointment;
  }
    R21ScreenType.AddFollowup() {
    _screenType = _ScreenType.AddFollowup;
  }
  static R21ScreenType fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _ScreenType screenType = _encoding.entries
        .firstWhere((MapEntry<_ScreenType, int> entry) {
      return entry.value == code;
    }).key;
    R21ScreenType object = R21ScreenType._();
    object._screenType = screenType;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is R21ScreenType && o._screenType == _screenType;

  // override hashcode
  @override
  int get hashCode => _screenType.hashCode;

  static List<R21ScreenType> get allValues => [
        R21ScreenType.Login(),
        R21ScreenType.CreateAccount(),
        R21ScreenType.Lock(),
        R21ScreenType.Main(),
        R21ScreenType.Patient(),
        R21ScreenType.EditPatient(),
        R21ScreenType.AddEvent(),
        R21ScreenType.AddMedicationRefil(),
        R21ScreenType.NewPIN(),
        R21ScreenType.Settings(),
        R21ScreenType.ChangePhoneNumber(),
        R21ScreenType.IconExplanation(),
        R21ScreenType.AddAppointment(),
        R21ScreenType.AddFollowup()
      ];

  /// Returns the text description of this orientation.
  String get description => _description[_screenType];

  /// Returns the code that represents this orientation.
  int get code => _encoding[_screenType];
}

enum _ScreenType {
  Login,
  CreateAccount,
  Lock,
  Main,
  Patient,
  EditPatient,
  AddEvent,
  AddMedicationRefil,
  NewPIN,
  Settings,
  ChangePhoneNumber,
  IconExplanation,
  AddAppointment,
  AddFollowup
}
