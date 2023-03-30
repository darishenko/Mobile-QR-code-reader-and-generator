import 'package:flutter/material.dart';
import 'package:qr_reader_and_generator/view/scrollable_app_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  return runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.black38,
    ),
    home: ScrollableAppBar(),
  ));
}