import 'package:flutter/material.dart';
import 'package:gameboy/presentation/app/blocs/bloc_extensions.dart';
import 'package:gameboy/presentation/app/blocs/master_page/master_page_events.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const String _appLogoAsset = 'assets/logos/app_logo_round.webp';

  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Row(
        children: [
          IgnorePointer(
            //TODO: Find a way to remove this, and make sure logo is correctly centered horizontally
            child: Opacity(
              opacity: 0.0,
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.home),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              _appLogoAsset,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                context.addMasterPageEvent(Logout());
              },
              icon: Icon(Icons.exit_to_app_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
