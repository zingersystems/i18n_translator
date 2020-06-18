import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/translator_provider.dart';

part 'event.dart';
part 'state.dart';

class TranslatorProviderBloc
    extends Bloc<TranslatorProviderBlocEvent, TranslatorProviderBlocState>
    with TranslatorProviderMixin {
  final List<Locale> supportedLocales;
  final Locale supportedLocale;
  final String langConfigFile;
  final String langDirectory;
  final bool init;

  TranslatorProviderBloc(
      {@required this.supportedLocales,
      this.langConfigFile = 'config.json',
      this.langDirectory = 'assets/lang/',
      this.init = false,
      bool reload = false,
      this.supportedLocale})
      : assert(supportedLocales != null) {
    // Initialize the delegate for this provider
    delegate = TranslatorProviderDelegate(
        supportedLocales: supportedLocales,
        langConfigFile: langConfigFile,
        langDirectory: langDirectory,
        reload: reload,
        provider: this);

    // Ensure to initialize the provider if asked
    if (init) {
      this.add(InitEvent());
    }
  }

  @override
  TranslatorProviderBlocState get initialState =>
      (isLoaded) ? LoadedState() : InitState();

  @override
  Future<void> close() async {
    // Clear the sentences for this provider
    sentences.clear();
    // Call the super close method
    await super.close();
  }

  @override
  Stream<TranslatorProviderBlocState> mapEventToState(
      TranslatorProviderBlocEvent event) async* {
    if (event is InitEvent) {
      yield* _mapInitEventToState(event);
    } else if (event is LoadEvent) {
      yield* _mapLoadEventToState(event);
    }
  }

  Stream<TranslatorProviderBlocState> _mapInitEventToState(
      InitEvent event) async* {
    // Load the translation strings
    yield LoadingState(event);
    await load();
    yield LoadedState(event);
  }

  Stream<TranslatorProviderBlocState> _mapLoadEventToState(
      LoadEvent event) async* {
    // Load the translation strings
    yield LoadingState(event);
    await load(event.locale);
    yield LoadedState(event);
  }
}
