import 'package:flutter/material.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/features/activity6/screens/dictionary_domain_screen.dart';

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
        backgroundColor: Colors.transparent, // Color de fondo transparente de la AppBar
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: DictionaryDomainScreen(),
      ),
    );
  }
}