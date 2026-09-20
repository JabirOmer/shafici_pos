import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/product_category_model.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/models/register_product_model.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/screens/app_layout_screens/responsive_app_layout_screen.dart';
import 'package:shafici_pos/screens/products_screen/edit_product_screen.dart';
import 'package:shafici_pos/screens/products_screen/widgets/product_details_display_widget.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:provider/provider.dart';


class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductsProvider _productsProvider;
  late UserModel _userData;
  late List<ProductCategoryModel> _categoryList;

  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final CApiServices _apiServices = CApiServices();

  bool _canEdit = false;
  bool _showEditPopup = false;
  bool _showChangeBarcodePopup = false;
  ProductModel? _newProductData;
  String? _productToBeDeletedId;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;


  // - - - - - - >>
  // - - - F U N C T I O N S 
  void _toggleShowEditPopup() {
    setState(() => _showEditPopup = !_showEditPopup);
  }

  void _showDeletePopupToggle(String? productId) {
    setState(() => _productToBeDeletedId = productId,);
  }

  Future<void> _handleUpdateSubmit(ProductModel product) async {
    _productsProvider = Provider.of<ProductsProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final  Map<String, dynamic> dataMap = RegisterProductModel(
        productBarcode: product.productBarcode.trim(), 
        productName: product.productName.trim(), 
        categoryId: product.categoryId, 
        expireDate: product.expireDate, 
        costInUsd: product.unitCostInUSD, 
        costInBirr: product.unitCost, 
        sellingPrice: product.sellingPrice, 
        onDiscountPrice: product.onDiscountPrice, 
        isTaxable: product.isTaxable,
        stockQuanity: product.stock, 
        alertQuantity: product.alertQuantity,
        productCode: product.productCode,
        batchNumber: product.batchNumber,
      ).toJson()..addAll({ "product_id": product.productId });


      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.patchRequest(url: CUrlStrings.updateProductUrl, data: dataMap, authToken: deviceToken);

      print(dataMap);

      switch (response.statusCode) {
        case 200: {
          _successMessage = response.data['msg'];
          _newProductData = product;
          _productsProvider.setProducts(onlyProducts: true);
        }

        default: {
          _errorMessage = response.data;
        }
      }
    } catch (e) {
      _errorMessage = "failed to update product's data";
    } finally {
      setState(() => _isLoading = false);
    }
  }



  void _toggleShowChangeBarcode() {
    setState(() => _showChangeBarcodePopup = !_showChangeBarcodePopup,);
  }



  // - - - 
  Future<void> _generateCustomBarcode() async {
    if (_isLoading) return;
    _toggleShowChangeBarcode();

    setState(() => _isLoading = true,);
    try {
      final dataMap = {
        'product_id': widget.product.productId
      };

      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.patchRequest(url: CUrlStrings.setNewBarcodeUrl, data: dataMap, authToken: deviceToken);

      switch (response.statusCode) {
        case 200: _successMessage = response.data['msg'];
        default: _errorMessage = response.data;
      }
    } 
    catch (e) {
      _errorMessage = 'Failed to change barcode';
    }
    finally {
      setState(() => _isLoading = false,);
    }
  }


  // - - - Delete Product
  Future<void> _handleProductDelete() async {    
    final productId = _productToBeDeletedId;
    if (productId == null) return;

    _productsProvider = Provider.of<ProductsProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _productToBeDeletedId = null;
    });

    try {
      final dataMap = { "product_id": productId };
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.patchRequest(url: CUrlStrings.deleteProductUrl, data: dataMap, authToken: deviceToken);
      if (!mounted) return;

      switch (response.statusCode) {
        case 200: {
          _successMessage = response.data['msg'];
          _productsProvider.setProducts();
        }

        default: _errorMessage = response.data;
      }
    } catch (e) {
      _errorMessage = "failed to delete product";
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _closeSuccessPopup() {
    setState(() {
      _successMessage = null;
      _showEditPopup = false;
    });
    _handleBack();
  }

  void _closeErrorPopup() {
    setState(() => _errorMessage = null,);
  }

  void _handleBack() {
    Navigator.canPop(context) ? Navigator.pop(context) : CHelperFunctions.navigateToScreen(
      context: context, screen: ResponsiveAppLayoutScreen(), replacement: true
    );
  }
  // - - - F U N C T I O N S
  // - - - - - - >>

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appInfoProvider = Provider.of<AppInfoProvider>(context, listen: false);
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);

    _userData = appInfoProvider.currentUser!;
    _categoryList = productsProvider.productCategoryList;
    final UserModel userData = appInfoProvider.currentUser!;
    setState(() => _canEdit = userData.canEditInventory);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
      
          // - - - P R O D U C T _ D E T A I L S _ D I S P L A Y
          ProductDetailsDisplayWidget(
            initialProduct: widget.product, 
            newData: _newProductData,
            userData: _userData, 
            canEdit: _canEdit,
            onEditClick: _toggleShowEditPopup,
            onDeleteClick: (productId) => _showDeletePopupToggle(productId), 
            onBackClick: _handleBack,
            onNewBarcodeClick: _toggleShowChangeBarcode,
          ),
      
      
          // - - - E D I T _ P O P U P
          if (_showEditPopup) EditProductScreen(
            product: _newProductData ?? widget.product,
            categoryList: _categoryList,
            isBasedOnUSD: widget.product.unitCostInUSD != null,
            onChangeSend: (newProduct) => _handleUpdateSubmit(newProduct),
            onBackClick: _toggleShowEditPopup,
          ),
      
      
          // - - - C H A N G E _ B A R C O D E _ P O P U P
          if (_showChangeBarcodePopup) UiPopupWidget(
          message: 'Do you want to generate custom barcode', 
          primaryText: 'yes', 
          primaryClick: _generateCustomBarcode, 
          secondaryText: 'cancel',
          secondaryClick: _toggleShowChangeBarcode,
          outSideClick: _toggleShowChangeBarcode
        ),

          // - - - S U C C E S S _ P O P U P
          if (_successMessage != null) UiPopupWidget(
            isSuccess: true,
            message: _successMessage!, 
            primaryText: 'ok', 
            primaryClick: _closeSuccessPopup, 
            outSideClick: _closeSuccessPopup
          ),
          
          
          // - - - E R R O R _ P O P U P
          if (_errorMessage != null) UiPopupWidget(
            message: _errorMessage!, 
            primaryText: 'try again', 
            primaryClick: _closeErrorPopup, 
            outSideClick: _closeErrorPopup
          ),


          // // - - - D E L E T E _ P O P U P
          // if (_productToBeDeletedId != null) UiPopupWidget(
          //   message: "this action can't be undone !", 
          //   primaryText: 'continue', 
          //   primaryClick: _handleProductDelete, 
          //   secondaryText: 'back',
          //   secondaryClick: () => _showDeletePopupToggle(null),
          //   outSideClick: () => _showDeletePopupToggle(null),
          // ),


          // - - - L O A D I N G
          if (_isLoading) UiLoadingScreenWidget(
            fullScreen: true,
            transparent: true,
          )
        ],
      ),
    );
  }




  // - - - - - -
  // - - - M E T H O D S
  // - - - - - -




  // - - - E D I T _ P R O D U C T _ P O P U P
  // Scaffold _editProductPopup({
  //   required String name,
  //   required EditPopupType editType,
  //   required TextEditingController controller,
  //   required void Function(TextEditingController controller) onBackClick,
  //   required void Function() onSubmitChangeClick,
  // }) {
  //   return Scaffold(
  //     backgroundColor: CColors.dimmedBackgound,
  //     body: GestureDetector(
  //       onTap: () => onBackClick(controller),
  //       child: BackdropFilter(
  //         filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Center(
  //               child: ConstrainedBox(
  //                 constraints: BoxConstraints(maxWidth: 600),
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     color: CColors.white,
  //                     borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
  //                   ),
  //                   padding: EdgeInsets.all(CSizes.largeGap),
  //                   margin: EdgeInsets.all(CSizes.largeGap),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     crossAxisAlignment: CrossAxisAlignment.stretch,
  //                     children: [
  //                       UiTitleWidget(
  //                         text: 'edit $name',
  //                         capitalizeWords: true,
  //                         bigger: true,
  //                         textAlign: TextAlign.center,
  //                       ),
                              
  //                       SizedBox(height: CSizes.largeGap,),
                              
  //                       UiTextFieldWidget(
  //                         textController: _productNameController,
  //                         label: name,
                          
  //                         validator: (value) => _validateProductName(value),
  //                       ),

  //                       SizedBox(height: CSizes.largeGap,),

  //                       Row(
  //                         children: [
  //                           Expanded(
  //                             child: UiButtonWidget(
  //                               text: 'back',
  //                               tranparent: true,
  //                               onClick: () => onBackClick(controller),
  //                             )
  //                           ),

  //                           SizedBox(width: CSizes.mediumGap,),

  //                           Expanded(
  //                             child: UiButtonWidget(
  //                               text: 'submit',
  //                               onClick: onSubmitChangeClick
  //                             )
  //                           )
  //                         ],
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}


// if (editType == EditPopupType.dropDown) UiDropDownWidget(
//                           value: _selectedCategory?.categoryName, 
//                           hint: 'select category', 
//                           items: ProductCategoryModel.toDropDownMap(_productsProvider.productCategoryList), 
//                           openDropDown: true, 
//                           dropDownClick: () {}, 
//                           optionClick: (key) => _handleCategoryChange(key),
//                         )
//                         else 