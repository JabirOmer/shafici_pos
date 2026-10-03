import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shafici_pos/app.dart';
import 'package:shafici_pos/blocs/cubits/credit_cubit.dart';
import 'package:shafici_pos/blocs/cubits/customer_cubit.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/hive_strings.dart';
import 'package:shafici_pos/models/order_calculation_model.dart';
import 'package:shafici_pos/models/order_data_model.dart';
import 'package:shafici_pos/models/order_item_model.dart';
import 'package:shafici_pos/models/order_payment_model.dart';
import 'package:shafici_pos/models/order_session_model.dart';
import 'package:shafici_pos/models/payment_method_model.dart';
import 'package:shafici_pos/models/product_category_model.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/models/sale_data_model.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/app_routes_provider.dart';
import 'package:shafici_pos/providers/payments_provider.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/providers/sales_provider.dart';
import 'package:shafici_pos/providers/users_provider.dart';
import 'package:shafici_pos/providers/web_socket_server_provider.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/services/shared_preferences_services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // - - - I N I T I A L I Z E _ H I V E
  await Hive.initFlutter();

  // - - - I N I T I A L I Z E _ S H A R E D _ P R E F E R E N C E S
  await CSharedPreferencesServices.init();

  // - - - R E G I S T E R _ H I V E _ A D A P T E R S
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(ProductCategoryModelAdapter());
  Hive.registerAdapter(PaymentMethodModelAdapter());
  Hive.registerAdapter(OrderDataModelAdapter());
  Hive.registerAdapter(OrderItemModelAdapter());
  Hive.registerAdapter(OrderCalculationModelAdapter());
  Hive.registerAdapter(OrderPaymentModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(OrderSessionModelAdapter());
  Hive.registerAdapter(SaleDataModelAdapter());


  // - - - O P E N _ H I V E _ B O X E S
  await safeOpenBox<ProductModel>(CHiveStrings.productsBox);
  await safeOpenBox<ProductCategoryModel>(CHiveStrings.productCategoriesBox);
  await safeOpenBox<OrderSessionModel>(CHiveStrings.orderSessionsBox);
  await safeOpenBox<PaymentMethodModel>(CHiveStrings.paymentMethodsBox);
  await safeOpenBox<UserModel>(CHiveStrings.usersBox);
  await safeOpenBox<SaleDataModel>(CHiveStrings.offlineSalesBox);

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky, // hides status & nav bars
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: CColors.primaryColor,
      statusBarIconBrightness: Brightness.light
    )
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => AppInfoProvider()),

        ChangeNotifierProvider(create: (context) => WebSocketServerProvider()),

        ChangeNotifierProvider(create: (_) => AppRoutesProvider()),
        ChangeNotifierProvider(create: (_) => PaymentMethodsProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),

        ChangeNotifierProvider(create: (context) => ProductsProvider(
          webSocketServerProvider: context.read<WebSocketServerProvider>()
        )),

        ChangeNotifierProvider( create: (context) => AppInfoProvider(
          productsProvider: context.read<ProductsProvider>()
        )),

        ChangeNotifierProvider(create: (context) => SalesProvider(
          appInfoProvider: context.read<AppInfoProvider>()
        )),
      ],
      // child: App(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (c) => CreditCubit(appInfoProvider: c.read<AppInfoProvider>())),
          BlocProvider(create: (c) => CustomerCubit(appInfoProvider: c.read<AppInfoProvider>()))
        ], 
        child: App()
      ),
    )
  );
}

  // runApp(MaterialApp(
  //   home: Scaffold(),
  // ));


Future<Box<T>> safeOpenBox<T>(String boxName) async {
  try {
    return await Hive.openBox<T>(boxName);
  } catch (e) {
    debugPrint('Hive box "$boxName" failed to open ($e) — resetting it.');
    await Hive.deleteBoxFromDisk(boxName);
    return await Hive.openBox<T>(boxName);
  }
}


Future<void> _clearAllLocalData() async {
  final hiveBoxNameList = [
    CHiveStrings.productsBox,
    CHiveStrings.productCategoriesBox,
    CHiveStrings.paymentMethodsBox,
    CHiveStrings.offlineSalesBox,
    CHiveStrings.orderSessionsBox,
    CHiveStrings.usersBox,
  ];
  for (var boxName in hiveBoxNameList) { await Hive.deleteBoxFromDisk(boxName); }

  await CSecureStorageService().deleteAll();
  await CSharedPreferencesServices().clear();
}