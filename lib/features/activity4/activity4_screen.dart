import 'package:flutter/material.dart';
import 'package:namui_wam/core/themes/app_theme.dart';

class Activity4Screen extends StatelessWidget {
  const Activity4Screen({super.key});

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: AppTheme.homeIcon,
          onPressed: () => _navigateToHome(context),
        ),
        title: const Text(
          'Nøsik utøwan asam kusrekun',
          style: AppTheme.activityTitleStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
      ),
    );
  }
}