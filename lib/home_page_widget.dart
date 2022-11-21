import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:recomienda_flutter/res/custom_colors.dart';
import 'package:recomienda_flutter/utils/authentication.dart';
import 'package:recomienda_flutter/widgets/google_sign_in_button.dart';

import '../flutter_flow/flutter_flow_icon_button.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'fcm/fcm_notification_handler.dart';
import 'main.dart';






class HomePageWidget2 extends StatefulWidget{
  var _scaffoldState = GlobalKey<ScaffoldState>();

  @override
  _HomePageWidget2 createState() => _HomePageWidget2();

}

class _HomePageWidget2 extends State<HomePageWidget2>{

  @override
  void initState(){
    super.initState();

    //FirebaseMessaging.instance.getToken().then((value) => print('Token: $value'));

    //subscribe topic
    FirebaseMessaging.instance.subscribeToTopic('reda').then((value) => print('Suscrito'));

    //setup message display
    initFirebaseMessagingHandler(channel!);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._scaffoldState,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: AlignmentDirectional(0, 0),
                child: Image.asset(
                  'assets/logo.png',
                  width: MediaQuery.of(context).size.width * 0.9,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              FutureBuilder(
                future: Authentication.initializeFirebase(context: context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error initializing Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return GoogleSignInButton();
                  };
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomColors.firebaseNavy,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
