import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shafici_pos/constants/shadows.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/product_category_model.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class PosProductsDisplayWidget extends StatefulWidget {
  final List<ProductCategoryModel> categories;
  final List<ProductModel> products;
  final void Function() onRefresh;
  final void Function(ProductModel product) onProductClick;
  final void Function(ProductModel product) onAddToCartClick;

  const PosProductsDisplayWidget({
    super.key,
    required this.categories,
    required this.products,
    required this.onRefresh,
    required this.onProductClick,
    required this.onAddToCartClick,
  });

  @override
  State<PosProductsDisplayWidget> createState() => _PosProductsDisplayWidgetState();
}

class _PosProductsDisplayWidgetState extends State<PosProductsDisplayWidget> {
  late ProductsProvider _productsProvider;
  // final _searchNameController = TextEditingController();
  // final _searchBarcodeController = TextEditingController();
  final _searchController = TextEditingController();
  final _scanBarcodeController = TextEditingController();
  late List<ProductModel> _filteredProductList;
  ProductCategoryModel? _selectedCategory;
  bool _scanTime = false;
  final FocusNode _scannerfocus = FocusNode();
  String? _scanError;

  
  @override
  void initState() {
    super.initState();
    _filteredProductList = widget.products;
    _selectedCategory = null;
  }

  
  // void _handleNameSearch(String value) {
  //   setState(() {
  //     _searchBarcodeController.clear();
  //     _selectedCategory = null;
  //     _filteredProductList = widget.products.where((p) => p.productName.toLowerCase().contains(value.toLowerCase())).toList();
  //   });
  // }

  // void _handleBarcodeSearch(String value) {
  //   setState(() {
  //     _searchNameController.clear();
  //     _selectedCategory = null;
  //     _filteredProductList = widget.products.where((p) => p.productBarcode.toLowerCase().contains(value.toLowerCase())).toList();
  //   });
  // }

        // (r) => r.toLowerCase().contains(value.toLowerCase()) 
  void _handleSearch(String value) {
    final products = widget.products.where(
      (p) => [p.productName, p.productBarcode, p.batchNumber].any(
        (r) => r != null && r.toLowerCase().contains(value.toLowerCase())
      )
    ).toList();

    setState(() {
      _selectedCategory = null;
      _filteredProductList = products;
    });
  }

  void _handleSearchErase() {
    setState(() {
      _searchController.clear();
      _filteredProductList = widget.products;
    });
  }

  void _handleScanToggle() {
    setState(() {
      _scanTime = !_scanTime;
      _scannerfocus.hasFocus ? _scannerfocus.unfocus() : _scannerfocus.requestFocus();
      _searchController.clear();
      _scanBarcodeController.clear();
      _scanError = null;
    });
    _handleSearchErase();
  }

  Future<void> _handleScanSubmit(String? value) async {
    if (value == null) return;
    _productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final ProductModel? product = _productsProvider.productList.firstWhereOrNull((p) => p.productBarcode == value);
    if (product == null) {
      _scanError = '$value: is not founded';
    } else {
      widget.onAddToCartClick(product);
    }
    setState(() {
      _scanBarcodeController.clear();
      _scannerfocus.requestFocus();
    });
    if (_scanError != null) {
      await Future.delayed(Duration(seconds: 2));
      setState(() => _scanError = null,);
    }
  }

  void _onScanChange() {
    if (_scanError != null) {
      setState(() => _scanError = null,);
    }
  }

