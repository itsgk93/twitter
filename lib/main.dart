import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:one_person_twitter/ui/page/common/locator.dart';
import 'package:one_person_twitter/ui/theme/theme.dart';
import 'helper/routes.dart';
import 'state/appState.dart';
import 'package:provider/provider.dart';
import 'state/authState.dart';
import 'state/feedState.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupDependencies();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<AuthState>(create: (_) => AuthState()),
        ChangeNotifierProvider<FeedState>(create: (_) => FeedState()),
      ],
      child: MaterialApp(
        title: 'Twiiter',
        theme: AppTheme.apptheme.copyWith(
          textTheme: GoogleFonts.muliTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        debugShowCheckedModeBanner: false,
        routes: TwitterRoutes.route(),
        onGenerateRoute: (settings) => TwitterRoutes.onGenerateRoute(settings),
        onUnknownRoute: (settings) => TwitterRoutes.onUnknownRoute(settings),
        initialRoute: "SplashPage",
      ),
    );
  }
}
