import 'package:flutter/material.dart';
import 'package:scaffassistant/core/local_storage/user_status.dart';

import '../../../core/const/size_const/dynamic_size.dart';
import '../../../core/const/string_const/icon_path.dart';
import '../../../core/const/string_const/image_path.dart';
import '../../../core/theme/SColor.dart';
import '../../../core/theme/text_theme.dart';
import 'login_note.dart';

class SDrawer extends StatelessWidget {
  const SDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> demoHistory = [
      'How to erect a scaffold?',
      'Scaffold safety tips',
      'Best practices for scaffold inspection',
      'Scaffold load capacity guidelines',
      'Training requirements for scaffold workers',
      'Daily inspection checklist',
      'Fall protection measures',
      'Platform width requirements',
      'Material handling on scaffold',
      'Scaffold tagging system',
      'How to erect a scaffold?',
      'Scaffold safety tips',
      'Best practices for scaffold inspection',
      'Scaffold load capacity guidelines',
      'Training requirements for scaffold workers',
      'Daily inspection checklist',
      'Fall protection measures',
      'Platform width requirements',
      'Material handling on scaffold',
      'Scaffold tagging system',
    ];

    final bool isLoggedIn = UserStatus.getIsLoggedIn();

    return Drawer(
      backgroundColor: SColor.primary,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(DynamicSize.medium(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Scaffold.of(context).closeDrawer(),
                    child: Image.asset(
                      IconPath.menuIcon,
                      height: 24,
                      width: 24,
                    ),
                  ),
                  SizedBox(width: DynamicSize.horizontalMedium(context)),
                  Image.asset(
                    ImagePath.logoIcon,
                    height: 28,
                  ),
                ],
              ),
              SizedBox(height: DynamicSize.medium(context)),
              ElevatedButton(
                onPressed: isLoggedIn ? () {} : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  backgroundColor: SColor.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      IconPath.noteIcon,
                      height: 16,
                      width: 16,
                      color: SColor.primary,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'New chat',
                      style: STextTheme.headLine().copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: DynamicSize.small(context)),
              Divider(color: SColor.textSecondary, thickness: 1),

              Expanded(
                child: isLoggedIn
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.history, color: SColor.textPrimary),
                      title: Text(
                        'History',
                        style: STextTheme.subHeadLine().copyWith(
                          color: SColor.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Divider(color: SColor.textSecondary, thickness: 1),
                    SizedBox(height: DynamicSize.small(context)),

                    Expanded(
                      child: ListView.separated(
                        itemCount: demoHistory.length,
                        itemBuilder: (context, index) {
                          return Text(
                            demoHistory[index],
                            style: STextTheme.subHeadLine().copyWith(
                              color: SColor.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                        separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                      ),
                    ),
                  ],
                )
                    : const LoginNote(),
              ),

              if (isLoggedIn) ...[
                Divider(color: SColor.textSecondary, thickness: 1),
                SizedBox(height: DynamicSize.small(context)),
                ElevatedButton(
                  onPressed: () {
                    UserStatus.setIsLoggedIn(false);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    backgroundColor: SColor.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Sign out',
                    style: STextTheme.headLine().copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
