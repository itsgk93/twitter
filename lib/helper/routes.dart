import 'package:flutter/material.dart';
import 'package:one_person_twitter/ui/page/Auth/selectAuthMethod.dart';
import 'package:one_person_twitter/ui/page/common/splash.dart';
import 'package:one_person_twitter/ui/page/feed/composeTweet/composeTweet.dart';
import 'package:one_person_twitter/ui/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:provider/provider.dart';

import '../helper/customRoute.dart';
import '../ui/page/Auth/forgetPasswordPage.dart';
import '../ui/page/Auth/signin.dart';
import '../ui/page/Auth/signup.dart';
import '../ui/page/feed/feedPostDetail.dart';
import '../ui/page/feed/imageViewPage.dart';
import '../widgets/customWidgets.dart';

class TwitterRoutes {
  static dynamic route() {
    return {
      'SplashPage': (BuildContext context) => SplashPage(),
    };
  }

  static void sendNavigationEventToFirebase(String path) {
    if (path != null && path.isNotEmpty) {
      // analytics.setCurrentScreen(screenName: path);
    }
  }

  static Route onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements[1]) {
      case "ComposeTweetPage":
        bool isRetweet = false;
        bool isTweet = false;
        if (pathElements.length == 3 && pathElements[2].contains('retweet')) {
          isRetweet = true;
        } else if (pathElements.length == 3 &&
            pathElements[2].contains('tweet')) {
          isTweet = true;
        }
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<ComposeTweetState>(
                  create: (_) => ComposeTweetState(),
                  child:
                      ComposeTweetPage(isRetweet: isRetweet, isTweet: isTweet),
                ));
      case "FeedPostDetail":
        var postId = pathElements[2];
        return SlideLeftRoute<bool>(
            builder: (BuildContext context) => FeedPostDetail(
                  postId: postId,
                ),
            settings: RouteSettings(name: 'FeedPostDetail'));
      case "CreateFeedPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<ComposeTweetState>(
                  create: (_) => ComposeTweetState(),
                  child: ComposeTweetPage(isRetweet: false, isTweet: true),
                ));
      case "WelcomePage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => WelcomePage());
      case "SignIn":
        return CustomRoute<bool>(builder: (BuildContext context) => SignIn());
      case "SignUp":
        return CustomRoute<bool>(builder: (BuildContext context) => Signup());
      case "ForgetPasswordPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ForgetPasswordPage());

      case "ImageViewPge":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ImageViewPge());

      default:
        return onUnknownRoute(RouteSettings(name: '/Feature'));
    }
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: customTitleText(settings.name.split('/')[1]),
          centerTitle: true,
        ),
        body: Center(
          child: Text('${settings.name.split('/')[1]} Comming soon..'),
        ),
      ),
    );
  }
}
