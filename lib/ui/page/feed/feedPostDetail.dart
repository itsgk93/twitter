import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_person_twitter/helper/customRoute.dart';
import 'package:one_person_twitter/helper/enum.dart';
import 'package:one_person_twitter/model/feedModel.dart';
import 'package:one_person_twitter/state/authState.dart';
import 'package:one_person_twitter/state/feedState.dart';
import 'package:one_person_twitter/ui/theme/theme.dart';
import 'package:one_person_twitter/widgets/customWidgets.dart';
import 'package:one_person_twitter/widgets/tweet/tweet.dart';
import 'package:one_person_twitter/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:provider/provider.dart';

class FeedPostDetail extends StatefulWidget {
  FeedPostDetail({Key key, this.postId}) : super(key: key);
  final String postId;

  static Route<Null> getRoute(String postId) {
    return SlideLeftRoute<Null>(
      builder: (BuildContext context) => FeedPostDetail(
        postId: postId,
      ),
    );
  }

  _FeedPostDetailState createState() => _FeedPostDetailState();
}

class _FeedPostDetailState extends State<FeedPostDetail> {
  String postId;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    postId = widget.postId;
    var state = Provider.of<FeedState>(context, listen: false);
    state.getpostDetailFromDatabase(postId);
    super.initState();
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        var state = Provider.of<FeedState>(context, listen: false);
        state.setTweetToReply = state.tweetDetailModel?.last;
        Navigator.of(context).pushNamed('/ComposeTweetPage/' + postId);
      },
      child: Icon(Icons.add),
    );
  }

  Widget _commentRow(FeedModel model) {
    return Tweet(
      model: model,
      type: TweetType.Reply,
      trailing: TweetBottomSheet().tweetOptionIcon(context,
          scaffoldKey: scaffoldKey, model: model, type: TweetType.Reply),
    );
  }

  Widget _tweetDetail(FeedModel model) {
    return Tweet(
      model: model,
      type: TweetType.Detail,
      trailing: TweetBottomSheet().tweetOptionIcon(context,
          scaffoldKey: scaffoldKey, model: model, type: TweetType.Detail),
    );
  }

  void openImage() async {
    Navigator.pushNamed(context, '/ImageViewPge');
  }

  void deleteTweet(TweetType type, String tweetId, {String parentkey}) {
    var state = Provider.of<FeedState>(context, listen: false);
    state.deleteTweet(tweetId, type, parentkey: parentkey);
    Navigator.of(context).pop();
    if (type == TweetType.Detail) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    return WillPopScope(
      onWillPop: () async {
        Provider.of<FeedState>(context, listen: false)
            .removeLastTweetDetail(postId);
        return Future.value(true);
      },
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButton: _floatingActionButton(),
        backgroundColor: Theme.of(context).backgroundColor,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              title: customTitleText('Thread'),
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
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  state.tweetDetailModel == null ||
                          state.tweetDetailModel.length == 0
                      ? Container()
                      : _tweetDetail(state.tweetDetailModel?.last),
                  Container(
                    height: 6,
                    width: context.width,
                    color: TwitterColor.mystic,
                  )
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                state.tweetReplyMap == null ||
                        state.tweetReplyMap.length == 0 ||
                        state.tweetReplyMap[postId] == null
                    ? [
                        Container(
                          child: Center(
                              //  child: Text('No comments'),
                              ),
                        )
                      ]
                    : state.tweetReplyMap[postId]
                        .map((x) => _commentRow(x))
                        .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
