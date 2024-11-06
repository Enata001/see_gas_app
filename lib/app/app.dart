import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/features/authentication/entities/auth_result.dart';
import 'package:see_gas_app/providers/theme_provider.dart';
import 'package:see_gas_app/providers/user_notifier.dart';
import 'package:see_gas_app/utils/extensions.dart';
import 'package:see_gas_app/utils/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/authentication/entities/auth_state.dart';
import '../providers/auth_state_notifier.dart';

class MyApp extends StatelessWidget {
  final SharedPreferences preferences;

  const MyApp({super.key, required this.preferences});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        themeProvider.overrideWith(
          (ref) => ThemeProvider(preferences),
        ),
        userProvider.overrideWith(
          (ref) {
            return UserNotifier(null, preferences);
          },
        )
      ],
      child: Consumer(builder: (context, ref, child) {
        final appTheme = ref.watch(themeProvider);

        ref.listen<AuthState>(authStateNotifierProvider, (prev, next) {
          if (next.isLoading) {
            Navigation().loading();
          } else {
            if (Navigator.canPop(Navigation.navigatorKey.currentContext!)) {
              Navigation.close();
            }
          }
          if (next.result == AuthResult.failure) {
            Navigation().messenger(
              title: 'Error',
              description: next.errorMessage ?? "",
              icon: Icons.error_outline,
              color: Colors.red,
            );
            // ref.read(errorMessageProvider.notifier).clearError();
          }
        });
        return MaterialApp(
          title: 'Flutter Demo',
          theme: appTheme.theme,
          themeAnimationDuration: const Duration(milliseconds: 100),
          themeAnimationCurve: Curves.easeInQuad,
          debugShowCheckedModeBanner: false,
          navigatorKey: Navigation.navigatorKey,
          onGenerateRoute: Navigation.onGenerateRoute,
        );
      }),
    );
  }
}
