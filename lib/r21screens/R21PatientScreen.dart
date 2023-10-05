import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PEBRAppBottomSheet.dart';
import 'package:pebrapp/components/RequiredActionContainer.dart';
import 'package:pebrapp/components/TransparentHeaderPage.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/ARTRefillOption.dart';
import 'package:pebrapp/database/beans/R21Residency.dart';
import 'package:pebrapp/database/beans/R21ScreenType.dart';
import 'package:pebrapp/database/beans/SupportOption.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';
import 'package:pebrapp/database/beans/YesNoRefused.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/database/models/R21Appointment.dart';
import 'package:pebrapp/database/models/R21Event.dart';
import 'package:pebrapp/database/models/R21Followup.dart';
import 'package:pebrapp/database/models/R21MedicationRefill.dart';
import 'package:pebrapp/database/models/R21ScreenAnalytic.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';

import 'package:pebrapp/r21screens/R21AddFollowupScreen.dart';

import 'package:pebrapp/r21screens/R21EditPatientScreen.dart';
import 'package:pebrapp/r21screens/R21EditPatientSupportScreen.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:pebrapp/database/models/UserData.dart';

class R21PatientScreen extends StatefulWidget {
  final Patient _patient;
  R21PatientScreen(this._patient);
  @override
  createState() => _R21PatientScreenState(_patient);
}

class _R21PatientScreenState extends State<R21PatientScreen> {
  final int _descriptionFlex = 1;
  final int _contentFlex = 1;
  BuildContext _context;
  Patient _patient;
  UserData _userData;

  String _nextRefillText = '—';
  String _nextAppointment = '—';
  String _nextFollowup = '—';
  String _nextEvent = '—';

  double _screenWidth;

  final R21ScreenAnalytic _analytic =
      new R21ScreenAnalytic(type: R21ScreenType.Patient());

  StreamSubscription<AppState> _appStateStream;

  final double _spacingBetweenCards = 40.0;
  final Map<RequiredActionType, AnimateDirection>
      shouldAnimateRequiredActionContainer = {};

  // constructor 2
  _R21PatientScreenState(this._patient);

  loadAnalytics() async {
    final List<R21ScreenAnalytic> analytics =
        await DatabaseProvider().retrieveScreenAnalytics();

    print("Found " + analytics.length.toString());

    print(analytics.length == 0
        ? 'No Analytics'
        : 'Analytics Found: ' + analytics[analytics.length - 1].toString());

    analytics.forEach((v) {
      print(v.toString());
    });
  }

  loadEvents() async {
    final List<R21Event> events =
        await DatabaseProvider().retrieveEventsForPatient(_patient.personalStudyNumber);

    final List<R21Followup> followups = await DatabaseProvider()
        .retrieveFollowupsForPatient(_patient.personalStudyNumber);

    final List<R21Appointment> appointments = await DatabaseProvider()
        .retrieveAppointmentsForPatient(_patient.personalStudyNumber);

    print(
        'Found events: ${events.length}, appointments ${appointments.length}, followups ${followups.length}');

    events.forEach((v) {
      print(v.toString());
    });
  }

