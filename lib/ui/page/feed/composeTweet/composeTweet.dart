import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:one_person_twitter/helper/constant.dart';
import 'package:one_person_twitter/helper/utility.dart';
import 'package:one_person_twitter/model/feedModel.dart';
import 'package:one_person_twitter/model/user.dart';
import 'package:one_person_twitter/ui/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:one_person_twitter/ui/page/feed/composeTweet/widget/composeBottomIconWidget.dart';
import 'package:one_person_twitter/ui/page/feed/composeTweet/widget/composeTweetImage.dart';
import 'package:one_person_twitter/ui/page/feed/composeTweet/widget/widgetView.dart';
import 'package:one_person_twitter/state/authState.dart';
import 'package:one_person_twitter/state/feedState.dart';
import 'package:one_person_twitter/ui/page/profile/widgets/circular_image.dart';
import 'package:one_person_twitter/ui/theme/theme.dart';
import 'package:one_person_twitter/widgets/customAppBar.dart';
import 'package:one_person_twitter/widgets/customWidgets.dart';
import 'package:one_person_twitter/widgets/url_text/customUrlText.dart';
import 'package:one_person_twitter/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class ComposeTweetPage extends StatefulWidget {
  ComposeTweetPage({Key key, this.isRetweet, this.isTweet = true})
      : super(key: key);

  final bool isRetweet;
  final bool isTweet;
  _ComposeTweetReplyPageState createState() => _ComposeTweetReplyPageState();
}

class _ComposeTweetReplyPageState extends State<ComposeTweetPage> {
  bool isScrollingDown = false;
  FeedModel model;
  ScrollController scrollcontroller;

  File _image;
  TextEditingController _textEditingController;

  @override
  void dispose() {
    scrollcontroller.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var feedState = Provider.of<FeedState>(context, listen: false);
    model = feedState.tweetToReplyModel;
    scrollcontroller = ScrollController();
    _textEditingController = TextEditingController();
    scrollcontroller..addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (scrollcontroller.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!isScrollingDown) {
        Provider.of<ComposeTweetState>(context, listen: false)
            .setIsScrolllingDown = true;
      }
    }
    if (scrollcontroller.position.userScrollDirection ==
        ScrollDirection.forward) {
      Provider.of<ComposeTweetState>(context, listen: false)
          .setIsScrolllingDown = false;
    }
  }

  void _onCrossIconPressed() {
    setState(() {
      _image = null;
    });
  }

  void _onImageIconSelcted(File file) {
    setState(() {
      _image = file;
    });
  }

  /// Submit tweet to save in firebase database
  void _submitButton() async {
    if (_textEditingController.text == null ||
        _textEditingController.text.isEmpty ||
        _textEditingController.text.length > 280) {
      return;
    }
    var state = Provider.of<FeedState>(context, listen: false);
    kScreenloader.showLoader(context);

    FeedModel tweetModel = createTweetModel();
    if (_image != null) {
      await state.uploadFile(_image).then((imagePath) {
        if (imagePath != null) {
          tweetModel.imagePath = imagePath;

          /// If type of tweet is new tweet
          if (widget.isTweet) {
            state.createTweet(tweetModel);
            kScreenloader.hideLoader();
            Navigator.pop(context);
          }
        }
      });
    } else {
      if (widget.isTweet) {
        state.createTweet(tweetModel);
        kScreenloader.hideLoader();
        Navigator.pop(context);
      }
    }
  }

  FeedModel createTweetModel() {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    var myUser = authState.userModel;
    var profilePic = myUser.profilePic ?? Constants.dummyProfilePic;
    var commentedUser = UserModel(
        displayName: myUser.displayName ?? myUser.email.split('@')[0],
        profilePic: profilePic,
        userId: myUser.userId,
        isVerified: authState.userModel.isVerified,
        userName: authState.userModel.userName);
    FeedModel reply = FeedModel(
        description: _textEditingController.text,
        user: commentedUser,
        createdAt: DateTime.now().toUtc().toString(),
        tags: [],
        parentkey: widget.isTweet
            ? null
            : widget.isRetweet
                ? null
                : state.tweetToReplyModel.key,
        childRetwetkey: widget.isTweet
            ? null
            : widget.isRetweet
                ? model.key
                : null,
        userId: myUser.userId);
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: customTitleText(''),
        onActionPressed: _submitButton,
        isCrossButton: true,
        submitButtonText: 'Tweet',
        isSubmitDisable:
            !Provider.of<ComposeTweetState>(context).enableSubmitButton ||
                Provider.of<FeedState>(context).isBusy,
        isbootomLine: Provider.of<ComposeTweetState>(context).isScrollingDown,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: scrollcontroller,
              child: _ComposeTweet(this),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ComposeBottomIconWidget(
                textEditingController: _textEditingController,
                onImageIconSelcted: _onImageIconSelcted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposeTweet
    extends WidgetView<ComposeTweetPage, _ComposeTweetReplyPageState> {
  _ComposeTweet(this.viewState) : super(viewState);

  final _ComposeTweetReplyPageState viewState;

  Widget _tweerCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 30),
              margin: EdgeInsets.only(left: 20, top: 20, bottom: 3),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 2.0,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: context.width - 72,
                    child: UrlText(
                      text: viewState.model.description ?? '',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      urlStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  UrlText(
                    text:
                        'Replying to ${viewState.model.user.userName ?? viewState.model.user.displayName}',
                    style: TextStyle(
                      color: TwitterColor.paleSky,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircularImage(
                    path: viewState.model.user.profilePic, height: 40),
                SizedBox(width: 10),
                ConstrainedBox(
                  constraints:
                      BoxConstraints(minWidth: 0, maxWidth: context.width * .5),
                  child: TitleText(viewState.model.user.displayName,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 3),
                viewState.model.user.isVerified
                    ? customIcon(
                        context,
                        icon: AppIcon.blueTick,
                        istwitterIcon: true,
                        iconColor: AppColor.primary,
                        size: 13,
                        paddingIcon: 3,
                      )
                    : SizedBox(width: 0),
                SizedBox(width: viewState.model.user.isVerified ? 5 : 0),
                customText('${viewState.model.user.userName}',
                    style: TextStyles.userNameStyle.copyWith(fontSize: 15)),
                SizedBox(width: 5),
                Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: customText(
                      '- ${Utility.getChatTime(viewState.model.createdAt)}',
                      style: TextStyles.userNameStyle.copyWith(fontSize: 12)),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);
    return Container(
      height: context.height,
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          viewState.widget.isTweet ? SizedBox.shrink() : _tweerCard(context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircularImage(path: authState.user?.photoURL, height: 40),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: _TextField(
                  isTweet: widget.isTweet,
                  textEditingController: viewState._textEditingController,
                ),
              )
            ],
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                ComposeTweetImage(
                  image: viewState._image,
                  onCrossIconPressed: viewState._onCrossIconPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField(
      {Key key,
      this.textEditingController,
      this.isTweet = false,
      this.isRetweet = false})
      : super(key: key);
  final TextEditingController textEditingController;
  final bool isTweet;
  final bool isRetweet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: textEditingController,
          onChanged: (text) {
            Provider.of<ComposeTweetState>(context, listen: false)
                .onDescriptionChanged(text);
          },
          maxLines: null,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'What\'s happening?',
              hintStyle: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
