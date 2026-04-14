import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/member_controller.dart';
import '../controllers/statement_controller.dart';
import '../controllers/summary_controller.dart';
import '../views/auth/login_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/members/add_edit_member_view.dart';
import '../views/members/member_list_view.dart';
import '../views/reports/report_view.dart';
import '../views/splash/splash_view.dart';
import '../views/statements/add_edit_statement_view.dart';
import '../views/statements/statement_list_view.dart';
import '../views/summary/monthly_summary_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        Get.lazyPut<MemberController>(() => MemberController(), fenix: true);
        Get.lazyPut<SummaryController>(() => SummaryController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.memberList,
      page: () => const MemberListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MemberController>(() => MemberController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.addEditMember,
      page: () => const AddEditMemberView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MemberController>(() => MemberController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.statementList,
      page: () => const StatementListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StatementController>(() => StatementController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.addEditStatement,
      page: () => const AddEditStatementView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StatementController>(() => StatementController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.monthlySummary,
      page: () => const MonthlySummaryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SummaryController>(() => SummaryController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SummaryController>(() => SummaryController(), fenix: true);
      }),
    ),
  ];
}
