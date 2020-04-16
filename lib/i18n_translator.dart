library i18n_translator;

import 'package:flutter/material.dart';

import 'providers/translator_provider.dart';

typedef TranslationGetter<T> = T Function(String key, {String prefix});

/// Global variable to a global TranslatorProviderMixing instance
TranslatorProviderMixin translator;

/// Define a reference to the translation function as this may be use a lot.
/// These short hands will return null if translator is null.
TranslationGetter<String> translate = translator?.translate;
TranslationGetter<String> t = translator?.translate;
