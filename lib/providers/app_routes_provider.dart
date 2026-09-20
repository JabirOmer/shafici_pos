import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/models/app_route_model.dart';
import 'package:shafici_pos/screens/categories_screen/categories_screen.dart';
import 'package:shafici_pos/screens/point_of_sale/point_of_sale_screen.dart';
import 'package:shafici_pos/screens/settings_screen/settings_screen.dart';
import 'package:shafici_pos/screens/payments_screen/payments_screen.dart';
import 'package:shafici_pos/screens/products_screen/products_screen.dart';
import 'package:shafici_pos/screens/users_screen/users_screen.dart';
import 'package:shafici_pos/screens/sales_screen/sales_history_screen.dart';

class AppRoutesProvider extends ChangeNotifier {
  final List<AppRouteModel> _appRoutes = [
    // AppRouteModel(
    //   routeName: 'orders', routeIcon: CIcons.notificationIcon, 
    //   element: OrdersScreen(), roles: ['cashier', 'admin']
    // ),
    AppRouteModel(
      routeName: 'POS', 
      routeIcon: CIcons.bagIcon, 
      element: PointOfSaleScreen()
    ),
    AppRouteModel(
      routeName: 'Sales history', 
      routeIcon: CIcons.clockIcon, 
      element: SalesHistoryScreen() 
    ),
    // AppRouteModel(
    //   routeName: 'Users', 
    //   routeIcon: CIcons.profileIcon, 
    //   element: UsersScreen()
    // ),
    AppRouteModel(
      routeName: 'Products', 
      routeIcon: CIcons.shopIcon, 
      element: ProductsScreen()
    ),
    AppRouteModel(
      routeName: 'Categories', 
      routeIcon: CIcons.gridIcon, 
      element: CategoriesScreen()
    ),
    AppRouteModel(
      routeName: 'Payments', 
      routeIcon: CIcons.walletIcon, 
      element: PaymentsScreen()
    ),

    AppRouteModel(
      routeName: 'Settings', 
      routeIcon: CIcons.settingIcon, 
      element: SettingsScreen()
    ),
  ];

  int _activeRouteIndex = 10;
  int get activeRouteIndex => (_activeRouteIndex <= _appRoutes.length+1) ? _activeRouteIndex : 0;
  List<AppRouteModel> get appRoutes => _appRoutes;

  void changeActiveRouteIndex(int index) {
    _activeRouteIndex = index;
    notifyListeners();
  }

}