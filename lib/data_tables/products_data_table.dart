import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/animations.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/screens/products_screen/product_details_screen.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class ProductsDataTable extends StatelessWidget {
  final List<ProductModel> productList;
  final void Function() onSearchAgainClick;

  const ProductsDataTable({
    super.key,
    required this.productList,
    required this.onSearchAgainClick
  });

  @override
  Widget build(BuildContext context) {
    // print(productList.length >= 10 ? 10 : defaultRowsPerPage);
    return Theme(
      data: Theme.of(context).copyWith(cardTheme: CardThemeData(color: CColors.red, elevation: 0)),
      child: Theme(
        data: Theme.of(context).copyWith(cardTheme: CardThemeData(color: CColors.white, elevation: 0)),
        child: PaginatedDataTable2(

          // Empty
          empty: UiNoDataFounded(
            title: 'no products are founded',
            noDataAnimation: CAnimations.emptyList,
            // buttonText: 'Seach again',
            // onButtonClick: onSearchAgainClick,
            backgroundColor: CColors.whiteShade1,
          ),
      

          // Decoration
          headingRowDecoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CColors.primaryColor, CColors.blackShade1],
            ),
            border: Border(bottom: BorderSide(width: 1, color: CColors.red)),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(CSizes.largeGap),
              topRight: Radius.circular(CSizes.largeGap),
            )
          ),
          
          // rowsPerPage: productList.length >= 30 ? 30 : defaultRowsPerPage,
          headingRowHeight: 80,
          dataRowHeight: 50,
          autoRowsToHeight: true,
          
          showFirstLastButtons: true,
          minWidth: 1000,
          columnSpacing: CSizes.mediumGap,
          renderEmptyRowsInTheEnd: false,
        
          // Columns
          columns: [
            DataColumn2(
              label: FittedBox(child: UiTitleWidget(text: '#', color: CColors.whiteShade1, medium: true,)),
              fixedWidth: 50,
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'product name', color: CColors.whiteShade1, medium: true,),
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'barcode', color: CColors.whiteShade1, medium: true,)
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'category', color: CColors.whiteShade1, medium: true,)
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'stock', color: CColors.whiteShade1, medium: true,)
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'price', color: CColors.whiteShade1, medium: true,)
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'expire date', color: CColors.whiteShade1, medium: true,)
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'action', color: CColors.whiteShade1, medium: true,),
              fixedWidth: 80
            ),
          ], 
          source: ProductsDataTableSource(
            productList: productList,
            openDetail: (product) => CHelperFunctions.navigateToScreen(context: context, screen: ProductDetailsScreen(product: product)),
          ),
        ),
      ),
    );
  }
}




class ProductsDataTableSource extends DataTableSource {
  final List<ProductModel> productList;
  void Function(ProductModel product) openDetail;

  ProductsDataTableSource({
     required this.productList,
     required this.openDetail,
  });

  @override
  DataRow? getRow(int index) {
    final product = productList[index];
    late String stockStatus;
    late Color stockStatusColor;

    void getStockStatus() {
      if (product.stock <= 0) {
        stockStatus = 'out of stock';
        stockStatusColor = CColors.red.withValues(alpha: 0.3);
      } 
      else if (product.stock <= product.alertQuantity) {
        stockStatus = 'low stock';
        stockStatusColor = CColors.deepOrange.withValues(alpha: 0.3);
      } 
      else {
        stockStatus = 'available';
        stockStatusColor = CColors.green.withValues(alpha: 0.3);
      } 
    }
    getStockStatus();

    bool isExpired = product.expireDate != null && product.expireDate!.isBefore(DateTime.now());

    return DataRow2(
      decoration: BoxDecoration(
        color: index.isEven ? CColors.white : CColors.primaryColor.withValues(alpha: 0.1),
      ),
      cells: [
        DataCell(
          UiTitleWidget(
            text: (index+1).toString().padLeft(2, '0'),
            bold: false,
          )
        ),

        // - - - P R O D U C T _ N A M E
        DataCell(
          UiTitleWidget(
            text: product.productName,
            bold: false,
          )
        ),

        // - - - B A R C O D E
        DataCell(
          UiTitleWidget(
            text: product.productBarcode,
            bold: false,
          )
        ),

        // - - - C A T E G O R Y
        DataCell(
          UiTitleWidget(
            text: product.categoryName,
            bold: false,
          )
        ),

        // - - - S T O C K
        DataCell(
          Container(
            decoration: BoxDecoration(
              color: stockStatusColor,
              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
            ),
            padding: EdgeInsets.symmetric(
              vertical: 4, 
              horizontal: CSizes.mediumGap
            ),
            child: Text(
              CHelperFunctions.capitalizeWords(stockStatus),
            ),
          )
        ),

        // - - - P R I C E
        DataCell(
          UiTitleWidget(
            text: '${CHelperFunctions.formatNumberWithComma(product.sellingPrice)} Birr',
            capitalizeWords: true,
            bold: false,
          )
        ),

        // - - - E X P I R E _ D A T E
        DataCell(
          isExpired ? Container(
            decoration: BoxDecoration(
              color: CColors.red.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
            ),
            padding: EdgeInsets.symmetric(
              vertical: 4, 
              horizontal: CSizes.mediumGap
            ),
            child: Text(
              'Expired',
            ),
          ) : UiTitleWidget(
            text: product.expireDate == null ? '- - -' : CHelperFunctions.formatDateTime(product.expireDate!,),
            defaultText: true,
            bold: false,
          )
        ),

        // - - - A C T I O N S
        DataCell(
          UiButtonWidget(
            icon: CIcons.eyeOpen,
            vericalPadding: CSizes.smallGap,
            onClick: () => openDetail(product),
          )
        )
      ]
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  // int get rowCount => productList.length > 30 ? 30 : productList.length;
  int get rowCount => productList.length;

  @override
  int get selectedRowCount => 0;
}