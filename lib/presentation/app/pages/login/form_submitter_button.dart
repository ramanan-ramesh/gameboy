import 'package:flutter/material.dart';

class LoginFormSubmitterButton extends StatefulWidget {
  final IconData icon;
  final BuildContext context;
  final VoidCallback? callback;
  VoidCallback? validationFailureCallback;
  VoidCallback? validationSuccessCallback;
  final Color? iconColor;
  GlobalKey<FormState>? formState;
  bool isSubmitted;
  bool isEnabledInitially;

  LoginFormSubmitterButton(
      {super.key,
      required this.icon,
      required this.context,
      this.iconColor,
      this.callback,
      this.formState,
      this.validationFailureCallback,
      this.validationSuccessCallback,
      this.isSubmitted = false,
      this.isEnabledInitially = false});

  @override
  State<LoginFormSubmitterButton> createState() =>
      _LoginFormSubmitterButtonState();
}

class _LoginFormSubmitterButtonState extends State<LoginFormSubmitterButton> {
  bool get _isCallbackNull => widget.formState != null
      ? (widget.validationSuccessCallback == null)
      : widget.callback == null;

  @override
  Widget build(BuildContext context) {
    var canEnable = !_isCallbackNull && widget.isEnabledInitially;
    return FloatingActionButton(
      onPressed: widget.isSubmitted || !canEnable ? () {} : _onPressed,
      splashColor: !canEnable ? Colors.white30 : null,
      backgroundColor: !canEnable ? Colors.white10 : null,
      child:
          widget.isSubmitted ? CircularProgressIndicator() : Icon(widget.icon),
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
          widget.isSubmitted = false;
          setState(() {});
        }
      }
      return;
    }
    setState(() {
      widget.isSubmitted = true;
      widget.callback!();
    });
  }
}
