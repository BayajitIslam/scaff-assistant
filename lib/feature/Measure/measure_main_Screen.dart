import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/feature/Measure/Level/Screens/level_screen.dart';
import 'package:scaffassistant/feature/Measure/Measure/Screens/measure_screen.dart';

class MeasureMainScreen extends StatefulWidget {
  const MeasureMainScreen({super.key});

  @override
  State<MeasureMainScreen> createState() => _MeasureMainScreenState();
}

class _MeasureMainScreenState extends State<MeasureMainScreen> {
  // Current tab: 0 = Measure, 1 = Level
  int _currentTab = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _buildAppBar(),
      body: _currentTab == 1 ? const LevelView() : const MeasureView(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          _currentTab == 1 ? 'LEVEL' : 'MEASURE',
          key: ValueKey(_currentTab),
          style: AppTextStyles.headLine().copyWith(
            color: AppColors.textBlack,
            fontWeight: FontWeight.w400,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(color: Colors.transparent),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _buildNavButton(
              icon: Icons.straighten_rounded,
              label: 'MEASURE',
              isSelected: _currentTab == 0,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _currentTab = 0);
              },
            ),
            const SizedBox(width: 12),
            _buildNavButton(
              icon: Icons.crop_free_rounded,
              label: 'LEVEL',
              isSelected: _currentTab == 1,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _currentTab = 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.background,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.headLine().copyWith(
                  color: Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CLIPPER
// ═══════════════════════════════════════════════════════════════════════════
