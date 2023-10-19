import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/R21Interest.dart';
import 'package:pebrapp/database/beans/R21ScreenType.dart';
import 'package:pebrapp/database/beans/R21Week.dart';
import 'package:pebrapp/database/beans/R21YesNo.dart';
import 'package:pebrapp/database/beans/R21YesNoUnsure.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/R21Followup.dart';
import 'package:pebrapp/database/models/R21ScreenAnalytic.dart';
import 'package:pebrapp/r21screens/R21ChooseFacilityScreen.dart';
import 'package:pebrapp/r21screens/R21ViewResourcesScreen.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/Utils.dart';

class R21AddFollowupScreen extends StatelessWidget {
  final Patient _patient;
  final String _title;
  final R21ScreenAnalytic _analytic =
      new R21ScreenAnalytic(type: R21ScreenType.AddFollowup());

  R21AddFollowupScreen(
    this._patient,
    this._title,
  );

  _onPressCancel(BuildContext context) {
    Navigator.of(context).popUntil((Route<dynamic> route) {
      //end anlytics

      _analytic.stopAnalytics(
          resultAction: 'Cancel',
          subjectEntity: this._patient.personalStudyNumber);

      return route.settings.name == '/patient';
    });
  }

  @override
  Widget build(BuildContext context) {
    //start analytics
    _analytic.startAnalytics();

    return PopupScreen(
        title: '${this._title}',
        subtitle: _patient.personalStudyNumber,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _onPressCancel(context);
              })
        ],
        child: R21AddFollowupForm(_patient, _analytic));
  }
}

class R21AddFollowupForm extends StatefulWidget {
  final Patient _patient;
  final R21ScreenAnalytic _analytic;

  R21AddFollowupForm(this._patient, this._analytic);

  @override
  createState() => _R21AddFollowupFormState(_patient, _analytic);
}

class _R21AddFollowupFormState extends State<R21AddFollowupForm> {
  // fields
  final _formKey = GlobalKey<FormState>();
  final int _questionsFlex = 1;
  final int _answersFlex = 1;
  double _screenWidth = double.infinity;

  final Patient _patient;
  final R21ScreenAnalytic _analytic;

  R21Followup _event;

  TextEditingController _interestContraceptionMethodOtherCtr =
      TextEditingController();

  TextEditingController _interestContraceptionSelectedFacilityCodeCtr =
      TextEditingController();

  TextEditingController _interestContraceptionNotNowDateOtherCtr =
      TextEditingController();

  TextEditingController _interestContraceptionMaybeMethodSpecifyCtr =
      TextEditingController();

  static final int minAgeForEligibility = 15;

  static final DateTime minARTRefilDate =
      DateTime(now.year - minAgeForEligibility, now.month, now.day);

  static final DateTime now = DateTime.now();

  // constructor
  _R21AddFollowupFormState(this._patient, this._analytic) {
    _event = R21Followup(patientART: this._patient.personalStudyNumber);
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;

    const double _spacing = 20.0;
    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              _contraceptionInterestCard(),
              SizedBox(height: _spacing),
              _prepInterestCard(),
              SizedBox(height: _spacing),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                PEBRAButtonRaised(
                  'Save',
                  onPressed: () {
                    _onSubmitForm(context);
                  },
                )
              ]),
              SizedBox(height: _spacing),
            ],
          ),
        ));
  }

  Widget _makeQuestion(String question,
      {@required Widget answer,
      bool forceColumn = false,
      bool makeBold = false}) {
    if (_screenWidth < NARROW_DESIGN_WIDTH || forceColumn) {
      final double _spacingBetweenQuestions = 4.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: _spacingBetweenQuestions),
          Text(question,
              style: TextStyle(
                  fontWeight: makeBold ? FontWeight.bold : FontWeight.normal)),
          answer,
          SizedBox(height: _spacingBetweenQuestions),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: _questionsFlex,
          child: Text(question),
        ),
        SizedBox(width: 5.0),
        Expanded(
          flex: _answersFlex,
          child: answer,
        ),
      ],
    );
  }

