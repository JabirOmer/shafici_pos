import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class MiniProductDetailsWidget extends StatelessWidget {
  final ProductModel product;
  final bool isInCart;
  final void Function() onBackClick;
  final void Function(ProductModel product) addToCart;
  final void Function(ProductModel product) removeFromCart;

  const MiniProductDetailsWidget({
    super.key,
    required this.product,
    required this.isInCart,
    required this.onBackClick,
    required this.addToCart,
    required this.removeFromCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBackClick,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: CSizes.blurSigma,
            sigmaY: CSizes.blurSigma
          ),
          child: Container(
            color: CColors.dimmedBackgound,
            child: Center(
              child: Wrap(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 600
                      ),
                      child: Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: CColors.white,
                          borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                        ),
                        padding: EdgeInsets.all(CSizes.largeGap),
                        margin: EdgeInsets.symmetric(
                          horizontal: CSizes.xLargeGap
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: UiTitleWidget(
                                    text: CHelperFunctions.capitalizeWords(product.productName),
                                    bigger: true,
                                    maxLine: 2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                // SizedBox(width: CSizes.smallGap),
                                // if (!product.isTaxable) Image.asset(
                                //   'assets/images/tax-free-tag.png', 
                                //   fit: BoxFit.contain,
                                //   width: 32,
                                //   height: 32,
                                // )
                              ],
                            ),
                      
                            Container(
                              color: CColors.whiteShade2,
                              height: 1,
                              margin: EdgeInsets.symmetric(vertical: CSizes.mediumGap),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                UiTitleWidget(
                                  text: 'category',
                                  bold: false,
                                  color: CColors.blackShade3,
                                ),
                      
                                UiTitleWidget(
                                  text: product.categoryName,
                                  bold: false,
                                )
                              ],
                            ),
                      
                            SizedBox(height: CSizes.mediumGap,),
                          
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                UiTitleWidget(
                                  text: 'barcode',
                                  bold: false,
                                  color: CColors.blackShade3,
                                ),
                      
                                UiTitleWidget(
                                  text: product.productBarcode,
                                  bold: false,
                                )
                              ],
                            ),

                            SizedBox(height: CSizes.mediumGap,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                UiTitleWidget(
                                  text: 'product_id',
                                  bold: false,
                                  color: CColors.blackShade3,
                                ),
                      
                                UiTitleWidget(
                                  text: product.productId,
                                  bold: false,
                                )
                              ],
                            ),
                      
                            Container(
                              color: CColors.whiteShade2,
                              height: 1,
                              margin: EdgeInsets.symmetric(vertical: CSizes.mediumGap),
                            ),
                      
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                UiTitleWidget(
                                  text: 'stock quantity',
                                  bold: false,
                                  color: CColors.blackShade3,
                                ),
                      
                                UiTitleWidget(
                                  text: product.stock.toString(),
                                  bold: false,
                                )
                              ],
                            ), 
                            
                            SizedBox(height: CSizes.mediumGap,),
                      
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                UiTitleWidget(
                                  text: 'expire date:',
                                  bold: false,
                                  color: CColors.blackShade3,
                                ),
                      
                                UiTitleWidget(
                                  text: product.expireDate != null ? CHelperFunctions.formatDateTime(product.expireDate!) : 'no expire date',
                                  bold: false,
                                )
                              ],
                            ),  
                      
                            Container(
                              color: CColors.whiteShade2,
                              height: 1,
                              margin: EdgeInsets.symmetric(vertical: CSizes.mediumGap),
                            ),
                      
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                UiTitleWidget(
                                  text: 'Selling Price:',
                                  bold: false,
                                  color: CColors.blackShade3,
                                ),
                      
                                UiTitleWidget(
                                  text: '${CHelperFunctions.formatNumberWithComma(product.sellingPrice, addDecimal: false)} Birr',
                                  capitalizeWords: true,
                                  bigger: true,
                                )
                              ],
                            ), 
                          
                            SizedBox(height: CSizes.largeGap,),
                          
                            Row(
                              children: [
                                UiButtonWidget(
                                  text: 'back',
                                  tranparent: true,
                                  onClick: onBackClick
                                ), 
                          
                                SizedBox(width: CSizes.smallGap,),
                          
                                Expanded(
                                  child: UiButtonWidget(
                                    text: isInCart ? 'remove' : 'add to cart',
                                    backgroundColor: isInCart ? CColors.red : null,
                                    icon: CIcons.bagIcon,
                                    onClick: () => isInCart ? removeFromCart(product) : addToCart(product)
                                  ),
                                ), 
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}