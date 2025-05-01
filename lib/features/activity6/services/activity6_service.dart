import 'dart:async';
import 'dart:convert'; // Re-added necessary import

import 'package:flutter/services.dart' show rootBundle;
import 'package:namuiwam/core/di/service_locator.dart';
import 'package:namuiwam/core/services/logger_service.dart';
import 'package:namuiwam/features/activity6/models/dictionary_entry.dart';
import 'package:namuiwam/features/activity6/models/semantic_domain.dart';

class Activity6Service {
  final LoggerService _logger = getIt<LoggerService>();

  List<SemanticDomain> _cachedDomains = [];
  Map<int, List<DictionaryEntry>> _cachedEntriesByDomainId = {};
  // Use a map for quick entry lookup by ID if needed later
  Map<int, DictionaryEntry> _cachedEntriesById = {};

  final Completer<void> _loadCompleter = Completer<void>();
  bool _isLoadComplete = false;

  // Map domain names to their JSON key prefixes
  final Map<String, String> _domainToKeyPrefixMap = {
    'Ushamera': 'animal',
    'Pisielɵ': 'color',
    'Srɵwammera': 'neologismo',
    'Asrumunchimera': 'partecuerpo',
    'Maintusrmera': 'plantacomestible',
    'Wamap amɵñikun': 'saludo',
    'Namui kewa amɵneiklɵ': 'vestido',
  };

  // Map domain names to their specific asset folder path names if they differ from the calculated default
  final Map<String, String> _domainPathOverrides = {
    'Wamap amɵñikun': 'wamapamɵnikun',
    'Namui kewa amɵneiklɵ': 'kewaamɵneiklɵ',
  };

  Activity6Service() {
    _logger.info('*** Activity6Service constructor llamado ***'); // Use logger instead of print
    _logger.info('Activity6Service constructor llamado');
    _logger.info('Activity6Service creado. Inicializando data load...');
    initialize();
  }

  Future<void> initialize() async {
    if (_isLoadComplete) return;
    try {
      await _loadDataFromJson();
      _isLoadComplete = true;
      _loadCompleter.complete();
      _logger.info('Activity6Service: Dictionary data loaded into memory successfully.');
    } catch (e, stackTrace) {
      _logger.error('Activity6Service: Failed to load dictionary data into memory', e, stackTrace);
      _loadCompleter.completeError(e, stackTrace);
    }
  }

  Future<void> _waitUntilLoaded() async {
    if (!_isLoadComplete) {
      _logger.info('Waiting for dictionary data load to complete...');
      await _loadCompleter.future;
      _logger
          .info('Activity6Service: Dictionary data load finished. Proceeding.');
    }
  }

  String _getDomainImagePath(String domainNameFormatted) {
    return 'assets/images/dictionary/$domainNameFormatted.png';
  }

  String _calculateDomainPathName(String domainName) {
    return domainName.toLowerCase().replaceAll(' ', '_');
  }

