import 'package:flutter/widgets.dart';

class AppRouteModel {
  final String routeName;
  final String routeIcon;
  final Widget element;
  // final List<String> roles;

  AppRouteModel({
    required this.routeName,
    required this.routeIcon,
    required this.element,
    // required this.roles,
  });
}