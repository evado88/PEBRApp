import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PEBRAppBottomSheet.dart';
import 'package:pebrapp/components/RequiredActionBadge.dart';
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/R21ScreenType.dart';
import 'package:pebrapp/database/models/R21ScreenAnalytic.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/r21screens/R21NewFlatPatientScreen.dart';
import 'package:pebrapp/r21screens/R21PatientScreen.dart';
import 'package:pebrapp/screens/DebugScreen.dart';
import 'dart:ui';
import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:pebrapp/screens/IconExplanationsScreen.dart';
import 'package:pebrapp/components/TransparentHeaderPage.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/Utils.dart';

class R21MainScreen extends StatefulWidget {
  final bool _isScreenLogged;

  R21MainScreen(this._isScreenLogged);

  @override
  State<R21MainScreen> createState() => _R21MainScreenState(_isScreenLogged);
}

class _R21MainScreenState extends State<R21MainScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
// #region state variables
  BuildContext _context;
  bool _isLoading = true;
  bool _patientScreenPushed = false;
  List<Patient> _patients = [];
  UserData _userData = UserData();
  bool _isLoadingUserData = true;
  StreamSubscription<AppState> _appStateStream;
  bool _loginLockCheckRunning = false;
  bool _backupRunning = false;
  bool _settingsActionRequired = false;
  R21ScreenAnalytic _analytic =
      new R21ScreenAnalytic(type: R21ScreenType.Main());

  final DateTime _start = DateTime.now();

  static const int _ANIMATION_TIME = 800; // in milliseconds

  Map<String, AnimationController> animationControllers = {};
  Map<String, bool> shouldAnimateRequiredActionBadge = {};
  bool shouldAnimateSettingsActionRequired = true;

// #endregion

// constructor
  _R21MainScreenState(this._loginLockCheckRunning);

