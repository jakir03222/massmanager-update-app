import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'views/auth/login_view.dart';
import 'views/home/main_shell.dart';

/// App shell: theme and auth-gated home. Holds [AuthController].
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: ListenableBuilder(
        listenable: _authController,
        builder: (context, _) {
          if (_authController.loading && _authController.user == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (_authController.user == null) {
            return LoginView(authController: _authController);
          }
          return MainShell(authController: _authController);
        },
      ),
    );
  }
}