//Contraception
  Widget _contraceptionStarted() {

  
    return _makeQuestion(
      'Has the client started a new contraceptive method?',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _event.srhContraceptionStarted,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _event.srhContraceptionStarted = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21YesNo.allValues
            .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
          return DropdownMenuItem<R21YesNo>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _contraceptionInterest() {

     if (_event.srhContraceptionStarted == null ||
        _event.srhContraceptionStarted != R21YesNo.NO()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Interest in using contraception ',
      answer: DropdownButtonFormField<R21Interest>(
        value: _event.srhContraceptionInterest,
        onChanged: (R21Interest newValue) {
          setState(() {
            _event.srhContraceptionInterest = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21Interest.allValues
            .map<DropdownMenuItem<R21Interest>>((R21Interest value) {
          return DropdownMenuItem<R21Interest>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _hasMethodInMind() {
    if (_event.srhContraceptionInterest == null ||
        _event.srhContraceptionInterest != R21Interest.VeryInterested()) {
      return SizedBox();
    }
    return _makeQuestion(
      'Does she have a particular method in mind?',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _event.srhContraceptionMethodInMind,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _event.srhContraceptionMethodInMind = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21YesNo.allValues
            .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
          return DropdownMenuItem<R21YesNo>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _particularMethodInMind() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.VeryInterested()) ||
        (_event.srhContraceptionMethodInMind == null ||
            _event.srhContraceptionMethodInMind == R21YesNo.NO())) {
      return SizedBox();
    }

    return _makeQuestion('Which method',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestMaleCondom,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestMaleCondom = value;
                });
              },
            ),
            Text(
              'Male Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestFemaleCondom,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestFemaleCondom = value;
                });
              },
            ),
            Text(
              'Female Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestImplant,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestImplant = value;
                });
              },
            ),
            Text(
              'Implant',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestInjection,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestInjection = value;
                });
              },
            ),
            Text(
              'Injection',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestIUD,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestIUD = value;
                });
              },
            ),
            Text(
              'IUD (intrauterine Device or Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestIUS,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestIUS = value;
                });
              },
            ),
            Text(
              'IUS (intrauterine System or Hormonal Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestPills,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestPills = value;
                });
              },
            ),
            Text(
              'Contraception Pills (combined or progestogen-only)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestOther = value;
                });
              },
            ),
            Text(
              'Other (specify)',
            ),
          ])
        ]),
        forceColumn: true,
        makeBold: true);
  }

  Widget _specifyInterestContraceptionMethodOther() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.VeryInterested()) ||
        (_event.srhContraceptionMethodInMind == null ||
            _event.srhContraceptionMethodInMind == R21YesNo.NO()) ||
        (_event.srhContraceptionInterestOther == null ||
            _event.srhContraceptionInterestOther == false)) {
      return Container();
    }
    return _makeQuestion(
      'Specify other method',
      answer: TextFormField(
        controller: _interestContraceptionMethodOtherCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify the method';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionLikeInfoMethods() {
    if (_event.srhContraceptionInterest == null ||
        _event.srhContraceptionInterest != R21Interest.VeryInterested()) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like more information about different methods right now?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhContraceptionInformationMethods,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhContraceptionInformationMethods = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionOpenCounselingInfoPage() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.VeryInterested()) ||
        (_event.srhContraceptionInformationMethods == null ||
            _event.srhContraceptionInformationMethods == R21YesNo.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information Page', onPressed: () {
      print('~~~ OPENING COUNSELLING INFO PAGE =>');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestContraceptionLikeFacilitySchedule() {
    if (_event.srhContraceptionInterest == null ||
        _event.srhContraceptionInterest != R21Interest.VeryInterested()) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly a method of her choice NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _event.srhContraceptionFindScheduleFacility,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _event.srhContraceptionFindScheduleFacility = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNoUnsure.allValues
              .map<DropdownMenuItem<R21YesNoUnsure>>((R21YesNoUnsure value) {
            return DropdownMenuItem<R21YesNoUnsure>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionLikeFacilityScheduleDate() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.VeryInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'When would she like to go',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _event.srhContraceptionFindScheduleFacilityYesDate == null
                  ? ''
                  : '${formatDateConsistent(_event.srhContraceptionFindScheduleFacilityYesDate)}',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          onPressed: () async {
            DateTime date = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: minARTRefilDate,
              lastDate: now,
            );
            if (date != null) {
              setState(() {
                _event.srhContraceptionFindScheduleFacilityYesDate = date;
              });
            }
          },
        ),
        Divider(
          color: CUSTOM_FORM_FIELD_UNDERLINE,
          height: 1.0,
        ),
        _event.srhContraceptionFindScheduleFacilityYesDate != null
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'Please select a date',
                  style: TextStyle(
                    color: CUSTOM_FORM_FIELD_ERROR_TEXT,
                    fontSize: 12.0,
                  ),
                ),
              ),
      ]),
    );
  }

  Widget _interestContraceptionLikePNAccompany() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.VeryInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }
    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhContraceptionFindScheduleFacilityYesPNAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhContraceptionFindScheduleFacilityYesPNAccompany =
                  newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: false);
  }

  Widget _interestContraceptionOpenFacilitiesPage() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.VeryInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ 1. OPENING FACILITIES PAGE NOW =>');
      _pushChooseFacilityScreen();
    });
  }

  Widget _interestContraceptionSelectedFacility() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.VeryInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }
    return _makeQuestion(
      'Selected Facility Code',
      answer: TextFormField(
        controller: _interestContraceptionSelectedFacilityCodeCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify selected facility';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionNotNowDate() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.VeryInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
        'When would she like to go for counseling and possibly a method of her choice?',
        answer: DropdownButtonFormField<R21Week>(
          value: _event.srhContraceptionFindScheduleFacilityNoDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _event.srhContraceptionFindScheduleFacilityNoDate = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items:
              R21Week.allValues.map<DropdownMenuItem<R21Week>>((R21Week value) {
            return DropdownMenuItem<R21Week>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionNotNowDateOther() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.VeryInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES()) ||
        (_event.srhContraceptionFindScheduleFacilityNoDate == null ||
            _event.srhContraceptionFindScheduleFacilityNoDate !=
                R21Week.Other())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other date',
      answer: TextFormField(
        controller: _interestContraceptionNotNowDateOtherCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify date';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionNotNowPickFacility() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.VeryInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _event.srhContraceptionFindScheduleFacilityNoPick,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _event.srhContraceptionFindScheduleFacilityNoPick = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21YesNo.allValues
            .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
          return DropdownMenuItem<R21YesNo>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _interestContraceptionNotNowPickFacilityShow() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.VeryInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES()) ||
        (_event.srhContraceptionFindScheduleFacilityNoPick == null ||
            _event.srhContraceptionFindScheduleFacilityNoPick ==
                R21YesNo.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ 2. OPENING FACILITIES PAGE =>');
    });
  }

  Widget _interestContraceptionNotNowPickFacilitySelected() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.VeryInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.YES()) ||
        (_event.srhContraceptionFindScheduleFacilityNoPick == null ||
            _event.srhContraceptionFindScheduleFacilityNoPick ==
                R21YesNo.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code',
      answer: TextFormField(
        controller: _interestContraceptionSelectedFacilityCodeCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify selected facility';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionLikeInformationOnApp() {
    if (_event.srhContraceptionInterest == null ||
        _event.srhContraceptionInterest != R21Interest.VeryInterested()) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhContraceptionInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhContraceptionInformationApp = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionMaybeMethod() {
    if (_event.srhContraceptionInterest == null ||
        _event.srhContraceptionInterest != R21Interest.MaybeInterested()) {
      return SizedBox();
    }

    return _makeQuestion('What method(s) is the client possibly interested in',
        answer: Column(children: [
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestMaleCondom,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestMaleCondom = value;
                });
              },
            ),
            Text(
              'Male Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestFemaleCondom,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestFemaleCondom = value;
                });
              },
            ),
            Text(
              'Female Condoms',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestImplant,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestImplant = value;
                });
              },
            ),
            Text(
              'Implant',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestInjection,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestInjection = value;
                });
              },
            ),
            Text(
              'Injection',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestIUD,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestIUD = value;
                });
              },
            ),
            Text(
              'IUD (intrauterine Device or Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestIUS,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestIUS = value;
                });
              },
            ),
            Text(
              'IUS (intrauterine System or Hormonal Coil)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestPills,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestPills = value;
                });
              },
            ),
            Text(
              'Contraception Pills (combined or progestogen-only)',
            ),
          ]),
          Row(children: [
            Checkbox(
              value: _event.srhContraceptionInterestOther,
              tristate: false,
              onChanged: (bool value) {
                setState(() {
                  _event.srhContraceptionInterestOther = value;
                });
              },
            ),
            Text(
              'Other (specify)',
            ),
          ])
        ]),
        forceColumn: true,
        makeBold: true);
  }

  Widget _interestContraceptionMaybeMethodSpecify() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        !_event.srhContraceptionInterestOther) {
      return SizedBox();
    }
    return _makeQuestion(
      'Specify other method',
      answer: TextFormField(
        controller: _interestContraceptionMaybeMethodSpecifyCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify the method';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionMaybeLikeFacilitySchedule() {
    if ((_event.srhContraceptionInterest == null ||
        _event.srhContraceptionInterest != R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly a method of her choice NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _event.srhContraceptionFindScheduleFacility,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _event.srhContraceptionFindScheduleFacility = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNoUnsure.allValues
              .map<DropdownMenuItem<R21YesNoUnsure>>((R21YesNoUnsure value) {
            return DropdownMenuItem<R21YesNoUnsure>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionMaybeLikeFacilityScheduleDate() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'When would she like to go',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _event.srhContraceptionFindScheduleFacilityYesDate == null
                  ? ''
                  : '${formatDateConsistent(_event.srhContraceptionFindScheduleFacilityYesDate)}',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          onPressed: () async {
            DateTime date = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: minARTRefilDate,
              lastDate: now,
            );
            if (date != null) {
              setState(() {
                _event.srhContraceptionFindScheduleFacilityYesDate = date;
              });
            }
          },
        ),
        Divider(
          color: CUSTOM_FORM_FIELD_UNDERLINE,
          height: 1.0,
        ),
        _interestContraceptionMaybeMethodSpecifyCtr != null
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'Please select a date',
                  style: TextStyle(
                    color: CUSTOM_FORM_FIELD_ERROR_TEXT,
                    fontSize: 12.0,
                  ),
                ),
              ),
      ]),
    );
  }

  Widget _interestContraceptionMaybeLikePNAccompany() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }
    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhContraceptionFindScheduleFacilityYesPNAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhContraceptionFindScheduleFacilityYesPNAccompany =
                  newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: false);
  }

  Widget _interestContraceptionMaybeOpenFacilitiesPage() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ 3. OPENING FACILITIES PAGE =>');
    });
  }

  Widget _interestContraceptionMaybeSelectedFacility() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility ==
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }
    return _makeQuestion(
      'Selected Facility Code',
      answer: TextFormField(
        controller: _interestContraceptionSelectedFacilityCodeCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify selected facility';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionMaybeNotNowDate() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
        'When would she like to go for counseling and possibly a method of her choice?-',
        answer: DropdownButtonFormField<R21Week>(
          value: _event.srhContraceptionFindScheduleFacilityNoDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _event.srhContraceptionFindScheduleFacilityNoDate = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items:
              R21Week.allValues.map<DropdownMenuItem<R21Week>>((R21Week value) {
            return DropdownMenuItem<R21Week>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionMaybeNotNowDateOther() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_event.srhContraceptionFindScheduleFacilityNoDate == null ||
            _event.srhContraceptionFindScheduleFacilityNoDate !=
                R21Week.Other())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other date',
      answer: TextFormField(
        controller: _interestContraceptionNotNowDateOtherCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify date';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionMaybeNotNowPickFacility() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?-',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _event.srhContraceptionFindScheduleFacilityNoPick,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _event.srhContraceptionFindScheduleFacilityNoPick = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21YesNo.allValues
            .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
          return DropdownMenuItem<R21YesNo>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _interestContraceptionMaybeNotNowPickFacilityShow() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_event.srhContraceptionFindScheduleFacilityNoPick == null ||
            _event.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('XOpen Facilities Page-', onPressed: () {
      print('4. Opening facilities page');
    });
  }

  Widget _interestContraceptionMaybeNotNowPickFacilitySelected() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_event.srhContraceptionFindScheduleFacilityNoPick == null ||
            _event.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code',
      answer: TextFormField(
        controller: _interestContraceptionSelectedFacilityCodeCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify selected facility';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionMaybeLikeInformationOnApp() {
    if ((_event.srhContraceptionInterest == null ||
        _event.srhContraceptionInterest != R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhContraceptionInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhContraceptionInformationApp = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionMaybeLikeInfoOnMethods() {
    if ((_event.srhContraceptionInterest == null ||
        _event.srhContraceptionInterest != R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to learn more about different contraceptive methods right now?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhContraceptionLearnMethods,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhContraceptionLearnMethods = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionMaybeLikeInfoOnMethodsShow() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        (_event.srhContraceptionLearnMethods == null ||
            _event.srhContraceptionLearnMethods != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestContraceptionNotSpecifyReason() {
    if ((_event.srhContraceptionInterest == null ||
        _event.srhContraceptionInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }
    return _makeQuestion(
      'Why not interest in contraception?',
      answer: TextFormField(
        controller: _interestContraceptionMaybeMethodSpecifyCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify reason';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestContraceptionNotLikeInfoOnMethods() {
    if ((_event.srhContraceptionInterest == null ||
        _event.srhContraceptionInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to learn more about different contraceptive methods right now?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhContraceptionInformationMethods,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhContraceptionInformationMethods = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestContraceptionNotLikeInfoOnMethodsShow() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.NoInterested()) ||
        (_event.srhContraceptionInformationMethods == null ||
            _event.srhContraceptionInformationMethods != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      _pushViewResourcesScreen();
    });
  }

  Widget _interestContraceptionNotLikeInformationOnApp() {
    if ((_event.srhContraceptionInterest == null ||
        _event.srhContraceptionInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhContraceptionInformationApp,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhContraceptionInformationApp = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

//Prep
  Widget _prepStarted() {
    return _makeQuestion(
      'Has the client started using PrEP? ',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _event.srhPrePStarted,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _event.srhPrePStarted = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21YesNo.allValues
            .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
          return DropdownMenuItem<R21YesNo>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _interestPrep() {
    if (_event.srhPrePStarted == null ||
        _event.srhPrePStarted != R21YesNo.NO()) {
      return SizedBox();
    }

    return _makeQuestion(
      'Interest in using PrEP',
      answer: DropdownButtonFormField<R21Interest>(
        value: _event.srhPrePInterest,
        onChanged: (R21Interest newValue) {
          setState(() {
            _event.srhPrePInterest = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21Interest.allValues
            .map<DropdownMenuItem<R21Interest>>((R21Interest value) {
          return DropdownMenuItem<R21Interest>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _interestPrepLikeInfoOnMethods() {
    if ((_event.srhPrePInterest == null ||
        _event.srhPrePInterest != R21Interest.VeryInterested())) {
      return SizedBox();
    }

    return _makeQuestion('Would she like more information now about PrEP',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhPrepLikeMoreInformation,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhPrepLikeMoreInformation = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestPrepLikeInfoOnMethodsShow() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.VeryInterested()) ||
        (_event.srhPrepLikeMoreInformation == null ||
            _event.srhPrepLikeMoreInformation != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Informationxx...');
      //_pushViewResourcesScreen();
    });
  }

  Widget _interestPrepVeryLikeFacilitySchedule() {
    if ((_event.srhPrePInterest == null ||
        _event.srhPrePInterest != R21Interest.VeryInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly get PrEP NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _event.srhPrePFindScheduleFacilitySchedule,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _event.srhPrePFindScheduleFacilitySchedule = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNoUnsure.allValues
              .map<DropdownMenuItem<R21YesNoUnsure>>((R21YesNoUnsure value) {
            return DropdownMenuItem<R21YesNoUnsure>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestPrepVeryLikeFacilityScheduleDate() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.VeryInterested()) ||
        ((_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return _makeQuestion(
      'When would she like to go',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _event.srhPrepFindScheduleFacilityYesDate == null
                  ? ''
                  : '${formatDateConsistent(_event.srhPrepFindScheduleFacilityYesDate)}',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          onPressed: () async {
            DateTime date = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: minARTRefilDate,
              lastDate: now,
            );
            if (date != null) {
              setState(() {
                _event.srhPrepFindScheduleFacilityYesDate = date;
              });
            }
          },
        ),
        Divider(
          color: CUSTOM_FORM_FIELD_UNDERLINE,
          height: 1.0,
        ),
        _event.srhPrepFindScheduleFacilityYesDate != null
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'Please select a date',
                  style: TextStyle(
                    color: CUSTOM_FORM_FIELD_ERROR_TEXT,
                    fontSize: 12.0,
                  ),
                ),
              ),
      ]),
    );
  }

  Widget _interestPrepVeryLikePNAccompany() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.VeryInterested()) ||
        ((_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhPrePFindScheduleFacilityYesPNAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhPrePFindScheduleFacilityYesPNAccompany = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: false);
  }

  Widget _interestPrepVeryOpenFacilitiesPage() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.VeryInterested()) ||
        ((_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ 3. OPENING FACILITIES PAGE =>');
    });
  }

  Widget _interestPrepVerySelectedFacility() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.VeryInterested()) ||
        ((_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code',
      answer: TextFormField(
        controller: _interestContraceptionSelectedFacilityCodeCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify selected facility';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestPrepVeryNotNowDate() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.VeryInterested()) ||
        (_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
        'If no, when would she like to go for counseling and possibly get PrEP?',
        answer: DropdownButtonFormField<R21Week>(
          value: _event.srhPrePFindScheduleFacilityNoDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _event.srhPrePFindScheduleFacilityNoDate = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items:
              R21Week.allValues.map<DropdownMenuItem<R21Week>>((R21Week value) {
            return DropdownMenuItem<R21Week>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestPrepVeryNotNowDateOther() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.VeryInterested()) ||
        (_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_event.srhPrePFindScheduleFacilityNoDate == null ||
            _event.srhPrePFindScheduleFacilityNoDate != R21Week.Other())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other date',
      answer: TextFormField(
        controller: _interestContraceptionNotNowDateOtherCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify date';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestPrepVeryNotNowPickFacility() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.VeryInterested()) ||
        (_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?-',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _event.srhPrePFindScheduleFacilityNoPick,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _event.srhPrePFindScheduleFacilityNoPick = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21YesNo.allValues
            .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
          return DropdownMenuItem<R21YesNo>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _interestPrepVeryNotNowPickFacilityShow() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.VeryInterested()) ||
        (_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_event.srhPrePFindScheduleFacilityNoPick == null ||
            _event.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('XOpen Facilities Page-', onPressed: () {
      print('4. Opening facilities page');
    });
  }

  Widget _interestPrepVeryNotNowPickFacilitySelected() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        (_event.srhContraceptionFindScheduleFacility == null ||
            _event.srhContraceptionFindScheduleFacility !=
                R21YesNoUnsure.NO()) ||
        (_event.srhContraceptionFindScheduleFacilityNoPick == null ||
            _event.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code',
      answer: TextFormField(
        controller: _interestContraceptionSelectedFacilityCodeCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify selected facility';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestPrepVeryLikeInformationOnApp() {
    if ((_event.srhPrePInterest == null ||
        _event.srhPrePInterest != R21Interest.VeryInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information about PrEP sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhPrePInformationRead,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhPrePInformationRead = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }
//MAYBE

  Widget _interestPrepMaybeLikeInfoOnMethods() {
    if ((_event.srhPrePInterest == null ||
        _event.srhPrePInterest != R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion('Would she like more information now about PrEP',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhPrepLikeMoreInformation,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhPrepLikeMoreInformation = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestPrepMaybeLikeInfoOnMethodsShow() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.MaybeInterested()) ||
        (_event.srhPrepLikeMoreInformation == null ||
            _event.srhPrepLikeMoreInformation != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      //_pushViewResourcesScreen();
    });
  }

  Widget _interestPrepMaybeLikeFacilitySchedule() {
    if ((_event.srhPrePInterest == null ||
        _event.srhPrePInterest != R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like to find a facility and schedule a time to go for counseling and possibly get PrEP NOW?',
        answer: DropdownButtonFormField<R21YesNoUnsure>(
          value: _event.srhPrePFindScheduleFacilitySchedule,
          onChanged: (R21YesNoUnsure newValue) {
            setState(() {
              _event.srhPrePFindScheduleFacilitySchedule = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNoUnsure.allValues
              .map<DropdownMenuItem<R21YesNoUnsure>>((R21YesNoUnsure value) {
            return DropdownMenuItem<R21YesNoUnsure>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestPrepMaybeLikeFacilityScheduleDate() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.MaybeInterested()) ||
        ((_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return _makeQuestion(
      'When would she like to go',
      answer: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              _event.srhContraceptionFindScheduleFacilityYesDate == null
                  ? ''
                  : '${formatDateConsistent(_event.srhContraceptionFindScheduleFacilityYesDate)}',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          onPressed: () async {
            DateTime date = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: minARTRefilDate,
              lastDate: now,
            );
            if (date != null) {
              setState(() {
                _event.srhContraceptionFindScheduleFacilityYesDate = date;
              });
            }
          },
        ),
        Divider(
          color: CUSTOM_FORM_FIELD_UNDERLINE,
          height: 1.0,
        ),
        _event.srhContraceptionFindScheduleFacilityYesDate != null
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'Please select a date',
                  style: TextStyle(
                    color: CUSTOM_FORM_FIELD_ERROR_TEXT,
                    fontSize: 12.0,
                  ),
                ),
              ),
      ]),
    );
  }

  Widget _interestPrepMaybeLikePNAccompany() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.MaybeInterested()) ||
        ((_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return _makeQuestion('Would she like the PN to accompany her',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhPrePFindScheduleFacilityYesPNAccompany,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhPrePFindScheduleFacilityYesPNAccompany = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: false);
  }

  Widget _interestPrepMaybeOpenFacilitiesPage() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.MaybeInterested()) ||
        ((_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Facilities Page', onPressed: () {
      print('~~~ 3. OPENING FACILITIES PAGE =>');
    });
  }

  Widget _interestPrepMaybeSelectedFacility() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.MaybeInterested()) ||
        ((_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.YES()))) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code',
      answer: TextFormField(
        controller: _interestContraceptionSelectedFacilityCodeCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify selected facility';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestPrepMaybeNotNowDate() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.MaybeInterested()) ||
        (_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
        'If no, when would she like to go for counseling and possibly get PrEP?',
        answer: DropdownButtonFormField<R21Week>(
          value: _event.srhPrePFindScheduleFacilityNoDate,
          onChanged: (R21Week newValue) {
            setState(() {
              _event.srhPrePFindScheduleFacilityNoDate = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items:
              R21Week.allValues.map<DropdownMenuItem<R21Week>>((R21Week value) {
            return DropdownMenuItem<R21Week>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestPrepMaybeNotNowDateOther() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.MaybeInterested()) ||
        (_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_event.srhPrePFindScheduleFacilityNoDate == null ||
            _event.srhPrePFindScheduleFacilityNoDate != R21Week.Other())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Specify other date',
      answer: TextFormField(
        controller: _interestContraceptionNotNowDateOtherCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify date';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestPrepMaybeNotNowPickFacility() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.MaybeInterested()) ||
        (_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Would she like to pick a facility now?-',
      answer: DropdownButtonFormField<R21YesNo>(
        value: _event.srhPrePFindScheduleFacilityNoPick,
        onChanged: (R21YesNo newValue) {
          setState(() {
            _event.srhPrePFindScheduleFacilityNoPick = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
        },
        items: R21YesNo.allValues
            .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
          return DropdownMenuItem<R21YesNo>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _interestPrepMaybeNotNowPickFacilityShow() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.MaybeInterested()) ||
        (_event.srhPrePFindScheduleFacilitySchedule == null ||
            _event.srhPrePFindScheduleFacilitySchedule !=
                R21YesNoUnsure.NO()) ||
        (_event.srhPrePFindScheduleFacilityNoPick == null ||
            _event.srhPrePFindScheduleFacilityNoPick != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('XOpen Facilities Page-', onPressed: () {
      print('4. Opening facilities page');
    });
  }

  Widget _interestPrepMaybeNotNowPickFacilitySelected() {
    if ((_event.srhContraceptionInterest == null ||
            _event.srhContraceptionInterest != R21Interest.MaybeInterested()) ||
        (_event.srhPrePFindScheduleFacilityNoPick == null ||
            _event.srhPrePFindScheduleFacilityNoPick != R21YesNo.NO()) ||
        (_event.srhContraceptionFindScheduleFacilityNoPick == null ||
            _event.srhContraceptionFindScheduleFacilityNoPick !=
                R21YesNo.YES())) {
      return SizedBox();
    }

    return _makeQuestion(
      'Selected Facility Code',
      answer: TextFormField(
        controller: _interestContraceptionSelectedFacilityCodeCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify selected facility';
          }
          return null;
        },
      ),
    );
  }

  Widget _interestPrepMaybeLikeInformationOnApp() {
    if ((_event.srhPrePInterest == null ||
        _event.srhPrePInterest != R21Interest.MaybeInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information about PrEP sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhPrePInformationRead,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhPrePInformationRead = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

//NOT INTERESTED
  Widget _interestPrepNotLikeInfoOnMethods() {
    if ((_event.srhPrePInterest == null ||
        _event.srhPrePInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }

    return _makeQuestion('Would she like more information now about PrEP',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhPrepLikeMoreInformation,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhPrepLikeMoreInformation = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _interestPrepNotLikeInfoOnMethodsShow() {
    if ((_event.srhPrePInterest == null ||
            _event.srhPrePInterest != R21Interest.NoInterested()) ||
        (_event.srhPrepLikeMoreInformation == null ||
            _event.srhPrepLikeMoreInformation != R21YesNo.YES())) {
      return SizedBox();
    }

    return PEBRAButtonFlat('Open Counseling Information', onPressed: () {
      print('Opening Counseling Information...');
      //_pushViewResourcesScreen();
    });
  }

  Widget _interestPrepNotLikeInformationOnApp() {
    if ((_event.srhPrePInterest == null ||
        _event.srhPrePInterest != R21Interest.NoInterested())) {
      return SizedBox();
    }

    return _makeQuestion(
        'Would she like information about PrEP sent through the app that she can read?',
        answer: DropdownButtonFormField<R21YesNo>(
          value: _event.srhPrepLikeMoreInformation,
          onChanged: (R21YesNo newValue) {
            setState(() {
              _event.srhPrepLikeMoreInformation = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question.';
            }
          },
          items: R21YesNo.allValues
              .map<DropdownMenuItem<R21YesNo>>((R21YesNo value) {
            return DropdownMenuItem<R21YesNo>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        makeBold: false,
        forceColumn: true);
  }

  Widget _buildCard(String title,
      {@required Widget child, bool withTopPadding: true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: withTopPadding ? 20.0 : 0.0),
        _buildTitle(title),
        SizedBox(height: 10.0),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 0.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _prepInterestCard() {
    return _buildCard(
      'PreP',
      withTopPadding: true,
      child: Column(
        children: [
          _prepStarted(),
          _interestPrep(),
          _interestPrepLikeInfoOnMethods(),
          _interestPrepLikeInfoOnMethodsShow(),
          _interestPrepVeryLikeFacilitySchedule(),
          _interestPrepVeryLikeFacilityScheduleDate(),
          _interestPrepVeryLikePNAccompany(),
          _interestPrepVeryOpenFacilitiesPage(),
          _interestPrepVerySelectedFacility(),
          _interestPrepVeryNotNowDate(),
          _interestPrepVeryNotNowDateOther(),
          _interestPrepVeryNotNowPickFacility(),
          _interestPrepVeryNotNowPickFacilityShow(),
          _interestPrepVeryNotNowPickFacilitySelected(),
          _interestPrepVeryLikeInformationOnApp(),
          _interestPrepMaybeLikeInfoOnMethods(),
          _interestPrepMaybeLikeInfoOnMethodsShow(),
          _interestPrepMaybeLikeFacilitySchedule(),
          _interestPrepMaybeLikeFacilityScheduleDate(),
          _interestPrepMaybeLikePNAccompany(),
          _interestPrepMaybeOpenFacilitiesPage(),
          _interestPrepMaybeSelectedFacility(),
          _interestPrepMaybeNotNowDate(),
          _interestPrepMaybeNotNowDateOther(),
          _interestPrepMaybeNotNowPickFacility(),
          _interestPrepMaybeNotNowPickFacilityShow(),
          _interestPrepMaybeNotNowPickFacilitySelected(),
          _interestPrepMaybeLikeInformationOnApp(),
          _interestPrepNotLikeInfoOnMethods(),
          _interestPrepNotLikeInfoOnMethodsShow(),
          _interestPrepNotLikeInformationOnApp()
        ],
      ),
    );
  }

  Widget _contraceptionInterestCard() {
    return _buildCard(
      'Contraception',
      withTopPadding: true,
      child: Column(
        children: [
          _contraceptionStarted(),
          _contraceptionInterest(),
          _hasMethodInMind(),
          _particularMethodInMind(),
          _specifyInterestContraceptionMethodOther(),
          _interestContraceptionLikeInfoMethods(),
          _interestContraceptionOpenCounselingInfoPage(),
          _interestContraceptionLikeFacilitySchedule(),
          _interestContraceptionLikeFacilityScheduleDate(),
          _interestContraceptionLikePNAccompany(),
          _interestContraceptionOpenFacilitiesPage(),
          _interestContraceptionSelectedFacility(),
          _interestContraceptionNotNowDate(),
          _interestContraceptionNotNowDateOther(),
          _interestContraceptionNotNowPickFacility(),
          _interestContraceptionNotNowPickFacilityShow(),
          _interestContraceptionNotNowPickFacilitySelected(),
          _interestContraceptionLikeInformationOnApp(),
          _interestContraceptionMaybeMethod(),
          _interestContraceptionMaybeMethodSpecify(),
          _interestContraceptionMaybeLikeFacilitySchedule(),
          _interestContraceptionMaybeLikeFacilityScheduleDate(),
          _interestContraceptionMaybeLikePNAccompany(),
          _interestContraceptionMaybeOpenFacilitiesPage(),
          _interestContraceptionMaybeSelectedFacility(),
          _interestContraceptionMaybeNotNowDate(),
          _interestContraceptionMaybeNotNowDateOther(),
          _interestContraceptionMaybeNotNowPickFacility(),
          _interestContraceptionMaybeNotNowPickFacilityShow(),
          _interestContraceptionMaybeNotNowPickFacilitySelected(),
          _interestContraceptionMaybeLikeInformationOnApp(),
          _interestContraceptionMaybeLikeInfoOnMethods(),
          _interestContraceptionMaybeLikeInfoOnMethodsShow(),
          _interestContraceptionNotSpecifyReason(),
          _interestContraceptionNotLikeInfoOnMethods(),
          _interestContraceptionNotLikeInfoOnMethodsShow(),
          _interestContraceptionNotLikeInformationOnApp(),
        ],
      ),
    );
  }

  /// Pushes [newScreen] to the top of the navigation stack using a fade in
  /// transition.
  Future<T> _fadeInScreen<T extends Object>(Widget newScreen,
      {String routeName}) {
    return Navigator.of(context).push(
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

  Future<void> _pushChooseFacilityScreen() async {
    await _fadeInScreen(R21ChooseFacilityScreen(),
        routeName: '/choose-facility');
  }

  Future<void> _pushViewResourcesScreen() async {
    await _fadeInScreen(R21ViewResourcesScreen(), routeName: '/view-resources');
  }

  _onSubmitForm(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      print('***Saving followup to db' + _event.toString());

      await DatabaseProvider().insertFollowup(_event);
      _patient.followups.add(_event);
      _patient.initializeRecentFields();

      // we will also have to sink a PatientData event in case the patient's isActivated state changes
      Navigator.of(context).popUntil((Route<dynamic> route) {
        //end anlytics
        _analytic.stopAnalytics(
            resultAction: 'Saved',
            subjectEntity: this._patient.personalStudyNumber);

        return route.settings.name == '/patient';
      });
    }
  }
}
