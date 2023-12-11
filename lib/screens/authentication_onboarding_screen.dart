import 'dart:async';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:nownow_customer/providers/customer.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../screens/auth_screen.dart';

class AuthenticationOnboardingScreen extends StatefulWidget {
  static const routeName = '/authOnboarding';

  final int initialPage;
  const AuthenticationOnboardingScreen({Key? key, required this.initialPage})
      : super(key: key);

  @override
  _AuthenticationOnboardingScreenState createState() =>
      _AuthenticationOnboardingScreenState();
}

class _AuthenticationOnboardingScreenState
    extends State<AuthenticationOnboardingScreen>
    with TickerProviderStateMixin {
  late int initialPage;
  final _customerRegEmailGlobalKey = GlobalKey<FormState>();
  final _customerRegFirstnameGlobalKey = GlobalKey<FormState>();
  final _customerRegLastnameGlobalKey = GlobalKey<FormState>();
  final _customerRegPasswordGlobalKey = GlobalKey<FormState>();
  final _customerRegRepeatPasswordGlobalKey = GlobalKey<FormState>();

  bool _hasException = false;

  void _submit() async {
    FocusScope.of(context).unfocus();

    _customerRegEmailGlobalKey.currentState!.validate();
    _customerRegFirstnameGlobalKey.currentState!.validate();
    _customerRegLastnameGlobalKey.currentState!.validate();
    _customerRegPasswordGlobalKey.currentState!.validate();
    _customerRegRepeatPasswordGlobalKey.currentState!.validate();
    if (_customerRegEmailGlobalKey.currentState!.validate() &&
        _customerRegFirstnameGlobalKey.currentState!.validate() &&
        _customerRegLastnameGlobalKey.currentState!.validate() &&
        _customerRegPasswordGlobalKey.currentState!.validate() &&
        _customerRegRepeatPasswordGlobalKey.currentState!.validate()) {
    } else {
      if (_customerRegEmailGlobalKey.currentState!.validate() == false) {
        _emptyAlertFieldsString =
            _emptyAlertFieldsString + _emptyAlertEmailString;
      }
      if (_passwordSignUpController.text.isEmpty) {
        _emptyAlertFieldsString =
            _emptyAlertFieldsString + _emptyAlertPasswordString;
      }

      if (_repeatPasswordController.text.isEmpty) {
        _emptyAlertFieldsString =
            _emptyAlertFieldsString + _emptyAlertRepeatPasswordString;
      }

      await showOkAlertDialog(context: context, title: _emptyAlertFieldsString);
      _emptyAlertFieldsString = "Please fill in the empty text fields:\n";
      // }
    }
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

  var _radioColor =
      MaterialStateProperty.all<Color>(const Color.fromRGBO(112, 184, 73, 1.0));
  final _errorRadioColor =
      MaterialStateProperty.all<Color>(const Color.fromRGBO(112, 184, 73, 1.0));

  var _invoiceRadioColor =
      MaterialStateProperty.all<Color>(const Color.fromRGBO(112, 184, 73, 1.0));
  final _invoiceErrorRadioColor =
      MaterialStateProperty.all<Color>(const Color.fromRGBO(112, 184, 73, 1.0));

//Focus
  final _emailRegFocus = FocusNode();
  final _passwordRegFocus = FocusNode();
  final _repeatPasswordFocus = FocusNode();
  final _firstnameFocus = FocusNode();
  final _lastnameFocus = FocusNode();

  //Controller
  String? _gender;
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailSignUpController = TextEditingController();
  final _passwordSignUpController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  int pageIndex = 0;

  void _onEmailFocusChange() async {
    if (_emailRegFocus.hasFocus == false) {
      if (_customerRegEmailGlobalKey.currentState!.validate()) {
        if (_emailSignUpController.text.isNotEmpty) {
          try {
            final bool findedEmail =
                await Provider.of<Customer>(context, listen: false).findEmail(
              email: _emailSignUpController.text,
            );
            if (findedEmail) {
              setState(() {
                _checkEmail = true;
              });
              _customerRegEmailGlobalKey.currentState!.validate();
            } else {
              setState(() {
                _checkEmail = false;
              });
              _customerRegEmailGlobalKey.currentState!.validate();
            }
          } catch (e) {
            setState(() {
              _checkEmail = false;
            });
            _customerRegEmailGlobalKey.currentState!.validate();
          }
        }
      }
    }
  }

  void _onPasswordFocusChange() {
    if (_passwordRegFocus.hasFocus == false) {
      if (_passwordSignUpController.text.isEmpty) {
        _customerRegPasswordGlobalKey.currentState!.validate();
      } else {
        _customerRegPasswordGlobalKey.currentState!.validate();
        if (_repeatPasswordController.text.isNotEmpty) {
          _customerRegRepeatPasswordGlobalKey.currentState!.validate();
        }
      }
    }
  }

  void _onRepeatPasswordFocusChange() {
    if (_repeatPasswordFocus.hasFocus == false) {
      if (_repeatPasswordController.text.isEmpty) {
        _customerRegRepeatPasswordGlobalKey.currentState!.validate();
      } else {
        _customerRegPasswordGlobalKey.currentState!.validate();
        _customerRegRepeatPasswordGlobalKey.currentState!.validate();
      }
    }
  }

  String _emptyAlertFieldsString = "Please fill in the empty text fields:\n";
  final String _emptyAlertEmailString = "\n\n- E-Mail";
  final String _emptyAlertPasswordString = "\n\n- Password";
  final String _emptyAlertRepeatPasswordString = "\n\n- Repeat Password";

  final Color _emailBorderColor = const Color.fromRGBO(112, 184, 73, 1.0);
  final _emailErrorBorderColor = Colors.red;

  final Color _nowNowGeneralColor = const Color.fromRGBO(112, 184, 73, 1.0);
  final Color _nowNowBorderColor = const Color.fromRGBO(112, 184, 73, 1.0);

  bool? _checkEmail;

  bool loading = false;
  int _numPages = 2;
  late PageController _pageController;
  int _currentPage = 0;

  List<Widget> _pageIndicator() {
    List<Widget> list = [];
    for (var i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(
        milliseconds: 120,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.021,
      ),
      height: MediaQuery.of(context).size.height * 0.009,
      width: isActive
          ? MediaQuery.of(context).size.width * 0.045
          : MediaQuery.of(context).size.width * 0.021,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
        borderRadius: BorderRadius.all(
          Radius.circular(
            12.0,
          ),
        ),
      ),
    );
  }

  final ScrollController _listViewScrollController = ScrollController();

  bool _isLoading = false;

  final Color? _buttonColor = Colors.grey[350];

  bool hasException = false;

  ScrollController _scrollController = ScrollController();

  bool isInit = true;

  @override
  void initState() {
    super.initState();

    initialPage = widget.initialPage;

    _emailRegFocus.addListener(_onEmailFocusChange);
    _passwordRegFocus.addListener(_onPasswordFocusChange);
    _repeatPasswordFocus.addListener(_onRepeatPasswordFocusChange);
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _emailRegFocus.dispose();
    _passwordRegFocus.dispose();
    _repeatPasswordFocus.dispose();
    _firstnameFocus.dispose();
    _lastnameFocus.dispose();

    _emailSignUpController.dispose();
    _passwordSignUpController.dispose();
    _repeatPasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();

    _scrollController.dispose();

    _firstnameController.dispose();
    _lastnameController.dispose();

    _pageController.dispose();
    _listViewScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Container(
              height: _height,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: _height * 0.012,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: _currentPage != _numPages - 1
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage == _numPages - 1)
                          Container(
                            margin: EdgeInsets.only(
                              top: _height * 0.03,
                              right: _width * 0.021,
                            ),
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                _pageController.previousPage(
                                  duration: Duration(milliseconds: 120),
                                  curve: Curves.ease,
                                );
                                FocusScope.of(context).unfocus();
                              },
                              child: Text(
                                "Back",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                              ),
                            ),
                          ),
                        Container(
                          margin: EdgeInsets.only(
                            top: _height * 0.03,
                            right: _width * 0.021,
                          ),
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () async {
                              await Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      duration: Duration(
                                        milliseconds: 120,
                                      ),
                                      type: PageTransitionType.leftToRight,
                                      child: const AuthScreen()));
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 15,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              splashFactory: NoSplash.splashFactory,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: _height * 0.801,
                      child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (pageIndex) {
                          setState(() {
                            _currentPage = pageIndex;
                          });
                          print("page Index: " + pageIndex.toString());
                        },
                        children: [
                          _buildEmailPage(context),
                          _buildDonePage(context),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _pageIndicator(),
                    ),
                    _currentPage != _numPages - 1
                        ? Flexible(
                            fit: FlexFit.loose,
                            child: Row(
                              mainAxisAlignment: _currentPage != 0
                                  ? MainAxisAlignment.spaceBetween
                                  : MainAxisAlignment.end,
                              children: [
                                if (_currentPage != 0)
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        splashFactory: NoSplash.splashFactory),
                                    onPressed: () {
                                      _pageController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 120),
                                        curve: Curves.ease,
                                      );
                                      FocusScope.of(context).unfocus();
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.arrowLeft,
                                          color: Theme.of(context).primaryColor,
                                          size: 21.0,
                                        ),
                                        SizedBox(
                                          width: _width * 0.01,
                                        ),
                                        Text(
                                          "Back",
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                loading
                                    ? Platform.isAndroid
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                              top: _height * 0.021,
                                              right: _width * 0.1,
                                            ),
                                            child:
                                                const CircularProgressIndicator(),
                                          )
                                        : Padding(
                                            padding: EdgeInsets.only(
                                              top: _height * 0.021,
                                              right: _width * 0.1,
                                            ),
                                            child:
                                                const CupertinoActivityIndicator(),
                                          )
                                    : TextButton(
                                        style: TextButton.styleFrom(
                                          splashFactory: NoSplash.splashFactory,
                                        ),
                                        onPressed: () async {
                                          if (!loading) {
                                            setState(() {
                                              loading = true;
                                            });

                                            if (_currentPage == 0) {
                                              await _signUpCustomer();
                                            }

                                            setState(() {
                                              loading = false;
                                            });
                                          }
                                          FocusScope.of(context).unfocus();
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Next",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: 18,
                                              ),
                                            ),
                                            SizedBox(
                                              width: _width * 0.01,
                                            ),
                                            Icon(
                                              FontAwesomeIcons.arrowRight,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 21.0,
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          )
                        : const Text(""),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomSheet: _bottonSheet(context),
      ),
    );
  }

  Widget? _bottonSheet(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    if (_isLoading && _currentPage == _numPages - 1) {
      return Container(
        height: _height * 0.081,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(114, 180, 62, 1.0),
              Color.fromRGBO(153, 199, 60, 1.0),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: _height * 0.012,
            ),
            child: Platform.isAndroid
                ? const CircularProgressIndicator(
                    color: Color.fromRGBO(253, 166, 41, 1.0),
                  )
                : const CupertinoActivityIndicator(),
          ),
        ),
      );
    }
    if (!_isLoading && _currentPage == _numPages - 1) {
      return GestureDetector(
        onTap: () async {
          if (!_isLoading) {
            setState(() {
              _isLoading = true;
            });
            // await Navigate to homefeed
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: Container(
          height: _height * 0.081,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(114, 180, 62, 1.0),
                Color.fromRGBO(153, 199, 60, 1.0),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: _height * 0.012,
              ),
              child: const Text(
                "Get Started",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildEmailPage(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);
    return Padding(
      padding: EdgeInsets.only(
        right: _width * 0.063,
        left: _width * 0.063,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image(
              image: const AssetImage(
                'assets/images/signupmail.png',
              ),
              height: _height * 0.18,
              width: _width * 0.7,
            ),
          ),
          const Text(
            "Get the ur cusomized STADS & QROFFER",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          SizedBox(
            height: _height * 0.012,
          ),
          Text(
            "Be a part of NowNow",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          SizedBox(
            height: _height * 0.005,
          ),
          Text(
            "Get STAD and QROFFER in real time, from ur neighbourhood",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 15,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          _emptySpaceColum,
          _emptySpaceColumTextField,
          _formAndTextFormField(
            key: _customerRegEmailGlobalKey,
            nextFocusNode: _passwordRegFocus,
            focusNode: _emailRegFocus,
            textController: _emailSignUpController,
            generalColor: _nowNowGeneralColor,
            errorBorderColor: _emailErrorBorderColor,
            borderColor: _emailBorderColor,
            icon: _emailIcon,
            hintText: "E-Mail",
            textInputType: TextInputType.emailAddress,
            validator: (value) {
              if (value!.isEmpty) {
                return "Required";
              } else {
                bool _emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (_emailValid == false) {
                  return "Invalid E-Mail";
                } else {
                  if (_checkEmail == false) {
                    return "Email address assigned";
                  }
                }
              }
            },
            autoFillHints: _emailAutoFillHints,
          ),
          _emptySpaceColumTextField,
          _formAndTextFormField(
            key: _customerRegPasswordGlobalKey,
            nextFocusNode: _repeatPasswordFocus,
            focusNode: _passwordRegFocus,
            textController: _passwordSignUpController,
            obscure: true,
            generalColor: _nowNowGeneralColor,
            errorBorderColor: Colors.red,
            borderColor: _nowNowBorderColor,
            icon: _passwordIcon,
            hintText: "Password",
            textInputType: TextInputType.text,
            validator: MinLengthValidator(6,
                errorText: 'Enter at least 6 Characters.'),
          ),
          _emptySpaceColumTextField,
          _formAndTextFormField(
            key: _customerRegRepeatPasswordGlobalKey,
            focusNode: _repeatPasswordFocus,
            textController: _repeatPasswordController,
            obscure: true,
            generalColor: _nowNowGeneralColor,
            errorBorderColor: Colors.red,
            borderColor: _nowNowBorderColor,
            icon: _passwordIcon,
            hintText: "Repeat Password",
            textInputType: TextInputType.text,
            validator: (value) =>
                MatchValidator(errorText: 'Passwords do not match.')
                    .validateMatch(value!, _passwordSignUpController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildDonePage(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);
    return Padding(
      padding: EdgeInsets.only(
        right: _width * 0.063,
        left: _width * 0.063,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image(
              image: const AssetImage(
                'assets/images/done.png',
              ),
              height: _height * 0.270,
              width: _width * 0.81,
            ),
          ),
          SizedBox(
            height: _height * 0.012,
          ),
          Text(
            "U are an Customer and a part of NowNow! 😍",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          SizedBox(
            height: _height * 0.005,
          ),
          Text(
            "Advertise STAD and QROFFER in real time, promote ur store and grow up 📈 🛫",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 15,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          _emptySpaceColum,
        ],
      ),
    );
  }

  Future<void> _signUpCustomer() async {
    _customerRegEmailGlobalKey.currentState!.validate();

    _customerRegPasswordGlobalKey.currentState!.validate();

    _customerRegRepeatPasswordGlobalKey.currentState!.validate();

    if (_emailSignUpController.text.isNotEmpty) {
      try {
        final bool findedEmail =
            await Provider.of<Customer>(context, listen: false).findEmail(
          email: _emailSignUpController.text,
        );
        if (findedEmail) {
          setState(() {
            _checkEmail = true;
          });
          _customerRegEmailGlobalKey.currentState!.validate();
        } else {
          setState(() {
            _checkEmail = false;
          });
          _customerRegEmailGlobalKey.currentState!.validate();
        }
      } catch (e) {
        setState(() {
          _checkEmail = false;
        });
        _customerRegEmailGlobalKey.currentState!.validate();
      }
    }

    if (_customerRegEmailGlobalKey.currentState!.validate() &&
        _customerRegPasswordGlobalKey.currentState!.validate() &&
        _customerRegRepeatPasswordGlobalKey.currentState!.validate() &&
        _checkEmail!) {
      try {
        await Provider.of<Customer>(context, listen: false).signUp(
          customer: Customer(
            email: _emailSignUpController.text.trim(),
            password: _passwordSignUpController.text,
            firstname: _firstnameController.text,
            lastname: _lastnameController.text,
            gender: _gender,
          ),
        );

        await _pageController.nextPage(
          duration: const Duration(milliseconds: 120),
          curve: Curves.ease,
        );
      } catch (e) {
        print(e);
      }
    }
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
          hintStyle: const TextStyle(color: Colors.black26),
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
}
