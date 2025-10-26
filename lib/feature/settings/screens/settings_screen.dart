import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/const/string_const/icon_path.dart';
import 'package:scaffassistant/core/const/string_const/image_path.dart';
import 'package:scaffassistant/core/local_storage/user_info.dart';
import 'package:scaffassistant/core/local_storage/user_status.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';
import 'package:scaffassistant/feature/auth/controllers/logout_controller.dart';
import 'package:scaffassistant/routing/route_name.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final LogoutController logoutController = Get.put(LogoutController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: SColor.primary,
        title: Text('Settings',style: STextTheme.headLine().copyWith(color: SColor.textPrimary, fontSize: 20, fontWeight: FontWeight.w500),),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(DynamicSize.large(context)),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: SColor.textPrimary,
                child: Text(
                   UserInfo.getUserName()[0].toUpperCase(),
                  style: STextTheme.headLine().copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: SColor.primary,
                  ),
                ),
              ),
              title: Text(
                UserInfo.getUserName(),
                style: STextTheme.subHeadLine().copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: SColor.textPrimary,
                ),
              ),
            ),
            Divider(color: SColor.borderColor,thickness: 1,),
            ListTile(
              leading: Image.asset(IconPath.emailIcon,width: 24,height: 24,color: SColor.textPrimary,),
              title: Text('Email',style: STextTheme.subHeadLine().copyWith(fontSize: 16,fontWeight: FontWeight.w600,color: SColor.textPrimary)),
              subtitle: Text(UserInfo.getUserEmail(),style: STextTheme.subHeadLine().copyWith(fontSize: 12,color: SColor.textSecondary)),
              onTap: (){
                Get.showSnackbar(GetSnackBar(
                  message: 'You can\'t change email now.',
                  duration: Duration(seconds: 2),
                ));
              },
            ),
            Divider(color: SColor.borderColor,thickness: 1,),
            ListTile(
              onTap: (){
                Get.toNamed(RouteNames.tramsAndPrivacy);
              },
              leading: Image.asset(IconPath.shildIcon,width: 24,height: 24,color: SColor.textPrimary,),
              title: Text('Terms and Privacy Policy',style: STextTheme.subHeadLine().copyWith(fontSize: 16,fontWeight: FontWeight.w600,color: SColor.textPrimary)),
            ),
            Divider(color: SColor.borderColor,thickness: 1,),
            ListTile(
              onTap: (){
                logoutController.login();
              },
              leading: Image.asset(IconPath.exitIcon,width: 24,height: 24,color: SColor.textPrimary,),
              title: Obx(()=> Text(logoutController.isLoading.value ? 'Log out ...' : 'Log out',style: STextTheme.subHeadLine().copyWith(fontSize: 16,fontWeight: FontWeight.w600,color: SColor.textPrimary)),)
            ),
          ],
        ),
      ),
    );
  }
}