  void _changeCategoty(ProductCategoryModel? category) {
    setState(() {
      _selectedCategory = category;
      _filteredProductList = category == null ? widget.products : widget.products.where((p) => p.categoryId == category.categoryId).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    final productsProvider = context.watch<ProductsProvider>();

    if (productsProvider.orderSessions.isEmpty) {
      productsProvider.createOrderSession();
    }

    return LayoutBuilder(
      builder: (context, constraints) {

        int crossAxisCount() {
          if (constraints.maxWidth < 800) {
            return 2;
          }
          else if (constraints.maxWidth < 1000) {
            return 3;
          }
          else if (constraints.maxWidth < 1200) {
            return 4;
          } else if (constraints.maxWidth < 1400) {
            return 5;
          } else {
            return 5;
          }
        }

        return Stack(
          children: [
            // - - - M A I N _ D I S P L A Y
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: CSizes.largeGap,),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CSizes.largeGap),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      UiTitleWidget(
                        text: 'POS - Screen',
                        defaultText: true,
                        capitalizeWords: true,
                        bigger: true,
                      ),
                  
                      SizedBox(height: CSizes.largeGap,),
                    
                      // Top Section
                      topSectionMethod(),
                      
                      // Categories
                      if ( widget.categories.isNotEmpty && _searchController.text.isEmpty ) categoriesMethod(),
                          
                      SizedBox(height: CSizes.largeGap,),
                  
                      // Products
                      if (_filteredProductList.isEmpty) UiNoDataFounded(
                      title: 'no products are founded',
                      buttonText: 'search again',
                      onButtonClick: widget.onRefresh,
                      ),
                    ],
                  ),
                ),
            
            
                Expanded(
                  child: _filteredProductList.isNotEmpty ? productsMethod(crossAxisCount) : SizedBox(),
                )
            
                // Expanded(
                //   child: SingleChildScrollView(
                //     child: Column(
                //       children: [
                //         if (_filteredProductList.isNotEmpty) productsMethod(crossAxisCount),
                //         SizedBox(height: CSizes.largeGap,),
                //       ],
                //     ),
                //   ),
                // )
                
            
            
            
              ],
            ),
        
