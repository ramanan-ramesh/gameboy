import 'package:flutter/material.dart';
import 'package:gameboy/presentation/app/blocs/bloc_extensions.dart';
import 'package:gameboy/presentation/app/blocs/master_page/master_page_events.dart';
import 'package:gameboy/presentation/app/extensions.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const String _appLogoAsset =
      'assets/logos/app_logo_without_phrase.webp';

  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: AppBar(
        flexibleSpace: Center(
          child: Image.asset(
            _appLogoAsset,
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          _UserProfilePopupMenu(),
        ],
      ),
    );
  }
}

class _UserProfilePopupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var userPhotoUrl = context.getAppData().activeUser!.photoUrl;
    return PopupMenuButton<Widget>(
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: Theme.of(context).iconTheme.color,
                ),
                SizedBox(width: 8),
                Text('Logout'),
              ],
            ),
            onTap: () {
              context.addMasterPageEvent(Logout());
            },
          ),
        ];
      },
      offset: const Offset(0, kToolbarHeight + 5),
      child: Padding(
        padding: EdgeInsets.all(2.0),
        child: _ProfileActionButton(
          photoUrl: userPhotoUrl,
        ),
      ),
    );
  }
}

class _ProfileActionButton extends StatefulWidget {
  final String? photoUrl;

  const _ProfileActionButton({super.key, required this.photoUrl});

  @override
  State<_ProfileActionButton> createState() => _ProfileActionButtonState();
}

class _ProfileActionButtonState extends State<_ProfileActionButton> {
  var _isImageLoaded = false;
  NetworkImage? _userProfileNetworkImage;

  @override
  void initState() {
    super.initState();
    if (widget.photoUrl != null) {
      _userProfileNetworkImage = NetworkImage(widget.photoUrl!);
      var imageStreamListener = ImageStreamListener((image, synchronousCall) {
        if (mounted) {
          setState(() {
            _isImageLoaded = true;
          });
        }
      });
      _userProfileNetworkImage!
          .resolve(const ImageConfiguration(size: Size(40, 40)))
          .addListener(imageStreamListener);
    }
  }

  //TODO: Clip the CircleAvatar to a circle, and splash too
  @override
  Widget build(BuildContext context) {
    return !_isImageLoaded
        ? const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.black,
            child: Icon(
              Icons.account_circle_rounded,
              color: Colors.green,
            ),
          )
        : CircleAvatar(
            radius: 30,
            backgroundImage: _userProfileNetworkImage,
            backgroundColor: Colors.black,
          );
  }
}
