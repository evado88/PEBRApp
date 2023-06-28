import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAppBottomSheet.dart';
import 'package:pebrapp/r21screens/R21NewPatientScreen.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/components/TransparentHeaderPage.dart';
import 'package:pebrapp/screens/DebugScreen.dart';
import 'package:pebrapp/screens/IconExplanationsScreen.dart';
import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:pebrapp/components/RequiredActionBadge.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/database/models/Patient.dart';

class R21MainScreenBlank extends StatefulWidget {
  final String title;

  const R21MainScreenBlank({this.title});

  @override
  State<R21MainScreenBlank> createState() => _R21MainScreenBlankState();
}

class _R21MainScreenBlankState extends State<R21MainScreenBlank> {
  _R21MainScreenBlankState();

  BuildContext _context;
  bool _isLoadingUserData = true;
  bool shouldAnimateSettingsActionRequired = true;
  bool _settingsActionRequired = false;
  bool _isLoading = true;
  List<Patient> _patients = [];

  Map<String, AnimationController> animationControllers = {};

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

  Future<void> _pushSettingsScreen() async {
    await _fadeInScreen(SettingsScreen(), routeName: '/settings');
  }

  Future<void> _pushIconExplanationsScreen() async {
    await _fadeInScreen(IconExplanationsScreen(),
        routeName: '/icon-explanations');
  }

  Future<void> _pushNewPatientScreen() async {
    await _fadeInScreen(R21NewPatientScreen(), routeName: '/new-patient');
  }

// #region Math functions

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
  
// #endregion


  Widget _buildEmptyBox() {
    return SizedBox.shrink();
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
        children: [],
      ),
    );
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
        onPressed: _pushNewPatientScreen,
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
            icon: Icon(Icons.account_box),
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
}
