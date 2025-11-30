import 'package:flutter/material.dart';

class LoginFormSubmitterButton extends StatefulWidget {
  final IconData icon;
  final BuildContext context;
  final VoidCallback? callback;
  final VoidCallback? validationFailureCallback;
  final VoidCallback? validationSuccessCallback;
  final Color? iconColor;
  final GlobalKey<FormState>? formState;
  final bool isEnabledInitially;
  final bool isSubmittedInitially;

  const LoginFormSubmitterButton(
      {super.key,
      required this.icon,
      required this.context,
      this.iconColor,
      this.callback,
      this.formState,
      this.validationFailureCallback,
      this.validationSuccessCallback,
      this.isSubmittedInitially = false,
      this.isEnabledInitially = false});

  @override
  State<LoginFormSubmitterButton> createState() =>
      _LoginFormSubmitterButtonState();
}

class _LoginFormSubmitterButtonState extends State<LoginFormSubmitterButton> {
  late bool _isSubmitted;

  @override
  void initState() {
    super.initState();
    _isSubmitted = widget.isSubmittedInitially;
  }

  bool get _isCallbackNull => widget.formState != null
      ? (widget.validationSuccessCallback == null)
      : widget.callback == null;

  @override
  Widget build(BuildContext context) {
    var canEnable = !_isCallbackNull && widget.isEnabledInitially;
    return FloatingActionButton(
      onPressed: _isSubmitted || !canEnable ? () {} : _onPressed,
      splashColor: !canEnable ? Colors.white30 : null,
      backgroundColor: !canEnable ? Colors.white10 : null,
      child:
          _isSubmitted ? const CircularProgressIndicator() : Icon(widget.icon),
    );
  }

  void _onPressed() {
    if (_isCallbackNull) {
      return;
    }
    if (widget.formState != null) {
      if (widget.formState!.currentState != null) {
        if (widget.formState!.currentState!.validate()) {
          widget.validationSuccessCallback?.call();
        } else {
          widget.validationFailureCallback?.call();
          _isSubmitted = false;
          setState(() {});
        }
      }
      return;
    }
    setState(() {
      _isSubmitted = true;
      widget.callback!();
    });
  }
}
