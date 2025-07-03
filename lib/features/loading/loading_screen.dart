import 'package:flutter/material.dart';
import 'package:namuiwam/core/di/service_locator.dart';
import 'package:flutter/gestures.dart';
import 'package:namuiwam/features/auth/presentation/screens/legal_document_screen.dart';
import 'package:namuiwam/features/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

    /// Realiza la inicialización de servicios y gestiona el flujo de navegación inicial.
  ///
  /// Este método primero inicializa los servicios esenciales de la aplicación.
  /// Luego, comprueba si el usuario ha aceptado los términos y condiciones.
  /// Si no los ha aceptado, muestra un diálogo modal de consentimiento.
  /// Una vez que los términos son aceptados (o si ya lo estaban), navega a la [HomeScreen].
  Future<void> _initializeAndNavigate() async {
    // Inicializar servicios y cualquier otra carga de datos.
    await initializeServices();

    if (!mounted) return;

    // Comprobar si los términos han sido aceptados.
    final prefs = await SharedPreferences.getInstance();
    final bool termsAccepted = prefs.getBool('terms_accepted') ?? false;

    if (!termsAccepted) {
      // Si no han sido aceptados, mostrar el diálogo modal.
      await showDialog(
        context: context,
        barrierDismissible: false, // El usuario debe interactuar con el diálogo.
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('¡Atención!', textAlign: TextAlign.center),
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  const TextSpan(text: 'Te damos la bienvenida a Tsatsɵ Musik. Si aceptas estos documentos: '),
                  _buildLink(dialogContext, 'Términos de uso', 'assets/legal/terms_of_use.md'),
                  const TextSpan(text: ', '),
                  _buildLink(dialogContext, 'Política de privacidad', 'assets/legal/privacy_policy.md'),
                  const TextSpan(text: ' y '),
                  _buildLink(dialogContext, 'Acuerdo de licencia', 'assets/legal/eula.md'),
                  const TextSpan(text: ', haz clic en “Aceptar”.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () async {
                  await prefs.setBool('terms_accepted', true);
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        },
      );
    }

    // Navegar a la pantalla principal después de que el diálogo se cierre (si se mostró).
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  /// Construye un [TextSpan] con estilo de hipervínculo para los documentos legales.
  ///
  /// Al ser presionado, navega a [LegalDocumentScreen] para mostrar el contenido
  /// del archivo Markdown especificado en [mdFilePath].
  ///
  /// [context]: El contexto del widget para la navegación.
  /// [text]: El texto que se mostrará en el enlace.
  /// [mdFilePath]: La ruta en `assets` hacia el archivo .md a mostrar.
  TextSpan _buildLink(BuildContext context, String text, String mdFilePath) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LegalDocumentScreen(
                title: text,
                mdFilePath: mdFilePath,
              ),
            ),
          );
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detect if the app is in dark mode to match the native splash screen.
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    // The UI is designed to be identical to the native splash screen,
    // with the addition of a progress indicator.
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // The app logo, as defined in flutter_native_splash.
            Image.asset(
              'assets/images/app_icon.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 50),
            // A subtle linear progress bar to give user feedback.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
