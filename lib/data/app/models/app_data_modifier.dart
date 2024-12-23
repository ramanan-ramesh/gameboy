import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gameboy/data/app/models/app_data.dart';

abstract class AppDataModifier extends AppDataFacade {
  String get googleWebClientId;

  Future<bool> updateActiveUser(User? platformUser);

  void updateActiveThemeMode(ThemeMode themeMode);
}
