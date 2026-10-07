import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'package:shafici_pos/screens/credit_screens/new_credit_record_form.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class CreditDetailsScreen extends StatefulWidget {
  final CreditModel credit;

  const CreditDetailsScreen({
    super.key,
    required this.credit
  });

  @override
  State<CreditDetailsScreen> createState() => _CreditDetailsScreenState();
}

class _CreditDetailsScreenState extends State<CreditDetailsScreen> {
  bool _showRecordForm = false;
  bool _showDeleteRecordPopup = false;

  double _totalPaid = 0;
  double _remaingBalance = 0;

  Color _getStatusColor() {
    switch (widget.credit.creditStatus) {
      case 'pending': return CColors.redDimmed;
      case 'partial': return CColors.deepOrange;
      case 'completed': return CColors.green;
      default: return CColors.whiteShade3;
    }
  }

  // - - - 
  void _toggleShowRecordForm() {
    setState(() => _showRecordForm = !_showRecordForm,);
  }

  void _toggleShowDeleteRecord() {
    setState(() => _showDeleteRecordPopup = !_showDeleteRecordPopup,);
  }

  // -- -- --
  Future<void> _addNewRecord() async {}

  // -- -- --
  Future<void> _handleDeleteRecord(String recordId) async {}


  // 


  // - - - - - -
  @override
  void initState() {
    super.initState();
    _calCulateTotalPaid();
  }

  void _calCulateTotalPaid() {
    double paid = 0;
    for (var record in widget.credit.records) { paid = paid+(record.amountPaid); }
    double balance = widget.credit.totalAmount - paid;

    setState(() {
      _totalPaid = paid;
      _remaingBalance = balance < 0 ? 0 : balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // - - - - - - MAIN_CONTAINER
          ListView(
            children: [
              
              ConstrainedBox(
                constraints: BoxConstraints( minHeight: CHelperFunctions.availableScreenHeight(context: context) ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints( maxWidth: 800 ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CColors.white,
                            boxShadow: CShadows.shadow1,
                            borderRadius: BorderRadius.circular(CSizes.largeGap)
                          ),
                          padding: EdgeInsets.all(CSizes.largeGap),
                          margin: EdgeInsets.all(CSizes.largeGap),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              UiTitleWidget(
                                text: 'Customer',
                                bigger: true,
                              ),

                              SizedBox(height: CSizes.mediumGap,),
                              
                              Container(
                                decoration: BoxDecoration(
                                  color: CColors.whiteShade1,
                                  borderRadius: BorderRadius.circular(CSizes.largeGap),
                                  border: Border.all(width: 1, color: CColors.whiteShade2)
                                ),
                                padding: EdgeInsets.all(CSizes.mediumGap),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        UiTitleWidget(text: 'name', bold: false,),
                                        UiTitleWidget(text: widget.credit.customer.customerName),
                                      ],
                                    ),
                
                                    SizedBox(height: CSizes.smallGap,),
                              
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        UiTitleWidget(text: 'phone number', bold: false,),
                                        UiTitleWidget(text: widget.credit.customer.phoneNumber),
                                      ],
                                    ),

                                    SizedBox(height: CSizes.smallGap,),
                              
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        UiTitleWidget(text: 'address', bold: false,),
                                        UiTitleWidget(text: widget.credit.customer.address ?? '---'),
                                      ],
                                    ),

                                    SizedBox(height: CSizes.smallGap,),
                              
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        UiTitleWidget(text: 'tin number', bold: false,),
                                        UiTitleWidget(text: widget.credit.customer.tinNumber ?? '---'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: CSizes.largeGap,),


                              UiTitleWidget(
                                text: 'Credit info',
                                bigger: true,
                              ),

                              SizedBox(height: CSizes.mediumGap,),
                        
                              Container(
                                decoration: BoxDecoration(
                                  color: CColors.whiteShade1,
                                  borderRadius: BorderRadius.circular(CSizes.largeGap),
                                  border: Border.all(width: 1, color: CColors.whiteShade2)
                                ),
                                padding: EdgeInsets.all(CSizes.largeGap),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        UiTitleWidget(text: 'Credit status', bold: false,),
                                        Row(
                                          children: [
                                            Container(
                                              width: 10, 
                                              height: 10, 
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                color: _getStatusColor()
                                              ),
                                              margin: EdgeInsets.only(right: CSizes.smallGap),
                                            ),
                                            UiTitleWidget(text: widget.credit.creditStatus, color: _getStatusColor(), bold: false, customSize: 12,),
                                          ],
                                        )
                                      ],
                                    ),
                
