import 'package:flutter/material.dart';

import 'login/login_page.dart';
import 'onboarding_page.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  static const _cutOffSize = 600.0;
  static const _smallScreenSize = 550.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        BoxConstraints constraintsToApply;
        Widget pageToRender;
        double minHeight = constraints.minHeight < _cutOffSize
            ? _cutOffSize
            : constraints.minHeight;
        double maxHeight = constraints.maxHeight < _cutOffSize
            ? _cutOffSize
            : constraints.maxHeight;
        if (constraints.minWidth > 1000) {
          constraintsToApply = BoxConstraints(
              minWidth: constraints.minWidth,
              maxWidth: constraints.maxWidth,
              minHeight: minHeight,
              maxHeight: maxHeight);
          pageToRender = _getPageToRender(true);
        } else {
          pageToRender = _getPageToRender(false);
          constraintsToApply = BoxConstraints(
              minWidth: _smallScreenSize,
              maxWidth: _smallScreenSize,
              minHeight: minHeight,
              maxHeight: maxHeight);
        }
        return SingleChildScrollView(
          child:
              Container(constraints: constraintsToApply, child: pageToRender),
        );
      },
    );
  }

  Widget _getPageToRender(bool isBigLayout) {
    return Row(
      children: [
        if (isBigLayout)
          Expanded(
            child: OnBoardingPage(
              isBigLayout: isBigLayout,
            ),
          ),
        const Expanded(
          child: LoginPage(),
        ),
      ],
    );
  }
}
