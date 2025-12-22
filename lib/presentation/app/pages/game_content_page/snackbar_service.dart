import 'dart:async';

import 'package:flutter/material.dart';

class SnackBarService extends ChangeNotifier {
  final Set<Timer> _pendingTimers = {};
  ScaffoldMessengerState? _scaffoldMessenger;
  bool _isDisposed = false;

  void setScaffoldContext(BuildContext context) {
    if (_isDisposed) return;
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  void showSnackBar(String message, {Duration? duration}) {
    if (_isDisposed || _scaffoldMessenger == null) {
      return;
    }

    _scaffoldMessenger!.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }

  void showSnackBarDelayed(String message,
      {Duration delay = const Duration(seconds: 1), Duration? duration}) {
    if (_isDisposed) return;

    late final Timer timer;
    timer = Timer(delay, () {
      _pendingTimers.remove(timer);
      if (!_isDisposed) {
        showSnackBar(message, duration: duration);
      }
    });
    _pendingTimers.add(timer);
  }

  void cancelAllPendingSnackBars() {
    for (final timer in _pendingTimers) {
      timer.cancel();
    }
    _pendingTimers.clear();
    _scaffoldMessenger?.clearSnackBars();
  }

  @override
  void dispose() {
    _isDisposed = true;
    cancelAllPendingSnackBars();
    _scaffoldMessenger = null;
    super.dispose();
  }
}

class SnackBarServiceProvider extends InheritedWidget {
  final SnackBarService service;

  const SnackBarServiceProvider({
    super.key,
    required this.service,
    required super.child,
  });

  static SnackBarService of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<SnackBarServiceProvider>();
    assert(provider != null, 'No SnackBarServiceProvider found in context');
    return provider!.service;
  }

  static SnackBarService? maybeOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<SnackBarServiceProvider>();
    return provider?.service;
  }

  @override
  bool updateShouldNotify(SnackBarServiceProvider oldWidget) {
    return service != oldWidget.service;
  }
}

extension SnackBarServiceExtension on BuildContext {
  SnackBarService get snackBarService => SnackBarServiceProvider.of(this);

  void showGameSnackBar(String message) {
    snackBarService.showSnackBar(message);
  }

  void showGameSnackBarDelayed(String message,
      {Duration delay = const Duration(seconds: 1), Duration? duration}) {
    snackBarService.showSnackBarDelayed(message,
        delay: delay, duration: duration);
  }
}
