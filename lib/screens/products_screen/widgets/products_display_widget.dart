import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/shadows.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/data_tables/products_data_table.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/screens/products_screen/register_products_screen.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:provider/provider.dart';

class ProductsDisplayWidget extends StatefulWidget {
  final List<ProductModel> products;

  const ProductsDisplayWidget({
    super.key,
    required this.products,
  });

  @override
  State<ProductsDisplayWidget> createState() => _ProductsDisplayWidgetState();
}

class _ProductsDisplayWidgetState extends State<ProductsDisplayWidget> {
  bool _canEdit = false;
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _filteredProductList = [];
  String? _overviewTitle;
  List<ProductModel>? _overviewProducts;

  // - - - - - - >>
  // - - - F U N C T I O N S
  void _onRegisterClick() {
    CHelperFunctions.navigateToScreen(
      context: context, screen: RegisterProductsScreen()
    );
  }
  void _refreshData() {
    final ProductsProvider productsProvider = Provider.of(context, listen: false);
    productsProvider.setProducts();
  }
  
  void _handleSearch(String value) {
    // final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    // _filteredProductList.clear();    
    // if (value != null) {
    //   _filteredProductList.addAll(
    //     productsProvider.productList.where(
    //       (p) => [p.productName, p.productBarcode].any((v) => v.toLowerCase().contains(value.toLowerCase()))
    //     )
    //   );
    // }
    // setState(() {});

    final products = widget.products.where(
      (p) => [p.productName, p.productBarcode, p.productCode].any(
        (r) => r != null && r.toLowerCase().contains(value.toLowerCase())
      )
    ).toList();

    setState(() {
      _filteredProductList = products;
    });
  }

  void _handleSearchReset() {
    setState(() {
      _filteredProductList.clear();
      _searchController.clear();
    });
  }

  void _handleOverviewClick(String? title, List<ProductModel>? list) {
    setState(() {
      _overviewTitle = title;
      _overviewProducts = list;
    });
  }

