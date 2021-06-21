import 'package:flutter/material.dart';
import 'package:one_person_twitter/helper/enum.dart';
import 'package:one_person_twitter/model/feedModel.dart';
import 'package:one_person_twitter/state/feedState.dart';
import 'package:one_person_twitter/ui/theme/theme.dart';
import 'package:one_person_twitter/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class TweetBottomSheet {
  Widget tweetOptionIcon(BuildContext context,
      {FeedModel model, TweetType type, GlobalKey<ScaffoldState> scaffoldKey}) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: customIcon(context,
          icon: AppIcon.delete,
          istwitterIcon: true,
          iconColor: AppColor.lightGrey),
    ).ripple(
      () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Delete"),
            content: Text('Do you want to delete this Tweet?'),
            actions: [
              // ignore: deprecated_member_use
              FlatButton(
                textColor: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              // ignore: deprecated_member_use
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    TwitterColor.dodgetBlue,
                  ),
                  foregroundColor: MaterialStateProperty.all(
                    TwitterColor.white,
                  ),
                ),
                onPressed: () {
                  _deleteTweet(
                    context,
                    type,
                    model.key,
                    parentkey: model.parentkey,
                  );
                },
                child: Text('Confirm'),
              ),
            ],
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
    );
  }

  
  void _deleteTweet(BuildContext context, TweetType type, String tweetId,
      {String parentkey}) {
    var state = Provider.of<FeedState>(context, listen: false);
    state.deleteTweet(tweetId, type, parentkey: parentkey);
    // CLose bottom sheet
    Navigator.of(context).pop();
    if (type == TweetType.Detail) {
      // Close Tweet detail page
      Navigator.of(context).pop();
      // Remove last tweet from tweet detail stack page
      state.removeLastTweetDetail(tweetId);
    }
  }

  
 
  
}
