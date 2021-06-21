import 'package:flutter/material.dart';
import 'package:one_person_twitter/helper/enum.dart';
import 'package:one_person_twitter/model/feedModel.dart';
import 'package:one_person_twitter/ui/theme/theme.dart';
import 'package:one_person_twitter/widgets/customWidgets.dart';

class TweetIconsRow extends StatelessWidget {
  final FeedModel model;
  final Color iconColor;
  final Color iconEnableColor;
  final double size;
  final bool isTweetDetail;
  final TweetType type;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const TweetIconsRow(
      {Key key,
      this.model,
      this.iconColor,
      this.iconEnableColor,
      this.size,
      this.isTweetDetail = false,
      this.type,
      this.scaffoldKey})
      : super(key: key);

  Widget _likeCommentsIcons(BuildContext context, FeedModel model) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: 0, top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          _iconWidget(
            context,
            text: '0',
            icon: AppIcon.reply,
            iconColor: iconColor,
            size: size ?? 20,
            onPressed: () {},
          ),
          _iconWidget(context,
              text: '0',
              icon: AppIcon.retweet,
              iconColor: iconColor,
              size: size ?? 20,
              onPressed: () {}),
          _iconWidget(
            context,
            text: '0',
            icon: AppIcon.heartEmpty,
            onPressed: () {},
            iconColor: iconColor,
            size: size ?? 20,
          ),
          _iconWidget(context,
              text: '',
              icon: null,
              sysIcon: Icons.share,
              onPressed: () {},
              iconColor: iconColor,
              size: size ?? 20),
        ],
      ),
    );
  }

  Widget _iconWidget(BuildContext context,
      {String text,
      IconData icon,
      Function onPressed,
      IconData sysIcon,
      Color iconColor,
      double size = 20}) {
    return Expanded(
      child: Container(
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () {
                if (onPressed != null) onPressed();
              },
              icon: sysIcon != null
                  ? Icon(sysIcon, color: iconColor, size: size)
                  : customIcon(
                      context,
                      size: size,
                      icon: icon,
                      istwitterIcon: true,
                      iconColor: iconColor,
                    ),
            ),
            customText(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: iconColor,
                fontSize: size - 5,
              ),
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _likeCommentsIcons(context, model));
  }
}
