import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../api/facebook_signin_api.dart';
import '../api/google_signin_api.dart';
import '../providers/customer.dart';
import 'package:page_transition/page_transition.dart';
import '../screens/authentication_onboarding_screen.dart';
import 'package:provider/provider.dart';

enum AuthMode { Signup, Login, ForgotPassword }
enum ResetPasswordResult { Fine, Error }

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.Login;
  ResetPasswordResult? _resetPasswordResult;
  final _customerLogGlobalKey = GlobalKey<FormState>();
  final _customerForgotGlobalKey = GlobalKey<FormState>();

  bool _hasException = false;

  void _submit() async {
    FocusScope.of(context).unfocus();
    FlutterSecureStorage _secure = FlutterSecureStorage();

    _secure.deleteAll().then((value) async {
      if (_authMode == AuthMode.Login) {
        _customerLogGlobalKey.currentState!.validate();
        if (_customerLogGlobalKey.currentState!.validate()) {
          setState(() {
            loading = true;
          });
          try {
            Customer? customer =
                await Provider.of<Customer>(context, listen: false).signIn(
              email: _emailLoginController.text.trim(),
              password: _passwordLoginController.text,
            );

            // await Navigator.of(context)
            //     .pushReplacementNamed(HomeScreen.routeName);
          } catch (e) {
            await showOkAlertDialog(context: context, message: e.toString());
          }
          setState(() {
            loading = false;
          });
        }
      }

      if (_authMode == AuthMode.ForgotPassword) {
        _customerForgotGlobalKey.currentState!.validate();
        if (_customerForgotGlobalKey.currentState!.validate()) {
          try {
            await Provider.of<Customer>(context, listen: false).resetPassword(
              email: _forgotEmailController.text.trim(),
            );
          } catch (e) {
            setState(() {
              _hasException = true;
            });
          }
        }
      }
    });
  }

  final Icon _emailIcon =
      const Icon(Icons.alternate_email, color: Colors.white);

  final _emailAutoFillHints = [AutofillHints.email];

  final _emailValidator = MultiValidator([
    RequiredValidator(errorText: 'Required'),
    EmailValidator(errorText: 'Enter a valid E-Mail'),
  ]);

  final Icon _passwordIcon = const Icon(Icons.lock, color: Colors.white);

  final Icon _firstnameIcon = const Icon(Icons.person, color: Colors.white);

  final Icon _birthDayIcon = const Icon(Icons.event, color: Colors.white);

  final Icon _phoneIcon = const Icon(Icons.phone, color: Colors.white);

  final Icon _taxIdIcon = const Icon(Icons.menu_book, color: Colors.white);

  final Icon _crnIcon = const Icon(Icons.store, color: Colors.white);

  final Icon _ibanIcon = const Icon(Icons.credit_card, color: Colors.white);

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _resetPasswordResult = null;
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _resetPasswordResult = null;
        _authMode = AuthMode.Login;
      });
    }
  }

  var _radioColor =
      MaterialStateProperty.all<Color>(const Color.fromRGBO(112, 184, 73, 1.0));
  final _errorRadioColor =
      MaterialStateProperty.all<Color>(const Color.fromRGBO(112, 184, 73, 1.0));

