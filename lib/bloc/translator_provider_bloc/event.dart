part of 'bloc.dart';

abstract class TranslatorProviderBlocEvent {}

class InitEvent extends TranslatorProviderBlocEvent {}

class LoadEvent extends TranslatorProviderBlocEvent {
  final Locale locale;
  LoadEvent([this.locale]);
}
