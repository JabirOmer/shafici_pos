import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/screens/order_screens/order_payment_screen.dart';
import 'package:shafici_pos/screens/point_of_sale/widgets/mini_product_details_widget.dart';
import 'package:shafici_pos/screens/point_of_sale/widgets/pos_order_display_widget.dart';
import 'package:shafici_pos/screens/point_of_sale/widgets/pos_products_display_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';

class PointOfSaleScreen extends StatefulWidget {
  const PointOfSaleScreen({super.key});

  @override
  State<PointOfSaleScreen> createState() => _PointOfSaleScreenState();
}

class _PointOfSaleScreenState extends State<PointOfSaleScreen> {
  ProductModel? _productToBeLooked;
  
  
  // - - - - - -
  // - - - F U N C T I O N S

  
  // -- -- --
  Future<void> _refreshAppData() async {
    final ProductsProvider productsProvider = Provider.of(context, listen: false);
    await productsProvider.setProducts();
  }

  
  // -- -- --
  void _setProductDetail(ProductModel product) {
    setState(() => _productToBeLooked = product);
  }

  
  // -- -- --
  void _clearProductDetail() {
    setState(() => _productToBeLooked = null);
  }


  // -- -- --
  void _handleOrderSubmit() {
    CHelperFunctions.navigateToScreen(
      context: context, 
      screen: OrderPaymentScreen()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, provider, child) {
        // - - - L O A D I N G
        if (provider.isLoading) {
          return UiLoadingScreenWidget();
        }

        // - - - E R R O R
        if (provider.errorMessage != null) {
          return UiNoDataFounded(
            addAnimation: false,
            title: provider.errorMessage,
            onButtonClick: _refreshAppData
          );
        }

        // - - - D O N E
        return Stack(
          children: [
            Row(
              children: [
                // - - - P R O D U C T S _ D I S P L A Y
                Expanded(
                  child: PosProductsDisplayWidget(
                    categories: provider.productCategoryList,
                    products: provider.productList,
                    onRefresh: _refreshAppData,
                    onProductClick: (product) => _setProductDetail(product),
                    onAddToCartClick: (product) => provider.incrementItemInOrderSession(product),
                  ),
                ),

                // Container(
                //   width: 1,
                //   color: CColors.whiteShade2,
                // ),
             
                // // - - - O R D E R _ L I S T _ D I S P L A Y
                PosOrderDisplayWidget(
                  onProductClick: (product) => _setProductDetail(product),
                  onSubmitClick: _handleOrderSubmit,
                )
              ],
            ),


            // - - - P R O D U C T _ D E T A I L S
            if (_productToBeLooked != null) MiniProductDetailsWidget(
              product: _productToBeLooked!,
              isInCart: provider.activeSessionData?.items.any((i) => i.productId == _productToBeLooked?.productId) ?? false,
              onBackClick: _clearProductDetail,
              addToCart: (product) {
                provider.incrementItemInOrderSession(product);
                _clearProductDetail();
              },
              removeFromCart: (product) {
                provider.removeItemFromOrderSession(product);
                _clearProductDetail();
              }
            ),

          ]
        );

      }
    );
  }
}