class NoChatDownloadReason {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Reason, int> _encoding = {
    _Reason.WILL_DOWNLOAD: 1,
    _Reason.NO_INTEREST: 2,
    _Reason.NO_INTERNET_BUNDLE: 3,
    _Reason.OTHER: 4,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Reason, String> _description = {
    _Reason.WILL_DOWNLOAD: 'Will Download Later',
    _Reason.NO_INTEREST: 'No interest to participate',
    _Reason.NO_INTERNET_BUNDLE: 'No Internet Bundles',
    _Reason.OTHER: 'Other...',
  };

  _Reason _reason;

  // Constructors
  // ------------

  // make default constructor private
  NoChatDownloadReason._();

  NoChatDownloadReason.NO_TIME() {
    _reason = _Reason.WILL_DOWNLOAD;
  }

  NoChatDownloadReason.NO_INTEREST() {
    _reason = _Reason.NO_INTEREST;
  }

  NoChatDownloadReason.MISTRUST() {
    _reason = _Reason.NO_INTERNET_BUNDLE;
  }

  NoChatDownloadReason.OTHER() {
    _reason = _Reason.OTHER;
  }

  static NoChatDownloadReason fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Reason reason =
        _encoding.entries.firstWhere((MapEntry<_Reason, int> entry) {
      return entry.value == code;
    }).key;
    NoChatDownloadReason object = NoChatDownloadReason._();
    object._reason = reason;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is NoChatDownloadReason && o._reason == _reason;

  // override hashcode
  @override
  int get hashCode => _reason.hashCode;

  static List<NoChatDownloadReason> get allValues => [
        NoChatDownloadReason.NO_TIME(),
        NoChatDownloadReason.NO_INTEREST(),
        NoChatDownloadReason.MISTRUST(),
        NoChatDownloadReason.OTHER(),
      ];

  /// Returns the text description of this reason.
  String get description => _description[_reason];

  /// Returns the code that represents this reason.
  int get code => _encoding[_reason];
}

enum _Reason { WILL_DOWNLOAD, NO_INTEREST, NO_INTERNET_BUNDLE, OTHER }
