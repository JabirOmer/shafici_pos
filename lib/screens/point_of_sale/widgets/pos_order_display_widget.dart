import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/screens/point_of_sale/widgets/order_sessions_display_widget.dart';
import 'package:shafici_pos/screens/point_of_sale/widgets/pos_order_list_display_widget.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_order_calculation_summary_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class PosOrderDisplayWidget extends StatefulWidget {
  final void Function(ProductModel product) onProductClick;
  final void Function() onSubmitClick;

  const PosOrderDisplayWidget({
    super.key,
    required this.onProductClick,
    required this.onSubmitClick,
  });

  @override
  State<PosOrderDisplayWidget> createState() => _PosOrderDisplayWidgetState();
}

class _PosOrderDisplayWidgetState extends State<PosOrderDisplayWidget> {
  late ProductsProvider _productsProvider;
  // Timer? _rapidCallTimer;

  
  
  // - - - - - - >>
  // - - - F U N C T I O N S
  // Future<void> _startRapidCall(ProductModel product, bool isIncrement) async {
  //   _productsProvider = Provider.of<ProductsProvider>(context, listen: false);

  //   isIncrement ? await _productsProvider.incrementItemInOrderSession(product) : 
  //   await _productsProvider.decrementItemInOrderSession(product);
  // }

  // void _endRapidCall() {}


  // - - - D E L E T E _ S E S S I O N
  Future<void> _handleDeleteSession(int sessionId) async {
    _productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    await _productsProvider.deleteOrderSession(sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      color: CColors.white,
      padding: EdgeInsets.only(
        top: CSizes.largeGap
      ),
      child: Consumer<ProductsProvider>(
        builder: (context, productsProvider, child) {

          // - - - E M P T Y _ O R D E R _ S E S S I O N S
          if (productsProvider.orderSessions.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UiTitleWidget(
                  text: 'no session is founded',
                  bold: false,
                ),
            
                SizedBox(height: CSizes.largeGap,),
            
                UiButtonWidget(
                  text: 'open new session',
                  onClick: productsProvider.createOrderSession
                )
              ],
            );
          } 


    
          // - - - S U C C E S S
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(left: CSizes.largeGap),
                child: UiTitleWidget(
                  text: 'order list',
                  bigger: true,
                  // textAlign: TextAlign.center,
                ),
              ),
    
              SizedBox(height: CSizes.mediumGap,),


    
              // - - - O R D E R _ S E S S I O N S _ D I S P L A Y
              OrderSessionsDisplayWidget(
                orderSessions: productsProvider.orderSessions,
                addNewSession: productsProvider.createOrderSession,
                activeSessionId: productsProvider.activeSessionId,
                changeActiveSessionId: (sessionId) => productsProvider.setActiveSession(sessionId),
              ),

    
              SizedBox(height: CSizes.mediumGap,),


              // - - - E M P T Y _ C A R T
              if (productsProvider.activeSessionData == null || productsProvider.activeSessionData!.items.isEmpty) Expanded(
                child: SingleChildScrollView(
                  child: UiNoDataFounded(
                    title: 'cart is empty',
                  ),
                ),
              )

              // - - - D I S P L A Y _ I T E M S _ L I S T
              else if (productsProvider.activeSessionData!.items.isNotEmpty) Expanded(
                child: PosOrderListDisplayWidget(
                  items: productsProvider.activeSessionData!.items,
                  products: productsProvider.productList,
                  onIncrease: (product) => productsProvider.incrementItemInOrderSession(product),
                  onDecrease: (product) => productsProvider.decrementItemInOrderSession(product),
                  // onLongPressStart: (product, is) => startRapid,
                  onLongPressStart: (_, _) => {},
                  onLongPressEnd: () {},
                  onProductClick: (product) => widget.onProductClick(product),
                ),
              ),


    
              



              // - - - D I S P L A Y _ O R D E R _ C A L C U L A T I O N S
              if (productsProvider.activeSessionCalc != null) Container(
                margin: EdgeInsets.all(CSizes.largeGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: UiTextFieldWidget(
                    //         // initialValue: CHelperFunctions.formatNumberWithComma(productsProvider.activeSessionCalc!.discount),
                    //         hint: 'discount',
                    //       ),
                    //     ),

                    //     SizedBox(width: CSizes.mediumGap,),

                    //     UiButtonWidget(
                    //       icon: CIcons.sendIcon,
                    //       vericalPadding: 8,
                    //       horizontalPadding: 8,
                    //       onClick: () {}
                    //     )
                    //   ],
                    // ),

                    // Divider(
                    //   height: CSizes.largeGap,
                    //   color: CColors.whiteShade2,
                    // ),

                    UiOrderCalculationSummaryWidget(
                      orderCalculation: productsProvider.activeSessionCalc!,
                    ),

                    SizedBox(height: CSizes.mediumGap,),

                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          UiButtonWidget(
                            icon: CIcons.trashIcon,
                            backgroundColor: CColors.red,
                            horizontalPadding: CSizes.mediumGap,
                            onClick: () => _handleDeleteSession(productsProvider.activeSessionId)
                          ),
                      
                          SizedBox(width: CSizes.mediumGap,),
                      
                          Expanded(
                            child: UiButtonWidget(
                              text: 'submit',
                              vericalPadding: 0,
                              isDisabled: productsProvider.activeSessionCalc?.grandTotal == 0,
                              onClick: widget.onSubmitClick,
                            ),
                          ),
                      
                        ],
                      ),
                    ),

                
                    // SizedBox(height: CSizes.mediumGap,),
                  ],
                ),
              )

            ],
          );
        },
      )
    );
  }
}