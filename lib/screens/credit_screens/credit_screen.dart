import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shafici_pos/blocs/cubits/credit_cubit.dart';
import 'package:shafici_pos/blocs/states/credit_state.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/shadows.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/credit_model.dart';
import 'package:shafici_pos/screens/credit_screens/credit_details_screen.dart';
import 'package:shafici_pos/services/invoice_pdf_service.dart';
import 'package:shafici_pos/services/pdf_service.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  final _searchController = TextEditingController();


  // - - - - - - F U N C T I O N S

  // -- -- --
  Future<void> _searchAgain() async {
    context.read<CreditCubit>().fetchCredits();
  }

  // -- -- --
  void _handleSearch(String? value) {}

  // -- -- --
  void _handleSearchReset() {}

  // -- -- --
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return CColors.red;
      case 'partial': return CColors.deepOrange;
      case 'completed': return CColors.green;
      default: return CColors.whiteShade3;
    }
  }

  // -- -- --
  void _navigateToDetails(CreditModel credit) {
    CHelperFunctions.navigateToScreen(context: context, screen: CreditDetailsScreen(credit: credit));
  }

  Future<void> _handleDownloadInvoice(CreditModel credit) async {
    final pdfFile = await CInvoicePdfService.generate(credit);

    CPdfService.openFile(pdfFile);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric( horizontal: CSizes.largeGap ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: CSizes.largeGap,),

          UiTitleWidget(
            text: 'Credits',
            bigger: true,
          ),

          SizedBox(height: CSizes.largeGap,),
      
          Expanded(
            child: BlocBuilder<CreditCubit, CreditState>(
              builder: (context, state) {
                // - - - L O A D I N G
                if (state.isLoading) {
                  return Center(
                    child: UiLoadingScreenWidget()
                  );
                }
            
                
                // - - - E R R O R
                if (state.errorMessage != null) {
                  return UiNoDataFounded(
                    title: state.errorMessage,
                    buttonText: 'Search again',
                    onButtonClick: _searchAgain,
                  );
                }
            
            
                // - - - E M P T Y
                if (state.filteredCreditsList.isEmpty) {
                  return UiNoDataFounded(
                    title: 'No active credit is founded',
                    buttonText: 'Search again',
                    onButtonClick: _searchAgain,
                  );
                }
            
            
                // - - - S U C C E S S
                return Column(
                  children: [
                    _topSectionMethod(),

                    SizedBox(height: CSizes.largeGap,),

                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverList.separated(
                            itemBuilder: (context, index) {
                              final credit = state.filteredCreditsList[index];
                              return _creditTileMethod(
                                index: index,
                                credit: credit,
                                onClick: () => _navigateToDetails(credit),
                                onDownloadClick: () => _handleDownloadInvoice(credit),
                              );
                            }, 
                            separatorBuilder: (context, index) => SizedBox(height: CSizes.largeGap,),
                            itemCount: state.filteredCreditsList.length,
                          ),
                        ],
                      ),
                    )

                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }




  // - - - - - -
  // - - - M E T H O D S
  // - - - - - -




  // - - -
  GestureDetector _creditTileMethod({
    required int index,
    required CreditModel credit,
    required void Function() onClick,
    required void Function() onDownloadClick
  }) {
    return GestureDetector(
      onTap: onClick,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: CColors.white,
            borderRadius: BorderRadius.circular(CSizes.xLargeGap),
            // boxShadow: CShadows.shadow1,
            border: Border.all(width: 1, color: _getStatusColor(credit.creditStatus).withAlpha(70))
          ),
          padding: EdgeInsets.all(CSizes.mediumGap),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // - - - Index
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: CColors.whiteShade1,
                        borderRadius: BorderRadius.circular(CSizes.mediumGap)
                      ),
                      child: Center(
                        child: UiTitleWidget(
                          text: (index+1).toString().padLeft(2, '0'), 
                          color: CColors.blackShade1,
                          customSize: 11,
                        )
                      ),
                    ),
                        
                    SizedBox(width: CSizes.mediumGap,),
                        
                    // - - - Customer name
                    UiTitleWidget(
                      text: credit.customer.customerName,
                      bold: false,
                    )
                  ],
                ),
              ),
        
              SizedBox(width: CSizes.mediumGap,),
        
              // - - - Credit Status
              SizedBox(
                width: 120,
                child: Row(
                  children: [
                    Container(
                      width: 10, 
                      height: 10, 
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: _getStatusColor(credit.creditStatus)
                      ),
                      margin: EdgeInsets.only(right: CSizes.smallGap),
                    ),
                    UiTitleWidget(
                      text: credit.creditStatus, color: _getStatusColor(credit.creditStatus), customSize: 12, bold: false,
                    ),
                  ],
                ),
              ),
        
              SizedBox(width: CSizes.mediumGap,),
        
              // - - - Right Side
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    UiTitleWidget(
                      text: '${CHelperFunctions.formatNumberWithComma(credit.totalAmount)} Birr',
                      bold: false,
                      defaultText: true,
                    ),
                
                    SizedBox(width: CSizes.mediumGap,),
                
                    UiButtonWidget(
                      icon: CIcons.moreIconDots,
                      vericalPadding: CSizes.smallGap,
                      horizontalPadding: CSizes.largeGap,
                      tranparent: true,
                      onClick: onClick
                    ),

                    // SizedBox(width: CSizes.mediumGap,),

                    // UiButtonWidget(
                    //   // icon: CIcons.location,
                    //   text: 'invoice',
                    //   vericalPadding: CSizes.smallGap,
                    //   horizontalPadding: CSizes.largeGap,
                    //   tranparent: true,
                    //   onClick: onDownloadClick
                    // ),
                
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }




  // - - - - - -
  // - - - - - -
  // - - - - - -




  // - - -
  IntrinsicHeight _topSectionMethod() {
    return IntrinsicHeight(
      child: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300),
            child: UiTextFieldWidget(
              label: 'Search by user name',
              defaultLabel: true,
              textController: _searchController,
              onChange: (value) => _handleSearch(value),
            ),
          ),
      
          if (_searchController.text.isNotEmpty) Container(
            margin: EdgeInsets.only(left: CSizes.mediumGap),
            child: UiButtonWidget(
              icon: CIcons.eraseIcon,
              vericalPadding: CSizes.smallGap,
              horizontalPadding: CSizes.smallGap,
              onClick: _handleSearchReset,
            ),
          ),

          Container(
            margin: EdgeInsets.only(left: CSizes.mediumGap),
            child: UiButtonWidget(
              icon: CIcons.refreshIcon,
              vericalPadding: CSizes.smallGap,
              horizontalPadding: CSizes.smallGap,
              tranparent: true,
              borderColor: CColors.primaryColor,
              onClick: _searchAgain
            )
          )
        ],
      ),
    );
  }
}