//Init state
  @override
  void initState() {
    super.initState();

    print('~~~ R21MainScreenState.initState ~~~');

    _analytic.startAnalytics();

    // listen to changes in the app lifecycle
    WidgetsBinding.instance.addObserver(this);
    DatabaseProvider().retrieveLatestUserData().then((UserData user) {
      if (user != null) {
        setState(() {
          this._userData = user;
          this._settingsActionRequired = user.phoneNumberUploadRequired;
          this._isLoadingUserData = false;
        });
      }
    });

    _onAppStart();

    _appStateStream = PatientBloc.instance.appState.listen((streamEvent) {
      if (streamEvent is AppStateLoading) {
        setState(() {
          this._isLoading = true;
        });
      }
      if (streamEvent is AppStateNoData) {
        setState(() {
          this._patients = [];
          this._isLoading = false;
        });
      }
      if (streamEvent is AppStatePatientData) {
        final newPatient = streamEvent.patient;
        print(
            '*** R21MainScreen received AppStatePatientData: ${newPatient.personalStudyNumber} ***');
        setState(() {
          this._isLoading = false;
          int indexOfExisting = this
              ._patients
              .indexWhere((p) => p.personalStudyNumber == newPatient.personalStudyNumber);
          if (indexOfExisting > -1) {
            // replace if patient exists (patient was edited)
            this._patients[indexOfExisting] = newPatient;
            // make sure the animation has run
            animationControllers[newPatient.personalStudyNumber].forward();
          } else {
            // add if not exists (new patient was added)

              this._patients.add(newPatient);
              // add animation controller for this patient card
              final controller = AnimationController(
                  duration: const Duration(milliseconds: _ANIMATION_TIME),
                  vsync: this);
              animationControllers[newPatient.personalStudyNumber] = controller;
              // start animation
              controller.forward();
            
          }
        });
      }
      if (streamEvent is AppStateRequiredActionData) {
        print(
            '*** R21MainScreen received AppStateRequiredActionData: ${streamEvent.action.patientART} ***');
        Patient affectedPatient = _patients.singleWhere(
            (Patient p) => p.personalStudyNumber == streamEvent.action.patientART,
            orElse: () => null);
        if (affectedPatient != null && !_patientScreenPushed) {
          setState(() {
            if (streamEvent.isDone) {
              shouldAnimateRequiredActionBadge[affectedPatient.personalStudyNumber] =
                  true;
              affectedPatient.requiredActions.removeWhere(
                  (RequiredAction a) => a.type == streamEvent.action.type);
            } else {
              if (affectedPatient.requiredActions.firstWhere(
                      (RequiredAction a) => a.type == streamEvent.action.type,
                      orElse: () => null) ==
                  null) {
                shouldAnimateRequiredActionBadge[affectedPatient.personalStudyNumber] =
                    true;
                affectedPatient.requiredActions.add(streamEvent.action);
              }
            }
          });
        }
      }
      if (streamEvent is AppStateSettingsRequiredActionData) {
        print(
            '*** R21MainScreen received AppStateSettingsRequiredActionData: ${streamEvent.isDone} ***');
        this.shouldAnimateSettingsActionRequired = true;
        setState(() {
          this._settingsActionRequired = !streamEvent.isDone;
        });
      }
    });

    PatientBloc.instance.sinkAllPatientsFromDatabase();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appStateStream.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _analytic = new R21ScreenAnalytic(type: R21ScreenType.Main());

        _onAppResume();
        break;
      case AppLifecycleState.paused:
        _analytic.stopAnalytics(
            resultAction: 'Paused', subjectEntity: this._userData.username);

        if (!_loginLockCheckRunning) {
          // if the app is already locked do not update the last active date!
          // otherwise, we can work around the lock by force closing the app and
          // restarting it within the time limit
          storeAppLastActiveInSharedPrefs();
        }
        break;
      case AppLifecycleState.inactive:
        _analytic.stopAnalytics(
            resultAction: 'Inactive', subjectEntity: this._userData.username);
        break;
      case AppLifecycleState.detached:
        _analytic.stopAnalytics(
            resultAction: 'detached', subjectEntity: this._userData.username);
        break;
      default:
        print('>>>>> UNHANDLED: $state');
        print('>>>>>1 MAIN SCREEN UNKNOWN');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('~~~ R21MainScreenState.build ~~~');
    _context = context;
    return Scaffold(
      bottomSheet: PEBRAppBottomSheet(),
      backgroundColor: BACKGROUND_COLOR,
      floatingActionButton: FloatingActionButton(
        key: Key(
            'addPatient'), // key can be used to find the button in integration testing
        onPressed:(){ _pushFlatPatientScreen(); },
        child: Icon(Icons.add),
        backgroundColor: FLOATING_ACTION_BUTTON,
      ),
      body: TransparentHeaderPage(
        title: 'Participants',
        subtitle: 'Overview',
        child: Center(child: _bodyToDisplayBasedOnState()),
        actions: <Widget>[
          kReleaseMode
              ? SizedBox()
              : IconButton(
                  icon: Icon(Icons.bug_report),
                  onPressed: () {
                    _fadeInScreen(DebugScreen());
                  }),
          IconButton(
            icon: Icon(Icons.message),
            onPressed: _pushIconExplanationsScreen,
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: _pushIconExplanationsScreen,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // reset animation
              animationControllers.values
                  .forEach((AnimationController c) => c.reset());
              // reload patients from SQLite database
              PatientBloc.instance.sinkAllPatientsFromDatabase();
            },
          ),
          IconButton(
            icon: _settingsActionRequired
                ? Stack(alignment: AlignmentDirectional(2.2, 1.8), children: [
                    Icon(Icons.settings),
                    RequiredActionBadge(
                      '1',
                      animate: shouldAnimateSettingsActionRequired,
                      badgeSize: 16.0,
                      boxShadow: [
                        BoxShadow(
                          color: BACKGROUND_COLOR,
                          blurRadius: 0.0,
                          spreadRadius: 1.0,
                        )
                      ],
                      onAnimateComplete: () {
                        this.shouldAnimateSettingsActionRequired = false;
                      },
                    ),
                  ])
                : Icon(Icons.settings),
            onPressed: _pushSettingsScreen,
          ),
        ],
      ),
    );
  }

  /// Runs checks whether user is logged in / whether the app should be locked,
  /// and whether a backup should be run simultaneously.
  ///
  /// Gets called when the application is started cold, i.e., when the app was
  /// not open in the background already.
  Future<void> _onAppStart() async {
    await _checkLoggedInAndLockStatus();
    //await _runVLFetchIfDue();
    await _runBackupIfDue();
  }

  /// Runs checks whether user is logged in / whether the app should be locked,
  /// and whether a backup should be run simultaneously. It also rebuilds the
  /// screen to update any changes to required actions, i.e., to check if any
  /// ART refills, preference assessments, or endpoint surveys have become due.
  ///
  /// Gets called when the application was already open in the background and
  /// comes to the foreground again.
  Future<void> _onAppResume() async {
    await _checkLoggedInAndLockStatus();
    //await _runVLFetchIfDue();
    await _recalculateRequiredActionsForAllPatients();
    await _runBackupIfDue();
  }

  /// Checks if an ART refill, preference assessment, or endpoint survey has
  /// become due by re-calculating the required actions field for each patient.
  /// It send an [PatientBloc.AppStatePatientData] event for each patient to
  /// inform all listeners of the new data.
  Future<void> _recalculateRequiredActionsForAllPatients() async {
    for (Patient p in _patients) {
      final Set<RequiredAction> previousActions =
          p.dueRequiredActionsAtInitialization;
      await p.initializeRequiredActionsField();
      final Set<RequiredAction> newActions = p.calculateDueRequiredActions();
      final bool shouldAnimate = previousActions.length != newActions.length;
      if (shouldAnimate) {
        shouldAnimateRequiredActionBadge[p.personalStudyNumber] = shouldAnimate;
        PatientBloc.instance
            .sinkNewPatientData(p, oldRequiredActions: previousActions);
      }
    }
  }

  /// Checks whether the user is logged in (if not shows the login screen) and
  /// whether the app should be locked (if so it shows the PIN code screen).
  Future<void> _checkLoggedInAndLockStatus() async {
    // if _checkLoggedInAndLockStatus has already been called we do nothing
    if (_loginLockCheckRunning) {
      return;
    }
    // enable concurrency lock
    _loginLockCheckRunning = true;

    // make user log in if he/she isn't already
    UserData loginData = await DatabaseProvider().retrieveLatestUserData();
    if (loginData == null) {
      await _pushSettingsScreen();
      _loginLockCheckRunning = false;
      return;
    }

    // lock the app if it has been inactive for a certain time
    DateTime lastActive = await appLastActive;
    if (lastActive == null) {
      await lockApp(_context);
    } else {
      DateTime now = DateTime.now();
      Duration difference = now.difference(lastActive);
      print('Seconds since app last active: ${difference.inSeconds}');
      if (difference.inSeconds >= SECONDS_UNTIL_APP_LOCK) {
        await lockApp(_context);
      }
    }
    _loginLockCheckRunning = false;
  }

  /// Checks if a backup is due and if so, starts a backup.
  Future<void> _runBackupIfDue() async {
    // if backup is running, do not start another backup
    if (_backupRunning) {
      return;
    }
    _backupRunning = true;

    // if user is not logged in, do not run a backup
    UserData loginData = await DatabaseProvider().retrieveLatestUserData();
    if (loginData == null) {
      _backupRunning = false;
      return;
    }

    // check if backup is due
    int daysSinceLastBackup = -1; // -1 means one day from today, i.e. tomorrow
    final DateTime lastBackup = await latestBackupFromSharedPrefs;
    if (lastBackup != null) {
      daysSinceLastBackup = differenceInDays(lastBackup, DateTime.now());
      print('days since last backup: $daysSinceLastBackup');
      if (daysSinceLastBackup < AUTO_BACKUP_EVERY_X_DAYS &&
          daysSinceLastBackup >= 0) {
        print(
            "backup not due yet (only due after $AUTO_BACKUP_EVERY_X_DAYS days)");
        _backupRunning = false;
        return; // don't run a backup, we have already backed up today
      }
    }

    try {
      await DatabaseProvider().createAdditionalBackupOnServer(loginData);
      showFlushbar('Upload Successful');
    } catch (e, s) {
      print('Caught exception during automated backup: $e');
      print('Stacktrace: $s');
      // show warning if backup wasn't successful for a long time
      if (daysSinceLastBackup >= SHOW_BACKUP_WARNING_AFTER_X_DAYS) {
        showFlushbar(
            "Last upload was $daysSinceLastBackup days ago.\nPlease perform a manual upload from the settings screen.",
            title: "Warning",
            error: true);
      }
    }
    _backupRunning = false;
  }

  Widget _bodyToDisplayBasedOnState() {
    if (_isLoadingUserData) {
      return _bodyLoading();
    } else if (_isLoading) {
      return _bodyLoading();
    } else if (_patients.isEmpty) {
      return _bodyNoData();
    } else {
      return _bodyPatientTable();
    }
  }

  /// Pushes [newScreen] to the top of the navigation stack using a fade in
  /// transition.
  Future<T> _fadeInScreen<T extends Object>(Widget newScreen,
      {String routeName}) {
    return Navigator.of(_context).push(
      PageRouteBuilder<T>(
        settings: RouteSettings(name: routeName),
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1,
            Animation<double> anim2, Widget widget) {
          return FadeTransition(
            opacity: anim1,
            child: widget, // child is the value returned by pageBuilder
          );
        },
        pageBuilder: (BuildContext context, _, __) {
          return newScreen;
        },
      ),
    );
  }

