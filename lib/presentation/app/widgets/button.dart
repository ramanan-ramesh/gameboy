import 'package:flutter/material.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/app/models/language_metadata.dart';
import 'package:gameboy/presentation/app/blocs/bloc_extensions.dart';
import 'package:gameboy/presentation/app/blocs/master_page/master_page_events.dart';

class LanguageSwitcher extends StatefulWidget {
  LanguageSwitcher({super.key});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  List<Widget> _buildLanguageButtons() {
    return context
        .getAppData()
        .languageMetadatas
        .map((e) => _LanguageButton(languageMetadata: e, visible: _isExpanded))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._buildLanguageButtons().map((e) => Container(
              padding: const EdgeInsets.all(4),
              child: e,
            )),
        FloatingActionButton.large(
          onPressed: _toggleExpand,
          child: Icon(
            Icons.translate,
            size: 75,
          ),
        ),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton(
      {required LanguageMetadata languageMetadata, required bool visible})
      : _languageMetadata = languageMetadata,
        _visible = visible;

  final LanguageMetadata _languageMetadata;
  final bool _visible;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: _visible,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: AnimatedOpacity(
            duration: const Duration(milliseconds: 700),
            curve: Curves.fastOutSlowIn,
            opacity: _visible ? 1 : 0,
            child: FloatingActionButton.extended(
              onPressed: () {
                context.addMasterPageEvent(ChangeLanguage(
                    languageToChangeTo: _languageMetadata.locale));
              },
              label: Text(
                _languageMetadata.name,
                style: const TextStyle(fontSize: 16.0),
              ),
              icon: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Image.asset(
                  _languageMetadata.flagAssetLocation,
                  width: 35,
                  height: 35,
                  fit: BoxFit.fill,
                ),
              ),
            )));
  }
}
