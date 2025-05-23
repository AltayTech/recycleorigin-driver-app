import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigindriver/models/error.dart';
import 'package:recycleorigindriver/widgets/custom_dialog_login_error.dart';

import '../../classes/http_exception.dart';
import '../../provider/app_theme.dart';
import '../../provider/auth.dart';
import '../../widgets/main_drawer.dart';
import '../navigation_bottom_screen.dart';

enum AuthMode { VerificationCode, Login }

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: MainDrawer(),
      ), // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          height: deviceSize.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/login_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: deviceSize.height * 0.1,
                child: Container(
                  height: deviceSize.height * 0.99,
                  width: deviceSize.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 30),
                        child: Text(
                          'سامانه مدیریت پسماند',
                          style: TextStyle(
                            fontFamily: 'BFarnaz',
                            fontWeight: FontWeight.w900,
                            color: Colors.green,
                            fontSize: textScaleFactor * 28.0,
                          ),
                        ),
                      )),
                      Flexible(
                        flex: deviceSize.width > 600 ? 2 : 1,
                        child: AuthCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.VerificationCode;
  Map<String, String> _authData = {
    'phoneNumber': '',
    'verificationCode': '',
  };

  var _isLoading = false;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  late  Animation<Offset> _slideAnimation1;
  late Animation<double> _opacityAnimation1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 600,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(3, 0),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    _slideAnimation1 = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(-3, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation1 = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('مشکل در ورود'),
        content: Text(message),
        actions: <Widget>[
          FilledButton(
            child: Text('تایید'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.VerificationCode) {
        // Log user in
        var response = await Provider.of<Auth>(context, listen: false).login(
          _authData['phoneNumber']!,
        );

        _switchAuthMode();
      } else {
        var response =
            await Provider.of<Auth>(context, listen: false).getVerCode(
          _authData['verificationCode']!,
          _authData['phoneNumber']!,
        );
        print(response);
        if (response.code == 'true') {
          Navigator.of(context)
              .pushReplacementNamed(NavigationBottomScreen.routeName);
        } else {
          _showLogindialog(response);
        }
      }
    } on HttpException catch (error) {
      var errorMessage = 'ارتباط برقرار نشد.';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'ارتباط برقرار نشد، لطفا دوباره تلاش کنید.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    print('swotchMode');
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.VerificationCode;
//        _controller.reverse();
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
        _controller.forward();
      });
    }
  }

  void _switchPhoneCorrectMode() {
    print('swotchMode');
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.VerificationCode;
        _controller.reverse();
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
        _controller.forward();
      });
    }
  }

  void _showLogindialog(LoginError loginError) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogLoginError(
        title: loginError.code,
        buttonText: 'خب',
        description: loginError.message,
        image: Image.asset(''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Container(
      width: deviceSize.width * 0.85,
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  AnimatedContainer(
                    duration: _controller.duration!,
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Center(
                            child: Text(
                              'کد دریافتی را وارد نمایید',
                              style: TextStyle(
                                color: AppTheme.h1,
                                fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 11.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: _controller.duration!,
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation1,
                      child: SlideTransition(
                          position: _slideAnimation1,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Center(
                              child: Text(
                                'برای ورود شماره تلفن همراه را وارد نمایید',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'Iransans',
                                  fontSize: textScaleFactor * 11.0,
                                ),
                              ),
                            ),
                          )),
                    ),
                  ),
                ],
              ),
              Stack(
                children: <Widget>[
                  AnimatedContainer(
                    duration: _controller.duration!,
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: deviceSize.height * 0.055,
                                width: deviceSize.width * 0.6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.blue, width: 1.5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: TextFormField(
                                          textAlign: TextAlign.center,
                                          enabled: true,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            suffix: Text(''),
                                            labelStyle: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 15.0,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: _authMode == AuthMode.Login
                                              ? (value) {
                                                  _authData[
                                                          'verificationCode'] =
                                                      value!;
                                                  return null;
                                                }
                                              : null,
                                        ),
                                      ),
                                      Positioned(
                                          right: 3,
                                          top: 5,
                                          bottom: 12,
                                          child: Icon(
                                            Icons.mobile_screen_share,
                                            color: Colors.blue,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: _controller.duration!,
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation1,
                      child: SlideTransition(
                        position: _slideAnimation1,
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: deviceSize.height * 0.055,
                                width: deviceSize.width * 0.6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: AppTheme.h1, width: 0.5),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      TextFormField(
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          suffix: Text(''),
                                          counterStyle: TextStyle(
                                            decorationStyle:
                                                TextDecorationStyle.dashed,
                                            color: Colors.grey,
                                            fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 18.0,
                                          ),
                                        ),
                                        keyboardType: TextInputType.phone,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'لطفا شماره تلفن را وارد نمایید';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _authData['phoneNumber'] = value!;
                                        },
                                      ),
                                      Positioned(
                                          right: 3,
                                          top: 5,
                                          bottom: 12,
                                          child: Icon(
                                            Icons.mobile_screen_share,
                                            color: AppTheme.secondary,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              _isLoading
                  ? SpinKitFadingCircle(
                      itemBuilder: (BuildContext context, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index.isEven ? Colors.grey : Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: deviceSize.height * 0.055,
                      width: deviceSize.width * 0.6,
                      child: FilledButton(
                        child: Text(
                          _authMode == AuthMode.Login
                              ? 'ورود'
                              : 'دریافت کد تایید',
                          style: TextStyle(
                            color: AppTheme.bg,
                            fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 13.0,
                          ),
                        ),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _submit();
                        },
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(5),
                        // ),
                        // padding: EdgeInsets.symmetric(
                        //     horizontal: 30.0, vertical: 8.0),
                        // color: AppTheme.primary,
                        // textColor: AppTheme.bg,
                      ),
                    ),
              AnimatedContainer(
                duration: _controller.duration!,
                curve: Curves.easeIn,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ElevatedButton(
                      child: Text(
                        'اصلاح شماره تلفن',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Iransans',
                          fontSize: textScaleFactor * 9.0,
                        ),
                      ),
                      onPressed: _switchPhoneCorrectMode,
                      // padding: EdgeInsets.only(right: 30.0, left: 30.0, top: 4),
                      // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      // textColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
