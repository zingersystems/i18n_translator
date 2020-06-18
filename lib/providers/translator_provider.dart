import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/translator_provider_bloc/bloc.dart';

class TranslatorProvider with TranslatorProviderMixin {
  TranslatorProvider(
      {@required List<Locale> supportedLocales,
      String langConfigFile = 'config.json',
      String langDirectory = 'assets/lang/',
      bool reload = false,
      Locale locale})
      : assert(supportedLocales != null) {
    // Let's create a new delegate based on the constructor parameters
    delegate = TranslatorProviderDelegate(
        supportedLocales: supportedLocales,
        langConfigFile: langConfigFile,
        langDirectory: langDirectory,
        reload: reload,
        provider: this);
  }
}


mixin TranslatorProviderMixin {
  // Translator delegate that
  TranslatorProviderDelegate delegate;

  // Let's define some internal variables
  final String savedLocaleKey = 'savedLocale';
  final Map<String, dynamic> sentences = {};

  /// Returns whether or not the sentences for this translation provider are loaded
  bool get isLoaded {
    return (delegate?.locale != null) && (sentences?.isNotEmpty == true);
  }

  /// Getter and Setter for the langConfigFile
  String get langConfigFile {
    return delegate.langConfigFile;
  }

  /// Getter and Setter for the langDirectory
  String get langDirectory {
    return delegate.langDirectory;
  }


  /// Getter for supportedLocales
  Locale get supportedLocale {
    return delegate.locale;
  }

  /// Getter for supportedLocales
  List<Locale> get supportedLocales {
    return delegate.supportedLocales;
  }

  /// Sets a new locale for the Translator Provider
  Future<void> setLocale(Locale locale) async {
    assert(isSupported(locale),
        "The locale ($locale) that is being set is not contained in supported locales for the defined Translator.");

    // Check that it is not same as old locale
    if (locale?.toString()?.toLowerCase() !=
        delegate.locale?.toString()?.toLowerCase()) {
      // Create new delegate based on the current.
      delegate = TranslatorProviderDelegate(
          supportedLocales: delegate.supportedLocales,
          locale: locale,
          provider: this);

      // Initiate loading of the translation based on new locale
      await delegate.load(locale);
    }
  }

  /// Getter for supportedLocales
  List<LocalizationsDelegate> get delegates {
    return [
      delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate
    ];
  }

  /// Resolves the locale to be used
  Locale resolveSupportedLocale(Locale locale, [Iterable<Locale> supportedLocales]) {

    supportedLocales ??= delegate.supportedLocales;

    if (locale == null) {
      debugPrint("Language locale to resolve is NULL!!!");
      return delegate.supportedLocales.first;
    } else {
      _userPreferredLocale = locale;
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
    return delegate.supportedLocales.first;
  }


  /// The user preferred locale
  Locale _userPreferredLocale;
  Locale get userPreferredLocale{
    return _userPreferredLocale;
  }


  String t(String key, {String prefix}) {
    key = (prefix?.isNotEmpty == true) ? "${prefix}_$key" : key;
    return (sentences?.containsKey(key) == true)
        ? sentences[key].toString()
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
    // Assign the default locale if none was passed.
    locale ??= delegate.locale;

    // First we read the config file to extract the other translation files.
    final _config = json.decode(await rootBundle
        .loadString("${delegate.langDirectory}${delegate.langConfigFile}"));

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

            Map _trans = json.decode(await rootBundle
                .loadString("${delegate.langDirectory}$filename"));

            if (_trans?.isNotEmpty == true) {
              (_translations ??= {}).addAll(_trans.map((key, value) {
                return MapEntry("${prefix}_$key", value);
              }));
            }
          } else if (entry is String) {
            String filename = entry;
            Map _trans = json.decode(await rootBundle
                .loadString("${delegate.langDirectory}$filename"));
            if (_trans?.isNotEmpty == true) {
              (_translations ??= {}).addAll(_trans);
            }
          }
        }

        // At this stage, all went well.
        if (_translations?.isNotEmpty == true) {
          sentences.clear();
          sentences.addAll(_translations);
          return sentences;
        }
      }
    }

    // If we got here, it means something wasn't right so we return null.
    return null;
  }

  /// Checks if a locale is supported
  bool isSupported(Locale locale) {
    if (locale == null) {
      debugPrint("Locale to check if supported is null!!!");
      return false;
    }

    for (Locale loc in delegate.supportedLocales) {
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

  bool shouldReload(LocalizationsDelegate<Map<String, dynamic>> old) {
    return this.delegate.reload;
  }

  /// Saves the current locale or one that is passed to shared preference storage
  Future<void> saveLocale([Locale locale]) async {
    locale ??= delegate.locale;
    assert(isSupported(locale),
        "The locale ($locale) that is being saved is not contained in supported locales for the defined Translator.");

    final _preferences = await SharedPreferences.getInstance();
    await _preferences.setString(
        savedLocaleKey, "${locale.languageCode}_${locale.countryCode}");
  }

  /// Gets the saved locale from shared preference storage
  Future<Locale> getSavedLocale() async {
    final _preferences = await SharedPreferences.getInstance();
    final _strLocale = _preferences.getString(savedLocaleKey);
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
    await _preferences.remove(savedLocaleKey);
  }
}

class TranslatorProviderDelegate extends LocalizationsDelegate<Map<String, dynamic>> {
  final List<Locale> supportedLocales;
  Locale _locale;
  final String langConfigFile;
  final String langDirectory;
  final bool reload;

  final TranslatorProviderMixin provider;

  TranslatorProviderDelegate(
      {@required this.supportedLocales,
      @required this.provider,
      Locale locale,
      this.langConfigFile = 'config.json',
      this.langDirectory = 'assets/lang/',
      this.reload = false,
      }) : assert(supportedLocales?.isNotEmpty == true) {
    this._locale = locale;
  }

  /// Getter for the private locale variable
  Locale get locale {
    return _locale;
  }

  @override
  Future<Map<String, dynamic>> load([Locale locale]) async {
    // If loading for the first time, we give preference to persisted locale - if any
    // If null, set the locale to the current, persisted, default supported or first supported in that order
    locale ??= (locale ??
        await provider.getSavedLocale() ??
        provider.userPreferredLocale ??
        supportedLocales.first);

    // We need to make sure the locale that is being set is contained in supported locales
    assert(isSupported(locale),
        "The locale ($locale) that translation is requested for is not contained in supported locales for the defined Translator Delegate.");

    // Assign the current locale to this delegate
    _locale = locale;

    if (provider is TranslatorProviderBloc) {
      (provider as TranslatorProviderBloc).add(LoadEvent(locale));
      return null;
    } else {
      // Ask the provider to load translations based on this locale
      return await provider.load(locale);
    }
  }

  @override
  bool isSupported(Locale locale) {
    return provider.isSupported(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Map<String, dynamic>> old) {
    return provider.shouldReload(old);
  }
}
