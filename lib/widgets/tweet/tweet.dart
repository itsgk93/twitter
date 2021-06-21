import 'package:flutter/material.dart';
import 'package:one_person_twitter/helper/enum.dart';
import 'package:one_person_twitter/helper/utility.dart';
import 'package:one_person_twitter/model/feedModel.dart';
import 'package:one_person_twitter/ui/page/profile/widgets/circular_image.dart';
import 'package:one_person_twitter/ui/theme/theme.dart';
import 'package:one_person_twitter/widgets/newWidget/title_text.dart';
import 'package:one_person_twitter/widgets/tweet/widgets/parentTweet.dart';
import 'package:one_person_twitter/widgets/tweet/widgets/tweetIconsRow.dart';
import 'package:one_person_twitter/widgets/url_text/customUrlText.dart';
import 'package:one_person_twitter/widgets/url_text/custom_link_media_info.dart';

import '../customWidgets.dart';
import 'widgets/tweetImage.dart';

class Tweet extends StatelessWidget {
  final FeedModel model;
  final Widget trailing;
  final TweetType type;
  final bool isDisplayOnProfile;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const Tweet({
    Key key,
    this.model,
    this.trailing,
    this.type = TweetType.Tweet,
    this.isDisplayOnProfile = false,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        type != TweetType.ParentTweet
            ? SizedBox.shrink()
            : Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 38,
                    top: 75,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 2.0, color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(
                  top: type == TweetType.Tweet || type == TweetType.Reply
                      ? 12
                      : 0,
                ),
                child: _TweetBody(
                  isDisplayOnProfile: isDisplayOnProfile,
                  model: model,
                  trailing: trailing,
                  type: type,
                )),
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: TweetImage(
                model: model,
                type: type,
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: type == TweetType.Detail ? 10 : 60),
              child: TweetIconsRow(
                type: type,
                model: model,
                isTweetDetail: type == TweetType.Detail,
                iconColor: Theme.of(context).textTheme.caption.color,
                iconEnableColor: TwitterColor.ceriseRed,
                size: 20,
              ),
            ),
            type == TweetType.ParentTweet
                ? SizedBox.shrink()
                : Divider(height: .5, thickness: .5)
          ],
        ),
      ],
    );
  }
}

class _TweetBody extends StatelessWidget {
  final FeedModel model;
  final Widget trailing;
  final TweetType type;
  final bool isDisplayOnProfile;
  const _TweetBody(
      {Key key, this.model, this.trailing, this.type, this.isDisplayOnProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double descriptionFontSize = type == TweetType.Tweet
        ? 15
        : type == TweetType.Detail || type == TweetType.ParentTweet
            ? 18
            : 14;
    FontWeight descriptionFontWeight =
        type == TweetType.Tweet || type == TweetType.Tweet
            ? FontWeight.w400
            : FontWeight.w400;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: 10),
        Container(
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              if (isDisplayOnProfile) {
                return;
              }
            },
            child: CircularImage(path: model.user.profilePic),
          ),
        ),
        SizedBox(width: 20),
        Container(
          width: context.width - 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: 0, maxWidth: context.width * .5),
                          child: TitleText(model.user.displayName,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(width: 3),
                        model.user.isVerified
                            ? customIcon(
                                context,
                                icon: AppIcon.blueTick,
                                istwitterIcon: true,
                                iconColor: AppColor.primary,
                                size: 13,
                                paddingIcon: 3,
                              )
                            : SizedBox(width: 0),
                        SizedBox(
                          width: model.user.isVerified ? 5 : 0,
                        ),
                        Flexible(
                          child: customText(
                            '${model.user.userName}',
                            style: TextStyles.userNameStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4),
                        customText('· ${Utility.getChatTime(model.createdAt)}',
                            style: TextStyles.userNameStyle),
                      ],
                    ),
                  ),
                  Container(child: trailing == null ? SizedBox() : trailing),
                ],
              ),
              model.description == null
                  ? SizedBox()
                  : UrlText(
                      text: model.description.removeSpaces,
                      onHashTagPressed: (tag) {
                        cprint(tag);
                      },
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: descriptionFontSize,
                          fontWeight: descriptionFontWeight),
                      urlStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: descriptionFontSize,
                          fontWeight: descriptionFontWeight),
                    ),
              if (model.imagePath == null && model.description != null)
                CustomLinkMediaInfo(text: model.description),
            ],
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}

class _TweetDetailBody extends StatelessWidget {
  final FeedModel model;
  final Widget trailing;
  final TweetType type;
  final bool isDisplayOnProfile;
  const _TweetDetailBody(
      {Key key, this.model, this.trailing, this.type, this.isDisplayOnProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double descriptionFontSize = type == TweetType.Tweet
        ? context.getDimention(context, 15)
        : type == TweetType.Detail
            ? context.getDimention(context, 18)
            : type == TweetType.ParentTweet
                ? context.getDimention(context, 14)
                : 10;

    FontWeight descriptionFontWeight =
        type == TweetType.Tweet || type == TweetType.Tweet
            ? FontWeight.w300
            : FontWeight.w400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        model.parentkey != null &&
                model.childRetwetkey == null &&
                type != TweetType.ParentTweet
            ? ParentTweetWidget(
                childRetwetkey: model.parentkey,
                isImageAvailable: false,
                trailing: trailing)
            : SizedBox.shrink(),
        Container(
          width: context.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                leading: GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //     context, ProfilePage.getRoute(profileId: model.userId));
                  },
                  child: CircularImage(path: model.user.profilePic),
                ),
                title: Row(
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: 0, maxWidth: context.width * .5),
                      child: TitleText(model.user.displayName,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 3),
                    model.user.isVerified
                        ? customIcon(
                            context,
                            icon: AppIcon.blueTick,
                            istwitterIcon: true,
                            iconColor: AppColor.primary,
                            size: 13,
                            paddingIcon: 3,
                          )
                        : SizedBox(width: 0),
                    SizedBox(
                      width: model.user.isVerified ? 5 : 0,
                    ),
                  ],
                ),
                subtitle: customText('${model.user.userName}',
                    style: TextStyles.userNameStyle),
                trailing: trailing,
              ),
              model.description == null
                  ? SizedBox()
                  : Padding(
                      padding: type == TweetType.ParentTweet
                          ? EdgeInsets.only(left: 80, right: 16)
                          : EdgeInsets.symmetric(horizontal: 16),
                      child: UrlText(
                        text: model.description.removeSpaces,
                        onHashTagPressed: (tag) {
                          cprint(tag);
                        },
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: descriptionFontSize,
                          fontWeight: descriptionFontWeight,
                        ),
                        urlStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: descriptionFontSize,
                          fontWeight: descriptionFontWeight,
                        ),
                      ),
                    ),
              if (model.imagePath == null && model.description != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomLinkMediaInfo(text: model.description),
                )
            ],
          ),
        ),
      ],
    );
  }
}
