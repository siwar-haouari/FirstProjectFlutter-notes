import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_notes/page/notes_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'Notes';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          primaryColor: Colors.pink,
          scaffoldBackgroundColor: Color.fromARGB(255, 233, 117, 155),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.pink,
            elevation: 0,
          ),
        ),
        home: NotesPage(),
      );
}
