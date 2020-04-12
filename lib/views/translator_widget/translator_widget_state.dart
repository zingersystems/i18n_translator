part of 'translator_widget.dart';

abstract class TranslatorWidgetState {
  final TranslatorWidgetEvent event;
  TranslatorWidgetState([this.event]);
}

class InitState extends TranslatorWidgetState{
  InitState([TranslatorWidgetEvent event]): super(event);
}

class LoadingState extends TranslatorWidgetState{
  LoadingState([TranslatorWidgetEvent event]): super(event);
}

class BuildState extends TranslatorWidgetState{
  BuildState([TranslatorWidgetEvent event]): super(event);
} 