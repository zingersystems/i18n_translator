part of 'translator_widget.dart';

abstract class TranslatorWidgetEvent {}

class InitEvent extends TranslatorWidgetEvent {}

class LoadEvent extends TranslatorWidgetEvent {
  final Locale locale;
  LoadEvent([this.locale]);
}
