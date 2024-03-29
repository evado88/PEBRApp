import 'package:flutter/material.dart';
import 'package:pebrapp/screens/LockScreen.dart';
import 'package:pebrapp/r21screens/R21MainScreen.dart';
import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:pebrapp/screens/IconExplanationsScreen.dart';

 void main() async {

  runApp(PEBRApp());

} 

class PEBRApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PEBRAppState();
}

class PEBRAppState extends State<PEBRApp> {
  static BuildContext _rootContext;

  static BuildContext get rootContext => _rootContext;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Navigator(
        // 'sub-root' navigator, second in the hierarchy. We use the root navigator for flushbar notifications.
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (BuildContext context) {
            _rootContext = context;
            return R21MainScreen(false);
          },
          settings: RouteSettings(
            name: '/',
          ),
        ),
      ),
      routes: {
        // these can be used for calls such as
        // Navigator.pushNamed(context, '/settings')
        '/settings': (context) => SettingsScreen(),
        '/icons': (context) => IconExplanationsScreen(),
        '/lock': (context) => LockScreen(),
      },
      title: 'PEBRApp',
      theme: ThemeData(primarySwatch: Colors.purple),
    );
  }
}