  // - - - F U N C T I O N S
  // - - - - - - >>

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final AppInfoProvider appInfoProvider = Provider.of(context, listen: false);
    final UserModel userData = appInfoProvider.currentUser!;
    setState(() => _canEdit = userData.canEditInventory);
  }

  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [

        // - - - T O P _ S E C T I O N
        SliverToBoxAdapter(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300),
                      child: UiTextFieldWidget(
                        label: 'Search Name or Barcode',
                        defaultLabel: true,
                        textController: _searchController,
                        onChange: (value) => _handleSearch(value),
                      ),
                    ),
          
                    if (_searchController.text.isNotEmpty) Container(
                      margin: EdgeInsets.only(left: CSizes.mediumGap),
                      child: UiButtonWidget(
                        icon: CIcons.eraseIcon,
                        vericalPadding: CSizes.smallGap,
                        horizontalPadding: CSizes.smallGap,
                        onClick: _handleSearchReset,
                      ),
                    ),
          
                    SizedBox(width: CSizes.mediumGap,),
                
                    UiButtonWidget(
                      icon: CIcons.refreshIcon,
                      vericalPadding: CSizes.smallGap,
                      horizontalPadding: CSizes.smallGap,
                      tranparent: true,
                      // borderColor: CColors.whiteShade3,
                      onClick: _refreshData
                    )
                  ],
                ),
          
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    UiButtonWidget(
                      text: 'register product',
                      icon: CIcons.addIcon, 
                      vericalPadding: CSizes.smallGap,
                      onClick: _onRegisterClick,
                      isDisabled: !_canEdit,
                    ), 
                  ],
                ),
              ],
            ),
          ),
        ),

        
        SliverToBoxAdapter(
          child: SizedBox(height: CSizes.largeGap,)
        ),


        // - - - P R O D U C T S _ O V E R V I E W
        SliverToBoxAdapter(
          child: Consumer<ProductsProvider>(
            builder: (context, provider, child) {
              if (!provider.isLoading && provider.errorMessage == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints( minWidth: constraints.maxWidth ),
                            child: _productsOverviewMethod(
                              totalProducts: provider.productList,
                              lowStockProducts: provider.lowStockProducts,
                              outOfStockProducts: provider.outOfStockProducts,
                              expiringProducts: provider.expiringProducts,
                              expiredProducts: provider.expiredProducts
                            ),
                          )
                        );
                      }
                    ),
                    
          
                    SizedBox(height: CSizes.largeGap,),
                  ],
                );
              }
              return SizedBox();
            },
          ),
        ),


        if (_overviewTitle != null && _overviewProducts != null) SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: CSizes.largeGap,),
          
              UiTitleWidget(text: '${_overviewTitle!} products', bigger: true,),
          
              SizedBox(height: CSizes.largeGap,),
            ],
          ),
        ),

        
        // - - - P R O D U C T S _ T A B L E
        SliverFillRemaining(
          hasScrollBody: true,
          child: ProductsDataTable(
            productList: _overviewProducts ?? (_searchController.text.isNotEmpty ? _filteredProductList : widget.products),
            onSearchAgainClick: _handleSearchReset,
          )
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: CSizes.largeGap,)
        ),
      ],
    );
  }





  // - - - - - -
  // - - - M E T H O D S
  // - - - - - -




  // - - - P R O D U C T S _ O V E R V I E W _ M E T H O D
  IntrinsicWidth _productsOverviewMethod({
    required List<ProductModel> totalProducts,
    required List<ProductModel> lowStockProducts,
    required List<ProductModel> outOfStockProducts,
    required List<ProductModel> expiringProducts,
    required List<ProductModel> expiredProducts,
  }) {
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Total Products
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleOverviewClick(null, null),
                  child: _productOverviewCardMethod(
                    title: 'total products', 
                    value: CHelperFunctions.formatNumberWithComma(totalProducts.length).padLeft(2, '0'),
                    gradient: CColors.gradientGreen,
                  ),
                ),
              ),
          
              SizedBox(width: CSizes.largeGap,),
          
              // Low Stock
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleOverviewClick('low stock', lowStockProducts),
                  child: _productOverviewCardMethod(
                    title: 'low stock', 
                    value: CHelperFunctions.formatNumberWithComma(lowStockProducts.length).padLeft(2, '0'),
                    // gradient: LinearGradient(colors: [ const Color.fromARGB(255, 57, 77, 87), const Color.fromARGB(255, 0, 54, 81) ])
                    gradient: CColors.gradientNavyBlue
                  ),
                ),
              ),
          
              SizedBox(width: CSizes.largeGap,),
          
              // Out Of Stock
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleOverviewClick('out of stock', outOfStockProducts),
                  child: _productOverviewCardMethod(
                    title: 'out of stock', 
                    value: CHelperFunctions.formatNumberWithComma(outOfStockProducts.length).padLeft(2, '0'),
                    gradient: CColors.gradientOrange
                  ),
                ),
              ),
          
              SizedBox(width: CSizes.largeGap,),
          
              // Expiring
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleOverviewClick('expiring soon', expiringProducts),
                  child: _productOverviewCardMethod(
                    title: 'expiring soon', 
                    value: CHelperFunctions.formatNumberWithComma(expiringProducts.length).padLeft(2, '0'),
                    gradient: LinearGradient(colors: [ Color.fromARGB(255, 255, 140, 132), Color.fromARGB(255, 40, 40, 40) ])
                  ),
                ),
              ),

              SizedBox(width: CSizes.largeGap,),
          
              // Expired
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleOverviewClick('expired', expiredProducts),
                  child: _productOverviewCardMethod(
                    title: 'expired', 
                    value: CHelperFunctions.formatNumberWithComma(expiredProducts.length).padLeft(2, '0'),
                    // gradient: LinearGradient(colors: [ const Color.fromARGB(255, 154, 41, 33), const Color.fromARGB(255, 110, 7, 0) ])
                    gradient: CColors.gradientRed
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // - - - P R O D U C T _ O V E R V I E W _ C A R D _ M E T H O D
  MouseRegion _productOverviewCardMethod({ 
    required String title, 
    required String value,
    Color? color,
    Gradient? gradient,
  }) {
    final onOverviewFocus = _overviewTitle != null;
    final isActive = _overviewTitle?.toLowerCase() == title;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? CColors.whiteShade3,
          gradient: onOverviewFocus ? ( isActive ? gradient : null ) : gradient,
          border: Border.all(width: 1, color: CColors.whiteShade2),
          borderRadius: BorderRadius.circular(CSizes.mediumGap)
        ),
        padding: EdgeInsets.symmetric(vertical: CSizes.largeGap, horizontal: CSizes.largeGap),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UiTitleWidget(
              text: title,
              bigger: true,
              color: CColors.white,
            ),
      
            SizedBox(width: CSizes.mediumGap,),
            
            UiTitleWidget(
              text: value,
              bigger: true,
              defaultText: true,
              color: CColors.white,
            ),
          ],
        ),
      ),
    );
  }
}