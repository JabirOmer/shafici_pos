import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/animations.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/screens/users_screen/edit_user_screen.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class UsersDataTable extends StatelessWidget {
  final List<UserModel> userList;
  final bool canEdit;
  final void Function() onSearchAgainClick;
  final void Function() onBackCall;

  const UsersDataTable({
    super.key,
    required this.userList,
    required this.canEdit,
    required this.onSearchAgainClick,
    required this.onBackCall,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(cardTheme: CardThemeData(color: CColors.red, elevation: 0)),
      child: Theme(
        data: Theme.of(context).copyWith(cardTheme: CardThemeData(color: CColors.white, elevation: 0)),
        child: PaginatedDataTable2(
          empty: UiNoDataFounded(
            title: 'no users are founded',
            noDataAnimation: CAnimations.emptyList,
            buttonText: 'search again',
            onButtonClick: onSearchAgainClick,
            backgroundColor: CColors.whiteShade1,
          ),
      
          headingRowDecoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CColors.primaryColor, CColors.blackShade1],
            ),
            border: Border(bottom: BorderSide(width: 1, color: CColors.red)),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(CSizes.smallRadius),
              topRight: Radius.circular(CSizes.smallRadius),
            )
          ),
          
          // rowsPerPage: userList.length >= 10 ? 10 : userList.length,
          rowsPerPage: defaultRowsPerPage,
          headingRowHeight: 60,
          dataRowHeight: 60,
          
          showFirstLastButtons: true,
          minWidth: 1000,
          columnSpacing: CSizes.mediumGap,
          renderEmptyRowsInTheEnd: false,
        
          columns: [
            DataColumn2(
              label: FittedBox(child: UiTitleWidget(text: '#', color: CColors.whiteShade1, medium: true,)),
              fixedWidth: 50,
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'first name', color: CColors.whiteShade1, medium: true,),
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'middle name', color: CColors.whiteShade1, medium: true,)
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'last name', color: CColors.whiteShade1, medium: true,)
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'phone number', color: CColors.whiteShade1, medium: true,)
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'role', color: CColors.whiteShade1, medium: true,),
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'account status', color: CColors.whiteShade1, medium: true,),
            ),
            DataColumn2(
              label: UiTitleWidget(text: 'action', color: CColors.whiteShade1, medium: true,),
              fixedWidth: 80
            ),
          ], 
          source: UsersDataTableSource(
            userList: userList,
            canEdit: canEdit,
            onEditClick: (userData) => !canEdit ? {} : CHelperFunctions.navigateToScreen(
              context: context, 
              screen: EditUserScreen(
                userData: userData,
                onBackClick: onBackCall,
              )
            ),
          ),
        ),
      ),
    );
  }
}





class UsersDataTableSource extends DataTableSource {
  final List<UserModel> userList;
  final bool canEdit;
  void Function(UserModel userData) onEditClick;

  UsersDataTableSource({
     required this.userList,
     required this.canEdit,
     required this.onEditClick,
  });

  @override
  DataRow? getRow(int index) {
    final user = userList[index];
    late Color roleColor;
    late Color statusColor;

    void getRoleColor() {
      switch (user.userRole) {
        case 'admin': roleColor = CColors.primaryColor.withValues(alpha: 0.2);
        case 'cashier': roleColor = CColors.deepOrange.withValues(alpha: 0.2);
        case 'sales': roleColor = CColors.deepPurple.withValues(alpha: 0.2);
      }
    }
    getRoleColor();

    void getStatusColor() {
      statusColor = user.isActive ? 
        CColors.green.withValues(alpha: 0.2) : 
        CColors.red.withValues(alpha: 0.2);
    }
    getStatusColor();

    return DataRow2(
      decoration: BoxDecoration(
        color: index.isEven ? CColors.white : CColors.primaryColor.withValues(alpha: 0.1)
      ),
      cells: [
        DataCell(
          UiTitleWidget(
            text: (index+1).toString().padLeft(2, '0'),
            bold: false,
          )
        ),

        // - - - F I R S T _ N A M E
        DataCell(
          UiTitleWidget(
            text: user.firstName,
            bold: false,
          )
        ),

        
        // - - - M I D D L E _ N A M E
        DataCell(
          UiTitleWidget(
            text: user.middleName,
            bold: false,
          )
        ),
        
        
        // - - - L A S T _ N A M E
        DataCell(
          UiTitleWidget(
            text: user.lastName,
            bold: false,
          )
        ),


        // - - - P H O N E _ N U M B E R
        DataCell(
          UiTitleWidget(
            text: user.phoneNumber,
            bold: false,
          )
        ),


        // - - - R O L E
        DataCell(
          Container(
            decoration: BoxDecoration(
              color: roleColor,
              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
            ),
            padding: EdgeInsets.symmetric(
              vertical: 4, 
              horizontal: CSizes.mediumGap
            ),
            child: UiTitleWidget(
              text: user.userRole,
              bold: false,
            ),
          )
        ),


        // - - - S T A T U S
        DataCell(
          Container(
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
            ),
            padding: EdgeInsets.symmetric(
              vertical: 4, 
              horizontal: CSizes.mediumGap
            ),
            child: UiTitleWidget(
              text: user.isActive ? 'active' : 'disabled',
              bold: false,
            ),
          )
        ),


        // - - - A C T I O N S
        DataCell(
          UiButtonWidget(
            icon: CIcons.editIcon,
            vericalPadding: CSizes.smallGap,
            isDisabled: !canEdit,
            onClick: () => onEditClick(user),
          )
        )
      ]
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => userList.length > 30 ? 30 : userList.length;

  @override
  int get selectedRowCount => 0;
}