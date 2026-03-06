import 'package:flutter/material.dart';

class NotifierProvider<Model extends ChangeNotifier> extends StatefulWidget {
  final Widget child;
  final bool isManagingModel;
  final Model Function() create;
  
  const NotifierProvider({
    super.key,
    this.isManagingModel = true,
    required this.create,
    required this.child,
  });

  @override
  _NotifierProviderState<Model> createState() =>
      _NotifierProviderState<Model>();

  static Model? read<Model extends ChangeNotifier>(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<
          _InheritedNotifierProvider<Model>
        >()
        ?.widget;
    return widget is _InheritedNotifierProvider<Model> ? widget.model : null;
  }

  static Model? watch<Model extends ChangeNotifier>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedNotifierProvider<Model>>()
        ?.model;
  }
}

class _NotifierProviderState<Model extends ChangeNotifier>
    extends State<NotifierProvider<Model>> {
  late final Model _model;

  @override
  void initState() {
    super.initState();
    _model = widget.create();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedNotifierProvider(model: _model, child: widget.child);
  }

  @override
  void dispose() {
    if (widget.isManagingModel) {
      _model.dispose();
    }
    super.dispose();
  }
}

class _InheritedNotifierProvider<Model extends ChangeNotifier>
    extends InheritedNotifier {
  final Model model;
  const _InheritedNotifierProvider({
    super.key,
    required this.child,
    required this.model,
  }) : super(child: child, notifier: model);

  final Widget child;
}

class Provider<Model> extends InheritedWidget {
  final Model model;
  const Provider({super.key, required Widget child, required this.model})
    : super(child: child);

  static Model? watch<Model>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider<Model>>()?.model;
  }

  static Model? read<Model>(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<Provider<Model>>()
        ?.widget;
    return widget is Provider<Model> ? widget.model : null;
  }

  @override
  bool updateShouldNotify(Provider oldWidget) {
    return model != oldWidget.model;
  }
}
