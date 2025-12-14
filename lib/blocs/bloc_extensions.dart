import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/bloc.dart';
import 'app/events.dart';

extension BlocProviderExt on BuildContext {
  void addMasterPageEvent(MasterPageEvent event) {
    BlocProvider.of<MasterPageBloc>(this).add(event);
  }
}
