import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/shadows.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/product_category_model.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/screens/categories_screen/edit_category_popup.dart';
import 'package:shafici_pos/screens/categories_screen/register_product_category_poup.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductCategoryModel> _filteredCategoryList = [];
  ProductCategoryModel? _selectedCategory;

  bool _canEdit = false;
  bool _showRegisterPopup = false;


  // - - - - - - >>
  // - - - F U N C T I O N S
  void refreshCategoriesData() {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    productsProvider.setProducts(onlyCategories: true);
  }

  void _handleSearch(String? value) {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    if (value == null) {
      _filteredCategoryList.clear();
    } else {
      _filteredCategoryList = productsProvider.productCategoryList.where((c) => c.categoryName.toLowerCase().contains(value.toLowerCase())).toList();
    }
    setState(() {});
  }

  void _handleSearchReset() {
    setState(() {
      _filteredCategoryList.clear();
      _searchController.clear();
    });
  }

  void _toggleShowRegisterPopup({ bool reload = false }) {
    setState(() => _showRegisterPopup = !_showRegisterPopup,);
    if (reload) refreshCategoriesData();
  }

  void _toggleShowUpdatePopup({ ProductCategoryModel? category, bool reload = false }) {
    setState(() => _selectedCategory = category);
    if (reload) refreshCategoriesData();
  }

  int _getCrossAxisCount(double maxWidth) {
    if (maxWidth < 800) {
      return 2;
    }
    else if (maxWidth < 1000) {
      return 3;
    }
    else if (maxWidth < 1200) {
      return 4;
    } else if (maxWidth < 1400) {
      return 5;
    } else {
      return 6;
    }
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
    return Scaffold(
      body: Stack(
        children: [


          // - - - M A I N _ D I S P L A Y
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: CSizes.largeGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: CSizes.largeGap,),
            
                UiTitleWidget(
                  text: 'Categories',
                  bigger: true,
                ),
            
                SizedBox(height: CSizes.largeGap,),
            
                // - - - T O P _ S E C T I O N
                _topSectionMethod(
                  onRegisterClick: _toggleShowRegisterPopup
                ),
          
                SizedBox(height: CSizes.largeGap,),
          
                // - - - C A T E G O R I E S _ D I S P L A Y
                Expanded(
                  child: Consumer<ProductsProvider>(
                    builder: (context, provider, child) {
                      // Loading
                      if (provider.isLoading) {
                        return UiLoadingScreenWidget();
                      }
          
                      // Error
                      if (provider.errorMessage != null) {
                        return Container(
                          decoration: BoxDecoration(
                            color: CColors.white,
                            borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                          ),
                          child: UiNoDataFounded(
                              title: provider.errorMessage,
                              onButtonClick: provider.setProducts,
                              backgroundColor: CColors.whiteShade1,
                            ),
                        );
                      }
          
          
                      // No Data
                      if (provider.productCategoryList.isEmpty) {
                        return Container(
                          decoration: BoxDecoration(
                            color: CColors.white,
                            borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                          ),
                          child: UiNoDataFounded(
                            title: 'no products categories are founded',
                            onButtonClick: provider.setProducts,
                            backgroundColor: CColors.whiteShade1,
                          ),
                        );
                      }
          
          
                      return LayoutBuilder(
                        builder: (context, constraints) => _productCategoriesDisplayMethod(
                          categoryList: _searchController.text.isNotEmpty ? _filteredCategoryList : provider.productCategoryList,
                          productList: provider.productList,
                          crossAxisCount: _getCrossAxisCount(constraints.maxWidth),
                          seeEditClick: (category) => _toggleShowUpdatePopup(category: category),
                        )
                      );
                    },
                  ),
                ),
          
                SizedBox(height: CSizes.largeGap,),
              ]
            )
          ),



          // - - - R E G I S T E R _ C A T E G O R Y _ P O P U P
          if (_showRegisterPopup) RegisterProductCategoryPoup(
            onBackCall: (reload) => _toggleShowRegisterPopup(reload: reload),
          ),



          // - - - U P D A T E _ C A T E G O R Y _ P O P U P
          if (_selectedCategory != null) EditCategoryPopup(
            categoryData: _selectedCategory!, 
            onBackCall: (reload) => _toggleShowUpdatePopup(category: null, reload: reload),
          )

        ],
      )
    );
  }





  // - - - - - - 
  // - - - M E T H O D S
  // - - - - - - 




  // 
  IntrinsicHeight _topSectionMethod({
    required void Function() onRegisterClick,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300),
                child: UiTextFieldWidget(
                  label: 'Search category',
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
                // borderColor: CColors.primaryColor,
                onClick: refreshCategoriesData
              )
            ],
          ),
      
          if (_canEdit) UiButtonWidget(
            text: 'add new category',
            icon: CIcons.addIcon, 
            vericalPadding: CSizes.smallGap,
            isDisabled: !_canEdit,
            onClick: onRegisterClick
          ),
        ],
      ),
    );
  }






  // - - - P R O D U C T _ C A T E G O R Y _ D I S P L A Y _ M E T H O D
  MasonryGridView _productCategoriesDisplayMethod({
    required List<ProductCategoryModel> categoryList,
    required List<ProductModel> productList,
    required int crossAxisCount,
    required void Function(ProductCategoryModel category) seeEditClick
  }) {
    return MasonryGridView.count(
      shrinkWrap: true,
      itemCount: categoryList.length,
      crossAxisCount: crossAxisCount, 
      crossAxisSpacing: CSizes.mediumGap,
      mainAxisSpacing: CSizes.mediumGap, 
      itemBuilder: (context, index) {
        final category = categoryList[index];
        final totalProducts = productList.where((p) => p.categoryId == category.categoryId).length;

        return GestureDetector(
          onTap: () => _canEdit ? seeEditClick(category) : {},
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
              // border: Border.all(width: 1, color: CColors.whiteShade2.withValues(alpha: 1)),
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
                // Category name
                UiTitleWidget(
                  text: category.categoryName,
                  capitalizeWords: true,
                ),
            
                SizedBox(height: CSizes.smallGap,),
            
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          UiTitleWidget(text: 'total: ', bold: false, color: CColors.whiteShade3,),
                          Expanded(child: UiTitleWidget(text: CHelperFunctions.formatNumberWithComma(totalProducts), bold: false, color: CColors.whiteShade3,)),
                        ],
                      )
                    ),

                    SizedBox(width: CSizes.largeGap,),

                    UiButtonWidget(
                      icon: CIcons.editIcon,
                      horizontalPadding: CSizes.smallGap,
                      vericalPadding: CSizes.smallGap,
                      tranparent: true,
                      isDisabled: !_canEdit,
                      onClick: () => seeEditClick(category),
                    ),
                  ],
                )
              ],
            ),
          )
        );
      },
    );
  }
}