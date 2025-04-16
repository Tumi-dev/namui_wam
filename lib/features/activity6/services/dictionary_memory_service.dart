import 'dart:async';
import 'dart:convert'; // Re-added necessary import

import 'package:flutter/services.dart' show rootBundle;
import 'package:namui_wam/core/di/service_locator.dart';
import 'package:namui_wam/core/services/logger_service.dart';
import 'package:namui_wam/features/activity6/models/dictionary_entry.dart';
import 'package:namui_wam/features/activity6/models/semantic_domain.dart';

class DictionaryMemoryService {
  final LoggerService _logger = getIt<LoggerService>();

  List<SemanticDomain> _cachedDomains = [];
  Map<int, List<DictionaryEntry>> _cachedEntriesByDomainId = {};
  // Use a map for quick entry lookup by ID if needed later
  Map<int, DictionaryEntry> _cachedEntriesById = {};

  final Completer<void> _loadCompleter = Completer<void>();
  bool _isLoadComplete = false;

  // Map domain names to their JSON key prefixes
  final Map<String, String> _domainToKeyPrefixMap = {
    'Animales': 'animal',
    'Arboles': 'arbol', 
    'Colores': 'color',
    'Neologismos': 'neologismo',
    'Partes del cuerpo': 'pdc', 
    'Plantas comestibles': 'pc', 
    'Plantas medicinales': 'pm', 
    'Saludos': 'saludo', 
    'Vestido': 'vestido',
  };

  // Map domain names to their specific asset folder path names if they differ from the calculated default
  final Map<String, String> _domainPathOverrides = {
    'Partes del cuerpo': 'partescuerpo',
    'Plantas comestibles': 'plantascomestibles',
    'Plantas medicinales': 'plantasmedicinales',
  };

  DictionaryMemoryService() {
    _logger.info('*** DictionaryMemoryService constructor llamado ***'); // Use logger instead of print
    _logger.info('DictionaryMemoryService constructor llamado');
    _logger.info('DictionaryMemoryService creado. Inicializando data load...');
    initialize();
  }

  Future<void> initialize() async {
    if (_isLoadComplete) return; 
    try {
      await _loadDataFromJson();
      _isLoadComplete = true;
      _loadCompleter.complete();
      _logger.info('Dictionary data loaded into memory successfully.');
    } catch (e, stackTrace) {
      _logger.error('Failed to load dictionary data into memory', e, stackTrace);
      _loadCompleter.completeError(e, stackTrace);
    }
  }

  Future<void> _waitUntilLoaded() async {
    if (!_isLoadComplete) {
       _logger.info('Waiting for dictionary data load to complete...');
      await _loadCompleter.future;
       _logger.info('Dictionary data load finished. Proceeding.');
    }
  }

  String _getDomainImagePath(String domainNameFormatted) {
    return 'assets/images/dictionary/$domainNameFormatted.png';
  }

  String _calculateDomainPathName(String domainName) {
    return domainName.toLowerCase().replaceAll(' ', '_');
  }