//Focus
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  //Controller
  final _forgotEmailController = TextEditingController();
  final _emailLoginController = TextEditingController();
  final _passwordLoginController = TextEditingController();

  final Color _emailBorderColor = const Color.fromRGBO(112, 184, 73, 1.0);
  final _emailErrorBorderColor = Colors.red;

  final Color _nowNowGeneralColor = const Color.fromRGBO(112, 184, 73, 1.0);
  final Color _nowNowBorderColor = const Color.fromRGBO(112, 184, 73, 1.0);

  bool? _checkEmail;

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();

    _forgotEmailController.dispose();
    _emailLoginController.dispose();
    _passwordLoginController.dispose();

    super.dispose();
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: null,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(114, 180, 62, 1.0),
                    Color.fromRGBO(153, 199, 60, 1.0),
                  ]),
              color: Color.fromRGBO(107, 176, 62, 1.0),
            ),
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.045,
              ),
              child: Image.asset(
                "assets/images/customerLogoWithoutBackgroundAppFormat.png",
                scale: MediaQuery.of(context).size.height * 0.00333,
              ),
            ),
          ),
          toolbarHeight: MediaQuery.of(context).size.height * 0.081,
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // Container(
              //   decoration: const BoxDecoration(
              //     gradient: LinearGradient(
              //         begin: Alignment.topCenter,
              //         end: Alignment.bottomCenter,
              //         colors: [
              //           Color.fromRGBO(114, 180, 62, 1.0),
              //           Color.fromRGBO(153, 199, 60, 1.0),
              //         ]),
              //     color: Color.fromRGBO(107, 176, 62, 1.0),
              //   ),
              //   width: double.infinity,
              //   height: MediaQuery.of(context).size.height * 0.13,
              //   child: Column(
              //     children: [
              //       _emptySpaceColum,

              //       _emptySpaceColum,
              //     ],
              //   ),
              // ),
              // _emptySpaceColum,
              Padding(
                padding: const EdgeInsets.only(bottom: 9, left: 9, right: 9),
                child: Column(
                  children: <Widget>[
                    if (_authMode == AuthMode.Login ||
                        _authMode == AuthMode.ForgotPassword)
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.12),
                    if (_authMode == AuthMode.Login)
                      Form(
                        key: _customerLogGlobalKey,
                        child: Column(
                          children: [
                            _formAndTextFormField(
                              enabled: _authMode == AuthMode.Login,
                              nextFocusNode: _passwordFocus,
                              focusNode: _emailFocus,
                              textController: _emailLoginController,
                              generalColor: _nowNowGeneralColor,
                              errorBorderColor: _emailErrorBorderColor,
                              borderColor: _nowNowBorderColor,
                              icon: _emailIcon,
                              hintText: "E-Mail",
                              textInputType: TextInputType.emailAddress,
                              autoFillHints: _emailAutoFillHints,
                              validator: _emailValidator,
                            ),
                            _emptySpaceColumTextField,
                            _formAndTextFormField(
                              enabled: _authMode == AuthMode.Login,
                              obscure: true,
                              focusNode: _passwordFocus,
                              textController: _passwordLoginController,
                              generalColor: _nowNowGeneralColor,
                              errorBorderColor: Colors.red,
                              borderColor: _nowNowBorderColor,
                              icon: _passwordIcon,
                              hintText: "Password",
                              textInputType: TextInputType.text,
                              validator: RequiredValidator(
                                  errorText: _authMode == AuthMode.Login
                                      ? 'Required'
                                      : ''),
                            ),
                          ],
                        ),
                      ),
                    if (_authMode == AuthMode.ForgotPassword)
                      Column(
                        children: [
                          Text(
                            "Request e-mail to reset password.",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 18,
                            ),
                          ),
                          if (_resetPasswordResult == ResetPasswordResult.Fine)
                            Column(
                              children: [
                                _emptySpaceColumTextField,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Platform.isAndroid
                                          ? Icons.check_circle_outline
                                          : CupertinoIcons.checkmark_alt_circle,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    _emptySpaceColum,
                                    Text("Email sent!",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 15,
                                        ))
                                  ],
                                )
                              ],
                            ),
                          if (_resetPasswordResult == ResetPasswordResult.Error)
                            Column(
                              children: [
                                _emptySpaceColumTextField,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        Platform.isAndroid
                                            ? Icons.highlight_off
                                            : CupertinoIcons.xmark_circle,
                                        color: Platform.isAndroid
                                            ? Colors.red
                                            : CupertinoColors.systemRed),
                                    _emptySpaceColum,
                                    Text("Email not exist!",
                                        style: TextStyle(
                                          color: Platform.isAndroid
                                              ? Colors.red
                                              : CupertinoColors.systemRed,
                                          fontSize: 15,
                                        ))
                                  ],
                                )
                              ],
                            ),
                        ],
                      ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: loading == true
                          ? Center(
                              child: Platform.isAndroid
                                  ? const CircularProgressIndicator()
                                  : const CupertinoActivityIndicator(),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary:
                                    const Color.fromRGBO(253, 166, 41, 1.0),
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  side: const BorderSide(
                                      color: Colors.white, width: 2.0),
                                ),
                              ),
                              child: Text(
                                _authMode == AuthMode.Login
                                    ? "Login".toUpperCase()
                                    : _authMode == AuthMode.Signup
                                        ? "Sign Up".toUpperCase()
                                        : "Reset Password".toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              onPressed: _submit,
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.05),
                    ),
                    if (_authMode == AuthMode.Login)
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(30.0),
                                // ),
                              ),
                              onPressed: () async {
                                if (_authMode == AuthMode.Login) {
                                  await Navigator.pushReplacement(
                                    context,
                                    PageTransition(
                                      duration: const Duration(
                                        milliseconds: 120,
                                      ),
                                      type: PageTransitionType.rightToLeft,
                                      child:
                                          const AuthenticationOnboardingScreen(
                                        initialPage: 0,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.045,
                                  ),
                                  const Icon(FontAwesomeIcons.envelope),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.021,
                                  ),
                                  const Text("Sign up with E-Mail"),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.021,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                                primary: Colors.red,
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(30.0),
                                // ),
                              ),
                              onPressed: () async {
                                if (_authMode == AuthMode.Login) {
                                  await signInWithGoogle();
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.045,
                                  ),
                                  const Icon(FontAwesomeIcons.google),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.021,
                                  ),
                                  const Text("Sign In with Google"),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                                primary: Colors.blue[800],
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(30.0),
                                // ),
                              ),
                              onPressed: () async {
                                if (_authMode == AuthMode.Login) {
                                  await signInWithFacebook();
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.045,
                                  ),
                                  const Icon(FontAwesomeIcons.facebook),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.021,
                                  ),
                                  const Text("Sign In with Facebook"),
                                ],
                              ),
                            ),
                          ),
                          if (Platform.isIOS)
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  splashFactory: NoSplash.splashFactory,
                                  primary: Colors.black87,
                                  // shape: RoundedRectangleBorder(
                                  //   borderRadius: BorderRadius.circular(30.0),
                                  // ),
                                ),
                                onPressed: () async {
                                  if (_authMode == AuthMode.Login) {
                                    await Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                        duration: const Duration(
                                          milliseconds: 120,
                                        ),
                                        type: PageTransitionType.rightToLeft,
                                        child:
                                            const AuthenticationOnboardingScreen(
                                          initialPage: 0,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.045,
                                    ),
                                    const Icon(FontAwesomeIcons.apple),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.021,
                                    ),
                                    const Text("Sign In with Apple"),
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                                primary: Theme.of(context).accentColor,
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(30.0),
                                // ),
                              ),
                              onPressed: () async {
                                if (_authMode == AuthMode.Login) {
                                  await Navigator.pushReplacement(
                                    context,
                                    PageTransition(
                                      duration: const Duration(
                                        milliseconds: 120,
                                      ),
                                      type: PageTransitionType.rightToLeft,
                                      child:
                                          const AuthenticationOnboardingScreen(
                                        initialPage: 0,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.045,
                                  ),
                                  const Icon(FontAwesomeIcons.user),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.021,
                                  ),
                                  const Text("Continiue as Guest"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          if (_authMode != AuthMode.Login)
                            TextButton(
                                style: TextButton.styleFrom(
                                  primary: _nowNowGeneralColor,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  _authMode == AuthMode.Login
                                      ? "Sign Up".toUpperCase()
                                      : "Sign In".toUpperCase(),
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                onPressed:
                                    // _switchAuthMode
                                    () async {
                                  if (_authMode == AuthMode.ForgotPassword) {
                                    setState(() {
                                      _authMode = AuthMode.Login;
                                    });
                                  }
                                }),
                          if (_authMode == AuthMode.Login)
                            TextButton(
                              style: TextButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  primary: _nowNowGeneralColor),
                              child: Text(
                                "Forgot Password?".toUpperCase(),
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onPressed: () {
                                if (_authMode == AuthMode.Login) {
                                  setState(() {
                                    _resetPasswordResult = null;
                                    _authMode = AuthMode.ForgotPassword;
                                  });
                                } else {
                                  setState(() {
                                    _resetPasswordResult = null;
                                    _authMode = AuthMode.Login;
                                  });
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formAndTextFormField({
    Key? key,
    FocusNode? nextFocusNode,
    FocusNode? focusNode,
    required TextEditingController textController,
    required Color generalColor,
    required Color errorBorderColor,
    required Color borderColor,
    required Icon icon,
    required String hintText,
    required TextInputType textInputType,
    Iterable<String>? autoFillHints,
    String? Function(String?)? validator,
    bool? enabled = true,
    bool obscure = false,
    bool filled = true,
  }) {
    return Form(
      key: key,
      child: TextFormField(
        obscureText: obscure,
        enabled: enabled,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        },
        focusNode: focusNode,
        controller: textController,
        style: TextStyle(fontWeight: FontWeight.w400, color: generalColor),
        decoration: InputDecoration(
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 1.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: errorBorderColor, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: errorBorderColor, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          prefixIcon: Container(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: generalColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: icon,
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black26),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 1.0),
            borderRadius: BorderRadius.circular(25.0),
          ),
          filled: filled,
          fillColor: Colors.black.withOpacity(0.1),
        ),
        keyboardType: textInputType,
        autofillHints: autoFillHints,
        validator: validator,
      ),
    );
  }

  Future signInWithGoogle() async {
    try {
      final customer = await GoogleSignInApi.login();
      await Provider.of<Customer>(context, listen: false).signUp(
          customer: Customer(email: customer!.email, providerId: customer.id),
          provider: 'Google');
    } catch (e) {
      print(e);
    }
  }

  Future signInWithFacebook() async {
    try {
      final customer = await FacebookSignInApi.login();
      if (customer!.status == LoginStatus.success) {
        final customerData =
            await FacebookAuth.i.getUserData(fields: "email, name");

        if (customerData["email"] != null) {
          await Provider.of<Customer>(context, listen: false).signUp(
              customer: Customer(
                  email: customerData["email"].toString().toLowerCase().trim(),
                  providerId: customerData["id"].toString().trim()),
              provider: 'Facebook');
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