  @override
  void initState() {
    super.initState();

    loadEvents();
    _analytic.startAnalytics();

    DatabaseProvider().retrieveLatestUserData().then((UserData userData) {
      //this._userData = userData;
      if (userData != null) {
        setState(() {
          this._userData = userData;
        });
      }
    });
    _appStateStream = PatientBloc.instance.appState.listen((streamEvent) {
      if (streamEvent is AppStatePatientData &&
          streamEvent.patient.personalStudyNumber == _patient.personalStudyNumber) {
        print(
            '*** R21PatientScreen received AppStatePatientData: ${streamEvent.patient.personalStudyNumber} ***');
        final Set<RequiredAction> newVisibleRequiredActions =
            streamEvent.patient.calculateDueRequiredActions();
        for (RequiredAction a in newVisibleRequiredActions) {
          if (streamEvent.oldRequiredActions != null &&
              !streamEvent.oldRequiredActions.contains(a)) {
            // this required action is new, animate it forward
            shouldAnimateRequiredActionContainer[a.type] =
                AnimateDirection.FORWARD;
          }
        }
        setState(() {});
      }
      if (streamEvent is AppStateRequiredActionData &&
          streamEvent.action.patientART == _patient.personalStudyNumber) {
        print(
            '*** PatientScreen received AppStateRequiredActionData: ${streamEvent.action.patientART} ***');

        if (streamEvent.isDone) {
          // this required action is done, animate it back
          if (_patient.requiredActions.firstWhere(
                  (RequiredAction a) => a.type == streamEvent.action.type,
                  orElse: () => null) !=
              null) {
            setState(() {
              shouldAnimateRequiredActionContainer[streamEvent.action.type] =
                  AnimateDirection.BACKWARD;
            });
          }
        } else {
          // this required action is new, animate it forward
          if (_patient.requiredActions.firstWhere(
                  (RequiredAction a) => a.type == streamEvent.action.type,
                  orElse: () => null) ==
              null) {
            setState(() {
              shouldAnimateRequiredActionContainer[streamEvent.action.type] =
                  AnimateDirection.FORWARD;
              _patient.requiredActions.add(streamEvent.action);
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _appStateStream.cancel();
    _analytic.stopAnalytics();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('*** R21PatientScreenState.build ***');
    _context = context;
    _screenWidth = MediaQuery.of(context).size.width;


    DateTime nextFollowupDate =
        _patient.latestFollowup?.nextDate ?? _patient.utilityEnrollmentDate;
    _nextFollowup = formatDate(nextFollowupDate);

    final Widget content = Column(
      children: <Widget>[
        _buildRequiredActions(),
        _buildPatientCharacteristicsCard(),
        _makeButton('Edit Characteristics', onPressed: () {
          _editCharacteristicsPressed(_patient);
        }, flat: true),
        _makeButton('Edit Desired Support', onPressed: () {
          _editDesiredSupportPressed(_patient);
        }, flat: true),
        _buildNextActions(),
        SizedBox(height: _spacingBetweenCards),
        SizedBox(height: _spacingBetweenCards),
      ],
    );

    return Scaffold(
      bottomSheet: PEBRAppBottomSheet(),
      backgroundColor: BACKGROUND_COLOR,
      body: TransparentHeaderPage(
        title: 'Participant',
        subtitle: _patient.personalStudyNumber,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
          )
        ],
        child: content,
      ),
    );
  }

  Widget _buildEmptyBox() {
    return SizedBox.shrink();
  }

  Widget _buildRequiredActions() {
    final List<RequiredAction> visibleRequiredActionsSorted =
        _patient.calculateDueRequiredActions().toList();

    // Filter out REFILL_REQUIRED and ASSESSMENT_REQUIRED for clinics in the control cluster

    visibleRequiredActionsSorted.sort((RequiredAction a, RequiredAction b) =>
        a.dueDate.isBefore(b.dueDate) ? -1 : 1);
    final actions = visibleRequiredActionsSorted
        .asMap()
        .map((int i, RequiredAction action) {
          final mapEntry = MapEntry(
            i,
            RequiredActionContainer(
              action,
              i,
              _patient,
              animateDirection:
                  shouldAnimateRequiredActionContainer[action.type],
              onAnimated: () {
                setState(() {});
              },
            ),
          );
          shouldAnimateRequiredActionContainer[action.type] = null;
          _patient.initializeRequiredActionsField();
          return mapEntry;
        })
        .values
        .toList();

    return Column(
      children: <Widget>[
        ...actions,
        SizedBox(height: actions.length > 0 ? 20.0 : 0.0),
      ],
    );
  }

  Widget _buildNextActions() {
    Widget _buildNextActionRow(
        {String title, String dueDate, String explanation, Widget button}) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      Text(dueDate, style: TextStyle(fontSize: 16.0)),
                      SizedBox(height: 10.0),
                      Text(explanation),
                    ],
                  ),
                ),
                SizedBox(width: 10.0),
                button,
              ],
            ),
          ],
        ),
      );
    }

    String pronoun = 'his/her';
    if (_patient.personalResidency == R21Residency.UNZA()) {
      pronoun = 'her';
    } else if (_patient.personalResidency == R21Residency.ADDRESS()) {
      pronoun = 'his';
    }
    return Column(
      children: <Widget>[
        SizedBox(height: _spacingBetweenCards),
        _buildNextActionRow(
          title: 'Next Medication Refill',
          dueDate: _nextRefillText,
          explanation:
              'The medication refill date is selected when the participant collects $pronoun medication or has them delivered.',
          button: !_patient.srhContraceptionInterestIUD
              ? _makeButton('Manage Refill')
              : _makeButton('Manage Refill', onPressed: () {
                }),
        ),
        SizedBox(height: _spacingBetweenCards),
        SizedBox(height: _spacingBetweenCards),
        _buildNextActionRow(
          title: 'Next Appointment',
          dueDate: _nextAppointment,
          explanation:
              'The appointment date is selected when the participant shows up for $pronoun appointment with the peer navigator.',
          button: !_patient.historyContraceptionIUD
              ? _makeButton('Manage Appointment')
              : _makeButton('Manage Appointment', onPressed: () {

                }),
        ),
        SizedBox(height: _spacingBetweenCards),
        SizedBox(height: _spacingBetweenCards),
        _buildNextActionRow(
          title: 'Next Followup',
          dueDate: _nextFollowup,
          explanation:
              'Check if participant is experiecing any side-effects from their medication',
          button: !_patient.historyContraceptionIUD
              ? _makeButton('Manage Follow-up')
              : _makeButton('Manage Follow-up', onPressed: () {
                  _manageFollowupPressed(_context, _patient, 'Add Followup');
                }),
        ),
        SizedBox(height: _spacingBetweenCards),
        _buildFollowupCard("Previous Followups",
            "The list of previous folllow ups and events for this partipant"),
        SizedBox(height: _spacingBetweenCards),
        _buildNextActionRow(
          title: 'Next Event',
          dueDate: _nextEvent,
          explanation:
              'Check if participant is experiecing any side-effects from their medication',
          button: !_patient.historyContraceptionIUD
              ? _makeButton('Manage Event')
              : _makeButton('Manage Event', onPressed: () {

                }),
        ),
        SizedBox(height: _spacingBetweenCards),
        SizedBox(height: _spacingBetweenCards),
      ],
    );
  }

  _buildPatientCharacteristicsCard() {
    return _buildCard(
      title: 'Participant Characterstics',
      child: Column(
        children: [
          _buildRow(
              'Enrollment Date', formatDateConsistent(_patient.utilityEnrollmentDate)),
          _buildRow('Study Number', _patient.personalStudyNumber),
          _buildRow('Birthday',
              '${formatDateConsistent(_patient.personalBirthday)} (age ${calculateAge(_patient.personalBirthday)})'),
          _buildRow('Gender', _patient.personalResidency.description),
          _buildRow(
              'Sexual Orientation', _patient.personalPreferredContactMethod.description),
          _buildRow('Phone Number', _patient.personalPhoneNumber),
        ],
      ),
    );
  }


  _buildFollowupCard(String eventTitle, String eventDescription) {
    final double _spaceBetweenColumns = 10.0;

    Widget _buildEventHeader() {
      Widget row = Container(
        width: MediaQuery.of(context).size.width - 20,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        /*
        decoration: BoxDecoration(
          border: Border.all(width: 0, color: Colors.red),
        ),*/
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: _formatHeaderRowText('Date'),
                flex: 1,
              ),
              SizedBox(width: _spaceBetweenColumns),
              Expanded(child: _formatHeaderRowText('DESCRIPTION')),
              SizedBox(width: _spaceBetweenColumns),
              Expanded(child: _formatHeaderRowText('OCCURED')),
              SizedBox(width: _spaceBetweenColumns),
              Expanded(child: _formatHeaderRowText('REASON')),
              SizedBox(width: _spaceBetweenColumns),
              Expanded(
                child: _formatHeaderRowText('NEXT Date'),
              )
            ],
          ),
        ),
      );
      return row;
    }

    Widget _buildEventRow(R21Followup ev, {bool bold: false}) {
      final String date = '${formatDateConsistent(ev.date)}';
      final String nextDate = '${formatDateConsistent(ev.nextDate)}';

      return Container(
          width: MediaQuery.of(context).size.width - 20,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          /*decoration: BoxDecoration(
            border: Border.all(width: 0, color: Colors.blue),
          ),*/
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    child: Text(date,
                        style: TextStyle(
                            fontWeight:
                                bold ? FontWeight.bold : FontWeight.normal))),
                SizedBox(width: _spaceBetweenColumns),
                Expanded(
                    child: Text(ev.description ?? '—',
                        style: TextStyle(
                            fontWeight:
                                bold ? FontWeight.bold : FontWeight.normal))),
                SizedBox(width: _spaceBetweenColumns),
                Expanded(
                    child: Text(ev.occured ? 'Yes' : 'No',
                        style: TextStyle(
                            fontWeight:
                                bold ? FontWeight.bold : FontWeight.normal))),
                Expanded(
                    child: Text(
                        ev.noOccurReason == null
                            ? '-'
                            : ev.noOccurReason.description,
                        style: TextStyle(
                            fontWeight:
                                bold ? FontWeight.bold : FontWeight.normal))),
                SizedBox(width: _spaceBetweenColumns),
                SizedBox(width: _spaceBetweenColumns),
                Expanded(
                  child: Text(nextDate,
                      style: TextStyle(
                          fontWeight:
                              bold ? FontWeight.bold : FontWeight.normal)),
                ),
              ],
            ),
          ));
    }

    Widget content;

    if (_patient.followups.length == 0) {
      Widget emptyRow = Center(
        child: Text(
          "No followups available for this participant.",
          style: TextStyle(color: NO_DATA_TEXT),
        ),
      );

      content = Column(children: <Widget>[_buildEventHeader(), emptyRow]);
    } else {
      final int numOfVLs = _patient.followups.length;
      final List<R21Followup> items = _patient.followups;

      final List<Map<String, dynamic>> evsMarkedAsBold = [];
      // determine which viral load should be marked as bold (namely the last one)
      items.asMap().forEach((int i, R21Followup vl) {
        evsMarkedAsBold
            .add({'ev': vl, 'bold': numOfVLs > 1 && i == numOfVLs - 1});
      });

      // build widgets
      final events = evsMarkedAsBold.map((Map<String, dynamic> m) {
        R21Followup ev = m['ev'];
        bool bold = m['bold'];
        return _buildEventRow(ev, bold: bold);
      }).toList();
      content = Column(children: <Widget>[
        _buildEventHeader(),
        ...events,
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(eventTitle),
        _buildExplanation(eventDescription),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: content,
            ),
          ),
        ),
      ],
    );
  }


  /*
   * Helper Functions
   */

  Widget _buildCard(
      {@required Widget child, String title, String explanationText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (title == null || title == '') ? Container() : _buildTitle(title),
        (explanationText == null || explanationText == '')
            ? Container()
            : _buildExplanation(explanationText),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String description, String content) {
    return _buildRowWithWidget(description, Text(content ?? '—'));
  }

  Widget _buildRowWithWidget(String description, Widget content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(flex: _descriptionFlex, child: Text(description)),
          SizedBox(width: 5.0),
          Expanded(flex: _contentFlex, child: content),
        ],
      ),
    );
  }

  Widget _formatHeaderRowText(String text) {
    return Text(
      text.toUpperCase(),
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 12.0,
        color: VL_HISTORY_HEADER_TEXT,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExplanation(String explanation) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
      child: Text(
        explanation,
      ),
    );
  }

  Widget _buildSubtitle(String subtitle) {
    return Row(
      children: [
        Text(
          subtitle,
          style: TextStyle(
            color: DATA_SUBTITLE_TEXT,
            fontStyle: FontStyle.italic,
            fontSize: 15.0,
          ),
        ),
      ],
    );
  }

  ClipRect _getPaddedIcon(String assetLocation,
      {Color color, double width: 25.0, double height: 25.0}) {
    return ClipRect(
        clipBehavior: Clip.antiAlias,
        child: SizedOverflowBox(
            size: Size(width, height),
            child: Image(
              height: height,
              color: color,
              image: AssetImage(assetLocation),
            )));
  }

  Row _buildSupportOption(String title,
      {bool checkboxState,
      Function onChanged(bool newState),
      Widget icon,
      String doneText}) {
    return Row(children: [
      Expanded(
        child: CheckboxListTile(
          activeColor: ICON_INACTIVE,
          secondary: icon,
          subtitle: checkboxState
              ? Text(doneText ?? 'done',
                  style: TextStyle(fontStyle: FontStyle.italic))
              : null,
          title: Text(
            title,
            style: TextStyle(
              decoration: checkboxState
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: checkboxState ? TEXT_INACTIVE : TEXT_ACTIVE,
            ),
          ),
          dense: true,
          value: checkboxState,
          onChanged: onChanged,
        ),
      ),
    ]);
  }

  /// Pushes [newScreen] to the top of the navigation stack using a fade in
  /// transition.
  Future<T> _fadeInScreen<T extends Object>(Widget newScreen) {
    return Navigator.of(_context).push(
      PageRouteBuilder<T>(
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

  void _editCharacteristicsPressed(Patient patient) {
    print("chracteristic");
    _fadeInScreen(R21EditPatientScreen(patient)).then((_) {
      // calling setState to trigger a re-render of the page and display the new
      // patient characteristics
      setState(() {});
    });
  }

  void _editDesiredSupportPressed(Patient patient) {
    print("Desired support");
    _fadeInScreen(R21EditPatientSupportScreen(patient)).then((_) {
      // calling setState to trigger a re-render of the page and display the new
      // patient characteristics
      setState(() {});
    });
  }




  Future<void> _manageFollowupPressed(
      BuildContext context, Patient patient, String title) async {
    await _fadeInScreen(R21AddFollowupScreen(patient, title));
    // calling setState to trigger a re-render of the page and display the new
    // ART Refill Date
    setState(() {});
  }



  Widget _makeButton(String buttonText,
      {Function() onPressed, bool flat: false, Widget widget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        flat
            ? PEBRAButtonFlat(buttonText, onPressed: onPressed, widget: widget)
            : PEBRAButtonRaised(buttonText,
                onPressed: onPressed, widget: widget),
      ],
    );
  }
}
