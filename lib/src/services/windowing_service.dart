// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/_window.dart' as flutter_windowing;

bool get isFlutterWindowingEnabled =>
    const String.fromEnvironment(
      'FLUTTER_ENABLED_FEATURE_FLAGS',
    ).split(',').contains('windowing');

bool get isFlutterWindowingAvailable =>
    !kIsWeb && _supportsWindowingAtRuntime();

Widget wrapWithWindowManager(Widget child) {
  if (!isFlutterWindowingAvailable) {
    return child;
  }
  return flutter_windowing.WindowManager(child: child);
}

bool isWindowedEditorContext(BuildContext context) {
  if (!isFlutterWindowingAvailable) {
    return false;
  }
  try {
    return flutter_windowing.WindowScope.maybeOf(context) != null;
  } catch (_) {
    return false;
  }
}

bool openRegularEditorWindow({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  Size preferredSize = const Size(1440, 920),
  VoidCallback? onClosed,
}) {
  if (!isFlutterWindowingAvailable) {
    return false;
  }

  try {
    final registry = flutter_windowing.WindowRegistry.of(context);
    late final flutter_windowing.WindowEntry entry;
    late final flutter_windowing.RegularWindowController controller;

    controller = flutter_windowing.RegularWindowController(
      title: title,
      preferredSize: preferredSize,
      delegate: _EditorWindowDelegate(
        onCloseRequested: () {
          registry.unregister(entry);
          controller.destroy();
        },
        onDestroyed: () {
          registry.unregister(entry);
          onClosed?.call();
        },
      ),
    );

    entry = flutter_windowing.WindowEntry(
      controller: controller,
      builder: builder,
    );
    registry.register(entry);
    controller.activate();
    return true;
  } catch (_) {
    return false;
  }
}

bool _supportsWindowingAtRuntime() {
  if (!isFlutterWindowingEnabled) {
    return false;
  }
  if (!(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    return false;
  }

  try {
    final owner = WidgetsBinding.instance.windowingOwner;
    return owner.runtimeType.toString() != '_WindowingOwnerUnsupported';
  } catch (_) {
    return false;
  }
}

class _EditorWindowDelegate
    extends flutter_windowing.RegularWindowControllerDelegate {
  _EditorWindowDelegate({
    required this.onCloseRequested,
    required this.onDestroyed,
  });

  final VoidCallback onCloseRequested;
  final VoidCallback onDestroyed;

  @override
  void onWindowCloseRequested(
    flutter_windowing.RegularWindowController controller,
  ) {
    onCloseRequested();
  }

  @override
  void onWindowDestroyed() {
    onDestroyed();
  }
}
