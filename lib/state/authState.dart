import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_person_twitter/helper/enum.dart';
import 'package:one_person_twitter/helper/shared_prefrence_helper.dart';
import 'package:one_person_twitter/helper/utility.dart';
import 'package:one_person_twitter/model/user.dart';
import 'package:one_person_twitter/ui/page/common/locator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'appState.dart';

class AuthState extends AppState {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  bool isSignInWithGoogle = false;
  User user;
  String userId;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  dabase.Query _profileQuery;
  // List<UserModel> _profileUserModelList;
  UserModel _userModel;

  UserModel get userModel => _userModel;

  UserModel get profileUserModel => _userModel;

  void logoutCallback() async {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    _userModel = null;
    user = null;
    _profileQuery?.onValue?.drain();
    _profileQuery = null;
    if (isSignInWithGoogle) {
      _googleSignIn.signOut();
    }
    _firebaseAuth.signOut();
    notifyListeners();
    await getIt<SharedPreferenceHelper>().clearPreferenceValues();
  }

  void openSignUpPage() {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    notifyListeners();
  }

  databaseInit() {
    try {
      if (_profileQuery == null) {
        _profileQuery = kDatabase.child("profile").child(user.uid);
        _profileQuery.onValue.listen(_onProfileChanged);
      }
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
    }
  }

  Future<String> signIn(String email, String password,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      loading = true;
      var result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      userId = user.uid;
      return user.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signIn');
      Utility.customSnackBar(scaffoldKey, error.message);
      // logoutCallback();
      return null;
    }
  }

  Future<User> handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google login cancelled by user');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      user = (await _firebaseAuth.signInWithCredential(credential)).user;
      authStatus = AuthStatus.LOGGED_IN;
      userId = user.uid;
      isSignInWithGoogle = true;
      createUserFromGoogleSignIn(user);
      notifyListeners();
      return user;
    } on PlatformException catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    } on Exception catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    } catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    }
  }

  createUserFromGoogleSignIn(User user) {
    var diff = DateTime.now().difference(user.metadata.creationTime);
    if (diff < Duration(seconds: 15)) {
      UserModel model = UserModel(
        bio: 'Edit profile to update bio',
        dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
            .toString(),
        location: 'Somewhere in universe',
        profilePic: user.photoURL,
        displayName: user.displayName,
        email: user.email,
        key: user.uid,
        userId: user.uid,
        contact: user.phoneNumber,
        isVerified: user.emailVerified,
      );
      createUser(model, newUser: true);
    } else {
      cprint('Last login at: ${user.metadata.lastSignInTime}');
    }
  }

  Future<String> signUp(UserModel userModel,
      {GlobalKey<ScaffoldState> scaffoldKey, String password}) async {
    try {
      loading = true;
      var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );
      user = result.user;
      authStatus = AuthStatus.LOGGED_IN;
      result.user.updateProfile(
          displayName: userModel.displayName, photoURL: userModel.profilePic);

      _userModel = userModel;
      _userModel.key = user.uid;
      _userModel.userId = user.uid;
      createUser(_userModel, newUser: true);
      return user.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signUp');
      Utility.customSnackBar(scaffoldKey, error.message);
      return null;
    }
  }

  createUser(UserModel user, {bool newUser = false}) {
    if (newUser) {
      user.userName =
          Utility.getUserName(id: user.userId, name: user.displayName);
      user.createdAt = DateTime.now().toUtc().toString();
    }
    kDatabase.child('profile').child(user.userId).set(user.toJson());
    _userModel = user;
    loading = false;
  }

  /// Fetch current user profile
  Future<User> getCurrentUser() async {
    try {
      loading = true;
      user = _firebaseAuth.currentUser;
      if (user != null) {
        authStatus = AuthStatus.LOGGED_IN;
        userId = user.uid;
        getProfileUser();
      } else {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      }
      loading = false;
      return user;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getCurrentUser');
      authStatus = AuthStatus.NOT_LOGGED_IN;
      return null;
    }
  }

  /// Reload user to get refresh user data
  reloadUser() async {
    await user.reload();
    user = _firebaseAuth.currentUser;
    if (user.emailVerified) {
      userModel.isVerified = true;
      createUser(userModel);
      cprint('UserModel email verification complete');
    }
  }

  /// Send password reset link to email
  Future<void> forgetPassword(String email,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email).then((value) {
        Utility.customSnackBar(scaffoldKey,
            'A reset password link is sent yo your mail.You can reset your password from there');
      }).catchError((error) {
        cprint(error.message);
        return false;
      });
    } catch (error) {
      Utility.customSnackBar(scaffoldKey, error.message);
      return Future.value(false);
    }
  }

  Future<UserModel> getuserDetail(String userId) async {
    UserModel user;
    var snapshot = await kDatabase.child('profile').child(userId).once();
    if (snapshot.value != null) {
      var map = snapshot.value;
      user = UserModel.fromJson(map);
      user.key = snapshot.key;
      return user;
    } else {
      return null;
    }
  }

  getProfileUser({String userProfileId}) {
    try {
      loading = true;

      userProfileId = userProfileId == null ? user.uid : userProfileId;
      kDatabase
          .child("profile")
          .child(userProfileId)
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            if (userProfileId == user.uid) {
              _userModel = UserModel.fromJson(map);
              _userModel.isVerified = user.emailVerified;
              if (!user.emailVerified) {
                // Check if logged in user verified his email address or not
                reloadUser();
              }
              getIt<SharedPreferenceHelper>().saveUserProfile(_userModel);
            }
          }
        }
        loading = false;
      });
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getProfileUser');
    }
  }

  void _onProfileChanged(Event event) {
    if (event.snapshot != null) {
      final updatedUser = UserModel.fromJson(event.snapshot.value);
      _userModel = updatedUser;
      cprint('UserModel Updated');
      notifyListeners();
    }
  }
}