// #region Push Screens
  Future<void> _pushSettingsScreen() async {
    await _fadeInScreen(SettingsScreen(), routeName: '/settings');
  }

  Future<void> _pushIconExplanationsScreen() async {
    await _fadeInScreen(IconExplanationsScreen(),
        routeName: '/icon-explanations');
  }

  Future<void> _pushNewPatientScreen() async {

  }

  Future<void> _pushFlatPatientScreen() async {
    _patientScreenPushed = true;
    await Navigator.of(_context, rootNavigator: true).push(
      new MaterialPageRoute<void>(
        settings: RouteSettings(name: '/patient'),
        builder: (BuildContext context) {
          return R21NewFlatPatientScreen();
        },
      ),
    );
    _patientScreenPushed = false;
  }

  Future<void> _pushPatientScreen(Patient patient) async {
    _patientScreenPushed = true;
    await Navigator.of(_context, rootNavigator: true).push(
      new MaterialPageRoute<void>(
        settings: RouteSettings(name: '/patient'),
        builder: (BuildContext context) {
          return R21PatientScreen(patient);
        },
      ),
    );
    _patientScreenPushed = false;
  }
// #endregion

  Widget _bodyLoading() {
    final double size = 80.0;
    return Container(
      padding: EdgeInsets.all(20.0),
      height: size,
      width: size,
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(SPINNER_MAIN_SCREEN)),
    );
  }

  Widget _bodyNoData() {
    return Padding(
      padding: EdgeInsets.all(25.0),
      child: Center(
        child: Text(
          "No participants recorded yet.\nAdd new participant by pressing the + icon.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _bodyPatientTable() {
    final double _paddingHorizontal = 10.0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(
        left: _paddingHorizontal,
        right: _paddingHorizontal,
        bottom: 10.0,
      ),
      child: Column(
        children: _buildPatientCards(),
      ),
    );
  }

  List<Widget> _buildPatientCards() {
    const _cardMarginVertical = 8.0;
    const _cardMarginHorizontal = 0.0;

    Text _formatHeaderRowText(String text) {
      return Text(
        text.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: MAIN_SCREEN_HEADER_TEXT,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    Text _formatPatientRowText(String text, {bool bold = false}) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: TEXT_ACTIVE,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    List<Widget> _patientCards = <Widget>[];

    final Widget headerRow = Container(
        width: MediaQuery.of(context).size.width - 20,
        margin: EdgeInsets.fromLTRB(0, 0, 500, 0),
        /*decoration: BoxDecoration(
          border: Border.all(width: 0, color: Colors.red),
        ),*/
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          Container(width: 10, color: Colors.blue),
          Expanded(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                Expanded(
                  child: _formatHeaderRowText("Study No"),
                ),
                Expanded(
                  child: _formatHeaderRowText("Age"),
                ),
                Expanded(
                  child: _formatHeaderRowText("Phone"),
                ),
                Expanded(
                  flex: 2,
                  child: _formatHeaderRowText("Support"),
                ),
                Expanded(
                  child: _formatHeaderRowText("SRH Service"),
                ),
              ])),
        ]));

    _patientCards.add(headerRow);

    ClipRect _getPaddedIcon(String assetLocation,
        {Color color = Colors.black}) {
      return ClipRect(
          clipBehavior: Clip.antiAlias,
          child: SizedOverflowBox(
              size: Size(32.0, 30.0),
              child: Image(
                height: 30.0,
                color: color,
                image: AssetImage(assetLocation),
              )));
    }

    final numberOfPatients = _patients.length;

    for (var i = 0; i < numberOfPatients; i++) {
      final Patient curPatient = _patients[i];
      final patientART = curPatient.personalStudyNumber;

      final _curCardMargin = EdgeInsets.symmetric(
          vertical: _cardMarginVertical, horizontal: _cardMarginHorizontal);

      void _showAlertDialogToActivatePatient() {
        final AnimationController controller =
            animationControllers[curPatient.personalStudyNumber];
        final originalAnimationDuration = controller.duration;
        final Duration _quickAnimationDuration =
            Duration(milliseconds: (_ANIMATION_TIME / 2).round());
        controller.duration = _quickAnimationDuration;
        showDialog(
          context: _context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(curPatient.personalStudyNumber),
            backgroundColor: BACKGROUND_COLOR,
            content: Column(mainAxisSize: MainAxisSize.min, children: [
  
              SizedBox(height: kReleaseMode ? 0.0 : 10.0),
              kReleaseMode
                  ? SizedBox()
                  : SizedBox(
                      width: 180.0,
                      child: PEBRAButtonRaised(
                        'Delete Participant',
                        onPressed: () async {
                          // **************
                          // delete patient
                          // **************
                          Navigator.of(context).pop();
                          DatabaseProvider().deletePatient(curPatient);
                          _patients.removeWhere((Patient p) =>
                              p.personalStudyNumber == curPatient.personalStudyNumber);
                          await controller.animateBack(0.0,
                              duration: _quickAnimationDuration,
                              curve: Curves.ease); // fold patient card up
                          controller.duration =
                              originalAnimationDuration; // reset animation duration
                        },
                      ),
                    ),
              SizedBox(height: 15.0),
              PEBRAButtonFlat(
                'Close',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]),
          ),
        );
      }

      Widget patientCard = Container(
        width: MediaQuery.of(context).size.width - 20,
        height: 90,
        margin: EdgeInsets.fromLTRB(0, 0, 500, 0),

        /*decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.yellow),
        ),*/
        child: Card(
          clipBehavior: Clip.hardEdge,
          color: CARD_ACTIVE,
          elevation: 5.0,
          margin: _curCardMargin,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              _pushPatientScreen(curPatient);
            },
            onLongPress: (kReleaseMode && curPatient.srhContraceptionInterestMaleCondom)
                ? null
                : _showAlertDialogToActivatePatient,
            child: Row(mainAxisSize: MainAxisSize.max, children: [
              Container(
                  height: 90,
                  width: 10,
                  color: i % 2 == 0 ? Colors.blue : Colors.red),
              Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                    Expanded(
                      child: _formatPatientRowText(patientART, bold: true),
                    ),
                    Expanded(
                      child: _formatPatientRowText(
                          '${formatDateConsistent(curPatient.personalBirthday)} (age ${calculateAge(curPatient.personalBirthday)})'),
                    ),
                    Expanded(
                      child:
                          _formatPatientRowText(curPatient.personalResidency.description),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: i % 2 == 0
                            ? [
                                _getPaddedIcon(
                                    'assets/icons/saturday_clinic_club.png'),
                                _getPaddedIcon('assets/icons/homevisit_pe.png')
                              ]
                            : [
                                _getPaddedIcon('assets/icons/youth_club.png'),
                                _getPaddedIcon('assets/icons/phonecall_pe.png'),
                                _getPaddedIcon('assets/icons/nurse_clinic.png')
                              ],
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      child: _formatPatientRowText(
                          curPatient.historyHIVPrepDesiredSupportOther== null
                              ? "-"
                              : curPatient.historyHIVPrepDesiredSupportOther),
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    )),
                  ])),
            ]),
          ),
        ),
      );

      _patientCards.add(patientCard);
    }

    return _patientCards;
  }
}
