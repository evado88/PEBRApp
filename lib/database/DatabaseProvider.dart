import 'dart:async';
import 'package:pebrapp/config/PebraCloudConfig.dart';
import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/R21ExportInfo.dart';
import 'package:pebrapp/database/beans/RefillType.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/R21Appointment.dart';
import 'package:pebrapp/database/models/R21Event.dart';
import 'package:pebrapp/database/models/R21Followup.dart';
import 'package:pebrapp/database/models/R21MedicationRefill.dart';
import 'package:pebrapp/database/models/R21ScreenAnalytic.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/SupportOptionDone.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/exceptions/NoLoginDataException.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:pebrapp/utils/PebraCloudUtils.dart';

/// Access to the SQFLite database.
/// Get an instance either via `DatabaseProvider.instance` or via the singleton constructor `DatabaseProvider()`.
class DatabaseProvider {
  // Increase the _DB_VERSION number if you made changes to the database schema.
  // An increase will call the [_onUpgrade] method.
  static const int _DB_VERSION = 1;
  // Do not access the _database directly (it might be null), instead use the
  // _databaseInstance getter which will initialize the database if it is
  // uninitialized
  static Database _database;
  static const String _dbFilename = "PEBRApp.db";
  static final DatabaseProvider _instance = DatabaseProvider._();

  // private constructor for Singleton pattern
  DatabaseProvider._();
  factory DatabaseProvider() {
    return _instance;
  }

  // Private Methods
  // ---------------

  get _databaseInstance async {
    if (_database == null) {
      // if _database is null we instantiate it
      await _initDB();
    }
    return _database;
  }

  Future<File> get _databaseFile async {
    return File(await databaseFilePath);
  }

  _initDB() async {
    String path = await databaseFilePath;
    print('opening database at $path');
    _database = await openDatabase(path,
        version: _DB_VERSION,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade);
  }

