import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/modules/auth/binding/auth_binding.dart';
import 'package:q_cut/modules/auth/views/forget_password_view.dart';
import 'package:q_cut/modules/auth/views/login_view.dart';
import 'package:q_cut/modules/auth/views/otp_verification_reset_case_view.dart';
import 'package:q_cut/modules/auth/views/otp_verification_view.dart';
import 'package:q_cut/modules/auth/views/reset_password_view.dart';
import 'package:q_cut/modules/auth/views/reset_phone_number_view.dart';
import 'package:q_cut/modules/auth/views/sign_up_view.dart';
import 'package:q_cut/modules/auth/views/legal_documents_view.dart';
import 'package:q_cut/modules/auth/views/update_phone_number_view.dart'; // Added
import 'package:q_cut/modules/barber/features/booking/presentation/views/b_available_appointments_view.dart';
import 'package:q_cut/modules/barber/features/booking/presentation/views/b_booking_view.dart';
import 'package:q_cut/modules/barber/features/booking/presentation/views/pay_to_qcut_feature/view/b_pay_to_q_cut_view.dart';
import 'package:q_cut/modules/barber/features/booking/presentation/views/b_payment_methods_view.dart';
import 'package:q_cut/modules/barber/features/booking/presentation/views/pay_to_qcut_feature/view/b_payment_time_line_view.dart';
import 'package:q_cut/modules/barber/features/booking/presentation/views/success_screen.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/views/b_appointment_view.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/b_profile_view.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/views/b_statics_view.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_edit/views/b_edit_profile_view.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/views/image_view.dart';
import 'package:q_cut/modules/barber/features/settings/presentation/views/b_connect_us_view.dart';
import 'package:q_cut/modules/barber/features/settings/presentation/views/b_history_view.dart';
import 'package:q_cut/modules/barber/features/settings/presentation/views/b_settings_view.dart';
import 'package:q_cut/modules/barber/features/settings/presentation/views/delete_account_reason_page.dart';
import 'package:q_cut/modules/barber/features/settings/report_feature/view/reports_view.dart';
import 'package:q_cut/modules/customer/features/booking_features/display_barber_services_feature/views/barber_services_view.dart';
import 'package:q_cut/modules/customer/features/booking_features/select_appointment_time/view/book_appointment_view.dart';
import 'package:q_cut/modules/customer/features/bookingAndPayment/view/views/book_appointment_with_payment_methods_view.dart';
import 'package:q_cut/modules/customer/features/booking_features/select_appointment_time/view/on_hold_appointment_view.dart';
import 'package:q_cut/modules/customer/features/bookingAndPayment/view/views/q_cut_services_view.dart';
import 'package:q_cut/modules/customer/features/favorite_feature/favorite_view.dart';
import 'package:q_cut/modules/customer/features/home_features/city_selection/bindings/city_binding.dart';
import 'package:q_cut/modules/customer/features/home_features/city_selection/views/city_selection_view_new.dart';
import 'package:q_cut/modules/customer/history_feature/binding/history_binding.dart';
import 'package:q_cut/modules/customer/history_feature/view/history_view.dart';
import 'package:q_cut/modules/customer/features/home_features/home/views/home_view.dart';
import 'package:q_cut/modules/customer/features/home_features/appointment_feature/view/my_appointment_view.dart';
import 'package:q_cut/modules/customer/features/home_features/profile_feature/views/my_profile_view.dart';
import 'package:q_cut/modules/main/view/home_navigation_bar.dart';
import 'package:q_cut/modules/customer/features/home_features/home/views/widgets/recommended_view.dart';
import 'package:q_cut/modules/customer/features/home/presentation/views/search_for_the_time_view.dart';
import 'package:q_cut/modules/customer/features/home_features/home/views/selected_view.dart';
import 'package:q_cut/modules/customer/features/settings/presentation/views/change_languges_view.dart';
import 'package:q_cut/modules/customer/features/settings/chat_feature/chat_with_us_view.dart';
// import 'package:q_cut/modules/customer/features/settings/presentation/views/connect_us_view.dart';
import 'package:q_cut/modules/customer/features/settings/notification_feature/view/notification_view.dart';
import 'package:q_cut/modules/customer/features/settings/presentation/views/settings_view.dart';
import 'package:q_cut/splash/views/select_services_view.dart';
import '../../splash/views/splash_view.dart';
import 'package:q_cut/splash/bindings/splash_binding.dart';
import 'package:q_cut/modules/main/binding/main_binding.dart';

