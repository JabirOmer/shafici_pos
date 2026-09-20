import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/order_item_model.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class PosOrderListDisplayWidget extends StatelessWidget {
  final List<OrderItemModel> items;
  final List<ProductModel> products;
  final void Function(ProductModel product) onIncrease;
  final void Function(ProductModel product) onDecrease;
  final void Function(ProductModel product, bool isIncrement) onLongPressStart;
  final void Function() onLongPressEnd;
  final void Function(ProductModel product) onProductClick;

  const PosOrderListDisplayWidget({
    super.key,
    required this.items,
    required this.products,
    required this.onIncrease,
    required this.onDecrease,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onProductClick,
  });

  // Future<void> _handleLongPressStart() {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = items[index];
        final product = products.firstWhere((p) => p.productId == item.productId);
        return GestureDetector(
          onTap: () => onProductClick(product),
          child: _orderItemBoxMethod(
            index: index, 
            item: item,
            availableQty: product.stock,
            onIncreaseClick: () => onIncrease(product),
            onDecreaseClick: () => onDecrease(product),
            onLongPressStart: (isIncrement) => onLongPressStart(product, isIncrement),
            onLongPressEnd: onLongPressEnd,
          ),
        );
      }, 
      separatorBuilder: (context, index) => Container(
        height: 1, 
        color: CColors.whiteShade2, 
        width: double.maxFinite, 
        margin: EdgeInsets.only(left: 38+16),
      ), 
      itemCount: items.length
    );
  }

  // - - - - - -
  Container _orderItemBoxMethod({
    required int index, 
    required OrderItemModel item, 
    required int availableQty,
    required void Function() onIncreaseClick,
    required void Function() onDecreaseClick,
    required void Function(bool isIncrement) onLongPressStart,
    required void Function() onLongPressEnd,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: CSizes.mediumGap,
        horizontal: CSizes.mediumGap
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: item.isTaxable ? CColors.deepOrange : CColors.white,
              borderRadius: BorderRadius.circular(CSizes.mediumGap)
            ),
            // padding: EdgeInsets.symmetric(vertical: CSizes.smallGap,),
            child: Center(
              child: Text(
                (index+1).toString().padLeft(2, '0'),
                style: TextStyle(
                  color: item.isTaxable ? CColors.white : CColors.whiteShade3,
                  fontSize: 11
                ),
              ),
            ),
          ),

          SizedBox(width: CSizes.smallGap,),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UiTitleWidget(
                  text: item.productName,
                  bold: false,
                ),
                Text(
                  '${CHelperFunctions.formatNumberWithComma(item.unitSoldAt, addDecimal: false)} Birr',
                  style: TextStyle(
                    color: CColors.whiteShade3,
                    fontSize: 12
                  ),
                )
              ],
            ),
          ),

          SizedBox(width: CSizes.mediumGap,),

          SizedBox(
            // width: 110,
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: UiButtonWidget(
                    icon: CIcons.minusIcon,
                    isDisabled: item.quantity == 1,
                    onClick: onDecreaseClick,
                    onLongPressStart: (_) => onLongPressStart(false),
                    onLongPressEnd: (_) => onLongPressEnd(),
                    vericalPadding: 0,
                    horizontalPadding: 0,
                  ),
                ),
          
                SizedBox(
                  width: 35,
                  child: Text(
                    item.quantity.toString().padLeft(2, '0'),
                    textAlign: TextAlign.center,
                  ),
                ),
          
                SizedBox(
                  width: 30,
                  height: 30,
                  child: UiButtonWidget(
                    icon: CIcons.addIcon,
                    isDisabled: item.quantity == availableQty,
                    onClick: () => onIncreaseClick(),
                    onLongPressStart: (_) => onLongPressStart(true),
                    onLongPressEnd: (_) => onLongPressEnd(),
                    vericalPadding: 0,
                    horizontalPadding: 0,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}