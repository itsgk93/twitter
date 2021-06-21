import 'dart:math';

import 'package:flutter/material.dart';
import 'package:one_person_twitter/helper/constant.dart';
import 'package:one_person_twitter/helper/enum.dart';
import 'package:one_person_twitter/helper/utility.dart';
import 'package:one_person_twitter/model/user.dart';
import 'package:one_person_twitter/state/authState.dart';
import 'package:one_person_twitter/ui/page/Auth/widget/googleLoginButton.dart';
import 'package:one_person_twitter/ui/theme/theme.dart';
import 'package:one_person_twitter/widgets/customFlatButton.dart';
import 'package:one_person_twitter/widgets/customWidgets.dart';
import 'package:one_person_twitter/widgets/newWidget/customLoader.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  final VoidCallback loginCallback;

  const Signup({Key key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController _nameController;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _confirmController;
  CustomLoader loader;
  final _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    loader = CustomLoader();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    super.initState();
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {
    return Container(
      height: context.height - 88,
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _entryFeild('Name', controller: _nameController),
            _entryFeild('Enter email',
                controller: _emailController, isEmail: true),
            // _entryFeild('Mobile no',controller: _mobileController),
            _entryFeild('Enter password',
                controller: _passwordController, isPassword: true),
            _entryFeild('Confirm password',
                controller: _confirmController, isPassword: true),
            _submitButton(context),

            Divider(height: 30),
            SizedBox(height: 30),
            // _googleLoginButton(context),
            GoogleLoginButton(
              loginCallback: widget.loginCallback,
              loader: loader,
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _entryFeild(String hint,
      {TextEditingController controller,
      bool isPassword = false,
      bool isEmail = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 35),
      child: CustomFlatButton(
        label: "Sign up",
        onPressed: _submitForm,
        borderRadius: 30,
      ),
    );
  }

  void _submitForm() {
    if (_emailController.text.isEmpty) {
      Utility.customSnackBar(_scaffoldKey, 'Please enter name');
      return;
    }
    if (_emailController.text.length > 27) {
      Utility.customSnackBar(
          _scaffoldKey, 'Name length cannot exceed 27 character');
      return;
    }
    if (_emailController.text == null ||
        _emailController.text.isEmpty ||
        _passwordController.text == null ||
        _passwordController.text.isEmpty ||
        _confirmController.text == null) {
      Utility.customSnackBar(_scaffoldKey, 'Please fill form carefully');
      return;
    } else if (_passwordController.text != _confirmController.text) {
      Utility.customSnackBar(
          _scaffoldKey, 'Password and confirm password did not match');
      return;
    }

    loader.showLoader(context);
    var state = Provider.of<AuthState>(context, listen: false);

    UserModel user = UserModel(
      email: _emailController.text.toLowerCase(),
      bio: 'Edit profile to update bio',
      // contact:  _mobileController.text,
      displayName: _nameController.text,
      dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
          .toString(),
      location: 'Somewhere in universe',
      profilePic: Constants.dummyProfilePic,
      isVerified: false,
    );
    state
        .signUp(
      user,
      password: _passwordController.text,
      scaffoldKey: _scaffoldKey,
    )
        .then((status) {
      print(status);
    }).whenComplete(
      () {
        loader.hideLoader();
        if (state.authStatus == AuthStatus.LOGGED_IN) {
          Navigator.pop(context);
          widget.loginCallback();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: customText(
          'Sign Up',
          context: context,
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(child: _body(context)),
    );
  }
}