abstract class AppRouter {
  // Define route names as static constants
  static const String initialPath = "/";
  static const String changeLangugesPath = "/changeLangugesPath";
  static const String selectServicesPath = "/selectServicesPath";
  static const String settingsPath = "/settingsPath";
  static const String loginPath = "/loginPath";
  static const String signUpPath = "/signUpPath";
  static const String forgetPasswordPath = "/forgetPasswordPath";
  static const String otpVerificationPath = "/otpVerificationPath";
  static const String resetPasswordPath = "/resetPasswordPath";
  static const String otpVerificationResetCasePath =
      "/otpVerificationResetCasePath";
  static const String resetPhoneNumberPath = "/resetPhoneNumberPath";
  static const String bloginPath = "/bloginPath";
  static const String bsignUpPath = "/bsignUpPath";
  static const String bforgetPasswordPath = "/bforgetPasswordPath";
  static const String botpVerificationPath = "/botpVerificationPath";
  static const String bresetPasswordPath = "/bresetPasswordPath";
  static const String botpVerificationResetCasePath =
      "/botpVerificationResetCasePath";
  static const String bresetPhoneNumberPath = "/bresetPhoneNumberPath";
  static const String updatePhoneNumberPath = "/updatePhoneNumberPath"; // Added
  static const String homPath = "/homPath";
  static const String selectedPath = "/selectedPath";
  static const String myProfilePath = "/myProfilePath";
  static const String myAppointmentPath = "/myAppointmentPath";
  static const String searchForTheTimePath = "/searchForTheTimePath";
  static const String recommendedPath = "/recommendedPath";
  static const String historyPath = "/historyPath";
  static const String conectUsPath = "/conectUsPath";
  static const String chatWithUsPath = "/chatWithUsPath";
  static const String favoritePath = "/favoritePath";
  static const String barberServicesPath = "/barberServicesPath";
  static const String qCutServicesPath = "/qCutServicesPath";
  static const String bookAppointmentPath = "/bookAppointmentPath";
  static const String bookAppointmentMoreThanOnePath =
      "/bookAppointmentMoreThanOnePath";
  static const String onHoldAppointmentPath = "/onHoldAppointmentPath";
  static const String bookAppointmentWithPaymentMethodsPath =
      "/bookAppointmentWithPaymentMethodsPath";
  static const String notificationPath = "/notificationPath";
  static const String bappointmentPath = "/bappointmentPath";
  static const String bstaticsPath = "/bstaticsPath";
  static const String bprofilePath = "/bprofilePath";
  static const String beditProfilePath = "/beditProfilePath";
  static const String imageViewPath = "/imageViewPath";
  static const String bconectUsPath = "/bconectUsPath";
  static const String bchatWithUsPath = "/bchatWithUsPath";
  static const String bdeleteAccountReasonPath = "/bdeleteAccountReasonPath";

  static const String bsettingsPath = "/bsettingsPath";
  static const String reportsPath = "/reportsPath";
  static const String bhistoryPath = "/bhistoryPath";
  static const String bbookingPath = "/bbookingPath";
  static const String bavailableAppointmentsPath =
      "/bavailableAppointmentsPath";
  static const String bpayToQCutPath = "/bpayToQCutPath";
  static const String bpaymentTimeLinePath = "/bpaymentTimeLinePath";
  static const String bpaymentMethodsPath = "/bpaymentMethodsPath";
  static const String successScreenPath = "/successScreenPath";
  static const String bottomNavigationBar = "/bottomNavigationBar";
  static const String citySelectionPath = "/citySelectionPath";
  static const String termsPath = "/termsPath"; // Added
  static const String privacyPolicyPath = "/privacyPolicyPath"; // Added

