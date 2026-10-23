import 'package:flutter/cupertino.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/widgets/rt_loader.dart';

class ProfileHeader extends StatelessWidget {
  final bool isOnline;
  final bool isLoading;
  final ValueChanged<bool> onToggleOnline;

  const ProfileHeader({
    super.key,
    required this.isOnline,
    required this.isLoading,
    required this.onToggleOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Profile",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        Row(
          children: [
            if (isLoading)
              const RtLoader(size: 20)
            else
              Text(
                isOnline ? "Online" : "Offline",
                style: TextStyle(
                  color: isOnline ? AppTheme.primaryColor : AppTheme.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            const SizedBox(width: 10),
            Transform.scale(
              scale: 0.8,
              child: CupertinoSwitch(
                value: isOnline,
                activeTrackColor: AppTheme.primaryColor,
                onChanged: isLoading ? null : onToggleOnline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
