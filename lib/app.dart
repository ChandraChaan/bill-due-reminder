import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'features/bills/presentation/bill_form_screen.dart';
import 'features/bills/presentation/home_screen.dart';
import 'features/bills/presentation/settings_screen.dart';
import 'l10n/app_localizations.dart';

GoRouter buildRouter() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: 'add',
          builder: (context, state) => const BillFormScreen(),
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) =>
              BillFormScreen(billId: state.pathParameters['id']),
        ),
      ],
    ),
  ],
);

class DueDayApp extends StatefulWidget {
  const DueDayApp({super.key, this.router});

  /// Tests pass their own router to start on a given screen.
  final GoRouter? router;

  @override
  State<DueDayApp> createState() => _DueDayAppState();
}

class _DueDayAppState extends State<DueDayApp> {
  late final GoRouter _router = widget.router ?? buildRouter();

  @override
  void dispose() {
    if (widget.router == null) _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    theme: buildTheme(Brightness.light),
    darkTheme: buildTheme(Brightness.dark),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: _router,
    debugShowCheckedModeBanner: false,
  );
}
