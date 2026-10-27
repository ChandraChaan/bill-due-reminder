// Renders the README screenshots from the real screens with made-up bills.
// Not part of `flutter test` (font rendering differs between machines):
//
//   flutter test test_screenshots --update-goldens
//
// Uses the Roboto and Material Icons fonts that ship with the Flutter SDK.

import 'dart:io';

import 'package:bill_due_reminder/features/bills/domain/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/fakes.dart';
import '../test/widgets/harness.dart';

Future<void> _loadFonts() async {
  final sdk = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent.parent;
  final fonts = Directory('${sdk.path}/bin/cache/artifacts/material_fonts');
  Future<ByteData> read(String name) async =>
      ByteData.sublistView(await File('${fonts.path}/$name').readAsBytes());
  final roboto = FontLoader('Roboto');
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    roboto.addFont(read('Roboto-$weight.ttf'));
  }
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(read('MaterialIcons-Regular.otf'))).load();
}

Future<void> _phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

Future<void> _shoot(String path) =>
    expectLater(find.byType(MaterialApp), matchesGoldenFile(path));

/// Paints real shadows (flutter_test draws elevation as black outlines by
/// default) and restores the default before the test ends.
Future<void> Function(WidgetTester) _withShadows(
  Future<void> Function(WidgetTester tester) body,
) => (tester) async {
  debugDisableShadows = false;
  try {
    await body(tester);
  } finally {
    debugDisableShadows = true;
  }
};

void main() {
  setUpAll(_loadFonts);
  // Touch, not keyboard: no focus rings in the pictures.
  setUp(
    () => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTouch,
  );

  testWidgets(
    '01 home',
    _withShadows((tester) async {
      await pumpApp(tester, store: FakeStore(sampleData()));
      await _phone(tester);
      await tester.pumpAndSettle();
      await _shoot('../docs/screenshots/01_home.png');
    }),
  );

  testWidgets(
    '02 bill',
    _withShadows((tester) async {
      await pumpApp(tester, store: FakeStore(sampleData()));
      await _phone(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('HDFC Bank'));
      await tester.pumpAndSettle();
      await _shoot('../docs/screenshots/02_bill.png');
    }),
  );

  testWidgets(
    '03 onboarding',
    _withShadows((tester) async {
      await pumpApp(tester, store: FakeStore(AppData.empty()));
      await _phone(tester);
      await tester.pumpAndSettle();
      await _shoot('../docs/screenshots/03_privacy.png');
    }),
  );

  testWidgets(
    '04 settings',
    _withShadows((tester) async {
      await pumpApp(
        tester,
        store: FakeStore(sampleData()),
        location: '/settings',
      );
      await _phone(tester);
      await tester.pumpAndSettle();
      await _shoot('../docs/screenshots/04_settings.png');
    }),
  );
}
