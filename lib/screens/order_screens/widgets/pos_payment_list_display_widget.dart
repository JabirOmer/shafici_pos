import 'package:flutter/widgets.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/order_payment_model.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class PosPaymentListDisplayWidget extends StatelessWidget {
  final int index;
  final OrderPaymentModel payment;
  final void Function() onDeleteClick;

  const PosPaymentListDisplayWidget({
    super.key,
    required this.index,
    required this.payment,
    required this.onDeleteClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CColors.white,
        borderRadius: BorderRadius.circular(CSizes.smallGap)
      ),
      padding: EdgeInsets.all(CSizes.mediumGap),
      child: Row(
        children: [

          // Right
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 25,
                  decoration: BoxDecoration(
                    color: CColors.whiteShade2,
                    borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                  ),
                  child: UiTitleWidget(
                    text: (index+1).toString().padLeft(2, '0'),
                    bold: false,
                    textAlign: TextAlign.center,
                    // color: CColors.whiteShade2,
                  ),
                ),

                SizedBox(width: CSizes.mediumGap,),

                UiTitleWidget(
                  text: '${CHelperFunctions.formatNumberWithComma(payment.paidAmount)} birr',
                  capitalizeWords: true,
                )
              ],
            )
          ),


          SizedBox(width: CSizes.smallGap,),
          
          // Middle
          Expanded(
            child: UiTitleWidget(
              text: payment.paymentName,
              bold: false,
              textAlign: TextAlign.center,
              color: CColors.whiteShade3,
            )
          ),

          
          SizedBox(width: CSizes.smallGap,),
          

          // Left
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                UiButtonWidget(
                  icon: CIcons.trashIcon,
                  vericalPadding: CSizes.smallGap,
                  horizontalPadding: CSizes.smallGap,
                  backgroundColor: CColors.red,
                  onClick: onDeleteClick
                ),
              ],
            )
          ),


        ],
      ),
    );
  }
}