import 'package:flutter/material.dart';
import 'package:one_person_twitter/helper/enum.dart';
import 'package:one_person_twitter/model/feedModel.dart';
import 'package:one_person_twitter/state/authState.dart';
import 'package:one_person_twitter/state/feedState.dart';
import 'package:one_person_twitter/ui/theme/theme.dart';
import 'package:one_person_twitter/widgets/customWidgets.dart';
import 'package:one_person_twitter/widgets/newWidget/customLoader.dart';
import 'package:one_person_twitter/widgets/newWidget/emptyList.dart';
import 'package:one_person_twitter/widgets/tweet/tweet.dart';
import 'package:one_person_twitter/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key key, this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/CreateFeedPage/tweet');
      },
      child: customIcon(
        context,
        icon: AppIcon.fabTweet,
        istwitterIcon: true,
        iconColor: Theme.of(context).colorScheme.onPrimary,
        size: 25,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _floatingActionButton(context),
      backgroundColor: TwitterColor.mystic,
      body: SafeArea(
        child: Container(
          height: context.height,
          width: context.width,
          child: RefreshIndicator(
            key: refreshIndicatorKey,
            onRefresh: () async {
              /// refresh home page feed
              var feedState = Provider.of<FeedState>(context, listen: false);
              feedState.getDataFromDatabase();
              return Future.value(true);
            },
            child: _FeedPageBody(
              refreshIndicatorKey: refreshIndicatorKey,
              scaffoldKey: scaffoldKey,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedPageBody extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  const _FeedPageBody({Key key, this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authstate = Provider.of<AuthState>(context, listen: false);
    return Consumer<FeedState>(
      builder: (context, state, child) {
        final List<FeedModel> list = state.getTweetList(authstate.userModel);
        return CustomScrollView(
          slivers: <Widget>[
            child,
            list != null
                ? SliverList(
                    delegate: SliverChildListDelegate(
                      list.map(
                        (model) {
                          return Container(
                            color: Colors.white,
                            child: Tweet(
                              model: model,
                              trailing: TweetBottomSheet().tweetOptionIcon(
                                  context,
                                  model: model,
                                  type: TweetType.Tweet,
                                  scaffoldKey: scaffoldKey),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  )
                : list == null && !state.isBusy
                    ? SliverToBoxAdapter(
                        child: EmptyList(
                          'No Tweet added yet',
                          subTitle:
                              'When new Tweet added, they\'ll show up here \n Tap tweet button to add new',
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: Container(
                          height: context.height - 135,
                          child: CustomScreenLoader(
                            height: double.infinity,
                            width: context.width,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      )
          ],
        );
      },
      child: SliverAppBar(
        floating: true,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState.openDrawer();
              },
            );
          },
        ),
        title: Image.asset('assets/images/icon-480.png', height: 40),
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).appBarTheme.color,
        bottom: PreferredSize(
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
          preferredSize: Size.fromHeight(0.0),
        ),
      ),
    );
  }
}