  /// Gets called if the database does not exist.
  FutureOr<void> _onCreate(Database db, int version) async {
    print('Creating database with version $version');
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${Patient.tableName} (
          ${Patient.colUtilityId} INTEGER PRIMARY KEY, -- utility
          ${Patient.colUtilityEnrollmentDate} TEXT NULL,
          ${Patient.colPersonalStudyNumber} TEXT NULL, --personal
          ${Patient.colPersonalBirthday} TEXT NULL,
          ${Patient.colMessengerDownloaded} INTEGER NULL,  --messenger
          ${Patient.colMessengerNoDownloadReason} TEXT NULL,
          ${Patient.colContactPhoneNumber} TEXT NULL, --contact
          ${Patient.colContactOwnPhone} INTEGER NULL,
          ${Patient.colContactResidency} INTEGER NULL,
          ${Patient.colContactPrefferedContactMethod} INTEGER NULL,
          ${Patient.colContactContactFrequency} INTEGER NULL,
          ${Patient.colHistoryContraceptionUse} INTEGER NULL, -- history contraception
          ${Patient.colHistoryContraceptiontMaleCondom} BIT NULL,
          ${Patient.colHistoryContraceptionFemaleCondom} BIT NULL,
          ${Patient.colHistoryContraceptionImplant} BIT NULL,
          ${Patient.colHistoryContraceptionInjection} BIT NULL,
          ${Patient.colHistoryContraceptionIUD} BIT NULL,
          ${Patient.colHistoryContraceptionIUS} BIT NULL,
          ${Patient.colHistoryContraceptionPills} BIT NULL,
          ${Patient.colHistoryContraceptionOther} BIT NULL,
          ${Patient.colHistoryContraceptionOtherSpecify} TEXT NULL,
          ${Patient.colHistoryContraceptionSatisfaction} INTEGER NULL,
          ${Patient.colHistoryContraceptionSatisfactionReason} TEXT NULL,
          ${Patient.colHistoryHIVKnowStatus} INTEGER NULL, -- history hiv
          ${Patient.colHistoryHIVLastTest} TEXT NULL, 
          ${Patient.colHistoryHIVUsedPrep} INTEGER NULL,
          ${Patient.colHistoryHIVPrepLastRefil} TEXT NULL, 
          ${Patient.colHistoryHIVPrepLastRefilSource} INTEGER NULL,
          ${Patient.colHistoryHIVPrepLastRefilSourceSpecify} TEXT NULL, 
          ${Patient.colHistoryHIVPrepProblems} TEXT NULL,
          ${Patient.colHistoryHIVPrepQuestions} TEXT NULL,
          ${Patient.colHistoryHIVTakingART} INTEGER NULL,
          ${Patient.colHistoryHIVLastRefil} TEXT NULL, 
          ${Patient.colHistoryHIVLastRefilSource} INTEGER NULL,
          ${Patient.colHistoryHIVLastRefilSourceSpecify} TEXT NULL, 
          ${Patient.colHistoryHIVARTProblems} TEXT NULL,
          ${Patient.colHistoryHIVARTQuestions} TEXT NULL,
          ${Patient.colHistoryHIVDesiredSupportRemindersAppointments} BIT NULL,
          ${Patient.colHistoryHIVDesiredSupportRemindersCheckins} BIT NULL,
          ${Patient.colHistoryHIVDesiredSupportRefilsAccompany} BIT NULL,
          ${Patient.colHistoryHIVDesiredSupportRefilsPAAccompany} BIT NULL,
          ${Patient.colHistoryHIVDesiredSupportOther} BIT NULL,
          ${Patient.colHistoryHIVDesiredSupportOtherSpecify} TEXT NULL,
          ${Patient.colHistoryHIVPrepDesiredSupportRemindersAppointments} BIT NULL,
          ${Patient.colHistoryHIVPrepDesiredSupportRemindersAdherence} BIT NULL,
          ${Patient.colHistoryHIVPrepDesiredSupportRefilsPNAccompany} BIT NULL,
          ${Patient.colHistoryHIVPrepDesiredSupportPNHIVKit} BIT NULL,
          ${Patient.colHistoryHIVPrepDesiredSupportOther} BIT NULL,
          ${Patient.colHistoryHIVPrepDesiredSupportOtherSpecify} TEXT NULL,
          ${Patient.colSRHContraceptionInterest} INTEGER NULL, -- srh contraception
          ${Patient.colSRHContraceptionNoInterestReason} INTEGER NULL,
          ${Patient.colSRHContraceptionInterestMaleCondom} BIT NULL, 
          ${Patient.colSRHContraceptionInterestFemaleCondom} BIT NULL, 
          ${Patient.colSRHContraceptionInterestImplant} BIT NULL, 
          ${Patient.colSRHContraceptionInterestInjection} BIT NULL, 
          ${Patient.colSRHContraceptionInterestIUD} BIT NULL, 
          ${Patient.colSRHContraceptionInterestIUS} BIT NULL, 
          ${Patient.colSRHContraceptionInterestPills} BIT NULL, 
          ${Patient.colSRHContraceptionInterestOther} BIT NULL, 
          ${Patient.colSRHContraceptionInterestOtherSpecify} TEXT NULL,
          ${Patient.colSRHContraceptionMethodInMind} INTEGER NULL,
          ${Patient.colSRHContraceptionInformationMethods} INTEGER NULL,
          ${Patient.colSRHContraceptionFindScheduleFacility} INTEGER NULL,
          ${Patient.colSRHContraceptionFindScheduleFacilityYesDate} TEXT NULL,
          ${Patient.colSRHContraceptionFindScheduleFacilityYesPNAccompany} INTEGER NULL,
          ${Patient.colSRHContraceptionFindScheduleFacilityNoDate} TEXT NULL,
          ${Patient.colSRHContraceptionFindScheduleFacilityNoPick} INTEGER NULL,
          ${Patient.colSRHContraceptionFindScheduleFacilitySelected} TEXT NULL,
          ${Patient.colSRHContraceptionFindScheduleFacilityOther} INTEGER NULL,
          ${Patient.colSRHContraceptionInformationApp} INTEGER NULL,
          ${Patient.colSRHContraceptionLearnMethods} INTEGER NULL,
          ${Patient.colSRHPrePInterest} INTEGER NULL, -- srh prep
          ${Patient.colSRHPrePInformationApp} INTEGER NULL, 
          ${Patient.colSRHPrePFindScheduleFacility} INTEGER NULL, 
          ${Patient.colSRHPrePFindScheduleFacilityYesDate} TEXT NULL, 
          ${Patient.colSRHPrePFindScheduleFacilityYesPNAccompany} INTEGER NULL, 
          ${Patient.colSRHPrePFindScheduleFacilityNoDate} TEXT NULL, 
          ${Patient.colSRHPrePFindScheduleFacilityNoPick} INTEGER NULL, 
          ${Patient.colSRHPrePFindScheduleFacilitySelected} TEXT NULL, 
          ${Patient.colSRHPrePFindScheduleFacilityOther} TEXT NULL, 
          ${Patient.colSRHPrePInformationRead} INTEGER NULL, 
        );
        """);


    // R21Followup table:
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${R21Followup.tableName} (
          ${R21Event.colId} INTEGER PRIMARY KEY,
          ${R21Event.colCreatedDate} TEXT NOT NULL,
          ${R21Event.colPatientART} TEXT NOT NULL,
          ${R21Event.colDate} TEXT NOT NULL,
          ${R21Event.colDescription} TEXT NOT NULL,
          ${R21Event.colOccured} BIT NOT NULL,
          ${R21Event.colNoOccurReason} INTEGER,
          ${R21Event.colNextDate} TEXT NOT NULL
        );
        """);


