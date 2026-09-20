import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/animations.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/screens/products_screen/register_products_screen.dart';
import 'package:shafici_pos/screens/products_screen/widgets/products_display_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {
  // - - - F U N C T I O N S

  void _handleNavigateToRegister() {
    // setState(() {
    //   _showRegisterProductPopup = !_showRegisterProductPopup;
    // });
    CHelperFunctions.navigateToScreen(
      context: context, 
      screen: RegisterProductsScreen()
    );
  }


  // void _navigateToEdit(ProductModel product) {
  //   CHelperFunctions.navigateToScreen(
  //     context: context, 
  //     screen: ProductDetailsScreen(
  //       product: product, 
  //     )
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: CSizes.largeGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: CSizes.largeGap,),
                      
            // - - - P A G E _ T I T L E
            UiTitleWidget(
              text: 'products',
              bigger: true,
            ),
                      
            SizedBox(height: CSizes.largeGap,),
                      
            Expanded(
              child: Consumer<ProductsProvider>(
                builder: (context, provider, child) {
                  // - - - L O A D I N G
                  if (provider.isLoading) return UiLoadingScreenWidget();
              
                  // - - - E R R O R
                  if (provider.errorMessage != null) {
                    return UiPopupWidget(
                      message: provider.errorMessage!, 
                      primaryText: 'seach again', 
                      primaryClick: provider.setProducts, 
                      outSideClick: () {},
                      isDimmed: false,
                    );
                  }
              
                  // - - - N O _ P R O D U C T S
                  if (provider.productList.isEmpty) {
                    return UiNoDataFounded(
                      title: 'no products are registered',
                      buttonText: 'register now',
                      onButtonClick: _handleNavigateToRegister,
                      noDataAnimation: CAnimations.emptyList,
                    );
                  }
                  
                  // P R O D U C T S _ T A B L E
                  return ProductsDisplayWidget(
                    products: provider.productList
                  );
                },
              ),
            ),
        
          ],
        ),
      ),
    );
  }




  // - - - - - - 
  // - - - M E T H O D S
  // - - - - - - 
}

