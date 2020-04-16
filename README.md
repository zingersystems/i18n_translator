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

We provided three options for you: **Simple Provider**, **Bloc Provider** and a **Widget** approach. 
We also made available "global" variable and function **translator**, **translate** and **t** to ease access to the i18n_translator provider/bloc and the translation functions that package users may call often.

Below is a quick example below that shows how to use the package. Do not forget to import relevant packages.

### Simple Provider Approach
``` dart

// Define a static instance of the the Translator provider.
translator = TranslatorProvider(
  //Note: Keep locales as wide as possible. Use en instead of en_CM or en_US
  supportedLocales: [const Locale('en'), const Locale('fr')],
  langConfigFile: 'config.json',
  langDirectory: 'assets/lang/');

/// When material app is built, the load method of the delegate will be called
/// and the translator provider will load the translation strings.
/// This however results in a situation where translations are not loaded for
/// the home screen or page initially. To solve this, you may want to call
/// the method of the provider early but this results in loading twice.

// Call the load method directly from the provider
await translator.load();

// Get translation
translate('my_translation_key');
// Get translation with prefix
translate('my_translation_key', prefix: 'module_1');
// The line above is equivalent to this below
translate('module_1_my_translation_key');

```

### Bloc Provider Approach
``` dart

// Define a static instance of the the Translator provider.
  translator = TranslatorProviderBloc(
      //Note: Keep locales as wide as possible. Use en instead of en_CM or en_US
      supportedLocales: [const Locale('en'), const Locale('fr')],
      langConfigFile: 'config.json',
      langDirectory: 'assets/lang/'
  );

  /// When material app is built, the load method of the delegate will be called
  /// and the translator bloc LoadEvent will fire loading the translation.
  /// The bloc will go to the LoadingState and then LoadedState.

// Load the translation by triggering a bloc event
translator.add(LoadEvent());

// Get translation
translatorProvider.translate('my_translation_key');
// Get translation with prefix
translatorProvider.translate('my_translation_key', prefix: 'module_1');
// The line above is equivalent to this below
translatorProvider.translate('module_1_my_translation_key');

```

### Translator Widget Approach
``` dart

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
                            mProvider.translate('my_translation_key', prefix: "module_1"), // This is called from mProvider
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