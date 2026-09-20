import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/data_tables/paginated_data_table_2_widget.dart';
import 'package:shafici_pos/data_tables/source/payments_table_source.dart';
import 'package:shafici_pos/models/payment_method_model.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/payments_provider.dart';
import 'package:shafici_pos/screens/payments_screen/edit_payment_popup.dart';
import 'package:shafici_pos/screens/payments_screen/register_payment_popup.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:provider/provider.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<PaymentsScreen> {
  bool _canEdit = false;
  final TextEditingController _searchController = TextEditingController();
  List<PaymentMethodModel> _filteredMethodList = [];

  bool _showPaymentRegisterPopup = false;
  PaymentMethodModel? _paymentToBeEdited;


  // - - - - - - >>
  // - - - F U N C T I O N S
  void _reloadPaymentsData() {
    final paymentMethodsProvider = Provider.of<PaymentMethodsProvider>(context, listen: false);
    paymentMethodsProvider.setPaymentMethods();
    setState(() => _searchController.clear());
  }

  void _handleSearch(String? value) {
    final paymentMethodsProvider = Provider.of<PaymentMethodsProvider>(context, listen: false);
    if (value == null) {
      _filteredMethodList.clear();
    } else {
      _filteredMethodList = paymentMethodsProvider.paymentMethods.where((p) => p.paymentName.toLowerCase().contains(value.toLowerCase())).toList();
    }
    setState(() {});
  }

  void _handleSearchReset() {
    setState(() {
      _filteredMethodList.clear();
      _searchController.clear();
    });
  }

  void _toggleShowPaymentRegisterPopup({ bool reload = false }) {
    setState(() => _showPaymentRegisterPopup = !_showPaymentRegisterPopup,);
    if (reload) _reloadPaymentsData();
  }

  void _toggleShowPaymentEditPopup(PaymentMethodModel? payment, {bool reload = false}) {
    setState(() => _paymentToBeEdited = payment,);
    if (reload) _reloadPaymentsData();
  }
  // - - - F U N C T I O N S
  // - - - - - - >>


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final AppInfoProvider appInfoProvider = Provider.of(context, listen: false);
    final UserModel userData = appInfoProvider.currentUser!;
    setState(() => _canEdit = userData.canEditInventory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [


          // - - - M A I N _ W I N D O W
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: CSizes.largeGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: CSizes.largeGap,),
            
                UiTitleWidget(
                  text: 'payment methods',
                  bigger: true,
                ),
            
                SizedBox(height: CSizes.largeGap,),
            
                // - - - T O P _ S E C T I O N
                _topSectionMethod(),
          
                SizedBox(height: CSizes.largeGap,),
          
                // - - - P A Y M E N T _ M E T H O D S _ T A B L E
                Expanded(
                  child: Consumer<PaymentMethodsProvider>(
                    builder: (context, provider, child) {
                      // - - - L O A D I N G
                      if (provider.isLoading) return UiLoadingScreenWidget();
                  
                      // - - - E R R O R
                      if (provider.errorMessage != null) {
                        return UiPopupWidget(
                          message: provider.errorMessage!, 
                          primaryText: 'seach again', 
                          primaryClick: provider.setPaymentMethods, 
                          outSideClick: () {},
                          isDimmed: false,
                        );
                      }
                  
                      // - - - N O _ P A Y M E N T S
                      if (provider.paymentMethods.isEmpty) {
                        return UiNoDataFounded(
                          title: 'no payment is registered',
                          buttonText: _canEdit ? 'register now' : null,
                          onButtonClick: _canEdit ? _toggleShowPaymentRegisterPopup : null,
                        );
                      }

                      return PaginatedDataTable2Widget(
                        emptyMessage: 'no payment methods are founded', 
                        onSearchAgainClick: _reloadPaymentsData, 
                        columns: [
                          DataColumn2(
                            label: FittedBox(child: UiTitleWidget(text: '#', color: CColors.whiteShade1, medium: true,)),
                            fixedWidth: 50,
                          ),
                          DataColumn2(
                            label: UiTitleWidget(text: 'method name', color: CColors.whiteShade1, medium: true,),
                          ),
                          DataColumn2(
                            label: UiTitleWidget(text: 'account', color: CColors.whiteShade1, medium: true,),
                          ),
                          DataColumn2(
                            label: UiTitleWidget(text: 'last update', color: CColors.whiteShade1, medium: true,),
                          ),
                          DataColumn2(
                            label: UiTitleWidget(text: 'action', color: CColors.whiteShade1, medium: true,),
                            fixedWidth: 80
                          ),
                        ], 
                        source: PaymentsTableSource(
                          paymentMethodsList: _searchController.text.isNotEmpty ? _filteredMethodList : provider.paymentMethods,
                          canEdit: _canEdit,
                          onEditClick: (method) => _toggleShowPaymentEditPopup(method),
                        )
                      );
                    },
                  ),
                ),
          
                SizedBox(height: CSizes.largeGap,),
                
              ]
            )
          ),



          // - - - R E G I S T E R _ P A Y M E N T _ P O P U P
          if (_showPaymentRegisterPopup) RegisterPaymentPopup(
            onBackCall: (reload) => _toggleShowPaymentRegisterPopup(reload: reload)
          ),



          // - - - E D I T _ P A Y M E N T _ P O P U P
          if (_paymentToBeEdited != null) EditPaymentPopup(
            paymentMethod: _paymentToBeEdited!,
            onBackCall: (reload) => _toggleShowPaymentEditPopup(null, reload: reload)
          ),

        ],
      )
    );
  }




  // - - - - - -
  // - - - M E T H O D S
  // - - - - - -




  // 
  IntrinsicHeight _topSectionMethod() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300),
                child: UiTextFieldWidget(
                  label: 'Search method',
                  defaultLabel: true,
                  textController: _searchController,
                  onChange: (value) => _handleSearch(value),
                ),
              ),

              if (_searchController.text.isNotEmpty) Container(
                margin: EdgeInsets.only(left: CSizes.mediumGap,),
                child: UiButtonWidget(
                  icon: CIcons.eraseIcon,
                  vericalPadding: CSizes.smallGap,
                  horizontalPadding: CSizes.smallGap,
                  onClick: _handleSearchReset,
                ),
              ),

              SizedBox(width: CSizes.mediumGap,),
          
              UiButtonWidget(
                icon: CIcons.refreshIcon,
                vericalPadding: CSizes.smallGap,
                horizontalPadding: CSizes.smallGap,
                tranparent: true,
                onClick: _reloadPaymentsData
              )
            ],
          ),
      
          if (_canEdit) UiButtonWidget(
            text: 'add new method',
            icon: CIcons.addIcon, 
            vericalPadding: CSizes.smallGap,
            isDisabled: !_canEdit,
            onClick: _toggleShowPaymentRegisterPopup
          ),
        ],
      ),
    );
  }
}