import 'package:flutter/material.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/const/text_const/terms_privacy_text.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';

class TermsAndPrivacyPolicyScreen extends StatelessWidget {
  const TermsAndPrivacyPolicyScreen({super.key});

  Widget sectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: STextTheme.subHeadLine().copyWith(
            color: SColor.textPrimary,
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
          style: STextTheme.subHeadLine().copyWith(
            color: SColor.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        SizedBox(height: DynamicSize.large(context)),
        Divider(
          color: SColor.borderColor,
          thickness: 1.2,
        ),
        SizedBox(height: DynamicSize.large(context)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: SColor.primary,
        title: Text(
          'Terms and Privacy Policy',
          style: STextTheme.headLine().copyWith(
            color: SColor.textPrimary,
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
              style: STextTheme.headLine().copyWith(
                color: SColor.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DynamicSize.small(context)),
            Text(
              TermsPrivacyText.lastUpdated,
              style: STextTheme.subHeadLine().copyWith(
                color: SColor.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: DynamicSize.large(context)),
            Divider(color: SColor.borderColor, thickness: 2),
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
