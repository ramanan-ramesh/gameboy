import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/master_page_bloc.dart';
import 'app/master_page_events.dart';
import 'authentication/auth_bloc.dart';
import 'authentication/auth_events.dart';

extension BlocProviderExt on BuildContext {
  void addAuthenticationEvent(AuthenticationEvent event) {
    BlocProvider.of<AuthenticationBloc>(this).add(event);
  }

  void addMasterPageEvent(MasterPageEvent event) {
    BlocProvider.of<MasterPageBloc>(this).add(event);
  }
}
