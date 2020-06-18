import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/translator_provider.dart';
import '../../i18n_translator.dart';

part 'translator_widget_bloc.dart';
part 'translator_widget_event.dart';
part 'translator_widget_state.dart';

class TranslatorWidget extends StatefulWidget {
  final Widget child;
  final List<Locale> supportedLocales;
  final Locale locale;
  final String langConfigFile;
  final String langDirectory;
  final Color loaderColor;
  final TranslatorProvider provider;

  TranslatorWidget({
    Key key,
    @required this.child,
    @required this.supportedLocales,
    this.locale,
    this.langConfigFile = 'config.json',
    this.langDirectory = 'assets/lang/',
    this.provider,
    this.loaderColor = Colors.white,
  })  : assert(child != null),
        assert((provider != null) || (supportedLocales != null)),
        assert((provider != null) || (langConfigFile != null)),
        assert((provider != null) || (langDirectory != null)),
        super(key: key);

  @override
  _TranslatorWidgetState createState() => _TranslatorWidgetState();
}

class _TranslatorWidgetState extends State<TranslatorWidget> {
  TranslatorWidgetBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = TranslatorWidgetBloc(
        supportedLocales:
            widget.provider?.supportedLocales ?? widget.supportedLocales,
        locale: widget.provider?.supportedLocale ?? widget.locale,
        langConfigFile:
            widget.provider?.langConfigFile ?? widget.langConfigFile,
        langDirectory: widget.provider?.langDirectory ?? widget.langDirectory,
        provider: widget.provider);

    //NOTE: Here we have to redefine the global translator variable
    translator = _bloc.provider;
  }

  @override
  void dispose() {
    // Restore translator to the default
    translator = null;
    // Close or dispose the bloc
    _bloc?.close();
    // Dispose the state widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder(
        bloc: _bloc,
        builder: (context, state) {
          return widget.child;
        },
      ),
    );
  }
}
