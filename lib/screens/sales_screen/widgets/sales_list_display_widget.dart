import 'package:flutter/widgets.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/sale_data_model.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class SalesListDisplayWidget extends StatelessWidget {
  final List<SaleDataModel> salesList;
  final bool isOffline;
  final bool canDelete;
  final void Function(SaleDataModel sale) onSeeDetailsClick;
  final void Function(SaleDataModel sale)? onSendAgainClick;
  final void Function(SaleDataModel sale)? onDeleteClick;

  const SalesListDisplayWidget({
    super.key,
    required this.salesList,
    this.isOffline = false,
    this.canDelete = false,
    required this.onSeeDetailsClick,
    this.onSendAgainClick,
    this.onDeleteClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final sale = salesList[index];
        return _saleDisplayCardMethod(
          index: index,
          sale: sale,
          isOffline: isOffline,
          canDelete: canDelete,
          seeMoreClick: () => onSeeDetailsClick(sale),
          sendAgainClick: () {
            if (isOffline && onSendAgainClick != null) { onSendAgainClick!(sale); }
          },
          deleteIconClick: () {
            if (canDelete && onDeleteClick != null) { onDeleteClick!(sale); }
          },
        );
      }, 
      separatorBuilder: (context, index) => SizedBox(height: CSizes.mediumGap,), 
      itemCount: salesList.length
    );
  }





  // - - - S A L E S _ C A R D
  MouseRegion _saleDisplayCardMethod({
    required int index,
    required SaleDataModel sale,
    required bool isOffline,
    required bool canDelete,
    required void Function() seeMoreClick,
    required void Function() sendAgainClick,
    required void Function() deleteIconClick,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: seeMoreClick,
        child: Container(
          decoration: BoxDecoration(
            color: CColors.white,
            borderRadius: BorderRadius.circular(CSizes.mediumRadius + 20)
          ),
          padding: EdgeInsets.all(CSizes.mediumGap),
          child: Row(
            children: [
          
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 25,
                      child: UiTitleWidget(
                        text: (index+1).toString().padLeft(2, '0'),
                        bold: false,
                        color: CColors.whiteShade2,
                      ),
                    ),
          
                    SizedBox(width: CSizes.smallGap,),
          
                    UiTitleWidget(
                      text: sale.sellerName,
                      capitalizeWords: true, 
                      bold: false,
                    )
                  ],
                )
              ),
          
              SizedBox(width: CSizes.mediumGap,),
          
              Expanded(
                child: UiTitleWidget(
                  text: CHelperFunctions.formatDateTime(sale.createdAt),
                  bold: false,
                  textAlign: TextAlign.center,
                ),
              ),
          
              SizedBox(width: CSizes.mediumGap,),
          
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    UiButtonWidget(
                      icon: CIcons.eyeOpen,
                      tranparent: isOffline,
                      vericalPadding: CSizes.smallGap,
                      onClick: seeMoreClick
                    ),
          
                    if (isOffline) Row(
                      children: [
                        SizedBox(width: CSizes.mediumGap,),
          
                        UiButtonWidget(
                          icon: CIcons.sendIcon,
                          vericalPadding: CSizes.smallGap,
                          onClick: sendAgainClick
                        ),
        
                        if (canDelete) Row(
                          children: [
                            SizedBox(width: CSizes.mediumGap,),
        
                            UiButtonWidget(
                              icon: CIcons.trashIcon,
                              vericalPadding: CSizes.smallGap,
                              backgroundColor: CColors.red,
                              onClick: deleteIconClick
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                )
              )
          
            ],
          ),
        ),
      ),
    );
  }
}