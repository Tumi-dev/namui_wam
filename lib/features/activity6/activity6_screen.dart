import 'package:flutter/material.dart';
import 'package:namui_wam/core/themes/app_theme.dart';

class Activity6Screen extends StatelessWidget {
  const Activity6Screen({super.key});

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
          'Wammeran tulisha manchípik kui asamik pɵrik',
          style: AppTheme.activityTitleStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: const Center(
          child: Text(
            'Actividad 6 - En desarrollo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}