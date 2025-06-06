import 'package:flutter/material.dart';
import 'package:namuiwam/core/di/service_locator.dart'; // Para getIt
import 'package:namuiwam/core/services/sound_service.dart'; // Importar SoundService
// import 'package:namuiwam/core/models/game_state.dart'; // GameState ya no se usa aquí para volumen
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:url_launcher/url_launcher.dart'; // Mantenido para el diálogo "Acerca de"

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Acceder a SoundService
  final SoundService _soundService = getIt<SoundService>();

  // Las variables locales para la UI se sincronizarán con SoundService
  late bool _isMusicEnabled;
  late double _currentMusicVolume;

  // Nuevas variables de estado para efectos de sonido
  late bool _areSoundEffectsEnabled;
  late double _currentSoundEffectsVolume;

  @override
  void initState() {
    super.initState();
    // Sincronizar estado inicial desde SoundService
    _isMusicEnabled = _soundService.isBackgroundMusicEnabled;
    _currentMusicVolume = _soundService.backgroundMusicVolume;

    // Sincronizar estado inicial de efectos de sonido
    _areSoundEffectsEnabled = _soundService.areEffectsEnabled;
    _currentSoundEffectsVolume = _soundService.effectsVolume;
  }

  // --- Copied from home_screen.dart (with modifications) ---
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo abrir: $url')),
          );
        }
      } else if (mounted) {
        // Try to open in web view as fallback
        try {
          await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
            webViewConfiguration:
                const WebViewConfiguration(enableJavaScript: true),
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No se pudo abrir el enlace: $url')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocurrió un error al abrir el enlace')),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isLink ? Colors.blue : Theme.of(context).textTheme.bodyLarge?.color,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                'Acerca de Tsatsɵ Musik',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        AssetImage('assets/images/1.logo-colibri.png'),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoRow('Versión', '1.0.0'),
                const Divider(),
                _buildInfoRow(
                  'Diseñador Pedagógico Lingüístico e Investigador',
                  'Gregorio Alberto Yalanda Muelas',
                ),
                const Divider(),
                GestureDetector(
                  onTap: () => _launchUrl('https://github.com/TuMyXx93'),
                  child: _buildInfoRow(
                    'Desarrollado por',
                    'TumiDev',
                    isLink: true,
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () => _launchUrl('mailto:gyalanda@unicauca.edu.co'),
                  child: _buildInfoRow(
                    'Contacto (Investigador)',
                    'gyalanda@unicauca.edu.co',
                    isLink: true,
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () => _launchUrl('https://www.namuiwam.net'),
                  child: _buildInfoRow(
                    'Sitio web',
                    'www.namuiwam.net',
                    isLink: true,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'NAMUIWAM es una aplicación educativa desarrollada como parte de un proyecto de investigación en el marco de la Maestría en Revitalización y Enseñanza de Lenguas Indígenas de la Universidad del Cauca. Su propósito es apoyar el aprendizaje de la lengua namtrik a través de contenidos interactivos sobre los números, el sistema monetario, la lectura de la hora y un minidiccionario básico.',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.justify, // Justified for better readability
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    '© 2025 Tsatsɵ Musik. Todos los derechos reservados.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // --- End of copied code ---

  @override
  Widget build(BuildContext context) {
    // Ya no se usa context.watch<GameState>() para el volumen
    // final gameState = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuración y Acerca de',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Ensure title is visible on gradient
        ),
        flexibleSpace: Container( // Apply gradient to AppBar
          decoration: BoxDecoration(
            gradient: AppTheme.mainGradient, // Use the mainGradient from AppTheme
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Ensure back button is visible
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.music_note, color: Theme.of(context).colorScheme.secondary),
            title: const Text('Música de fondo'),
            trailing: Switch(
              value: _isMusicEnabled, // Usar estado local sincronizado
              onChanged: (bool value) async {
                await _soundService.toggleBackgroundMusic(value);
                setState(() {
                  _isMusicEnabled = _soundService.isBackgroundMusicEnabled;
                  // Actualizar también _currentMusicVolume por si toggle lo afecta indirectamente
                  _currentMusicVolume = _soundService.backgroundMusicVolume;
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  _isMusicEnabled
                      ? (_currentMusicVolume == 0
                          ? Icons.volume_off
                          : (_currentMusicVolume < 0.5
                              ? Icons.volume_down
                              : Icons.volume_up))
                      : Icons.volume_mute,
                  color: _isMusicEnabled ? Theme.of(context).colorScheme.secondary : Colors.grey,
                ),
                Expanded(
                  child: Slider(
                    value: _currentMusicVolume, // Usar estado local sincronizado
                    min: 0.0,
                    max: 1.0,
                    divisions: 20, // Aumentar divisiones para más granularidad
                    label: (_currentMusicVolume * 100).round().toString(),
                    onChanged: _isMusicEnabled
                        ? (double value) async {
                            await _soundService.setBackgroundMusicVolume(value);
                            setState(() {
                              _currentMusicVolume = _soundService.backgroundMusicVolume;
                            });
                          }
                        : null,
                    activeColor: _isMusicEnabled ? Theme.of(context).colorScheme.primary : Colors.grey,
                    inactiveColor: _isMusicEnabled ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 30, thickness: 1),
          ListTile(
            leading: Icon(Icons.spatial_audio_off, color: Theme.of(context).colorScheme.secondary), // Icono para efectos
            title: const Text('Efectos de sonido'),
            trailing: Switch(
              value: _areSoundEffectsEnabled,
              onChanged: (bool value) async {
                await _soundService.toggleEffects(value);
                setState(() {
                  _areSoundEffectsEnabled = _soundService.areEffectsEnabled;
                  // Actualizar también _currentSoundEffectsVolume por si toggle lo afecta
                  _currentSoundEffectsVolume = _soundService.effectsVolume;
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            child: Row(
              children: [
                Icon(
                  _areSoundEffectsEnabled
                      ? (_currentSoundEffectsVolume == 0
                          ? Icons.volume_off
                          : (_currentSoundEffectsVolume < 0.5
                              ? Icons.volume_down
                              : Icons.volume_up))
                      : Icons.volume_mute,
                  color: _areSoundEffectsEnabled ? Theme.of(context).colorScheme.secondary : Colors.grey,
                ),
                Expanded(
                  child: Slider(
                    value: _currentSoundEffectsVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: (_currentSoundEffectsVolume * 100).round().toString(),
                    onChanged: _areSoundEffectsEnabled
                        ? (double value) async {
                            await _soundService.setEffectsVolume(value);
                            setState(() {
                              _currentSoundEffectsVolume = _soundService.effectsVolume;
                            });
                          }
                        : null,
                    activeColor: _areSoundEffectsEnabled ? Theme.of(context).colorScheme.primary : Colors.grey,
                    inactiveColor: _areSoundEffectsEnabled ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 30, thickness: 1),
          ListTile(
            leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary),
            title: const Text('Acerca de la App'),
            onTap: _showAppInfoDialog,
          ),
        ],
      ),
    );
  }
} 