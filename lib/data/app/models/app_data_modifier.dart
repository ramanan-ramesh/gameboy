import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gameboy/data/app/models/app_data_facade.dart';

abstract class AppDataModifier extends AppDataFacade {
  String get googleWebClientId;

  Future updateActiveUser(User? platformUser);

  Future updateActiveThemeMode(ThemeMode themeMode);

  void updateLayoutType(bool isBigLayout);
}
