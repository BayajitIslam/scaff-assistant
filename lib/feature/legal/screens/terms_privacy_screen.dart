import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';
import 'package:scaffassistant/feature/legal/screens/terms_privacy_text.dart';

class TermsAndPrivacyPolicyScreen extends StatelessWidget {
  const TermsAndPrivacyPolicyScreen({super.key});

  Widget sectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.subHeadLine().copyWith(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: DynamicSize.small(context)),
      ],
    );
  }

  Widget sectionBody(BuildContext context, String text) {
    return Column(
      children: [
        Text(
          text,
          style: AppTextStyles.subHeadLine().copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        SizedBox(height: DynamicSize.large(context)),
        Divider(color: AppColors.borderColor, thickness: 1.2),
        SizedBox(height: DynamicSize.large(context)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Terms and Privacy Policy',
          style: AppTextStyles.headLine().copyWith(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DynamicSize.large(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TermsPrivacyText.title,
              style: AppTextStyles.headLine().copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DynamicSize.small(context)),
            Text(
              TermsPrivacyText.lastUpdated,
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: DynamicSize.large(context)),
            Divider(color: AppColors.borderColor, thickness: 2),
            SizedBox(height: DynamicSize.large(context)),

            // Sections
            sectionTitle(context, '1. Overview'),
            sectionBody(context, TermsPrivacyText.overview),

            sectionTitle(context, '2. Important Disclaimer'),
            sectionBody(context, TermsPrivacyText.disclaimer),

            sectionTitle(context, '3. Limitation of Liability'),
            sectionBody(context, TermsPrivacyText.limitation),

            sectionTitle(context, '4. Information We Collect'),
            sectionBody(context, TermsPrivacyText.infoCollect),

            sectionTitle(context, '5. How We Use Your Information'),
            sectionBody(context, TermsPrivacyText.infoUse),

            sectionTitle(context, '6. Data Security'),
            sectionBody(context, TermsPrivacyText.dataSecurity),

            sectionTitle(context, '7. Data Sharing'),
            sectionBody(context, TermsPrivacyText.dataSharing),

            sectionTitle(context, '8. Your Rights'),
            sectionBody(context, TermsPrivacyText.userRights),

            sectionTitle(context, '9. Age & Use Eligibility'),
            sectionBody(context, TermsPrivacyText.ageEligibility),

            sectionTitle(context, '10. AI Data Handling'),
            sectionBody(context, TermsPrivacyText.aiDataHandling),

            sectionTitle(context, '11. Policy Updates'),
            sectionBody(context, TermsPrivacyText.policyUpdates),

            sectionTitle(context, '12. Contact Us'),
            sectionBody(context, TermsPrivacyText.contactUs),
          ],
        ),
      ),
    );
  }
}