  Future<void> _loadDataFromJson() async {
    _logger.info(
        'Activity6Service: Starting to load dictionary data from JSON into memory...');
    final String jsonString =
        await rootBundle.loadString('assets/data/a6_namuiwam_dictionary.json');
    final Map<String, dynamic> dictionaryData = json.decode(jsonString);
    _logger.info('Activity6Service: JSON data decoded successfully.');

    final dynamic dictionaryContent = dictionaryData['dictionary'];
    if (dictionaryContent == null ||
        dictionaryContent is! Map<String, dynamic>) {
      _logger.error(
          'Activity6Service: Structure error: Missing or invalid "dictionary" key at the root. Data: $dictionaryData');
      throw Exception(
          'Invalid JSON structure: Root "dictionary" key not found or invalid.');
    }

    final dynamic namuiWamData = dictionaryContent['namui_wam'];
    if (namuiWamData == null || namuiWamData is! List || namuiWamData.isEmpty) {
      _logger.error(
          'Activity6Service: Structure error: Missing, invalid, or empty "namui_wam" list inside "dictionary". Data: $dictionaryContent');
      throw Exception(
          'Invalid JSON structure: "namui_wam" list not found or invalid.');
    }

    // --- Extract the map of domains from the first element ---
    final dynamic firstElement = namuiWamData[0];
    Map<String, dynamic> domainsMap = {};
    if (firstElement != null && firstElement is Map<String, dynamic>) {
      domainsMap = firstElement;
      _logger.info(
          'Activity6Service: Successfully extracted ${domainsMap.length} potential domains from the first list element.');
    } else {
      _logger.error(
          'Activity6Service: Structure error: First element in "namui_wam" is not a valid map. Data: $namuiWamData');
      throw Exception(
          'Invalid JSON structure: First element in "namui_wam" is not a map.');
    }

    // --- Clear caches before loading ---
    _cachedDomains = [];
    _cachedEntriesByDomainId = {};
    _cachedEntriesById = {};
    int currentDomainId = 0;
    final Map<String, int> domainNameToIdMap = {}; // Map to track existing domain IDs

    _logger.info('Processing ${domainsMap.length} domains...');

    // --- Iterate over each domain in the map ---
    domainsMap.forEach((domainName, entriesData) {
      _logger.info('Processing domain: "$domainName"');

      final dynamic entriesList = entriesData;
      if (entriesList == null || entriesList is! List) {
        _logger.warning(
            'Skipping domain "$domainName": entries data is null or not a list. Data: $entriesData');
        return; // Skip to the next domain
      }

      int domainIdToAdd;
      final String domainPathName = _domainPathOverrides[domainName] ??
          _calculateDomainPathName(domainName);
      final String domainImagePath = _getDomainImagePath(domainPathName);

      // Check if domain already added, otherwise add it
      if (!domainNameToIdMap.containsKey(domainName)) {
        currentDomainId++;
        domainIdToAdd = currentDomainId;
        final newDomain = SemanticDomain(
          id: domainIdToAdd,
          name: domainName,
          imagePath: domainImagePath,
          // pathName: domainPathName, // Remove if not needed
        );
        _cachedDomains.add(newDomain);
        domainNameToIdMap[domainName] = domainIdToAdd; // Store the new domain ID
        _logger.info(
            'Added new domain: "$domainName" with ID=$domainIdToAdd and image path=$domainImagePath');
      } else {
        domainIdToAdd = domainNameToIdMap[domainName]!; // Use existing ID
        _logger.debug(
            'Domain "$domainName" already exists with ID=$domainIdToAdd. Adding entries.');
      }

      List<DictionaryEntry> currentDomainEntries = [];

      // --- Handle specific structure for "Wamap amɵñikun" ---
      if (domainName == 'Wamap amɵñikun') {
        _logger.info('Applying specific logic for domain: "$domainName"');
        for (final entryData in entriesList) {
          if (entryData == null || entryData is! Map<String, dynamic>) {
            _logger.warning('Skipping invalid entry in "$domainName": $entryData');
            continue;
          }

          try {
            // Extract specific fields for saludos
            final String? namP = entryData['saludop_namtrik'] as String?;
            final String? spaP = entryData['saludop_spanish'] as String?;
            final String? namR = entryData['saludor_namtrik'] as String?;
            final String? spaR = entryData['saludor_spanish'] as String?;
            final String? imageName = entryData['saludo_image'] as String?;
            final String? audioNameP = entryData['saludop_audio'] as String?;
            final String? audioNameR = entryData['saludor_audio'] as String?; // Extract respuesta audio filename

            if (namP == null || spaP == null || namR == null || spaR == null) {
              _logger.warning('Skipping entry in "$domainName" due to missing text fields: $entryData');
              continue;
            }

            // Combine question and answer for display
            final String combinedNam = '$namP / $namR';
            final String combinedSpa = '$spaP / $spaR';

            // Construct paths
            final String? audioPath = (audioNameP != null && audioNameP.isNotEmpty)
                ? 'assets/audio/dictionary/$domainPathName/$audioNameP' // Pregunta audio
                : null;
            final String? audioVariantPath = (audioNameR != null && audioNameR.isNotEmpty)
                ? 'assets/audio/dictionary/$domainPathName/$audioNameR' // Respuesta audio
                : null;
            final String? imagePathEntry = (imageName != null && imageName.isNotEmpty)
                ? 'assets/images/dictionary/$domainPathName/$imageName'
                : null;

            // Create the entry
            final int entryId = _cachedEntriesById.length + currentDomainEntries.length + 1;
            final entry = DictionaryEntry(
              id: entryId,
              domainId: domainIdToAdd,
              namtrik: combinedNam,
              spanish: combinedSpa,
              audioPath: audioPath, // Audio Pregunta
              audioVariantPath: audioVariantPath, // Audio Respuesta
              imagePath: imagePathEntry,
            );
            currentDomainEntries.add(entry);
             _logger.debug(
                'Created saludo entry: ID=$entryId, Nam="$combinedNam", Spa="$combinedSpa", Audio1=$audioPath, Audio2=$audioVariantPath');

          } catch (e, stacktrace) {
            _logger.error(
              'Error processing entry for domain "$domainName": $entryData. Error: $e',
              e,
              stacktrace,
            );
          }
        }
      }
      // --- Handle generic structure for other domains ---
      else {
         _logger.info('Applying generic logic for domain: "$domainName"');
        final String? keyPrefix = _domainToKeyPrefixMap[domainName];
        if (keyPrefix == null) {
          _logger.warning(
              'Skipping domain "$domainName": No key prefix found in _domainToKeyPrefixMap.');
          return; // Use return instead of continue inside forEach callback
        }

        for (final entryData in entriesList) {
          if (entryData == null || entryData is! Map<String, dynamic>) {
            _logger.warning('Skipping invalid entry in "$domainName": $entryData');
            continue;
          }

          // Extract generic fields using the prefix
          final String? nam = entryData['${keyPrefix}_namtrik'] as String?;
          final String? spa = entryData['${keyPrefix}_spanish'] as String?;
          final String? imageName = entryData['${keyPrefix}_image'] as String?;
          final String? audioName = entryData['${keyPrefix}_audio'] as String?;

          // Basic validation
          if (nam == null || spa == null) {
            _logger.warning(
                'Skipping entry in "$domainName" due to missing namtrik or spanish field: $entryData');
            continue;
          }

          try {
            // Construct asset paths
             final String? audioPath = (audioName != null && audioName.isNotEmpty)
                ? 'assets/audio/dictionary/$domainPathName/$audioName'
                : null;
            final String? imagePathEntry = (imageName != null && imageName.isNotEmpty)
                ? 'assets/images/dictionary/$domainPathName/$imageName'
                : null;

            // Create the entry
            final int entryId = _cachedEntriesById.length + currentDomainEntries.length + 1;
            final entry = DictionaryEntry(
              id: entryId,
              domainId: domainIdToAdd, // Assign correct domainId
              namtrik: nam, // Use correct field name
              spanish: spa,
              audioPath: audioPath,
              imagePath: imagePathEntry,
            );
            currentDomainEntries.add(entry);
            _logger
                .debug('Created generic entry: ID=$entryId, Nam=$nam, Spa=$spa');
          } catch (e, stacktrace) {
            _logger.error(
              'Error processing entry for domain "$domainName" (Nam: $nam, Spa: $spa): $e',
              e, // Pass error as positional argument
              stacktrace, // Pass stack trace as positional argument
            );
          }
        }
      } // End of if/else for domain handling

      // Add the domain's entries if any were successfully created
      if (currentDomainEntries.isNotEmpty) {
        // Assign the correct domainId to entries and add them to the main cache
        for (var entry in currentDomainEntries) {
          // The domainId should already be correctly set when creating the entry
          _cachedEntriesById[entry.id] = entry;
        }
        _logger.info(
            'Stored ${currentDomainEntries.length} entries for domain "$domainName" (ID $domainIdToAdd) in main cache.');
      } else {
        _logger.warning(
            'No valid entries or stored for domain: "$domainName". It might appear empty.');
      }
    }); // End of domainsMap.forEach

    // --- Populate the _cachedEntriesByDomainId map ---
    _cachedEntriesByDomainId = {}; // Ensure it's clear before populating
    for (final entry in _cachedEntriesById.values) {
      if (!_cachedEntriesByDomainId.containsKey(entry.domainId)) {
        _cachedEntriesByDomainId[entry.domainId] = [];
      }
      _cachedEntriesByDomainId[entry.domainId]!.add(entry);
    }
    _logger.info(
        'Finished grouping ${_cachedEntriesById.length} total entries into ${_cachedEntriesByDomainId.length} domains.');

    _logger.info('Finished processing all domains.');
  }

