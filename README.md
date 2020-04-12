# i18n Translator

[![pub package](https://img.shields.io/pub/v/i18n_translator.svg)](https://pub.dartlang.org/packages/i18n_translator)

A flutter package designed to make internationalizing your flutter app a breeze. This package simplifies i18n/i10n during development by facilitating modularization and collaboration between team members during the internationalizing process of the app development cycle.

## Why

While there are many internationalization/localization packages available, we simple could not find one that addresses the i18n/i10n problem in a simple yet extensible way for teams with more than one developer working on a single project. Most approches to the i18n/i10n problem using json implementation uses one file resulting to merge conflict nightmares. We created this package to adddress just this problem.

* Configurable shared asset directory and translation files      
* Multiple translation json files per single supported locale i.e. support for modularize translation.       
* Use prefix to avoid overriding identical translation keys from different modules or packages       

## Install

To use this package, add `i18n_translator` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/) like so.

``` dart
dependencies:
  i18n_translator: <version>
```

Add translation assets to your application in the assets section of your pubspec.yaml file as below.
Ensure to define the root directory and the sub directories for each locale you plan to support.
Note that each asset directory definition ends with a trailing / directory separator
 

``` dart
assets:
    - assets/lang/
    - assets/lang/en/
    - assets/lang/fr/
```

Then run the flutter tooling:

```sh
flutter packages get
```

Create a json configuration file in the root translation directory you defined in the asset section above.
When instantiating the Translator Provider or Delegate, you will have the opportunity to specify the path - relative to the root - to the configuration file and the root directory that contains the translation json files.
An example config file may be as shown below.

``` json
{
  "en" : [
    {
      "prefix" : "module_1",
      "filename" : "en/module-1-en.json"
    },
    "en/module-2-en.json"
  ],
  "fr" : [
    {
      "prefix" : "module_1",
      "filename" : "en/module-1-fr.json"
    },
    "en/module-2-fr.json"
  ]
}
```


## Usage

See the main files provided with the accompanying example project for the different ways you may use this package.

We provided a **singleton** and a **widget** approach. 
We also made available "global" variables **Translator**, **translaor**, **translate** and **t** to ease access to the i18n_translator provider/delegate and the translation functions that package users may call often.

Below is a quick example below that shows how to use the package. 

### Singleton provider approach
``` dart

// Import relevant packages
import 'package:i18n_translator/i18n_translator.dart';

// Using the global 'translator' variable name and the singleton constructor 'Translator'.
translator = Translator(
    //Keep locales as wide as possible. Use en instead of en_CM or en_US
    supportedLocales: [const Locale('en'), const Locale('fr')],
    langConfigFile: 'config.json',
    langDirectory: 'assets/lang/'
);

// Fetch the mapped key-value pairs representing the translations for the provider/delegate.
await translator.load(); // When no locale is passed, uses saved or default supported locale.

// Get translation
translate('my_translation_key');
// Get translation with prefix
translate('my_translation_key', prefix: 'module_1');
// The line above is equivalent to this below
translate('module_1_my_translation_key');

```

### Translator provider class approach
``` dart

// Import relevant packages
import 'package:i18n_translator/i18n_translator.dart';
import 'providers/translator_provider.dart';

// Using the TranslatorProvider class.
final translatorProvider = TranslatorProvider(
    //Keep locales as wide as possible. Use en instead of en_CM or en_US
    supportedLocales: [const Locale('en'), const Locale('fr')],
    langConfigFile: 'config.json',
    langDirectory: 'assets/lang/'
);

// Fetch the mapped key-value pairs representing the translations for the provider/delegate.
await translatorProvider.load(); // When no locale is passed, uses saved or default supported locale.

// Get translation
translatorProvider.translate('my_translation_key');
// Get translation with prefix
translatorProvider.translate('my_translation_key', prefix: 'module_1');
// The line above is equivalent to this below
translatorProvider.translate('module_1_my_translation_key');

```

### Translator widget approach
``` dart

// Import relevant packages
import 'package:i18n_translator/i18n_translator.dart';
import 'package:i18n_translator/views/translator_widget/translator_widget.dart';

TranslatorWidget(
    supportedLocales : [const Locale('en'), const Locale('fr')],
    langConfigFile : 'config.json',
    langDirectory : 'assets/lang/',
    // provider : translator, //Only use if a singleton is instantiated - will override other provided variables
    child : Builder(
        builder: (context){

            // You may define a local variable
            final mProvider = BlocProvider.of<TranslatorWidgetBloc>(context).provider;

            // Or assign to the global translator provider variable from the package
            translator = BlocProvider.of<TranslatorWidgetBloc>(context).provider;

            return Container(
                child: Row(
                    children: [
                        Text(
                            // Usage with variable
                            mProvider.translate('my_translation_key', prefix: "module_1"), // This is called from translator
                        ),
                        Text(
                            // Usage with gloab translator variable
                            translate('my_translation_key', prefix: "module_1"), // This is called from translator
                        ),
                    ]
                ),
            );
        },
    )
);

```


## Testing

We have not yet implemented tests for the package. This shall be WIP as we continue to improve on the package.

```sh
flutter test
```

## Credits

* Ideas for the Translator Widgets came from [easy_localization](https://pub.dev/packages/easy_localization)

* We want to thank specially [Felix Angelov](https://github.com/felangel) for his amazing work on [flutter_bloc](https://pub.dev/packages/flutter_bloc) on which this package depends.

* It is easy to forget those who make this possible; hats off to the Flutter Team and the amazing Flutter Community. 

## Dependencies
This package depends on:
* shared_preferences ([https://pub.dev/packages/shared_preferences](https://pub.dev/packages/shared_preferences))
* flutter_bloc ([https://pub.dev/packages/flutter_bloc](https://pub.dev/packages/flutter_bloc))
* flutter_device_locale ([https://pub.dev/packages/flutter_device_locale](https://pub.dev/packages/flutter_device_locale))

## Contributions
Contributions are always welcome!

## Work with us
* hello[at]zingersystems.com
* labs[at]zingersystems.com


## License
Copyright (c) 2020 MIT - Zinger Systems Limited