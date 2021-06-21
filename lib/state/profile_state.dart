import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:one_person_twitter/helper/utility.dart';
import 'package:one_person_twitter/model/user.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;

class ProfileState extends ChangeNotifier {
  ProfileState(this.profileId) {
    databaseInit();
    userId = FirebaseAuth.instance.currentUser.uid;
    _getloggedInUserProfile(userId);
    _getProfileUser(profileId);
  }

  String userId;
  UserModel _userModel;
  UserModel get userModel => _userModel;

  dabase.Query _profileQuery;
  StreamSubscription<Event> profileSubscription;

  final String profileId;

  /// Profile data of user whose profile is open.
  UserModel _profileUserModel;
  UserModel get profileUserModel => _profileUserModel;

  bool _isBusy = true;
  bool get isbusy => _isBusy;
  set loading(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  databaseInit() {
    try {
      if (_profileQuery == null) {
        _profileQuery = kDatabase.child("profile").child(profileId);
      }
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
    }
  }

  bool get isMyProfile => profileId == userId;

  /// Fetch profile of logged in  user
  void _getloggedInUserProfile(String userId) async {
    kDatabase
        .child("profile")
        .child(userId)
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        var map = snapshot.value;
        if (map != null) {
          _userModel = UserModel.fromJson(map);
        }
      }
    });
  }

  /// Fetch profile data of user whoose profile is opened
  void _getProfileUser(String userProfileId) {
    assert(userProfileId != null);
    try {
      loading = true;
      kDatabase
          .child("profile")
          .child(userProfileId)
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            _profileUserModel = UserModel.fromJson(map);
          }
        }
        loading = false;
      });
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getProfileUser');
    }
  }

  @override
  void dispose() {
    _profileQuery.onValue.drain();
    profileSubscription.cancel();
    // _profileQuery.
    super.dispose();
  }
}
