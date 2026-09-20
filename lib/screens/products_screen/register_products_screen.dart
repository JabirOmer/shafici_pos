import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/register_product_message_model.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/screens/app_layout_screens/responsive_app_layout_screen.dart';
import 'package:shafici_pos/screens/products_screen/widgets/bulk_products_register_widget.dart';
import 'package:shafici_pos/screens/products_screen/widgets/single_product_register_widget.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_register_product_message_widget.dart';
import 'package:provider/provider.dart';

enum RegisterProductType { single, bulk }

class RegisterProductsScreen extends StatefulWidget {
  const RegisterProductsScreen({super.key});

  @override
  State<RegisterProductsScreen> createState() => _RegisterProductsScreenState();
}

class _RegisterProductsScreenState extends State<RegisterProductsScreen> {
  late ProductsProvider _productsProvider;
  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final CApiServices _apiServices = CApiServices();
  
  RegisterProductType _registerProductType = RegisterProductType.single;

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;
  RegisterProductMessageModel? _registerMessage;


  // - - - - - - >>
  // - - - F U N C T I O N S

  void _handleTypeChange(RegisterProductType type) {
    setState(() {
      _registerProductType = type;
    });
  }

  
  Future<void> _handleProductSubmit(Map<String, dynamic> productDataMap) async {
    print('object');
    _productsProvider = Provider.of(context, listen: false);
    setState(() {
      _isLoading = true;
      _successMessage = null;
      _errorMessage = null;
    });

    try {
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.postRequest(url: CUrlStrings.registerProductUrl, data: productDataMap, authToken: deviceToken);

      switch (response.statusCode) {
        case 201: {
          _successMessage = response.data['msg'];
          await _productsProvider.setProducts();
        }

        default: _errorMessage = response.data;
      }
    } catch (e) {
      _errorMessage = 'Failed to register product';
    } finally {
      setState(() => _isLoading = false,);
    }
  }



  Future<void> _handleBulkSubmit(PlatformFile file, String sheetName) async {}
  //   _productsProvider = Provider.of(context, listen: false);
  //   setState(() {
  //     _isLoading = true;
  //     _successMessage = null;
  //     _errorMessage = null;
  //   });

  //   try {
  //     MultipartFile multipartFile;

  //     if (file.path != null) {
  //       multipartFile = await MultipartFile.fromFile(
  //         file.path!,
  //         filename: file.name
  //       );
  //     } else {
  //       _errorMessage = 'no file is selected';
  //       return;
  //     }

  //     final FormData formData = FormData.fromMap({
  //       "file": multipartFile,
  //       "sheet_name": sheetName
  //     });

  //     final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
  //     final response = await _apiServices.postRequest(url: CUrlStrings.registerBulkProductsUrl, formData: formData, data: {}, authToken: deviceToken);
  //     // final response = await _apiServices.postRequest(url: 'http://localhost:5500/products/register-bulk', formData: formData, data: {}, authToken: deviceToken);

  //     switch(response.statusCode) {
  //       case 201: {
  //         final Map<String, dynamic> message = response.data;
  //         _registerMessage = RegisterProductMessageModel.fromMap(message);
  //         _productsProvider.setProducts();
  //       }

  //       default: _errorMessage = response.data;
  //     }

  //   } catch (e) {
  //     _errorMessage = 'failed to register bulk products';
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }


  void _handleBack() {
    Navigator.canPop(context) ? Navigator.pop(context) : 
    CHelperFunctions.navigateToScreen(context: context, screen: ResponsiveAppLayoutScreen(), replacement: true);
  }

  @override
  Widget build(BuildContext context) {
    _productsProvider = Provider.of(context, listen: false);    
    
    return Scaffold(
      body: Stack(
        children: [
          // - - - S I N G L E _ P R O D U C T _ R E G I S T E R
          if (_registerProductType == RegisterProductType.single) SingleProductRegisterWidget(
            categoryList: _productsProvider.productCategoryList,
            onSubmit: (productMap) => _handleProductSubmit(productMap),
            onBulkClick: (type) => _handleTypeChange(type),
            onBack: _handleBack,
          ),


          // - - - B U L K _ P R O D U C T _ R E G I S T E R
          if (_registerProductType == RegisterProductType.bulk) BulkProductsRegisterWidget(
            onSingleClick: (type) => _handleTypeChange(type),
            onSubmit: (file, sheetName) => _handleBulkSubmit(file, sheetName),
            onBackClick: _handleBack,
          ),


          // - - - M E S S A G E _ P O P U P
          if (_registerMessage != null) UiRegisterProductMessageWidget(
            message: _registerMessage!,
            onCancel: () => setState(() => _registerMessage = null),
          ),

          
          // - - - S U C C E S S _ P O P U P
          if (_successMessage != null) UiPopupWidget(
            isSuccess: true,
            message: _successMessage!, 
            primaryText: 'ok', 
            primaryClick: () => setState(() => _successMessage = null,), 
            outSideClick: () => setState(() => _successMessage = null,)
          ),


          // - - - E R R O R _ P O P U P
          if (_errorMessage != null) UiPopupWidget(
            message: _errorMessage!, 
            primaryText: 'try again', 
            primaryClick: () => setState(() => _errorMessage = null,), 
            outSideClick: () => setState(() => _errorMessage = null,)
          ),


          // - - - L O A D I N G
          if (_isLoading) UiLoadingScreenWidget(
            fullScreen: true,
            transparent: true,
          )

        ],
      ),
    );
  }
}