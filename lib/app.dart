import 'package:flutter/material.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/app_routes_provider.dart';
import 'package:shafici_pos/providers/payments_provider.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/providers/sales_provider.dart';
import 'package:shafici_pos/providers/users_provider.dart';
import 'package:shafici_pos/screens/app_layout_screens/responsive_app_layout_screen.dart';
import 'package:shafici_pos/screens/device_verify/verify_device_screen.dart';
import 'package:shafici_pos/screens/login_screens/login_screen.dart';
import 'package:shafici_pos/themes/app_theme.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appInfoProvider = Provider.of<AppInfoProvider>(context, listen: false);
      final appRoutesProvider = Provider.of<AppRoutesProvider>(context, listen: false);
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      final paymentMethodsProvider = Provider.of<PaymentMethodsProvider>(context, listen: false);
      final usersProvider = Provider.of<UsersProvider>(context, listen: false);
      final salesProvider = Provider.of<SalesProvider>(context, listen: false);

      // set default shared_prefs
      await appInfoProvider.setDafultPrefs();

      // reset active app route
      appRoutesProvider.changeActiveRouteIndex(0);

      // get user info
      await appInfoProvider.getAuthStatusEnum();

      // set products and categories
      productsProvider.setProducts();

      // set payment methods
      paymentMethodsProvider.setPaymentMethods();

      // set users data
      usersProvider.setUsers();

      // get online orders
      salesProvider.fetchOnlineSales();
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CAppTheme.lightMode,

      debugShowCheckedModeBanner: false,

      home: Consumer<AppInfoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return UiLoadingScreenWidget(fullScreen: true,);
          }
          
          if (provider.authStatusEnum == AuthStatusEnum.home) {
            return ResponsiveAppLayoutScreen();
          }
          else if (provider.authStatusEnum == AuthStatusEnum.unVerified) {
            return VerifyDeviceScreen();
          } 
          else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}