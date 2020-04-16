part of 'bloc.dart';

abstract class TranslatorProviderBlocState {
  final TranslatorProviderBlocEvent event;
  TranslatorProviderBlocState([this.event]);
}

class InitState extends TranslatorProviderBlocState {
  InitState([TranslatorProviderBlocEvent event]) : super(event);
}

class LoadingState extends TranslatorProviderBlocState {
  LoadingState([TranslatorProviderBlocEvent event]) : super(event);
}

class LoadedState extends TranslatorProviderBlocState {
  LoadedState([TranslatorProviderBlocEvent event]) : super(event);
}