  Future<List<SemanticDomain>> getAllDomains() async {
    await _waitUntilLoaded();
    _logger.info('Returning ${_cachedDomains.length} domains from memory.');
    return List.unmodifiable(_cachedDomains);
  }

  Future<List<DictionaryEntry>> getEntriesForDomain(int domainId) async {
    await _waitUntilLoaded();
    final entries = _cachedEntriesByDomainId[domainId] ?? [];
    _logger.info(
        'Returning ${entries.length} entries for domainId $domainId from memory.');
    return List.unmodifiable(entries);
  }

  Future<DictionaryEntry?> getEntryDetails(int entryId) async {
    await _waitUntilLoaded();
    final entry = _cachedEntriesById[entryId];
    _logger.info(
        'Returning details for entryId $entryId from memory: ${entry != null ? 'Found' : 'Not Found'}.');
    return entry;
  }

  Future<List<DictionaryEntry>> searchEntries(String query) async {
    await _waitUntilLoaded();
    if (query.isEmpty) {
      return [];
    }
    final lowerCaseQuery = query.toLowerCase();
    final results = _cachedEntriesById.values.where((entry) {
      // Handle potential null values for namtrik and spanish
      final bool namMatch =
          entry.namtrik?.toLowerCase().contains(lowerCaseQuery) ?? false;
      final bool spaMatch =
          entry.spanish?.toLowerCase().contains(lowerCaseQuery) ?? false;
      return namMatch || spaMatch;
    }).toList();
    _logger.info(
        'Found ${results.length} entries matching query "$query" in memory.');
    return results;
  }
}