  Future<void> _loadDataFromJson() async {
    _logger.info('Starting to load dictionary data from JSON into memory...');
    final String jsonString = await rootBundle.loadString('assets/data/a5_namuiwam_dictionary.json');
    final Map<String, dynamic> dictionaryData = json.decode(jsonString);
    _logger.info('JSON data decoded successfully.');

    final dynamic dictionaryContent = dictionaryData['dictionary'];
    if (dictionaryContent == null || dictionaryContent is! Map<String, dynamic>) {
      _logger.error('Structure error: Missing or invalid "dictionary" key at the root. Data: $dictionaryData');
      throw Exception('Invalid JSON structure: Root "dictionary" key not found or invalid.');
    }

    final dynamic namuiWamData = dictionaryContent['namui_wam'];
    if (namuiWamData == null || namuiWamData is! List || namuiWamData.isEmpty) {
       _logger.error('Structure error: Missing, invalid, or empty "namui_wam" list inside "dictionary". Data: $dictionaryContent');
      throw Exception('Invalid JSON structure: "namui_wam" list not found or invalid.');
    }

    final dynamic firstElement = namuiWamData[0];
    Map<String, dynamic> domainsMap = {};
    if (firstElement is Map<String, dynamic>) {
      domainsMap = firstElement;
       _logger.info('Successfully extracted domains map from JSON structure.');
    } else {
      _logger.error('Structure error: First element inside "namui_wam" list is not a Map. Data: $firstElement');
      throw Exception('Invalid JSON structure: Expected a Map as the first element in "namui_wam" list.');
    }

    _logger.info('Found ${domainsMap.length} potential domains in the JSON object.');

    _cachedDomains = [];
    _cachedEntriesByDomainId = {};
    _cachedEntriesById = {};

    for (final domainName in domainsMap.keys) {
      final domainDataList = domainsMap[domainName];
      if (domainDataList == null || domainDataList is! List) continue;

      final String? keyPrefix = _domainToKeyPrefixMap[domainName];

      if (keyPrefix == null) {
        _logger.warning('No key prefix mapping found for domain: "$domainName". Skipping.');
        continue;
      }

      _logger.info('Processing domain: "$domainName" using keyPrefix: "$keyPrefix"');

      // --- Calculate Domain Path Name (with override) ---
      String domainPathName = _calculateDomainPathName(domainName);
      if (_domainPathOverrides.containsKey(domainName)) {
        domainPathName = _domainPathOverrides[domainName]!;
        _logger.debug('Using overridden path name for "$domainName": "$domainPathName"');
      }
      // Default path if no override
      _logger.debug('Calculated domain path name for "$domainName": "$domainPathName", Image path: "${_getDomainImagePath(domainPathName)}"');
      // --- End Calculate Domain Path Name ---

      if (domainName == 'Saludos') {
        _logger.info('Handling special domain: Saludos');
        List<DictionaryEntry> currentDomainEntries = []; 

        int saludosDomainId = -1;
        var existingSaludosDomain = _cachedDomains.firstWhere((d) => d.name == domainName, orElse: () => SemanticDomain(id: -1, name: '', imagePath: ''));
        if (existingSaludosDomain.id == -1) {
          saludosDomainId = _cachedDomains.length + 1;
          final imagePath = _getDomainImagePath(domainPathName);
          final domain = SemanticDomain(id: saludosDomainId, name: domainName, imagePath: imagePath);
          _cachedDomains.add(domain);
          _logger.debug('Added domain placeholder: ID=$saludosDomainId, Name=$domainName, Image=$imagePath');
        } else {
          saludosDomainId = existingSaludosDomain.id;
           _logger.debug('Domain "$domainName" already exists with ID=$saludosDomainId. Adding entries.');
        }

        for (final entryData in domainDataList) {
          if (entryData is! Map<String, dynamic>) continue;

          final String? namQuestion = entryData['saludop_namtrik'];
          final String? spaQuestion = entryData['saludop_spanish'];
          final String? namAnswer = entryData['saludor_namtrik'];
          final String? spaAnswer = entryData['saludor_spanish'];
          final String? imgFileName = entryData['saludo_image']; 
          final String? audioQFileName = entryData['saludop_audio'];
          final String? audioAFileName = entryData['saludor_audio'];

          _logger.debug('Extracted Saludo Entry: NamQ=$namQuestion, SpaQ=$spaQuestion, NamA=$namAnswer, SpaA=$spaAnswer, Img=$imgFileName, AudioQ=$audioQFileName, AudioA=$audioAFileName');
            
          final String imagePathGreeting = (imgFileName != null && imgFileName.isNotEmpty)
              ? 'assets/images/dictionary/$domainPathName/$imgFileName'
              : '';
          final String audioPathQ = (audioQFileName != null && audioQFileName.isNotEmpty)
              ? 'assets/audio/dictionary/$domainPathName/$audioQFileName'
              : '';
          final String audioPathA = (audioAFileName != null && audioAFileName.isNotEmpty)
              ? 'assets/audio/dictionary/$domainPathName/$audioAFileName'
              : '';

          if (namQuestion == null || spaQuestion == null || namAnswer == null || spaAnswer == null) {
             _logger.warning('Skipping Saludos entry due to missing text fields: $entryData');
             continue;
          }

          try {
            final int entryId = _cachedEntriesById.length + currentDomainEntries.length + 1;
            final entry = DictionaryEntry(
              id: entryId,
              domainId: saludosDomainId,
              namtrik: null, 
              spanish: null, 
              imagePath: null, 
              audioPath: null, 
              greetings_ask_namtrik: namQuestion,
              greetings_ask_spanish: spaQuestion,
              greetings_answer_namtrik: namAnswer,
              greetings_answer_spanish: spaAnswer,
              images_greetings: imagePathGreeting,
              audio_greetings_ask: audioPathQ,
              audio_greetings_answer: audioPathA,
            );
            currentDomainEntries.add(entry);
            _logger.debug('Created Saludos entry: ID=$entryId, Q=$namQuestion, A=$namAnswer');
          } catch (e, stacktrace) {
             _logger.error(
              'Error processing Saludos entry: $e',
              e,
              stacktrace,
            );
          }
        }
        _cachedEntriesById.addAll({for (var entry in currentDomainEntries) entry.id: entry});
        _logger.info('Added ${currentDomainEntries.length} entries for special domain "$domainName"');

        continue; 
      }

      List<DictionaryEntry> currentDomainEntries = [];
      for (final entryData in domainDataList) {
        if (entryData is! Map<String, dynamic>) continue;

        // --- Extract data for generic entries ---
        final String namKey = '${keyPrefix}_namtrik';
        final String spaKey = '${keyPrefix}_spanish';
        final String imgKey = '${keyPrefix}_image';
        final String audioKey = '${keyPrefix}_audio';

        final String? nam = entryData[namKey];
        final String? spa = entryData[spaKey];
        final String? imgFileName = entryData[imgKey];
        final String? audioFileName = entryData[audioKey];

        _logger.debug('Attempted extraction for "$domainName": Nam="$nam" ($namKey), Spa="$spa" ($spaKey), Img="$imgFileName" ($imgKey), Audio="$audioFileName" ($audioKey)');

        if (nam == null || spa == null || nam.isEmpty || spa.isEmpty) {
          _logger.warning('Missing or empty Nam/Spa data for an entry in "$domainName". Skipping entry.');
          continue;
        }

        // Construct full paths
        final String imagePathEntry = (imgFileName != null && imgFileName.isNotEmpty)
            ? 'assets/images/dictionary/$domainPathName/$imgFileName'
            : ''; // Handle missing image
        final String audioPath = (audioFileName != null && audioFileName.isNotEmpty)
            ? 'assets/audio/dictionary/$domainPathName/$audioFileName'
            : ''; // Handle missing audio

        _logger.debug('Processing entry for "$domainName": Nam="$nam", Spa="$spa", ImagePath="$imagePathEntry", AudioPath="$audioPath"');

        try {
          int domainIdToAdd = -1;
          // Find existing domain or add new one
          var existingDomain = _cachedDomains.firstWhere((d) => d.name == domainName, orElse: () => SemanticDomain(id: -1, name: '', imagePath: '')); // Placeholder for check
          if (existingDomain.id == -1) { // Domain doesn't exist, add it
            domainIdToAdd = _cachedDomains.length + 1;
            final imagePath = _getDomainImagePath(domainPathName);
            final domain = SemanticDomain(
              id: domainIdToAdd,
              name: domainName,
              imagePath: imagePath,
            );
            _cachedDomains.add(domain);
            _logger.debug('Domain added: ID=$domainIdToAdd, Name=$domainName, Image=$imagePath');
          } else {
            domainIdToAdd = existingDomain.id;
            _logger.debug('Domain "$domainName" already exists with ID=$domainIdToAdd. Adding entries.');
          }

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
          _logger.debug('Created generic entry: ID=$entryId, Nam=$nam, Spa=$spa');
        } catch (e, stacktrace) {
          _logger.error(
            'Error processing entry for domain "$domainName" (Nam: $nam, Spa: $spa): $e',
            e, // Pass error as positional argument
            stacktrace, // Pass stack trace as positional argument
          );
        }
      }

      // Add the domain and its entries if any entries were successfully created
      if (currentDomainEntries.isNotEmpty) { // Now this variable is used
        // Assign the correct domainId to entries and add them
        for (var entry in currentDomainEntries) {
          final correctedEntry = DictionaryEntry(
            id: entry.id,
            domainId: entry.domainId, // Assign correct domainId
            namtrik: entry.namtrik,  // Use correct field name
            spanish: entry.spanish,
            audioPath: entry.audioPath,
            imagePath: entry.imagePath,
          );
          _cachedEntriesById[correctedEntry.id] = correctedEntry;
        }

        _logger.info('Added ${currentDomainEntries.length} entries for domain "$domainName" with domainId ${currentDomainEntries.first.domainId}');
      } else {
        _logger.warning('No valid entries processed for domain: "$domainName". It might appear empty.');
      }
    }

    // --- Populate the _cachedEntriesByDomainId map --- 
    _cachedEntriesByDomainId = {}; // Ensure it's clear before populating
    for (final entry in _cachedEntriesById.values) {
      if (!_cachedEntriesByDomainId.containsKey(entry.domainId)) {
        _cachedEntriesByDomainId[entry.domainId] = [];
      }
      _cachedEntriesByDomainId[entry.domainId]!.add(entry);
    }
    _logger.info('Finished grouping ${_cachedEntriesById.length} total entries into ${_cachedEntriesByDomainId.length} domains.');

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
    _logger.info('Returning ${entries.length} entries for domainId $domainId from memory.');
    return List.unmodifiable(entries);
  }

  Future<DictionaryEntry?> getEntryDetails(int entryId) async {
    await _waitUntilLoaded();
    final entry = _cachedEntriesById[entryId];
    _logger.info('Returning details for entryId $entryId from memory: ${entry != null ? 'Found' : 'Not Found'}.');
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
      final bool namMatch = entry.namtrik?.toLowerCase().contains(lowerCaseQuery) ?? false;
      final bool spaMatch = entry.spanish?.toLowerCase().contains(lowerCaseQuery) ?? false;
      return namMatch || spaMatch;
    }).toList();
    _logger.info('Found ${results.length} entries matching query "$query" in memory.');
    return results;
  }
}
