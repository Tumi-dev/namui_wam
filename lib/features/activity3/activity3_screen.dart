import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namui_wam/core/constants/activity_descriptions.dart';
import 'package:namui_wam/core/di/service_locator.dart';
import 'package:namui_wam/core/themes/app_theme.dart';
import 'package:namui_wam/core/widgets/game_description_widget.dart';
import 'package:namui_wam/features/activity3/services/activity3_service.dart';

class Activity3Screen extends StatefulWidget {
  const Activity3Screen({super.key});

  @override
  State<Activity3Screen> createState() => _Activity3ScreenState();
}

class _Activity3ScreenState extends State<Activity3Screen> {
  final TextEditingController _numberController = TextEditingController();
  final Activity3Service _activity3Service = getIt<Activity3Service>();
  String _namtrikResult = '';
  bool _isLoading = false;
  bool _hasInvalidInput = false;

  // Define the deeper green color seen in the image for the Namtrik display box
  final Color _boxColor = const Color(0xFF388E3C); // Material Design Green 700 - matches the image

  @override
  void initState() {
    super.initState();
    _numberController.addListener(_onNumberChanged);
  }

  @override
  void dispose() {
    _numberController.removeListener(_onNumberChanged);
    _numberController.dispose();
    super.dispose();
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _onNumberChanged() async {
    // If the text is empty, reset everything
    if (_numberController.text.isEmpty) {
      setState(() {
        _namtrikResult = '';
        _hasInvalidInput = false;
      });
      return;
    }

    final String text = _numberController.text;
    final int? number = int.tryParse(text);

    // Check if the input is "0"
    if (number == 0) {
      setState(() {
        _namtrikResult = 'El número debe estar entre 1 y 9999999';
        _hasInvalidInput = true;
      });
      
      // If user tries to enter more after "0", revert back to just "0"
      if (text.length > 1) {
        _numberController.text = "0";
        _numberController.selection = TextSelection.fromPosition(
          TextPosition(offset: _numberController.text.length),
        );
      }
      return;
    }
    
    // If previous input was invalid but now it's valid, reset the flag
    if (_hasInvalidInput && _activity3Service.isValidNumber(number)) {
      setState(() {
        _hasInvalidInput = false;
      });
    }

    if (_activity3Service.isValidNumber(number)) {
      setState(() {
        _isLoading = true;
      });

      try {
        final namtrikValue = await _activity3Service.getNamtrikForNumber(number!);
        setState(() {
          _namtrikResult = namtrikValue;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _namtrikResult = 'Error: $e';
          _isLoading = false;
        });
      }
    } else if (number != null) {
      setState(() {
        _namtrikResult = 'El número debe estar entre 1 y 9999999';
        _hasInvalidInput = true;
      });
    }
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
          'Muntsielan namtrikmai yunømarøpik',
          style: AppTheme.activityTitleStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: GameDescriptionWidget(
                    description:
                        ActivityGameDescriptions.getDescriptionForActivity(3),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Muntsik wan yu pør',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _numberController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(7),
                    // Custom input formatter to handle "0" input
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      // If we have an invalid input (like "0") and user is trying to add more digits
                      if (_hasInvalidInput && newValue.text.length > oldValue.text.length) {
                        return oldValue; // Prevent the change
                      }
                      return newValue; // Allow the change
                    }),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Digita el número',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor: _boxColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Namtrikmai',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 100,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _boxColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _namtrikResult.isEmpty
                              ? 'Resultado del número'
                              : _namtrikResult,
                          style: TextStyle(
                            color: _namtrikResult.isEmpty
                                ? Colors.white.withOpacity(0.7)
                                : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
