import 'package:flutter/material.dart';
import 'package:one_person_twitter/helper/constant.dart';
import 'package:one_person_twitter/state/authState.dart';
import 'package:one_person_twitter/ui/page/profile/widgets/circular_image.dart';
import 'package:one_person_twitter/ui/theme/theme.dart';
import 'package:one_person_twitter/widgets/customWidgets.dart';
import 'package:one_person_twitter/widgets/url_text/customUrlText.dart';
import 'package:provider/provider.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  Widget _menuHeader() {
    final state = context.watch<AuthState>();
    if (state.userModel == null) {
      return ConstrainedBox(
        constraints: BoxConstraints(minWidth: 200, minHeight: 100),
        child: Center(
          child: Text(
            'Login to continue',
            style: TextStyles.onPrimaryTitleText,
          ),
        ),
      ).ripple(() {
        _logOut();
        //  Navigator.of(context).pushNamed('/signIn');
      });
    } else {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 56,
              width: 56,
              margin: EdgeInsets.only(left: 17, top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(28),
                image: DecorationImage(
                  image: customAdvanceNetworkImage(
                    state.userModel.profilePic ?? Constants.dummyProfilePic,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: <Widget>[
                  UrlText(
                    text: state.userModel.displayName ?? "",
                    style: TextStyles.onPrimaryTitleText
                        .copyWith(color: Colors.black, fontSize: 20),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  state.userModel.isVerified ?? false
                      ? customIcon(context,
                          icon: AppIcon.blueTick,
                          istwitterIcon: true,
                          iconColor: AppColor.primary,
                          size: 18,
                          paddingIcon: 3)
                      : SizedBox(
                          width: 0,
                        ),
                ],
              ),
              subtitle: customText(
                state.userModel.userName,
                style: TextStyles.onPrimarySubTitleText
                    .copyWith(color: Colors.black54, fontSize: 15),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 17,
                  ),
                  _followerText('${state.userModel.getFollower}', ' Followers'),
                  SizedBox(width: 10),
                  _followerText(
                      '${state.userModel.getFollowing}', ' Following'),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _followerText(String count, String text) {
    return Row(
      children: <Widget>[
        customText(
          '$count ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        customText(
          '$text',
          style: TextStyle(color: AppColor.darkGrey, fontSize: 17),
        ),
      ],
    );
  }

  ListTile _menuListRowButton(String title,
      {Function onPressed, IconData icon, bool isEnable = false}) {
    return ListTile(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      leading: icon == null
          ? null
          : Padding(
              padding: EdgeInsets.only(top: 5),
              child: customIcon(
                context,
                icon: icon,
                size: 25,
                iconColor: isEnable ? AppColor.darkGrey : AppColor.lightGrey,
              ),
            ),
      title: customText(
        title,
        style: TextStyle(
          fontSize: 20,
          color: isEnable ? AppColor.secondary : AppColor.lightGrey,
        ),
      ),
    );
  }

  void _logOut() {
    final state = Provider.of<AuthState>(context, listen: false);
    Navigator.pop(context);
    state.logoutCallback();
  }

  void _navigateTo(String path) {
    Navigator.pop(context);
    Navigator.of(context).pushNamed('/$path');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 45),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  Container(
                    child: _menuHeader(),
                  ),
                  Divider(),
                  _menuListRowButton('Profile',
                      icon: AppIcon.profile, isEnable: true),
                  _menuListRowButton('Lists', icon: AppIcon.lists),
                  _menuListRowButton('Bookmark', icon: AppIcon.bookmark),
                  _menuListRowButton('Moments', icon: AppIcon.moments),
                  _menuListRowButton('Twitter ads', icon: AppIcon.twitterAds),
                  Divider(),
                  _menuListRowButton('Settings and privacy'),
                  _menuListRowButton('Help Center'),
                  Divider(),
                  _menuListRowButton('Logout',
                      icon: null, onPressed: _logOut, isEnable: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
