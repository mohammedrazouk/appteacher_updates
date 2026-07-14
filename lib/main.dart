import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/classes/class_dashboard_screen.dart';
import 'features/classes/classes_screen.dart';
import 'features/home/home_screen.dart';
import 'providers/app_state.dart';

void main() {
  runApp(const ItqanApp());
}

class ItqanApp extends StatelessWidget {
  const ItqanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'مؤسسة إتقان للتعليم والتنمية',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          '/classes': (_) => const ClassesScreen(),
          '/class': (ctx) {
            final classId = ModalRoute.of(ctx)!.settings.arguments as int;
            return ClassDashboardScreen(classId: classId);
          },
        },
      ),
    );
  }
}