            // - - - S C A N N E R
            if (_scanTime) scannerMethod()
          ],
        );
      } 
    );
  }





  // - - - M E T H O D S - - - -





  // Method 1.0
  SingleChildScrollView topSectionMethod() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: AlwaysScrollableScrollPhysics(),
        child: Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300),
              child: UiTextFieldWidget(
                textController: _searchController, 
                keyboardType: TextInputType.text,
                label: 'search name, barcode or brand',
                onChange: (value) => _handleSearch(value),
              ),
            ),
                    
            if (_searchController.text.isNotEmpty) Row(
              children: [
                SizedBox(width: CSizes.mediumGap,),
                    
                UiButtonWidget(
                  icon: CIcons.eraseIcon,
                  onClick: _handleSearchErase,
                  horizontalPadding: CSizes.smallGap,
                  vericalPadding: CSizes.smallGap,
                )
              ],
            ),
                    
            SizedBox(width: CSizes.mediumGap,),
                    
            UiButtonWidget(
              icon: CIcons.scanIcon,
              onClick: _handleScanToggle,
              tranparent: !_scanTime,
              horizontalPadding: CSizes.smallGap,
              vericalPadding: CSizes.smallGap,
            ),
            
            SizedBox(width: CSizes.mediumGap,),
                
            UiButtonWidget(
              icon: CIcons.refreshIcon,
              onClick: widget.onRefresh,
              tranparent: true,
              horizontalPadding: CSizes.smallGap,
              vericalPadding: CSizes.smallGap,
            ),
          ],
        ),
      );
  }





  // Method 2.0
  Column categoriesMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: CSizes.largeGap,),

        UiTitleWidget(
          text: 'categories',
          color: CColors.whiteShade3,
          bold: false,
        ),

        SizedBox(height: CSizes.smallGap,),

        SizedBox(
          height: 40,
          child: ListView(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: [
              categoryDisplayMethod(category: null),
              
              ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => categoryDisplayMethod(category: widget.categories[index]), 
                separatorBuilder: (context, index) => SizedBox(width: 0,), 
                itemCount: widget.categories.length
              ),
            ],
          ),
        ),
      ],
    );
  }

  MouseRegion categoryDisplayMethod({
    required ProductCategoryModel? category
  }) {
    return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _changeCategoty(category),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: CColors.white,
                  border: Border(
                    bottom: BorderSide(width: 2, color: _selectedCategory == category ? CColors.primaryColor : CColors.transparent)
                  ),
                  // borderRadius: BorderRadius.circular(CSizes.smallRadius+10) 
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: CSizes.mediumGap,
                  vertical: 0
                ),
                child: Center(
                  child: Text(
                    CHelperFunctions.capitalize(category?.categoryName ?? 'all')
                  ),
                ),
              ),
            ),
          );
  }





  // Method 3.0
  AlignedGridView productsMethod(int Function() crossAxisCount) {
    _productsProvider = Provider.of<ProductsProvider>(context);

    return AlignedGridView.count(
      padding: EdgeInsets.only(
        left: CSizes.largeGap,
        right: CSizes.largeGap,
        bottom: CSizes.largeGap,
      ),
      crossAxisCount: crossAxisCount(),
      crossAxisSpacing: CSizes.mediumGap,
      mainAxisSpacing: CSizes.mediumGap, 
      itemCount: _filteredProductList.length,
      itemBuilder: (context, index) {
        final product = _filteredProductList[index];
        final bool isInCart = _productsProvider.activeSessionData?.items.any(
          (item) => item.productId == product.productId,
        ) ?? false;
        
        return GestureDetector(
          onTap: () => widget.onProductClick(product),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
              color: CColors.white,
              boxShadow: CShadows.shadow1
            ),
            padding: EdgeInsets.symmetric(
              vertical: CSizes.mediumGap,
              horizontal: CSizes.mediumGap
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Name
                // Text(
                //   CHelperFunctions.capitalizeWords('Brand: ${product.productCode}'),
                //   maxLines: 1,
                // ),

                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: CColors.whiteShade1,
                        borderRadius: BorderRadius.circular(CSizes.smallRadius)
                      ),
                      padding: EdgeInsets.all(4),
                      child: UiTitleWidget(
                        text: CHelperFunctions.capitalizeWords(product.batchNumber != null ? 'B#: ${product.batchNumber}' : 'no-batch'),
                        bold: false,
                        customSize: 12,
                        defaultText: true,
                      ),
                    ),

                    SizedBox(width: CSizes.mediumGap,),

                    Expanded(
                      child: Text(
                        product.productBarcode,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12
                        ),
                      ),
                    )
                  ],
                ),

                SizedBox(height: CSizes.largeGap,),

                Text(
                  CHelperFunctions.capitalizeWords(product.productName),
                  maxLines: 1,
                  style: TextStyle(
                    // fontWeight: FontWeight.w700
                  ),
                ),

                if (product.productCode != null) Text(
                    CHelperFunctions.capitalizeWords(product.productCode!),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      color: CColors.whiteShade3
                    ),
                  ),

                  SizedBox(height: CSizes.smallGap,),
              

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    if (product.expireDate != null) Text(
                      CHelperFunctions.formatDateTime(product.expireDate!),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        color: CColors.whiteShade3
                      ),
                    ),
                    if (product.expireDate == null) Text('No expire date'),

                    Text(
                      CHelperFunctions.formatNumberWithComma(product.stock),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        color: CColors.whiteShade3
                      ),
                    ),
                  ],
                ),

                // SizedBox(height: CSizes.mediumGap,),

                Divider( color: CColors.whiteShade2, height: CSizes.largeGap, ),
                
                // Selling Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${CHelperFunctions.formatNumberWithComma(
                        product.sellingPrice, 
                        addDecimal: false
                      )} Birr'
                    ),
                      
                    UiButtonWidget(
                      icon: CIcons.bagIcon,
                      onClick: () => widget.onAddToCartClick(product),
                      horizontalPadding: CSizes.smallGap,
                      vericalPadding: CSizes.smallGap,
                      tranparent: !isInCart,
                      borderRaduis: CSizes.largeRadius,
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }





  // Method 4.0
  ClipRRect scannerMethod() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
        child: Container(
          width: double.maxFinite,
          color: CColors.dimmedBackgound,
          padding: EdgeInsets.all(CSizes.largeGap),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
    
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Container(
                  decoration: BoxDecoration(
                    color: CColors.white,
                    borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                  ),
                  padding: EdgeInsets.all(CSizes.largeGap),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      UiTitleWidget(text: 'barcode scanner'),
    
                      SizedBox(height: CSizes.largeGap,),
    
                      UiTextFieldWidget(
                        textController: _scanBarcodeController, 
                        keyboardType: TextInputType.text,
                        focusNode: _scannerfocus,
                        label: 'scan the barcode',
                        onChange: (value) => _onScanChange(),
                        fieldSubmit: (value) => _handleScanSubmit(value),
                      ),

                      AnimatedContainer(
                        duration: Duration(milliseconds: 150),
                        height: _scanError != null ? 40 : 0,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
                          color: CColors.redDimmed
                        ),
                        padding: EdgeInsets.symmetric(horizontal: CSizes.mediumGap),
                        margin: EdgeInsets.only(top: _scanError == null ? 0 : CSizes.largeGap),
                        child: Center(
                          child: Text(
                            _scanError ?? '',
                            style: TextStyle(
                              color: CColors.white
                            ),
                          ),
                        ),
                      ),
    
                      SizedBox(height: CSizes.largeGap,),
    
                      UiButtonWidget(
                        text: 'back',
                        onClick: _handleScanToggle,
                        // tranparent: true,
                      )
                    ],
                  ),
                ),
              )
    
            ],
          ),
        ),
      ),
    );
  }
}