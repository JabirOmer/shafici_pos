import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/data_table.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/models/customer_model.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class CustomersTableSource extends DataTableSource {
  final List<CustomerModel> customersDataList;
  final bool canEdit;
  final void Function(CustomerModel customer) onEditClick;
  final void Function(CustomerModel customer) onDeteleClick;

  CustomersTableSource({
    required this.customersDataList,
    required this.canEdit,
    required this.onEditClick,
    required this.onDeteleClick,
  });

  @override
  DataRow? getRow(int index) {
    final customer = customersDataList[index];

    return DataRow2(
      cells: [
        DataCell(
          UiTitleWidget(
            text: (index+1).toString().padLeft(2, '0'),
            bold: false,
          )
        ),

        // - - - M E T H O D _ N A M E
        DataCell(
          UiTitleWidget(
            text: customer.customerName,
            bold: false,
          )
        ),

        // - - - M E T H O D _ A C C O U N T
        DataCell(
          UiTitleWidget(
            text: customer.phoneNumber,
            bold: false,
          )
        ),

        // - - - A C T I O N S
        DataCell(
          Row(
            children: [
              UiButtonWidget(
                icon: CIcons.editIcon,
                vericalPadding: CSizes.smallGap,
                horizontalPadding: CSizes.smallGap,
                backgroundColor: CColors.whiteShade2,
                isDisabled: !canEdit,
                onClick: () => onEditClick(customer)
              ),

              SizedBox(width: CSizes.mediumGap,),

              UiButtonWidget(
                icon: CIcons.trashIcon,
                vericalPadding: CSizes.smallGap,
                horizontalPadding: CSizes.smallGap,
                backgroundColor: CColors.redDimmed,
                isDisabled: !canEdit,
                onClick: () => onDeteleClick(customer)
              )
            ]
          )
        )
      ]
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => customersDataList.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}