                                    SizedBox(height: CSizes.mediumGap,),
                
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        UiTitleWidget(text: 'Total amount', bold: false,),
                                        UiTitleWidget(text: '${CHelperFunctions.formatNumberWithComma(widget.credit.totalAmount)} Birr', defaultText: true,),
                                      ],
                                    ),
                
                                    SizedBox(height: CSizes.mediumGap,),
                
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        UiTitleWidget(text: 'Total paid', bold: false,),
                                        UiTitleWidget(text: '${CHelperFunctions.formatNumberWithComma(_totalPaid)} Birr', defaultText: true,),
                                      ],
                                    ),

                                    SizedBox(height: CSizes.mediumGap,),
                
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        UiTitleWidget(text: 'Remaining balance', bold: false,),
                                        UiTitleWidget(text: '${CHelperFunctions.formatNumberWithComma(_remaingBalance)} Birr', defaultText: true,),
                                      ],
                                    ),

                                    SizedBox(height: CSizes.mediumGap,),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        UiTitleWidget(text: 'Issue date', bold: false,),
                                        UiTitleWidget(text: CHelperFunctions.formatDateTime(widget.credit.createdAt)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
          
                              SizedBox(height: CSizes.largeGap,),

                              UiTitleWidget(
                                text: 'Items',
                                bigger: true,
                              ),

                              SizedBox(height: CSizes.mediumGap,),

                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: widget.credit.items.length,
                                itemBuilder: (context, index) {
                                  final item = widget.credit.items[index];
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: CSizes.mediumGap),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              UiTitleWidget( text: (index+1).toString().padLeft(2, '0') ),
                                              SizedBox(width: CSizes.smallGap,),
                                              UiTitleWidget( text: item.productName ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(width: CSizes.mediumGap,),

                                        UiTitleWidget( text: '${(item.quantity).toString().padLeft(2, '0')} * ' ),
                                        UiTitleWidget( text: '${CHelperFunctions.formatNumberWithComma(item.unitSoldAt)} Birr', defaultText: true, ),

                                        
                                      ],
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: CSizes.largeGap,),

                              UiTitleWidget(
                                text: 'Records',
                                bigger: true,
                              ),

                              SizedBox(height: CSizes.mediumGap,),
          
                              if (widget.credit.records.isEmpty) UiNoDataFounded(
                                title: 'No records are founded',
                                // noDataAnimation: CAnimations.manLookingEmptyList,
                              ),
          
                              if (widget.credit.records.isNotEmpty) ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final record = widget.credit.records[index];
                                  return _recordTileMethod(
                                    index: index,
                                    record: record
                                  );
                                }, 
                                separatorBuilder: (context, index) => SizedBox(height: CSizes.mediumGap,), 
                                itemCount: widget.credit.records.length
                              ),

                              SizedBox(height: CSizes.largeGap,),
          
                              Row(
                                children: [
                                  Expanded(
                                    child: UiButtonWidget(
                                      text: 'back',
                                      tranparent: widget.credit.totalAmount < _totalPaid,
                                      horizontalPadding: 0,
                                      onClick: () => Navigator.pop(context)
                                    )
                                  ),
          
                                  SizedBox(width: CSizes.mediumGap,),
          
                                  Expanded(
                                    child: UiButtonWidget(
                                      text: 'add new record',
                                      horizontalPadding: 0,
                                      isDisabled: widget.credit.totalAmount >= _totalPaid,
                                      // isDisabled: true,
                                      onClick: _toggleShowRecordForm,
                                    )
                                  )
                                ],
                              )
                        
                            ],
                          ),
                        ),
                      ),
                    )
                
                  ],
                ),
              ),
            ],
          ),
          



          // - - - - - - N E W _ R E C O R D _ F O R M
          if (_showRecordForm) NewCreditRecordForm(
            credit: widget.credit,
            onCancel: _toggleShowRecordForm,
          )

        ],

      ),
    );
  }




  // -
  // -
  // -




  // - - -
  Container _recordTileMethod({
    required int index,
    required CreditRecordModel record,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: CColors.whiteShade2),
        borderRadius: BorderRadius.circular(CSizes.xLargeGap)
      ),
      padding: EdgeInsets.all(CSizes.mediumGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Expanded(
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: CColors.whiteShade2,
                    borderRadius: BorderRadius.circular(CSizes.mediumGap)
                  ),
                  margin: EdgeInsets.only(right: CSizes.mediumGap),
                  child: Center(
                    child: UiTitleWidget(
                      text: (index+1).toString().padLeft(2, '0'),
                      customSize: 10,
                    )
                  ),
                ),
                    
                UiTitleWidget(text: '${CHelperFunctions.formatNumberWithComma(record.amountPaid)} Birr', defaultText: true, bold: false,),
              ],
            ),
          ),

          SizedBox(width: CSizes.mediumGap,),

          UiTitleWidget(text: record.paymentName, capitalizeWords: true, bold: false,),

          SizedBox(width: CSizes.mediumGap,),

          Expanded(child: UiTitleWidget(text: CHelperFunctions.formatDateTime(record.createdAt), bold: false, textAlign: TextAlign.end,)),    

          // Row(
          //   children: [
          //     UiTitleWidget(text: CHelperFunctions.formatDateTime(record.createdAt), defaultText: true, bold: false,),
          //     SizedBox(width: CSizes.mediumGap,),
          //     UiButtonWidget(
          //       icon: CIcons.trashIcon,
          //       vericalPadding: CSizes.smallGap,
          //       horizontalPadding: CSizes.smallGap,
          //       backgroundColor: CColors.redDimmed,
          //       color: CColors.red,
          //       onClick: () => _handleDeleteRecord(record.recordId)
          //     )
          //   ],
          // )

        ],
      ),
    );
  }

}