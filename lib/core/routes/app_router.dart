import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/register_profile_page.dart';
import '../../features/auth/presentation/pages/permissions_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/guide/presentation/pages/guide_page.dart';
import '../../features/personalization/presentation/pages/personalization_flow_page.dart';
import '../../features/menu/presentation/pages/menu_page.dart';
import '../../features/menu/presentation/pages/dashboard_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/goals/presentation/pages/goal_detail_page.dart';
import '../../features/goals/presentation/pages/goal_tracking_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/menu/presentation/pages/rate_noorva_page.dart';
import '../../features/menu/presentation/pages/settings_page.dart';
import '../../features/menu/presentation/pages/app_permissions_page.dart';
import '../../features/menu/presentation/pages/notification_preferences_page.dart';
import '../../features/menu/presentation/pages/tutorials_page.dart';
import '../../features/menu/presentation/pages/tutorial_detail_page.dart';
import '../../features/menu/presentation/pages/about_noorva_page.dart';
import '../../features/menu/presentation/pages/about_detail_page.dart';
import '../../features/menu/presentation/pages/chat_history_page.dart';
import '../../features/menu/presentation/pages/ongoing_conversations_page.dart';
import '../../features/menu/presentation/pages/profile_page.dart';
import '../../features/menu/presentation/pages/personal_details_page.dart';
import '../../features/menu/presentation/pages/edit_personal_details_page.dart';
import '../../features/menu/presentation/pages/change_password_page.dart';
import '../../features/menu/presentation/pages/offline_page.dart';
import '../../features/menu/presentation/pages/delete_account_page.dart';
import '../../features/events/presentation/pages/events_page.dart';
import '../../features/events/presentation/pages/event_detail_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/tasks/presentation/pages/task_details_page.dart';
import '../../features/menu/presentation/pages/support_menu_page.dart';
import '../../features/menu/presentation/pages/contact_us_page.dart';
import '../../features/menu/presentation/pages/support_history_page.dart';
import '../../features/menu/presentation/pages/shared_inquiries_page.dart';
import '../../features/menu/presentation/pages/report_bug_page.dart';
import '../../features/menu/presentation/pages/report_bug_success_page.dart';
import '../../features/menu/presentation/pages/reported_bugs_history_page.dart';
import '../../features/menu/presentation/pages/feature_request_page.dart';
import '../../features/menu/presentation/pages/feature_request_success_page.dart';
import '../../features/guide/presentation/pages/interactive_ai_page.dart';
import '../../features/events/presentation/pages/interactive_event_creation_page.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.splash: (context) => const SplashPage(),
        AppRoutes.onboarding: (context) => const OnboardingPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.register: (context) => const RegisterPage(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordPage(),
        AppRoutes.otpVerification: (context) => const OtpVerificationPage(),
        AppRoutes.verifyEmail: (context) => const VerifyEmailPage(),
        AppRoutes.resetPassword: (context) => const ResetPasswordPage(),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.guide: (context) => const GuidePage(),
        AppRoutes.personalization: (context) => const PersonalizationFlowPage(),
        AppRoutes.menu: (context) => const MenuPage(),
        AppRoutes.dashboard: (context) => const DashboardPage(),
        AppRoutes.goals: (context) => const GoalsPage(),
        AppRoutes.goalDetail: (context) => const GoalDetailPage(),
        AppRoutes.goalTracking: (context) => const GoalTrackingPage(),
        AppRoutes.registerProfile: (context) => const RegisterProfilePage(),
        AppRoutes.permissions: (context) => const PermissionsPage(),
        AppRoutes.notifications: (context) => const NotificationsPage(),
        AppRoutes.rateNoorva: (context) => const RateNoorvaPage(),
        AppRoutes.settings: (context) => const SettingsPage(),
        AppRoutes.appPermissions: (context) => const AppPermissionsPage(),
        AppRoutes.notificationPreferences: (context) => const NotificationPreferencesPage(),
        AppRoutes.tutorials: (context) => const TutorialsPage(),
        AppRoutes.tutorialDetail: (context) => const TutorialDetailPage(),
        AppRoutes.aboutNoorva: (context) => const AboutNoorvaPage(),
        AppRoutes.aboutDetail: (context) => const AboutDetailPage(),
        AppRoutes.chatHistory: (context) => const ChatHistoryPage(),
        AppRoutes.ongoingConversations: (context) => const OngoingConversationsPage(),
        AppRoutes.profile: (context) => const ProfilePage(),
        AppRoutes.personalDetails: (context) => const PersonalDetailsPage(),
        AppRoutes.editPersonalDetails: (context) => const EditPersonalDetailsPage(),
        AppRoutes.changePassword: (context) => const ChangePasswordPage(),
        AppRoutes.offline: (context) => const OfflinePage(),
        AppRoutes.deleteAccount: (context) => const DeleteAccountPage(),
        AppRoutes.events: (context) => const EventsPage(),
        AppRoutes.eventDetail: (context) {
          final eventId = ModalRoute.of(context)!.settings.arguments as String;
          return EventDetailPage(eventId: eventId);
        },
        AppRoutes.tasks: (context) => const TasksPage(),
        AppRoutes.taskDetail: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return TaskDetailPage(taskArgs: args);
        },
        AppRoutes.supportMenu: (context) => const SupportMenuPage(),
        AppRoutes.contactUs: (context) => const ContactUsPage(),
        AppRoutes.supportHistory: (context) => const SupportHistoryPage(),
        AppRoutes.sharedInquiries: (context) => const SharedInquiriesPage(),
        AppRoutes.reportBug: (context) => const ReportBugPage(),
        AppRoutes.reportBugSuccess: (context) => const ReportBugSuccessPage(),
        AppRoutes.reportedBugsHistory: (context) => const ReportedBugsHistoryPage(),
        AppRoutes.featureRequest: (context) => const FeatureRequestPage(),
        AppRoutes.featureRequestSuccess: (context) => const FeatureRequestSuccessPage(),
        AppRoutes.interactiveAi: (context) => const InteractiveAiPage(),
        AppRoutes.interactiveEventCreation: (context) => const InteractiveEventCreationPage(),
      };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
            builder: (_) => const SplashPage(), settings: settings);
      case AppRoutes.onboarding:
        return MaterialPageRoute(
            builder: (_) => const OnboardingPage(), settings: settings);
      case AppRoutes.login:
        return MaterialPageRoute(
            builder: (_) => const LoginPage(), settings: settings);
      case AppRoutes.register:
        return MaterialPageRoute(
            builder: (_) => const RegisterPage(), settings: settings);
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
            builder: (_) => const ForgotPasswordPage(), settings: settings);
      case AppRoutes.otpVerification:
        return MaterialPageRoute(
            builder: (_) => const OtpVerificationPage(), settings: settings);
      case AppRoutes.verifyEmail:
        return MaterialPageRoute(
            builder: (_) => const VerifyEmailPage(), settings: settings);
      case AppRoutes.resetPassword:
        return MaterialPageRoute(
            builder: (_) => const ResetPasswordPage(), settings: settings);
      case AppRoutes.home:
        return MaterialPageRoute(
            builder: (_) => const HomePage(), settings: settings);
      case AppRoutes.guide:
        return MaterialPageRoute(
            builder: (_) => const GuidePage(), settings: settings);
      case AppRoutes.personalization:
        final args = settings.arguments as Map<String, dynamic>?;
        final isProfileMode = args?['isProfileMode'] as bool? ?? false;
        return MaterialPageRoute(
            builder: (_) => PersonalizationFlowPage(isProfileMode: isProfileMode),
            settings: settings);
      case AppRoutes.menu:
        return MaterialPageRoute(
            builder: (_) => const MenuPage(), settings: settings);
      case AppRoutes.dashboard:
        return MaterialPageRoute(
            builder: (_) => const DashboardPage(), settings: settings);
      case AppRoutes.goals:
        return MaterialPageRoute(
            builder: (_) => const GoalsPage(), settings: settings);
      case AppRoutes.goalDetail:
        return MaterialPageRoute(
            builder: (_) => const GoalDetailPage(), settings: settings);
      case AppRoutes.goalTracking:
        return MaterialPageRoute(
            builder: (_) => const GoalTrackingPage(), settings: settings);
      case AppRoutes.registerProfile:
        return MaterialPageRoute(
            builder: (_) => const RegisterProfilePage(), settings: settings);
      case AppRoutes.permissions:
        return MaterialPageRoute(
            builder: (_) => const PermissionsPage(), settings: settings);
      case AppRoutes.notifications:
        return MaterialPageRoute(
            builder: (_) => const NotificationsPage(), settings: settings);
      case AppRoutes.rateNoorva:
        return MaterialPageRoute(
            builder: (_) => const RateNoorvaPage(), settings: settings);
      case AppRoutes.settings:
        return MaterialPageRoute(
            builder: (_) => const SettingsPage(), settings: settings);
      case AppRoutes.appPermissions:
        return MaterialPageRoute(
            builder: (_) => const AppPermissionsPage(), settings: settings);
      case AppRoutes.notificationPreferences:
        return MaterialPageRoute(
            builder: (_) => const NotificationPreferencesPage(), settings: settings);
      case AppRoutes.tutorials:
        return MaterialPageRoute(
            builder: (_) => const TutorialsPage(), settings: settings);
      case AppRoutes.tutorialDetail:
        return MaterialPageRoute(
            builder: (_) => const TutorialDetailPage(), settings: settings);
      case AppRoutes.aboutNoorva:
        return MaterialPageRoute(
            builder: (_) => const AboutNoorvaPage(), settings: settings);
      case AppRoutes.aboutDetail:
        return MaterialPageRoute(
            builder: (_) => const AboutDetailPage(), settings: settings);
      case AppRoutes.chatHistory:
        return MaterialPageRoute(
            builder: (_) => const ChatHistoryPage(), settings: settings);
      case AppRoutes.ongoingConversations:
        return MaterialPageRoute(
            builder: (_) => const OngoingConversationsPage(), settings: settings);
      case AppRoutes.profile:
        return MaterialPageRoute(
            builder: (_) => const ProfilePage(), settings: settings);
      case AppRoutes.personalDetails:
        return MaterialPageRoute(
            builder: (_) => const PersonalDetailsPage(), settings: settings);
      case AppRoutes.editPersonalDetails:
        return MaterialPageRoute(
            builder: (_) => const EditPersonalDetailsPage(), settings: settings);
      case AppRoutes.changePassword:
        return MaterialPageRoute(
            builder: (_) => const ChangePasswordPage(), settings: settings);
      case AppRoutes.offline:
        return MaterialPageRoute(
            builder: (_) => const OfflinePage(), settings: settings);
      case AppRoutes.deleteAccount:
        return MaterialPageRoute(
            builder: (_) => const DeleteAccountPage(), settings: settings);
      case AppRoutes.events:
        return MaterialPageRoute(
            builder: (_) => const EventsPage(), settings: settings);
      case AppRoutes.eventDetail:
        final eventId = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => EventDetailPage(eventId: eventId), settings: settings);
      case AppRoutes.tasks:
        return MaterialPageRoute(
            builder: (_) => const TasksPage(), settings: settings);
      case AppRoutes.taskDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => TaskDetailPage(taskArgs: args), settings: settings);
      case AppRoutes.supportMenu:
        return MaterialPageRoute(
            builder: (_) => const SupportMenuPage(), settings: settings);
      case AppRoutes.contactUs:
        return MaterialPageRoute(
            builder: (_) => const ContactUsPage(), settings: settings);
      case AppRoutes.supportHistory:
        return MaterialPageRoute(
            builder: (_) => const SupportHistoryPage(), settings: settings);
      case AppRoutes.sharedInquiries:
        return MaterialPageRoute(
            builder: (_) => const SharedInquiriesPage(), settings: settings);
      case AppRoutes.reportBug:
        return MaterialPageRoute(
            builder: (_) => const ReportBugPage(), settings: settings);
      case AppRoutes.reportBugSuccess:
        return MaterialPageRoute(
            builder: (_) => const ReportBugSuccessPage(), settings: settings);
      case AppRoutes.reportedBugsHistory:
        return MaterialPageRoute(
            builder: (_) => const ReportedBugsHistoryPage(), settings: settings);
      case AppRoutes.featureRequest:
        return MaterialPageRoute(
            builder: (_) => const FeatureRequestPage(), settings: settings);
      case AppRoutes.featureRequestSuccess:
        return MaterialPageRoute(
            builder: (_) => const FeatureRequestSuccessPage(), settings: settings);
      case AppRoutes.interactiveAi:
        return MaterialPageRoute(
            builder: (_) => const InteractiveAiPage(), settings: settings);
      case AppRoutes.interactiveEventCreation:
        return MaterialPageRoute(
            builder: (_) => const InteractiveEventCreationPage(), settings: settings);

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
