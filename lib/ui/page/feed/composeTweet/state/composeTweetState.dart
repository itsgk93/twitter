import 'dart:convert';
import 'package:one_person_twitter/helper/utility.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class ComposeTweetState extends ChangeNotifier {
  bool showUserList = false;
  bool enableSubmitButton = false;
  bool hideUserList = false;
  String description = "";
  String serverToken;
  final usernameRegex = r'(@\w*[a-zA-Z1-9]$)';

  bool _isScrollingDown = false;
  bool get isScrollingDown => _isScrollingDown;
  set setIsScrolllingDown(bool value) {
    _isScrollingDown = value;
    notifyListeners();
  }

  bool get displayUserList {
    RegExp regExp = new RegExp(usernameRegex);
    var status = regExp.hasMatch(description);
    if (status && !hideUserList) {
      return true;
    } else {
      return false;
    }
  }

  /// Hide userlist when a  user select a username from userlist
  void onUserSelected() {
    hideUserList = true;
    notifyListeners();
  }

 
  void onDescriptionChanged(String text) {
    description = text;
    hideUserList = false;
    if (text.isEmpty || text.length > 280) {
      /// Disable submit button if description is not availabele
      enableSubmitButton = false;
      notifyListeners();
      return;
    }

    /// Enable submit button if description is availabele
    enableSubmitButton = true;
    var last = text.substring(text.length - 1, text.length);

    RegExp regExp = new RegExp(usernameRegex);
    var status = regExp.hasMatch(text);
    if (status) {

      /// If last character is `@` then reset search user list
      if (last == "@") {
        /// Reset user list
      } else {
        /// Filter user list according to name
      }
    } else {
      /// Hide userlist if no matched username found
      hideUserList = false;
      notifyListeners();
    }
  }

  /// When user select user from userlist it will add username in description
  String getDescription(String username) {
    RegExp regExp = new RegExp(usernameRegex);
    Iterable<Match> _matches = regExp.allMatches(description);
    var name = description.substring(0, _matches.last.start);
    description = '$name $username';
    return description;
  }

   Future<Null> getFCMServerKey() async {
    /// If FCM server key is already fetched then no need to fetch it again.
    try {
      if (serverToken != null && serverToken.isNotEmpty) {
        return Future.value(null);
      }
      final RemoteConfig remoteConfig = await RemoteConfig.instance;
      await remoteConfig.fetch(expiration: const Duration(hours: 5));
      await remoteConfig.activateFetched();
      var data = remoteConfig.getString('FcmServerKey');
      if (data != null) {
        serverToken = jsonDecode(data)["key"];
      }
    } catch (error) {
      cprint("Add FcmServerKey in Firebase Remote config");
    }
  }
}
