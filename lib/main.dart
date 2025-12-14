import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gameboy/presentation/app/pages/master_page/master_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app/implementations/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(MasterPage(sharedPreferences));
}
