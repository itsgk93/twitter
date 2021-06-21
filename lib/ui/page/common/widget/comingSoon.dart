import 'package:flutter/material.dart';
import 'package:one_person_twitter/widgets/newWidget/title_text.dart';

class ComingSoon extends StatelessWidget {
  final String title;
  ComingSoon(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleText(title),
          Padding(
            padding: const EdgeInsets.only(top: 38.0),
            child: TitleText(
              "Coming Soon",
              fontSize: 40,
            ),
          ),
        ],
      )),
    );
  }
}
