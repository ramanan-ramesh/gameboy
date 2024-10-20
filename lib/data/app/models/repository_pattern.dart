import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

abstract interface class RepositoryPattern<T> {
  String? id;

  DatabaseReference get documentReference;

  Map<String, dynamic> toJson();

  FutureOr<bool> tryUpdate(T toUpdate);

  T get facade;
}

abstract interface class Dispose {
  Future dispose();
}
