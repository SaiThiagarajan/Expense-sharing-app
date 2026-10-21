import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../data/mock_data.dart';
import '../state/app_state.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

class ExpenseSharingApp extends StatelessWidget {
  const ExpenseSharingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(
        currentUser: MockData.currentUser,
        household: MockData.household,
        expenses: MockData.buildExpenses(),
        notifications: MockData.buildNotifications(),
      ),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.onboarding,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
