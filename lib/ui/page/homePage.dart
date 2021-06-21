import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:one_person_twitter/state/appState.dart';
import 'package:one_person_twitter/state/authState.dart';
import 'package:one_person_twitter/state/feedState.dart';
import 'package:one_person_twitter/ui/page/common/sidebar.dart';
import 'package:one_person_twitter/ui/page/feed/feedPage.dart';
import 'package:one_person_twitter/widgets/bottomMenuBar/bottomMenuBar.dart';
import 'package:provider/provider.dart';
import 'common/widget/comingSoon.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  int pageIndex = 0;
  // ignore: cancel_subscriptions
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<AppState>(context, listen: false);
      state.setpageIndex = 0;
      initTweets();
      initProfile();
      
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initTweets() {
    var state = Provider.of<FeedState>(context, listen: false);
    state.databaseInit();
    state.getDataFromDatabase();
  }

  void initProfile() {
    var state = Provider.of<AuthState>(context, listen: false);
    state.databaseInit();
  }

  Widget _body() {
    return SafeArea(
      child: Container(
        child: _getPage(Provider.of<AppState>(context).pageIndex),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return FeedPage(
          scaffoldKey: _scaffoldKey,
          refreshIndicatorKey: refreshIndicatorKey,
        );
        break;
      case 1:
        return ComingSoon("Search Screen");
        break;
      case 2:
        return ComingSoon("Notification Screen");
        break;
      case 3:
        return ComingSoon("Chat Screen");
        break;
      default:
        return FeedPage(scaffoldKey: _scaffoldKey);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomMenubar(),
      drawer: SidebarMenu(),
      body: _body(),
    );
  }
}
