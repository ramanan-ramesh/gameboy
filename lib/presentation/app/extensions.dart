import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/app_data.dart';

extension RepositoryExt on BuildContext {
  AppDataFacade getAppData() {
    return RepositoryProvider.of<AppDataFacade>(this);
  }
}