    // R21ScreenAnalytic table:
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${R21ScreenAnalytic.tableName} (
          ${R21ScreenAnalytic.colId} INTEGER PRIMARY KEY,
          ${R21ScreenAnalytic.colCreatedDate} TEXT NOT NULL,
          ${R21ScreenAnalytic.colType} INTEGER NOT NULL,
          ${R21ScreenAnalytic.colStartDate} TEXT NOT NULL,
          ${R21ScreenAnalytic.colEndDate} TEXT NOT NULL,
          ${R21ScreenAnalytic.colDuration} INTEGER NOT NULL,
          ${R21ScreenAnalytic.colResult} TEXT,
          ${R21ScreenAnalytic.colSubject} TEXT
        );
        """);


    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${UserData.tableName} (
          ${UserData.colId} INTEGER PRIMARY KEY,
          ${UserData.colCreatedDate} TEXT NOT NULL,
          ${UserData.colFirstName} TEXT NOT NULL,
          ${UserData.colLastName} TEXT NOT NULL,
          ${UserData.colUsername} TEXT NOT NULL,
          ${UserData.colPhoneNumber} TEXT NOT NULL,
          ${UserData.colPhoneNumberUploadRequired} BIT NOT NULL,
          ${UserData.colIsActive} BIT NOT NULL,
          ${UserData.colDeactivatedDate} TEXT
        );
        """);
    // RequiredAction table:
    // Each [RequiredAction.type] can only occur once per patient. The unique
    // constraint enforces that and allows us to insert actions redundantly.
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${RequiredAction.tableName} (
          ${RequiredAction.colId} INTEGER PRIMARY KEY,
          ${RequiredAction.colCreatedDate} TEXT NOT NULL,
          ${RequiredAction.colPatientART} TEXT NOT NULL,
          ${RequiredAction.colType} INTEGER NOT NULL,
          ${RequiredAction.colDueDate} TEXT NOT NULL,
          UNIQUE(${RequiredAction.colPatientART}, ${RequiredAction.colType}) ON CONFLICT IGNORE
        );
        """);
  }

  /// Gets called if the defined database version is higher than the current
  /// database version on the device.
  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to version $newVersion');
    print('New R21 - No need of previous databases');
  }

  FutureOr<void> _onDowngrade(
      Database db, int oldVersion, int newVersion) async {
    print(
        'Downgrading database from version $oldVersion to version $newVersion');
    print('NOT IMPLEMENTED, DATA WILL BE RESET!');
    await db.execute("DROP TABLE IF EXISTS ARTRefill;");
    await db.execute("DROP TABLE IF EXISTS Patient;");
    await db.execute("DROP TABLE IF EXISTS PreferenceAssessment;");
    await db.execute("DROP TABLE IF EXISTS RequiredAction;");
    await db.execute("DROP TABLE IF EXISTS SupportOptionDone;");
    await db.execute("DROP TABLE IF EXISTS ViralLoad;");
    await db.execute(
        "DROP TABLE IF EXISTS UserData;"); // Removing the UserData table will result in a login loop -> user has to create a new account
    await _onCreate(db, newVersion);
    showFlushbar('Please create a new account to continue using the app.',
        title: 'App Downgraded', error: true);
  }

  // Public Methods
  // --------------

  /// Get the full file system path of the sql lite database file,
  /// e.g., /data/user/0/com.twyshe/databases/PEBRApp.db
  Future<String> get databaseFilePath async {
    return join(await databasesDirectoryPath, _dbFilename);
  }

  /// Get the system path of the directory where the sql lite databases
  /// are stored, e.g., /data/user/0/com.twyshe/databases
  Future<String> get databasesDirectoryPath async {
    return getDatabasesPath();
  }

  /// Erases all data from the database.
  Future<void> resetDatabase() async {
    // close database
    final Database db = await _databaseInstance;
    await db.close();
    // delete database file
    final File dbFile = await _databaseFile;
    await dbFile.delete();
    // initialize new empty database
    await _initDB();
  }

  Future<File> _createFileWithContent(String filename, String content) async {
    final String filepath = join(await databasesDirectoryPath, filename);
    final file = File(filepath);
    return file.writeAsString(content, flush: true);
  }

  /// Backs up the SQLite database file and password file and exports the data
  /// as Excel file to PEBRAcloud. This method is slightly different from
  /// [createAdditionalBackupOnServer]: It includes the password file in the
  /// upload and stores [loginData] in the database before uploading.
  ///
  /// Throws [NoLoginDataException] if the [loginData] object is null.
  ///
  /// Throws [PebraCloudAuthFailedException] if the login to PEBRAcloud fails.
  ///
  /// Throws [SocketException] if there is no internet connection or PEBRAcloud
  /// cannot be reached.
  ///
  /// Throws [HTTPStatusNotOKException] if PEBRAcloud fails to receive the file.
  Future<void> createFirstBackupOnServer(
      UserData loginData, String pinCodeHash) async {
    if (loginData == null) {
      throw NoLoginDataException();
    }
    // store the user data in the database before creating the first backup
    await insertUserData(loginData);
    final File dbFile = await _databaseFile;

    R21ExportInfo exportInfo =
        await DatabaseExporter.exportDatabaseToExcelFile(loginData);

    final File excelFile = exportInfo.excelFile;

    final File passwordFile =
        await _createFileWithContent('PEBRA-password', pinCodeHash);
    // upload SQLite, password file, and Excel file
    final String filename =
        '${loginData.username}_${loginData.firstName}_${loginData.lastName}';
    await uploadFileToPebraCloud(dbFile, PEBRA_CLOUD_BACKUP_FOLDER,
        filename: '$filename.db');

    await uploadFileToPebraCloud(passwordFile, PEBRA_CLOUD_PASSWORD_FOLDER,
        filename: '${loginData.username}.txt');

    await uploadFileToPebraCloud(excelFile, PEBRA_CLOUD_DATA_FOLDER,
        filename: '$filename.xlsx');

    //R21 save json file
    await uploadJsonToPebraCloud(loginData.username, exportInfo.json);

    await storeLatestBackupInSharedPrefs();
  }

  /// Backs up the SQLite database file and exports the data as Excel file to
  /// PEBRAcloud.
  ///
  /// Throws [NoLoginDataException] if the [loginData] object is null.
  ///
  /// Throws [PebraCloudAuthFailedException] if the login to PEBRAcloud fails.
  ///
  /// Throws [SocketException] if there is no internet connection or PEBRAcloud
  /// cannot be reached.
  ///
  /// Throws [HTTPStatusNotOKException] if PEBRAcloud fails to receive the file.
  Future<void> createAdditionalBackupOnServer(UserData loginData) async {
    if (loginData == null) {
      throw NoLoginDataException();
    }
    final File dbFile = await _databaseFile;

    R21ExportInfo exportInfo =
        await DatabaseExporter.exportDatabaseToExcelFile(loginData);

    final File excelFile = exportInfo.excelFile;
    // update SQLite and Excel file with new version
    final String docName =
        '${loginData.username}_${loginData.firstName}_${loginData.lastName}';

    await uploadFileToPebraCloud(dbFile, PEBRA_CLOUD_BACKUP_FOLDER,
        filename: '$docName.db');

    await uploadFileToPebraCloud(excelFile, PEBRA_CLOUD_DATA_FOLDER,
        filename: '$docName.xlsx');

    //R21 save json file
    await uploadJsonToPebraCloud(loginData.username, exportInfo.json);

    await storeLatestBackupInSharedPrefs();
  }

  Future<void> restoreFromFile(File backup) async {
    // close database
    final Database db = await _databaseInstance;
    await db.close();
    // move new database file into place
    final String dbFilePath = await databaseFilePath;
    await backup.copy(dbFilePath);
    // load new database
    await _initDB();
    // remove backup file
    await backup.delete();
  }

  Future<void> insertPatient(Patient newPatient) async {
    final Database db = await _databaseInstance;
    //newPatient.createdDate = DateTime.now();
    final res = await db.insert(Patient.tableName, newPatient.toMap());
    return res;
  }

  Future<void> insertEvent(R21Event event, {DateTime createdDate}) async {
    final Database db = await _databaseInstance;
    event.createdDate = createdDate ?? DateTime.now();
    final res = await db.insert(R21Event.tableName, event.toMap());
    return res;
  }

  Future<void> insertAppointment(R21Appointment appointment,
      {DateTime createdDate}) async {
    final Database db = await _databaseInstance;
    appointment.createdDate = createdDate ?? DateTime.now();
    final res = await db.insert(R21Appointment.tableName, appointment.toMap());
    return res;
  }

  Future<void> insertFollowup(R21Followup followup,
      {DateTime createdDate}) async {
    final Database db = await _databaseInstance;
    followup.createdDate = createdDate ?? DateTime.now();
    final res = await db.insert(R21Followup.tableName, followup.toMap());
    return res;
  }

  Future<void> insertMedicationRefil(R21MedicationRefill refil,
      {DateTime createdDate}) async {
    final Database db = await _databaseInstance;
    refil.createdDate = createdDate ?? DateTime.now();
    final res = await db.insert(R21MedicationRefill.tableName, refil.toMap());
    return res;
  }

  Future<void> insertScreenAnalytic(R21ScreenAnalytic analytic,
      {DateTime createdDate}) async {
    final Database db = await _databaseInstance;
    analytic.createdDate = createdDate ?? DateTime.now();
    final res = await db.insert(R21ScreenAnalytic.tableName, analytic.toMap());
    return res;
  }

  Future<void> insertViralLoad(ViralLoad viralLoad,
      {DateTime createdDate}) async {
    final Database db = await _databaseInstance;
    viralLoad.createdDate = createdDate ?? DateTime.now();
    final res = await db.insert(ViralLoad.tableName, viralLoad.toMap());
    return res;
  }

  /// Sets the discrepancy attribute to true by updating row for the given [vl].
  Future<void> setViralLoadDiscrepancy(ViralLoad vl) async {
    vl.discrepancy = true;
    final Database db = await _databaseInstance;
    final res = await db.update(
      ViralLoad.tableName,
      vl.toMap(),
      where:
          '${ViralLoad.colPatientART} = ? AND ${ViralLoad.colViralLoadSource} = ? AND ${ViralLoad.colCreatedDate} = ? AND ${ViralLoad.colDateOfBloodDraw} = ? AND ${ViralLoad.colLabNumber} = ? AND ${ViralLoad.colFailed} = ?',
      whereArgs: [
        vl.patientART,
        vl.source.code,
        vl.createdDate.toIso8601String(),
        vl.dateOfBloodDraw.toIso8601String(),
        vl.labNumber,
        vl.failed
      ],
    );
    assert(res <= 1);
    return res;
  }



  /// Retrieves only the latest patients from the database, i.e. the ones with the latest changes.
  ///
  /// SQL Query:
  /// SELECT Patient.* FROM Patient INNER JOIN (
  ///	  SELECT id, MAX(created_date) FROM Patient GROUP BY art_number
  ///	) latest ON Patient.id == latest.id
  /// WHERE Patient.is_eligible == x AND Patient.consent_given == x
  ///
  /// @param [retrieveNonEligibles] Whether patients which are not eligible
  /// should also be retrieved. If false, only eligible patients are retrieved.
  ///
  /// @param [retrieveNonConsents] Whether patients which did not give consent
  /// should also be retrieved. If false, only patients which gave their consent
  /// are retrieved.
  Future<List<Patient>> retrieveLatestPatients(
      {retrieveNonEligibles: true, retrieveNonConsents: true}) async {
    final Database db = await _databaseInstance;
    List<Map<String, dynamic>> res;

    res = await db.rawQuery("""
    SELECT ${Patient.tableName}.* FROM ${Patient.tableName}
    """);

    List<Patient> list = List<Patient>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        Patient p = Patient.fromMap(map);
        await p.initializeEventsField();
        await p.initializeFollowupsField();
        await p.initializePreferenceAssessmentField();
        await p.initializeRequiredActionsField();

        //R21
        await p.initializeRecentFields();
        await p.initializeMedicationRefilsField();
        list.add(p);
      }
    }
    return list;
  }

  /// Inserts a [PreferenceAssessment] object into database and return the id
  /// given by the database.
  Future<int> insertPreferenceAssessment(
      PreferenceAssessment newPreferenceAssessment) async {
    final Database db = await _databaseInstance;
    newPreferenceAssessment.createdDate = DateTime.now();
    return db.insert(
        PreferenceAssessment.tableName, newPreferenceAssessment.toMap());
  }

  Future<void> insertUserData(UserData userData) async {
    final Database db = await _databaseInstance;
    userData.createdDate = DateTime.now();
    final res = await db.insert(UserData.tableName, userData.toMap());
    return res;
  }

  Future<void> insertRequiredAction(RequiredAction action) async {
    final Database db = await _databaseInstance;
    action.createdDate = DateTime.now();
    final res = await db.insert(RequiredAction.tableName, action.toMap());
    return res;
  }

  Future<void> removeRequiredAction(
      String patientART, RequiredActionType type) async {
    final Database db = await _databaseInstance;
    final int rowsDeleted = await db.delete(
      RequiredAction.tableName,
      where:
          "${RequiredAction.colPatientART} = ? AND ${RequiredAction.colType} = ?",
      whereArgs: [patientART, type.index],
    );
  }

  /// Sets the 'is_active' column to false (0) for the latest active user.
  Future<void> deactivateCurrentUser() async {
    final Database db = await _databaseInstance;
    final UserData latestUser = await retrieveLatestUserData();
    if (latestUser != null) {
      final map = {
        UserData.colIsActive: 0,
        UserData.colDeactivatedDate: DateTime.now().toIso8601String(),
      };
      db.update(
        UserData.tableName,
        map,
        where: '${UserData.colUsername} = ?',
        whereArgs: [latestUser.username],
      );
    }
  }

  Future<List<ViralLoad>> retrieveViralLoadsForPatient(
      String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
      ViralLoad.tableName,
      where: '${ViralLoad.colPatientART} = ?',
      whereArgs: [patientART],
    );
    if (res.length > 0) {
      final List<ViralLoad> vls = res
          .map((Map<dynamic, dynamic> map) => ViralLoad.fromMap(map))
          .toList();
      sortViralLoads(vls);
      return vls;
    }
    return [];
  }

  Future<List<R21Event>> retrieveEventsForPatient(String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
      R21Event.tableName,
      where: '${R21Event.colPatientART} = ?',
      whereArgs: [patientART],
    );
    if (res.length > 0) {
      final List<R21Event> events = res
          .map((Map<dynamic, dynamic> map) => R21Event.fromMap(map))
          .toList();
      return events;
    }
    return [];
  }

  Future<List<R21Appointment>> retrieveAppointmentsForPatient(
      String patientART) async {
    final Database db = await _databaseInstance;

    final List<Map> res = await db.query(
      R21Appointment.tableName,
      where: '${R21Appointment.colPatientART} = ?',
      whereArgs: [patientART],
    );
    if (res.length > 0) {
      final List<R21Appointment> events = res
          .map((Map<dynamic, dynamic> map) => R21Appointment.fromMap(map))
          .toList();
      return events;
    }
    return [];
  }

  Future<List<R21Followup>> retrieveFollowupsForPatient(
      String patientART) async {
    final Database db = await _databaseInstance;

    final List<Map> res = await db.query(
      R21Followup.tableName,
      where: '${R21Followup.colPatientART} = ?',
      whereArgs: [patientART],
    );
    if (res.length > 0) {
      final List<R21Followup> events = res
          .map((Map<dynamic, dynamic> map) => R21Followup.fromMap(map))
          .toList();
      return events;
    }
    return [];
  }

  Future<List<R21MedicationRefill>> retrieveMedicationRefilsForPatient(
      String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
      R21MedicationRefill.tableName,
      where: '${R21MedicationRefill.colPatientART} = ?',
      whereArgs: [patientART],
    );
    if (res.length > 0) {
      final List<R21MedicationRefill> events = res
          .map((Map<dynamic, dynamic> map) => R21MedicationRefill.fromMap(map))
          .toList();
      return events;
    }
    return [];
  }

  Future<List<R21ScreenAnalytic>> retrieveScreenAnalytics() async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
      R21ScreenAnalytic.tableName,
    );
    if (res.length > 0) {
      final List<R21ScreenAnalytic> analytics = res
          .map((Map<dynamic, dynamic> map) => R21ScreenAnalytic.fromMap(map))
          .toList();
      return analytics;
    }
    return [];
  }

  Future<PreferenceAssessment> retrieveLatestPreferenceAssessmentForPatient(
      String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(PreferenceAssessment.tableName,
        where: '${PreferenceAssessment.colPatientART} = ?',
        whereArgs: [patientART],
        orderBy: '${PreferenceAssessment.colCreatedDate} DESC');
    if (res.length > 0) {
      final PreferenceAssessment pa = PreferenceAssessment.fromMap(res.first);
      await pa.initializeSupportOptionDoneFields();
      return pa;
    }
    return null;
  }

  /// Only retrieves latest active user data.
  Future<UserData> retrieveLatestUserData() async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(UserData.tableName,
        where: '${UserData.colIsActive} = 1',
        orderBy: '${UserData.colCreatedDate} DESC');
    if (res.length > 0) {
      return UserData.fromMap(res.first);
    }
    return null;
  }

  Future<void> insertARTRefill(ARTRefill newARTRefill) async {
    final Database db = await _databaseInstance;
    newARTRefill.createdDate = DateTime.now();
    final res = await db.insert(ARTRefill.tableName, newARTRefill.toMap());
    return res;
  }

  Future<void> insertSupportOptionDone(SupportOptionDone supportOptionDone,
      {DateTime createdDate}) async {
    final Database db = await _databaseInstance;
    supportOptionDone.createdDate = createdDate ?? DateTime.now();
    final res =
        await db.insert(SupportOptionDone.tableName, supportOptionDone.toMap());
    return res;
  }

  Future<ARTRefill> retrieveLatestARTRefillForPatient(String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(ARTRefill.tableName,
        where: '${ARTRefill.colPatientART} = ?',
        whereArgs: [patientART],
        orderBy: '${ARTRefill.colCreatedDate} DESC');
    if (res.length > 0) {
      return ARTRefill.fromMap(res.first);
    }
    return null;
  }

  Future<R21MedicationRefill> retrieveLatestMedicationRefillForPatient(
      String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(R21MedicationRefill.tableName,
        where: '${R21MedicationRefill.colPatientART} = ?',
        whereArgs: [patientART],
        orderBy: '${R21MedicationRefill.colCreatedDate} DESC');
    if (res.length > 0) {
      return R21MedicationRefill.fromMap(res.first);
    }
    return null;
  }

  Future<R21Event> retrieveLatestEventForPatient(String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(R21Event.tableName,
        where: '${R21Event.colPatientART} = ?',
        whereArgs: [patientART],
        orderBy: '${R21Event.colCreatedDate} DESC');
    if (res.length > 0) {
      return R21Event.fromMap(res.first);
    }
    return null;
  }

  Future<R21Appointment> retrieveLatestAppointmentForPatient(
      String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(R21Appointment.tableName,
        where: '${R21Appointment.colPatientART} = ?',
        whereArgs: [patientART],
        orderBy: '${R21Appointment.colCreatedDate} DESC');
    if (res.length > 0) {
      return R21Appointment.fromMap(res.first);
    }
    return null;
  }

  Future<R21Followup> retrieveLatestFollowupForPatient(
      String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(R21Followup.tableName,
        where: '${R21Followup.colPatientART} = ?',
        whereArgs: [patientART],
        orderBy: '${R21Followup.colCreatedDate} DESC');
    if (res.length > 0) {
      return R21Followup.fromMap(res.first);
    }
    return null;
  }

  Future<ARTRefill> retrieveLatestDoneARTRefillForPatient(
      String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(ARTRefill.tableName,
        where:
            '${ARTRefill.colPatientART} = ? AND ${ARTRefill.colRefillType} != ?',
        whereArgs: [patientART, RefillType.NOT_DONE().code],
        orderBy: '${ARTRefill.colCreatedDate} DESC');
    if (res.length > 0) {
      return ARTRefill.fromMap(res.first);
    }
    return null;
  }

  Future<Set<RequiredAction>> retrieveRequiredActionsForPatient(
      String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
      RequiredAction.tableName,
      where: '${RequiredAction.colPatientART} = ?',
      whereArgs: [patientART],
    );
    final Set<RequiredAction> set = {};
    for (Map map in res) {
      set.add(RequiredAction.fromMap(map));
    }
    return set;
  }

  /// Retrieves only the support option done statuses for the preference
  /// assessment with [preferenceAssessmentId]. The elements in the set will
  /// be the ones with the most recent 'done' status.
  Future<Set<SupportOptionDone>>
      retrieveDoneSupportOptionsForPreferenceAssessment(
          int preferenceAssessmentId) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
      SupportOptionDone.tableName,
      where: '${SupportOptionDone.colPreferenceAssessmentId} = ?',
      whereArgs: [preferenceAssessmentId],
      orderBy: '${SupportOptionDone.colCreatedDate} DESC',
    );
    final Set<SupportOptionDone> set = {};
    for (Map map in res) {
      SupportOptionDone supportOptionDone = SupportOptionDone.fromMap(map);
      set.add(supportOptionDone);
    }
    return set;
  }

  /// Retrieves all patient rows from the database, including all edits.
  Future<List<Patient>> retrieveAllPatients() async {
    final Database db = await _databaseInstance;
    // query the table for all patients
    final res = await db.query(Patient.tableName);
    List<Patient> list = List<Patient>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        Patient p = Patient.fromMap(map);
        list.add(p);
      }
    }
    return list;
  }

  /// Retrieves all viral load rows from the database, including all edits.
  Future<List<ViralLoad>> retrieveAllViralLoads() async {
    final Database db = await _databaseInstance;
    final res = await db.query(ViralLoad.tableName);
    List<ViralLoad> list = List<ViralLoad>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        ViralLoad v = ViralLoad.fromMap(map);
        list.add(v);
      }
    }
    return list;
  }

  /// Retrieves all preference assessment rows from the database, including all
  /// edits.
  Future<List<PreferenceAssessment>> retrieveAllPreferenceAssessments() async {
    final Database db = await _databaseInstance;
    final res = await db.query(PreferenceAssessment.tableName);
    List<PreferenceAssessment> list = List<PreferenceAssessment>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        PreferenceAssessment pa = PreferenceAssessment.fromMap(map);
        list.add(pa);
      }
    }
    return list;
  }

  /// Retrieves all ART refill rows from the database, including all edits.
  Future<List<ARTRefill>> retrieveAllARTRefills() async {
    final Database db = await _databaseInstance;
    final res = await db.query(ARTRefill.tableName);
    List<ARTRefill> list = List<ARTRefill>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        ARTRefill r = ARTRefill.fromMap(map);
        list.add(r);
      }
    }
    return list;
  }

  /// Retrieves all user data rows from the database, including all edits.
  Future<List<UserData>> retrieveAllUserData() async {
    final Database db = await _databaseInstance;
    final res = await db.query(UserData.tableName);
    List<UserData> list = List<UserData>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        UserData u = UserData.fromMap(map);
        list.add(u);
      }
    }
    return list;
  }

  /// Retrieves all user data rows from the database, including all edits.
  Future<List<R21Event>> retrieveAllEventData() async {
    final Database db = await _databaseInstance;
    final res = await db.query(R21Event.tableName);
    List<R21Event> list = List<R21Event>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        R21Event u = R21Event.fromMap(map);
        list.add(u);
      }
    }
    return list;
  }

  Future<List<R21Appointment>> retrieveAllAppointmentData() async {
    final Database db = await _databaseInstance;
    final res = await db.query(R21Appointment.tableName);
    List<R21Appointment> list = List<R21Appointment>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        R21Appointment u = R21Appointment.fromMap(map);
        list.add(u);
      }
    }
    return list;
  }

  Future<List<R21Followup>> retrieveAllFollowupData() async {
    final Database db = await _databaseInstance;
    final res = await db.query(R21Followup.tableName);
    List<R21Followup> list = List<R21Followup>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        R21Followup u = R21Followup.fromMap(map);
        list.add(u);
      }
    }
    return list;
  }

  Future<List<R21ScreenAnalytic>> retrieveAllAnalyticData() async {
    final Database db = await _databaseInstance;
    final res = await db.query(R21ScreenAnalytic.tableName);
    List<R21ScreenAnalytic> list = List<R21ScreenAnalytic>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        R21ScreenAnalytic u = R21ScreenAnalytic.fromMap(map);
        list.add(u);
      }
    }
    return list;
  }

  Future<List<R21MedicationRefill>> retrieveAllMedicationRefillData() async {
    final Database db = await _databaseInstance;
    final res = await db.query(R21MedicationRefill.tableName);
    List<R21MedicationRefill> list = List<R21MedicationRefill>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        R21MedicationRefill u = R21MedicationRefill.fromMap(map);
        list.add(u);
      }
    }
    return list;
  }

  /// Retrieves all support option done data rows from the database, including
  /// all edits.
  Future<List<SupportOptionDone>> retrieveAllSupportOptionDones() async {
    final Database db = await _databaseInstance;
    final res = await db.query(SupportOptionDone.tableName);
    List<SupportOptionDone> list = List<SupportOptionDone>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        SupportOptionDone s = SupportOptionDone.fromMap(map);
        list.add(s);
      }
    }
    return list;
  }

  // Debug methods (should be removed/disabled for final release)
  // ------------------------------------------------------------
  // TODO: remove/disable these functions for the final release

  /// Retrieves a table's column names.
  Future<List<Map<String, dynamic>>> getTableInfo(String tableName) async {
    final Database db = await _databaseInstance;
    var res = db.rawQuery("PRAGMA table_info($tableName);");
    return res;
  }

  /// Deletes a patient from the Patient table and its corresponding entries from all other tables.
  Future<int> deletePatient(Patient deletePatient) async {
    final Database db = await _databaseInstance;
    final String artNumber = deletePatient.personalStudyNumber;
    final int rowsDeletedPatientTable = await db.delete(Patient.tableName,
        where: '${Patient.colPersonalStudyNumber} = ?', whereArgs: [artNumber]);
    final int rowsDeletedViralLoadTable = await db.delete(ViralLoad.tableName,
        where: '${ViralLoad.colPatientART} = ?', whereArgs: [artNumber]);
    final int rowsDeletedPreferenceAssessmentTable = await db.delete(
        PreferenceAssessment.tableName,
        where: '${PreferenceAssessment.colPatientART} = ?',
        whereArgs: [artNumber]);
    final int rowsDeletedARTRefillTable = await db.delete(ARTRefill.tableName,
        where: '${ARTRefill.colPatientART} = ?', whereArgs: [artNumber]);
    final int rowsDeletedRequiredActionTable = await db.delete(
        RequiredAction.tableName,
        where: '${RequiredAction.colPatientART} = ?',
        whereArgs: [artNumber]);
    return rowsDeletedPatientTable +
        rowsDeletedViralLoadTable +
        rowsDeletedPreferenceAssessmentTable +
        rowsDeletedARTRefillTable +
        rowsDeletedRequiredActionTable;
  }

  Future<int> resetTable(String tableName) async {
    final Database db = await _databaseInstance;
    final int rowsDeleted = await db.delete(tableName);
    return rowsDeleted;
  }
}
