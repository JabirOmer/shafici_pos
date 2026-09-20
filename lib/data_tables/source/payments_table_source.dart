import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/payment_method_model.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class PaymentsTableSource extends DataTableSource {
  final List<PaymentMethodModel> paymentMethodsList;
  final bool canEdit;
  final void Function(PaymentMethodModel method) onEditClick;

  PaymentsTableSource({
    required this.paymentMethodsList,
    required this.canEdit,
    required this.onEditClick
  });

  @override
  DataRow? getRow(int index) {
    final method = paymentMethodsList[index];

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
            text: method.paymentName,
            bold: false,
          )
        ),

        // - - - M E T H O D _ A C C O U N T
        DataCell(
          UiTitleWidget(
            text: method.paymentAccount ?? '---',
            bold: false,
          )
        ),

        // - - - L A S T _ U P D A T E D
        DataCell(
          UiTitleWidget(
            text: CHelperFunctions.formatDateTime(method.updatedAt, addTime: true),
            bold: false,
            defaultText: true,
          )
        ),

        // - - - A C T I O N S
        DataCell(
          UiButtonWidget(
            icon: CIcons.editIcon,
            vericalPadding: CSizes.smallGap,
            onClick: () => onEditClick(method),
            isDisabled: !canEdit,
          )
        )
      ]
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => paymentMethodsList.length;

  @override
  int get selectedRowCount => 0;

}