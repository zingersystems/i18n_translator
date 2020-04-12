import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_device_locale/flutter_device_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslatorProvider extends LocalizationsDelegate<Map<String, dynamic>> {
  List<Locale> _supportedLocales;
  Locale _locale;
  String _langConfigFile;
  String _langDirectory;

  TranslatorProvider(
      {@required List<Locale> supportedLocales,
      Locale locale,
      String langConfigFile = 'config.json',
      String langDirectory = 'assets/lang/'}) {
    assert((supportedLocales?.isNotEmpty == true),
        "The list of supported locales must be set.");

    this._supportedLocales = supportedLocales;
    this._locale = locale;
    this._langConfigFile = langConfigFile;
    this._langDirectory = langDirectory;
  }

  /// Define a static method that will play the role of a singleton if needed.
  /// The instance will be created only once based on parameters passed during
  /// the first call to create the instance. Thereafter, it will return the
  /// lone existing instance irrespective of passed parameters.
  static TranslatorProvider _instance;
  static TranslatorProvider instance(
      {@required List<Locale> supportedLocales,
      Locale locale,
      String langConfigFile = 'config.json',
      String langDirectory = 'assets/lang/'}) {
    if (_instance != null) {
      return _instance;
    } else if (supportedLocales?.isNotEmpty == true) {
      _instance = TranslatorProvider(
          supportedLocales: supportedLocales,
          locale: locale,
          langConfigFile: langConfigFile,
          langDirectory: langDirectory);
      return _instance;
    } else {
      debugPrint(
          "Remember to instantiate before calling the Translator instance method");
      return null;
    }
  }

  // Let's define some internal variables
  String _savedLocaleKey = 'savedLocale';
  Map<String, dynamic> _sentences;

  /// Returns whether or not the sentences for this translation provider are loaded
  bool get isLoaded {
    return (_locale != null) && (_sentences?.isNotEmpty == true);
  }

  /// Getter and Setter for the langConfigFile
  String get langConfigFile {
    return _langConfigFile;
  }

  /// Getter and Setter for the langDirectory
  String get langDirectory {
    return _langDirectory;
  }

  /// Getter and Setter for the current local
  Locale get locale {
    return _locale;
  }

  set locale(Locale locale) {
    assert(isSupported(locale),
        "The locale ($locale) that is being set is not contained in supported locales for the defined Translator.");
    _locale = locale;
  }

  /// Getter for supportedLocales
  List<Locale> get supportedLocales {
    return _supportedLocales;
  }

  /// Getter for supportedLocales
  List<LocalizationsDelegate> get delegates {
    return [
      this,
//      GlobalMaterialLocalizations.delegate,
//      GlobalWidgetsLocalizations.delegate,
//      GlobalCupertinoLocalizations.delegate
    ];
  }

  /// Resolves the locale to be used
  Locale resolveSupportedLocale(Locale locale,
      [Iterable<Locale> supportedLocales]) {
    supportedLocales ??= (_supportedLocales ?? []);

    if (locale == null) {
      debugPrint("Language locale to resolve is NULL!!!");
      return _supportedLocales.first;
    }

    for (Locale loc in supportedLocales) {
      if (loc.countryCode?.isNotEmpty == true) {
        // Check the case when the country code is set
        if ((loc.languageCode.toLowerCase() ==
                locale.languageCode.toLowerCase()) &&
            (loc.languageCode.toLowerCase() ==
                locale.languageCode.toLowerCase())) {
          return loc;
        }
      }
      // Loc only has language code but no country code
      else if (loc.languageCode.toLowerCase() ==
          locale.languageCode.toLowerCase()) {
        return loc;
      }
    }

    // Return the locale that was found.
    return _supportedLocales.first;
  }

  /// Returns the default supported locale
  Future<Locale> defaultSupportedLocale([BuildContext context]) async {
    return resolveSupportedLocale(await currentLocale(context));
  }

  /// Returns the current user preferred locales
  Future<List<Locale>> currentLocales([BuildContext context]) async {
    return await DeviceLocale.getPreferredLocales();
  }

  /// Returns the current device locale based on passed context of present
  Future<Locale> currentLocale([BuildContext context]) async {
    if (context != null) {
      return Localizations.localeOf(context);
    } else {
      return await DeviceLocale.getCurrentLocale();
    }
  }

  /// Sets the locale based on the current context.
  /// and loads the translation strings if the passed [locale] is different
  /// from the current
  Future<void> setLocale(Locale locale) async {
    // We need to make sure the locale that is being set is supported
    assert(isSupported(locale),
        "The locale ($locale) that is being set is not contained in supported locales for the defined Translator.");

    // Check that it is not same as old locale
    if (locale?.toString()?.toLowerCase() !=
        _locale?.toString()?.toLowerCase()) {
      // Reload the translation via this provider or delegate
      await this.load(locale);
    }
  }

  String t(String key, {String prefix}) {
    key = (prefix?.isNotEmpty == true) ? "${prefix}_$key" : key;
    return (_sentences?.containsKey(key) == true)
        ? _sentences[key].toString()
        : key;
  }

  /// Long form of t function
  String translate(String key, {String prefix}) {
    return t(key, prefix: prefix);
  }

  /// Load the translation strings based on the passed locale or current locale.
  /// We expect the json to be in format as:
  ///
  /// {
  ///   'en' : [
  ///     {
  ///      'prefix' : 'prefix_1',
  ///      'filename' : 'path_to_file_1',
  ///     },
  ///     'path_to_file_2',
  ///   ],
  ///   'en_US' : [
  ///      'path_to_file_1',
  ///       'path_to_file_2',
  ///   ]
  /// }
  Future<Map<String, dynamic>> load([Locale locale]) async {
    // If loading for the first time, we give preference to persisted locale - if any
    // If null, set the locale to the current, persisted, default supported or first supported in that order
    locale ??= (_locale ??
        await getSavedLocale() ??
        await defaultSupportedLocale() ??
        _supportedLocales.first);

    // We need to make sure the locale that is being set is contained in supported locales
    assert(isSupported(locale),
        "The locale ($locale) that translation is requested for is not contained in supported locales for the defined Translator.");

    // First we read the config file to extract the other translation files.
    Map _config = json
        .decode(await rootBundle.loadString("$_langDirectory$_langConfigFile"));
    if (_config?.isNotEmpty == true) {
      // Let's search for keys that march that of our locale
      String _localeKey = locale.toString().toLowerCase();
      String _langKey;
      for (String key in _config.keys.toList()) {
        if (_localeKey == key.toLowerCase()) {
          _langKey = key.toString();
          break;
        }
      }

      // We found the language key, now let's get the string translations
      if ((_langKey?.isNotEmpty == true) &&
          ((_config[_langKey] as List)?.isNotEmpty == true)) {
        Map<String, dynamic> _translations;

        for (var entry in _config[_langKey]) {
          if (entry is Map) {
            String prefix = entry['prefix'].toString();
            String filename = entry['filename'].toString();

            Map _trans = json.decode(
                await rootBundle.loadString("$_langDirectory$filename"));

            if (_trans?.isNotEmpty == true) {
              (_translations ??= {}).addAll(_trans.map((key, value) {
                return MapEntry("${prefix}_$key", value);
              }));
            }
          } else if (entry is String) {
            String filename = entry;
            Map _trans = json.decode(
                await rootBundle.loadString("$_langDirectory$filename"));
            if (_trans?.isNotEmpty == true) {
              (_translations ??= {}).addAll(_trans);
            }
          }
        }

        // At this stage, all went well.
        if (_translations?.isNotEmpty == true) {
          // Set the current locale to this one just loaded
          _locale = locale;
          _sentences = _translations;
          return _sentences;
        }
      }
    }

    // If we got here, it means something wasn't right so we return null.
    return null;
  }

  /// Checks if a locale is supported
  @override
  bool isSupported(Locale locale) {
    if (locale == null) {
      debugPrint("Locale to check if supported is null!!!");
      return false;
    }

    for (Locale loc in (_supportedLocales ?? [])) {
      if (loc.countryCode?.isNotEmpty == true) {
        // Check the case when the country code is set
        if ((loc.languageCode.toLowerCase() ==
                locale.languageCode.toLowerCase()) &&
            (loc.languageCode.toLowerCase() ==
                locale.languageCode.toLowerCase())) {
          return true;
        }
      }
      // Loc only has language code but no country code
      else if (loc.languageCode.toLowerCase() ==
          locale.languageCode.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldReload(TranslatorProvider old) {
    return false;
  }

  /// Saves the current locale or one that is passed to shared preference storage
  Future<void> saveLocale([Locale locale]) async {
    locale ??= _locale;
    assert(isSupported(locale),
        "The locale ($locale) that is being saved is not contained in supported locales for the defined Translator.");

    final _preferences = await SharedPreferences.getInstance();
    await _preferences.setString(
        _savedLocaleKey, "${locale.languageCode}_${locale.countryCode}");
  }

  /// Gets the saved locale from shared preference storage
  Future<Locale> getSavedLocale() async {
    final _preferences = await SharedPreferences.getInstance();
    final _strLocale = _preferences.getString(_savedLocaleKey);
    final locale = _strLocale != null ? _localeFromString(_strLocale) : null;

    return locale;
  }

  Locale _localeFromString(String val) {
    if (val?.isNotEmpty != true) {
      return null;
    }
    final localeList = val.split('_');
    return (localeList.length > 1) && (localeList.last?.isNotEmpty == true)
        ? Locale(localeList.first, localeList.last)
        : Locale(localeList.first);
  }

  /// Removes saved locale from shared preference storage
  Future<void> deleteSavedLocale() async {
    final _preferences = await SharedPreferences.getInstance();
    await _preferences.remove(_savedLocaleKey);
  }
}
