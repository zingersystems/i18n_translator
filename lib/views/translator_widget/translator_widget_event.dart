part of 'translator_widget.dart';

abstract class TranslatorWidgetEvent{}

class InitEvent extends TranslatorWidgetEvent{}

class UpdateLocaleEvent extends TranslatorWidgetEvent{
  final Locale locale;
  UpdateLocaleEvent([this.locale]);
}