  // Define the GetPage routes
  static final List<GetPage> routes = [
    GetPage(
      name: initialPath,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: bottomNavigationBar,
      page: () => const HomeNavigationBar(),
      binding: MainBinding(),
    ),
    GetPage(
      name: selectServicesPath,
      page: () => const SelectServicesView(),
    ),
    GetPage(
      name: changeLangugesPath,
      page: () => const ChangeLangugesView(),
    ),
    GetPage(
      name: settingsPath,
      page: () => const SettingsView(),
    ),
    GetPage(
      name: loginPath,
      page: () => const LoginView(),
       binding: AuthBinding(),
    ),
    GetPage(
      name: signUpPath,
      page: () => const SignUpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: forgetPasswordPath,
      page: () => const ForgetPasswordView(),
    ),
    GetPage(
      name: otpVerificationPath,
      page: () => const OtpVerificationView(userId: ""),
    ),
    GetPage(
      name: resetPasswordPath,
      page: () => const ResetPasswordView(),
    ),
    GetPage(
      name: otpVerificationResetCasePath,
      page: () => OtpVerificationResetCaseView(),
    ),
    GetPage(
      name: updatePhoneNumberPath,
      page: () => UpdatePhoneNumberView(),
    ),
    GetPage(
      name: resetPhoneNumberPath,
      page: () => ResetPhoneNumberView(),
    ),
    //////////////////////////////
    GetPage(
      name: homPath,
      page: () => const HomeView(),
    ),
    GetPage(
      name: selectedPath,
      page: () => const SelectedView(),
    ),
    GetPage(
      name: myProfilePath,
      page: () => const MyProfileView(),
    ),
    GetPage(
      name: myAppointmentPath,
      page: () => const MyAppointmentView(),
    ),
    GetPage(
      name: searchForTheTimePath,
      page: () => const SearchForTheTimeView(),
    ),
    GetPage(
      name: recommendedPath,
      page: () => const RecommendedView(),
    ),
    GetPage(
      name: historyPath,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    // GetPage(
    //   name: conectUsPath,
    //   page: () => const ConnectUsView(),
    // ),
    GetPage(
      name: chatWithUsPath,
      page: () => const ChatWithUsView(),
    ),
    GetPage(
      name: favoritePath,
      page: () => const FavoriteView(),
    ),
    GetPage(
      name: barberServicesPath,
      page: () => BarberServicesView(),
    ),
    GetPage(
      name: qCutServicesPath,
      page: () => QCutServicesView(),
    ),
    GetPage(
      name: bookAppointmentPath,
      page: () => const BookAppointmentView(),
    ),
    GetPage(
      name: bookAppointmentWithPaymentMethodsPath,
      page: () => const BookAppointmentWithPaymentMethodsView(),
    ),
    GetPage(
      name: onHoldAppointmentPath,
      page: () => const OnHoldAppointmentView(),
    ),
    GetPage(
      name: notificationPath,
      page: () => const NotificationView(),
    ),
    GetPage(
      name: bappointmentPath,
      page: () => const BAppointmentView(),
    ),
    GetPage(
      name: bstaticsPath,
      page: () => const BStaticsView(),
    ),
    GetPage(
      name: bprofilePath,
      page: () => const BProfileView(),
    ),
    GetPage(
      name: beditProfilePath,
      page: () => const BEditProfileView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: imageViewPath,
      page: () => const ImageView(),
    ),
    GetPage(
      name: bconectUsPath,
      page: () => const BConnectUsView(),
    ),
    // GetPage(
    //   name: bchatWithUsPath,
    //   page: () => const BChatWithUsView(),
    // ),
    GetPage(
      name: bsettingsPath,
      page: () => const BSettingsView(),
    ),
    // GetPage(
    //   name: bnotificationPath,
    //   page: () => const BNotificationView(),
    // ),
    // GetPage(
    //   name: bchangeLangugesPath,
    //   page: () => const BChangeLangugesView(),
    // ),
    GetPage(
      name: reportsPath,
      page: () => const ReportsView(),
    ),
    GetPage(
      name: bhistoryPath,
      page: () => const BHistoryView(),
    ),
    GetPage(
      name: bbookingPath,
      page: () => const BBookingView(),
    ),
    GetPage(
      name: bavailableAppointmentsPath,
      page: () => const BAvailableAppointmentsView(),
    ),
    GetPage(
      name: bpayToQCutPath,
      page: () => const BPayToQCutView(),
    ),
    GetPage(
      name: bpaymentTimeLinePath,
      page: () => const BPaymentTimeLineView(),
    ),
    GetPage(
      name: bdeleteAccountReasonPath,
      page: () => const DeleteAccountReasonPage(),
    ),
    GetPage(
      name: bpaymentMethodsPath,
      page: () => const BPaymentMethodsView(),
    ),
    GetPage(
      name: bresetPhoneNumberPath,
      page: () => ResetPhoneNumberView(),
    ),
    GetPage(
      name: botpVerificationResetCasePath,
      page: () => OtpVerificationResetCaseView(),
    ),
    GetPage(
      name: successScreenPath,
      page: () => const SuccessScreen(),
    ),
    GetPage(
      name: citySelectionPath,
      page: () => const CitySelectionView(),
      binding: CityBinding(),
    ),
    GetPage(
      name: termsPath,
      page: () => const LegalDocumentsView(titleKey: "Terms and Conditions"),
    ),
    GetPage(
      name: privacyPolicyPath,
      page: () => const LegalDocumentsView(titleKey: "privacyPolicy"),
    ),
  ];
}
