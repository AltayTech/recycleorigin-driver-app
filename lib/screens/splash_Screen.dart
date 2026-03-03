import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../provider/app_theme.dart';
import '../widgets/en_to_ar_number_convertor.dart';
import '../widgets/splashscreen.dart';
import 'auth_gate_screen.dart';

class SplashScreens extends StatefulWidget {
  @override
  _SplashScreensState createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
//      Provider.of<Products>(context, listen: false).fetchAndSetHomeData();
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 3,
      navigateAfterSeconds: const AuthGateScreen(),
      title: new Text(
        context.l10n.splashTitle,
        textAlign: TextAlign.center,
        style: new TextStyle(
          fontFamily: 'BFarnaz',
          fontSize: MediaQuery.of(context).textScaleFactor * 30,
          color: AppTheme.black,
          shadows: <Shadow>[
            Shadow(
              offset: Offset(0.0, 0.0),
              blurRadius: 0.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ),
      ),
      loadingText: Text(
        EnArConvertor().replaceArNumber(context.l10n.splashVersionLabel),
        style: new TextStyle(
          fontFamily: 'Iransans',
          fontWeight: FontWeight.w400,
          fontSize: MediaQuery.of(context).textScaleFactor * 18,
          color: Colors.black,
        ),
      ),
      image: Image.asset(
        'assets/images/splash_main.png',
//        color: AppTheme.primary,
        fit: BoxFit.contain,
        height: MediaQuery.of(context).size.width * 0.7,
        width: MediaQuery.of(context).size.width * 0.7,
      ),
      gradientBackground: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          AppTheme.bg,
          AppTheme.bg,
          AppTheme.bg,
        ],
      ),
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: MediaQuery.of(context).size.width * 0.7,
      onClick: () => print("Flutter Egypt"),
      loaderColor: Colors.white,
      imageBackground: AssetImage('assets/images/login_bg.png'),
    );
  }
}
