import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/themes/app_theme.dart';

class Activity2Screen extends StatelessWidget {
  const Activity2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Muntsikelan pөram kusrekun',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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