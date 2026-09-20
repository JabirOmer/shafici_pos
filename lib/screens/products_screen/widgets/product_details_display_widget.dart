import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class ProductDetailsDisplayWidget extends StatelessWidget {
  final ProductModel initialProduct;
  final ProductModel? newData;
  final UserModel userData;
  final bool canEdit;
  final void Function() onEditClick;
  final void Function(String productId) onDeleteClick;
  final void Function() onBackClick;
  final void Function() onNewBarcodeClick;

  const ProductDetailsDisplayWidget({
    super.key,
    required this.initialProduct,
    required this.newData,
    required this.userData,
    required this.canEdit,
    required this.onEditClick,
    required this.onDeleteClick,
    required this.onBackClick,
    required this.onNewBarcodeClick,
  });

  @override
  Widget build(BuildContext context) {
    final product = newData ?? initialProduct;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CColors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 900,
              ),
              child: Container(
                margin: EdgeInsets.all(CSizes.largeGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
          
                    // - - - - - - >>
                    // - - - I N F O
                    Container(
                      decoration: BoxDecoration(
                        color: CColors.white,
                        borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                      ),
                      padding: EdgeInsets.all(CSizes.largeGap),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // - - - T I T L E
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              UiTitleWidget(
                                text: 'product info',
                                bigger: true,
                              ),

                              if (canEdit)  Row(
                                children: [
                                  UiButtonWidget(
                                    text: 'custom barcode',
                                    vericalPadding: CSizes.smallGap,
                                    backgroundColor: CColors.transparent,
                                    color: CColors.black,
                                    borderColor: CColors.whiteShade3,
                                    onClick: onNewBarcodeClick
                                  ),

                                  SizedBox(width: CSizes.mediumGap,),

                                  UiButtonWidget(
                                    vericalPadding: CSizes.smallGap,
                                    text: 'edit',
                                    icon: CIcons.editIcon,
                                    isDisabled: !canEdit,
                                    onClick: canEdit ? onEditClick : () {},
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: CSizes.largeGap,),
          
                          // - - - Product Name
                          _productInfoTile(
                            title: 'product name :',
                            value: product.productName,
                          ),
      
                          // - - - Product Name
                          _productInfoTile(
                            title: 'product code :',
                            value: product.productCode ?? '---',
                          ),

                          // - - - Product Name
                          _productInfoTile(
                            title: 'barcode :',
                            value: product.productBarcode,
                          ),

                          // - - - Product Name
                          _productInfoTile(
                            title: 'Batch number :',
                            value: product.batchNumber ?? '---',
                          ),
          
                          // - - - Category
                          _productInfoTile(
                            title: 'category :',
                            value: product.categoryName,
                          ),
          
                          // - - - Expire Date
                          Theme(
                            data: Theme.of(context).copyWith(cardTheme: CardThemeData(color: CColors.black)),
                            child: _productInfoTile(
                              title: 'expire date :',
                              value: product.expireDate == null ? '- - -' : CHelperFunctions.formatDateTime(product.expireDate!),
                              defaultValue: true,
                              addBorder: false
                            ),
                          ),
                        ],
                      ),
                    ),
                    // - - - I N F O
                    // - - - - - - >>
          
          
                    // - - - - - - >>
                    // - - - P R I C I N G
                    if (canEdit) Container(
                      decoration: BoxDecoration(
                        color: CColors.white,
                        borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                      ),
                      margin: EdgeInsets.only(top: CSizes.largeGap),
                      padding: EdgeInsets.all(CSizes.largeGap),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // - - - T I T L E
                          UiTitleWidget(
                            text: 'pricing',
                            bigger: true,
                          ),

                          SizedBox(height: CSizes.largeGap,),
          
                          // - - - Cost USD
                          _productInfoTile(
                            title: 'Cost in USD :',
                            defaultTitle: true,
                            value: product.unitCostInUSD == null ? '---' : '\$${CHelperFunctions.formatNumberWithComma(product.unitCostInUSD!)}',
                          ),
          
                          // - - - Cost Birr
                          _productInfoTile(
                            title: 'Cost in Birr :',
                            defaultTitle: true,
                            value: '${CHelperFunctions.formatNumberWithComma(product.unitCost)} Birr',
                            capitalizeWords: true
                          ),

                          // - - - P R O F I T
                          _productInfoTile(
                            title: 'profit :',
                            value: '${CHelperFunctions.formatNumberWithComma(product.sellingPrice - product.unitCost)} Birr',
                            capitalizeWords: true
                          ),

                          // - - - Selling Price
                          _productInfoTile(
                            title: 'selling price :',
                            value: '${CHelperFunctions.formatNumberWithComma(product.sellingPrice)} Birr',
                            addBorder: false,
                            boldValue: true,
                            capitalizeWords: true
                          ),
                        ],
                      ),
                    ),
                    // - - - P R I C I N G
                    // - - - - - - >>
          
          
          
                    SizedBox(height: CSizes.largeGap,),
          
          
                    // - - - - - - >>
                    // - - - S T O C K
                    Container(
                      decoration: BoxDecoration(
                        color: CColors.white,
                        borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                      ),
                      padding: EdgeInsets.all(CSizes.largeGap),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // - - - T I T L E
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                UiTitleWidget(
                                  text: 'stock',
                                  bigger: true,
                                ),
                            
                                Container(
                                  decoration: BoxDecoration(
                                    color: CHelperFunctions.getStockStatusColor(stock: product.stock, alertQuantity: product.alertQuantity),
                                    borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: CSizes.mediumGap
                                  ),
                                  child: Center(
                                    child: UiTitleWidget(
                                      text: CHelperFunctions.getStockStatus(stock: product.stock, alertQuantity: product.alertQuantity),
                                      bold: false,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                          SizedBox(height: CSizes.largeGap,),
          
                          // - - - Stock
                          _productInfoTile(
                            title: 'stock quantity :',
                            value: CHelperFunctions.formatNumberWithComma(product.stock).padLeft(2, '0'),
                          ),
          
                          // - - - Stock Alert
                          _productInfoTile(
                            title: 'stock alert :',
                            value: CHelperFunctions.formatNumberWithComma(product.alertQuantity).padLeft(2, '0'),
                            addBorder: false
                          ),

                        ],
                      ),
                    ),
                    // - - - S T O C K
                    // - - - - - - >>


                    SizedBox(height: CSizes.largeGap,),

                    
                    // - - - - - - >>
                    // - - - T I M E
                    Container(
                      decoration: BoxDecoration(
                        color: CColors.white,
                        borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                      ),
                      padding: EdgeInsets.all(CSizes.largeGap),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // - - - T I T L E
                          UiTitleWidget(
                            text: 'period',
                            bigger: true,
                          ),

                          SizedBox(height: CSizes.largeGap,),

                          // - - - Updated At
                          if (product.createdAt != null) _productInfoTile(
                            title: 'created at :',
                            value: CHelperFunctions.formatDateTime(product.createdAt!, addTime: true),
                            defaultValue: true
                          ),

                          // - - - Updated At
                          if (product.updatedAt != null)  _productInfoTile(
                            title: 'latest update :',
                            value: CHelperFunctions.formatDateTime(product.updatedAt!, addTime: true),
                            defaultValue: true,
                            addBorder: false
                          ),
                        ],
                      ),
                    ),
          
                    SizedBox(height: CSizes.largeGap,),

                    // - - - - - - >>
                    // - - - D A N G E R _ Z O N E
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Container(
                    //       decoration: BoxDecoration(
                    //         color: CColors.white,
                    //         border: Border.all(width: 1, color: CColors.redDimmed),
                    //         borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                    //       ),
                    //       padding: EdgeInsets.symmetric(horizontal: CSizes.mediumGap, vertical: CSizes.mediumGap),
                    //       child: Row(
                    //         children: [
                    //           UiTitleWidget(
                    //             text: 'Delete',
                    //             color: CColors.red,
                    //             bold: false,
                    //             capitalizeWords: true,
                    //           ),

                    //           SizedBox(width: CSizes.largeGap,),
                        
                    //           UiButtonWidget(
                    //             icon: CIcons.trashIcon,
                    //             vericalPadding: CSizes.smallGap,
                    //             backgroundColor: CColors.redDimmed,
                    //             isDisabled: !canEdit,
                    //             onClick: () => onDeleteClick(product.productId)
                    //           )
                    //         ]
                    //       )
                    //     ),
                    //   ],
                    // ),

                    // SizedBox(height: CSizes.largeGap,),
      
                    UiButtonWidget(
                      text: 'back',
                      onClick: onBackClick
                    )
          
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }




  // - - - - - -
  // - - - M E T H O D S
  // - - - - - -




  // - - - P R O D U C T _ I N F O _ T I L E
  Container _productInfoTile({
    required String title,
    required String value,
    bool addBorder = true,
    bool defaultTitle = false,
    bool defaultValue = false,
    bool boldValue = false,
    bool capitalizeWords = false,
    Color? stockStatusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: addBorder ? 1 : 0, color: addBorder ? CColors.whiteShade2 : CColors.transparent)
        )
      ),
      padding: EdgeInsets.symmetric(
        vertical: stockStatusColor != null ? CSizes.smallGap : CSizes.mediumGap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          UiTitleWidget(
            text: title,
            defaultText: defaultTitle,
            bold: false,
            color: CColors.whiteShade3,
          ),
          
          Container(
            decoration: BoxDecoration(
              color: stockStatusColor,
              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
            ),
            padding: EdgeInsets.symmetric(
              horizontal: stockStatusColor != null ? CSizes.mediumGap : 0,
              vertical: stockStatusColor != null ? CSizes.smallGap : 0,
            ),
            child: UiTitleWidget(
              text: value,
              defaultText: defaultValue,
              bold: boldValue,
              capitalizeWords: capitalizeWords,
            ),
          ),


        ],
      ),
    );
  }
}