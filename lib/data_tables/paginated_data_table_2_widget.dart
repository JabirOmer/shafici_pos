import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/animations.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';

class PaginatedDataTable2Widget extends StatelessWidget {
  final String emptyMessage;
  final int? rowsPerPage;
  final void Function() onSearchAgainClick;
  final List<DataColumn> columns;
  final DataTableSource source;

  const PaginatedDataTable2Widget({
    super.key,
    required this.emptyMessage,
    required this.onSearchAgainClick,
    this.rowsPerPage,
    required this.columns,
    required this.source
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(cardTheme: CardThemeData(color: CColors.white, elevation: 0)),
      child: PaginatedDataTable2(

        // - - - E M P T Y
        empty: UiNoDataFounded(
          title: emptyMessage,
          noDataAnimation: CAnimations.emptyList,
          onButtonClick: onSearchAgainClick,
          backgroundColor: CColors.whiteShade1,
        ),

        // - - - D E C O R A T I O N
        headingRowDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ CColors.primaryColor, CColors.blackShade1 ],
          ),
          border: Border(bottom: BorderSide(width: 1, color: CColors.red)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(CSizes.mediumGap),
            topRight: Radius.circular(CSizes.mediumGap),
          )
        ),
        rowsPerPage: rowsPerPage ?? defaultRowsPerPage,
        headingRowHeight: 80,
        dataRowHeight: 50,
        showFirstLastButtons: true,
        minWidth: 1000,
        columnSpacing: CSizes.mediumGap,
        renderEmptyRowsInTheEnd: false,

        // - - - D A T A
        columns: columns, 
        source: source
      ),
    );
  }
}