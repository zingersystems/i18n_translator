part of 'translator_widget.dart';

class TranslatorWidgetBloc
    extends Bloc<TranslatorWidgetEvent, TranslatorWidgetState> {
  final List<Locale> supportedLocales;
  final Locale locale;
  final String langConfigFile;
  final String langDirectory;

  TranslatorProvider provider;

  TranslatorWidgetBloc(
      {@required this.supportedLocales,
      this.langConfigFile = 'config.json',
      this.langDirectory = 'assets/lang/',
      this.locale,
      this.provider})
      : assert((provider != null) || (supportedLocales != null)),
        assert((provider != null) || (langConfigFile != null)),
        assert((provider != null) || (langDirectory != null)) {
    // Ensure to initialize the provider
    provider ??= TranslatorProvider(
        supportedLocales: supportedLocales,
        langConfigFile: langConfigFile,
        langDirectory: langDirectory,
        locale: locale);

    if (provider?.isLoaded != true) {
      // Run the initializer process if the provider was not already loaded
      this.add(InitEvent());
    }
  }

  @override
  TranslatorWidgetState get initialState =>
      (provider?.isLoaded == true) ? BuildState() : InitState();

  @override
  Future<void> close() async {
    await super.close();
  }

  @override
  Stream<TranslatorWidgetState> mapEventToState(
      TranslatorWidgetEvent event) async* {
    if (event is InitEvent) {
      yield* _mapInitEventToState(event);
    } else if (event is UpdateLocaleEvent) {
      yield* _mapUpdateLocaleEventToState(event);
    }
  }

  Stream<TranslatorWidgetState> _mapInitEventToState(InitEvent event) async* {
    // Load the translation strings
    yield LoadingState(event);
    await provider?.load();
    yield BuildState(event);
  }

  Stream<TranslatorWidgetState> _mapUpdateLocaleEventToState(
      UpdateLocaleEvent event) async* {
    // Load the translation strings
    yield LoadingState(event);
    await provider?.load(event.locale);
    yield BuildState(event);
  }
}
