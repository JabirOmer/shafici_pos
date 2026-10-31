import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/blocs/cubits/credit_cubit.dart';
import 'package:shafici_pos/blocs/states/credit_state.dart';
import 'package:shafici_pos/constants/animations.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/shadows.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/credit_model.dart';
import 'package:shafici_pos/models/credit_record_model.dart';
import 'package:shafici_pos/models/payment_method_model.dart';
import 'package:shafici_pos/providers/payments_provider.dart';
import 'package:shafici_pos/screens/credit_screens/credit_details_widget.dart';
import 'package:shafici_pos/screens/credit_screens/new_credit_record_form.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class CreditDetailsScreen extends StatefulWidget {
  final String creditId;

  const CreditDetailsScreen({
    super.key,
    required this.creditId
  });

  @override
  State<CreditDetailsScreen> createState() => _CreditDetailsScreenState();
}

class _CreditDetailsScreenState extends State<CreditDetailsScreen> {
  bool _showRecordForm = false;
  CreditRecordModel? _deletingRecord;

  // -- -- --
  void _toggleShowRecordForm() {
    print('toggle');
    setState(() => _showRecordForm = !_showRecordForm,);
  }

  // -- -- --
  void _changeDeletingRecord(CreditRecordModel? record) {
    setState(() => _deletingRecord = record,);
  }

  // -- -- --
  Future<void> _handleDeleteRecord() async {
    if (_deletingRecord == null) return;
    context.read<CreditCubit>().deleteCreditRecord(_deletingRecord!);
    _changeDeletingRecord(null);
  }

  // -- -- --
  void _handleBack() {
    Navigator.canPop(context) ? Navigator.pop(context) : null;
  }

  void _clearErrorMessage() {
    context.read<CreditCubit>().clearErrorMessage();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
      
          // - - - - - - MAIN_CONTAINER
          BlocBuilder<CreditCubit, CreditState>(
            builder: (context, state) {
              // - - - L O A D I N G
              if (state.isLoading) {
                return UiLoadingScreenWidget(fullScreen: true, addText: true,);
              }
      
              // - - - NOT FOUNDED
              final creditData = state.creditsDataList.firstWhereOrNull((credit) => credit.creditId == widget.creditId);
              if (creditData == null) {
                return Scaffold(
                  body: UiNoDataFounded(
                    title: 'Credit data is not founded',
                    buttonText: 'back',
                    onButtonClick: _handleBack,
                  ),
                );
              }
      
              return Stack(
                children: [
      
                  // - - - M A I N
                  CreditDetailsWidget(
                    credit: creditData, 
                    onNewRecordClick: _toggleShowRecordForm, 
                    onDeleteRecordClick: (record) => _changeDeletingRecord(record),
                  ),
      
      
                  // - - - N E W _ R E C O R D _ F O R M
                  if (_showRecordForm) NewCreditRecordForm(
                    creditId: widget.creditId,
                    onCancel: _toggleShowRecordForm,
                  ),
      
                  // - - - D E L E T E _ R E C O R D _ P O P U P
                  if (_deletingRecord != null) UiPopupWidget(
                    message: 'Do you want to delete this record', 
                    primaryText: 'delete', 
                    primaryClick: _handleDeleteRecord, 
                    secondaryText: 'cancel',
                    secondaryClick: () => _changeDeletingRecord(null),
                    outSideClick: () => _changeDeletingRecord(null),
                  ),

                  // - - - E R R O R
                  if (state.errorMessage != null) UiPopupWidget(
                    message: state.errorMessage!,
                    primaryText: 'ok',
                    primaryClick: _clearErrorMessage,
                    outSideClick: _clearErrorMessage
                  )
                  
      
                ],
              );
            },
          ),
          
      
      
      
      
      
          
      
        ],
      
      ),
    );
  }

}