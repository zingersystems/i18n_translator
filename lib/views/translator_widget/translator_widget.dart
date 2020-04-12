import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/translator_provider.dart';

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
        assert(supportedLocales?.isNotEmpty == true),
        assert(langConfigFile?.isNotEmpty == true),
        assert(langDirectory?.isNotEmpty == true),
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
        supportedLocales: widget.supportedLocales,
        locale: widget.locale,
        langConfigFile: widget.langConfigFile,
        langDirectory: widget.langDirectory,
        provider: widget.provider
    );

  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder(
        bloc: _bloc,
        builder: (context, state){
          return widget.child;
        },
      ),
    );
  }

}