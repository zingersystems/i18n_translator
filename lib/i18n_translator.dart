library i18n_translator;

import 'package:flutter/material.dart';

import 'providers/translator_provider.dart';

typedef TranslatorProviderGetter<T> = T Function(
    {List<Locale> supportedLocales,
    Locale locale,
    String langConfigFile,
    String langDirectory});

typedef TranslatorGetter<T> = T Function();
typedef TranslationGetter<T> = T Function(String key, {String prefix});

/// Define a reference to a translator singleton instance that plugin users
/// may use globally. Since this returns an instance of a Translator Provider,
/// it is justified why we name the type Translator with capital T since
/// it behaves like and instance of a class.
// ignore: non_constant_identifier_names
TranslatorProviderGetter<TranslatorProviderMixin> Translator =
    TranslatorProvider.instance;

/// Short hand for static instance of translator
TranslatorProviderMixin translator;

/// Define a reference to the translation function as this may be use a lot.
/// These short hands will return null if translator is null.
TranslationGetter<String> translate = translator?.translate;
TranslationGetter<String> t = translator?.translate;
