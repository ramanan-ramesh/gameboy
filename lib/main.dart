import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gameboy/presentation/app/pages/master_page/master_page.dart';

import 'data/app/implementations/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MasterPage());
}
