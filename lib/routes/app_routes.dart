import 'package:flutter/material.dart';
import '../pages/MainShell_Page.dart';
import '../pages/register_page.dart';
import '../pages/history_page.dart';
import '../pages/login_page.dart';



class AppRoutes {
  static const String home = "/";
  static const String login = "/login";

  static const String register = "/register";
  static const String history = "/history";

  static Map<String, WidgetBuilder> routes = {

    home: (context) => MainShell(),
    register: (context) => RegisterPage(),
    history: (context) => HistoryPage(),
  };
}