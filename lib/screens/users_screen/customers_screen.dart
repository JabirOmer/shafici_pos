import 'dart:ui';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shafici_pos/blocs/cubits/customer_cubit.dart';
import 'package:shafici_pos/blocs/states/customer_state.dart';
import 'package:shafici_pos/constants/animations.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/data_tables/paginated_data_table_2_widget.dart';
import 'package:shafici_pos/data_tables/source/customers_table_source.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/customer_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_animated_mini_message_widget.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_form_message.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _secureStorageService = CSecureStorageService();
  final _apiServices = CApiServices();

  final digitsOnlyRegex = RegExp(r'^\d+$');

  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _tinNumberController = TextEditingController();
  bool _showRegisterForm = false;
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // - - -
  String? _validateCustomerName(String? value) {
    if (value == null || value.isEmpty) return 'customer name is missing';
    return null;
  }
  String? _validateCustomerPhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'phone number is missing';
    if (!digitsOnlyRegex.hasMatch(value)) return 'Only digits (0-9) are allowed.';
    if (value.length < 10) return 'Phone number should be 10 digits';
    if (int.tryParse(value) == null) return 'invalid phone number';
    return null;
  }

  // - - - 
  void _refreshCustomers() {
    context.read<CustomerCubit>().fetchCustomers();
  }

  // -- -- --
  void _toggleShowRegisterForm() {
    if (!mounted) return;
    _clearMessages();
    _customerNameController.clear();
    _customerPhoneNumberController.clear();
    setState(() => _showRegisterForm = !_showRegisterForm);
  }


  // -- -- --
  void _toggleEditCustomer(CustomerModel customer) {}


  // -- -- --
  void _toggleDeleteCustomer(CustomerModel customer) {}

  
  // -- -- --
  Future<void> _handleFormSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_isLoading) return;

      setState(() => _isLoading = true,);

      try {
        final branchId = context.read<AppInfoProvider>().deviceData?.branchId;
        final dataMap = {
          "branch_id": branchId,
          "customer_name": _customerNameController.text.trim(),
          "customer_number": _customerPhoneNumberController.text.trim(),
          "address": _addressController.text.trim(),
          "tin_number": _tinNumberController.text.trim(),
        };
        
        final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
        final response = await _apiServices.postRequest(url: CUrlStrings.registerCustomer, data: dataMap, authToken: deviceToken);
        if (!mounted) return;
        
        switch (response.statusCode) {
          case 201: {
            _successMessage = response.data['msg'];
            context.read<CustomerCubit>().fetchCustomers();
          }

          default: _errorMessage = response.data;
        }
      } 
      catch (e) {
        _errorMessage = 'Failed to register user';
      }
      finally {
        setState(() => _isLoading = false);
        await Future.delayed(Duration(seconds: 2));
        _toggleShowRegisterForm();
      }
    }
  }


  // -- -- --
  void _clearMessages() {
    setState(() {
      _successMessage = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [


        // - - - - - - M A I N
        Scaffold(
          body: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: CSizes.largeGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: CSizes.largeGap,),
            
                UiTitleWidget(text: 'Customers', bigger: true,),
                
                SizedBox(height: CSizes.largeGap,),
        
                Expanded(
                  child: BlocBuilder<CustomerCubit, CustomerState>(
                    builder: (context, state) {
                      // - - - L O A D I N G
                      if (state.isLoading) {
                        return UiLoadingScreenWidget();
                      }
        
                      // - - - E R R O R
                      if (state.errorMessage != null) {
                        return UiNoDataFounded(
                          noDataAnimation: CAnimations.manLookingEmptyList,
                          title: state.errorMessage,
                          buttonText: 'search again',
                          onButtonClick: _refreshCustomers,
                        );
                      }
        
                      // - - - E M P T Y
                      if (state.filteredCustomersList.isEmpty) {
                        return UiNoDataFounded(
                          title: 'No customers are founded',
                          buttonText: 'register now',
                          onButtonClick: _toggleShowRegisterForm,
                          secondaryText: 'search again',
                          onSecondaryBtnClick: _refreshCustomers,
                        );
                      }
        
                      // - - - C U S T O M E R S _ L I S T
                      return CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _topSectionMethod(),
                          ),

                          SliverToBoxAdapter(
                            child: SizedBox(height: CSizes.largeGap,),
                          ),

                          SliverFillRemaining(
                            child: PaginatedDataTable2Widget(
                              emptyMessage: 'No customers are founded', 
                              onSearchAgainClick: () {}, 
                              columns: [
                                DataColumn2(
                                  label: FittedBox(child: UiTitleWidget(text: '#', color: CColors.whiteShade1, medium: true,)),
                                  fixedWidth: 50,
                                ),
                                DataColumn2(
                                  label: UiTitleWidget(text: 'customer name', color: CColors.whiteShade1, medium: true,),
                                ),
                                DataColumn2(
                                  label: UiTitleWidget(text: 'phone number', color: CColors.whiteShade1, medium: true,),
                                ),
                                DataColumn2(
                                  label: UiTitleWidget(text: 'Address', color: CColors.whiteShade1, medium: true,),
                                ),
                                DataColumn2(
                                  label: UiTitleWidget(text: 'Tin', color: CColors.whiteShade1, medium: true,),
                                ),
                                // DataColumn2(
                                //   label: UiTitleWidget(text: 'actions', color: CColors.whiteShade1, medium: true,),
                                //   fixedWidth: 100
                                // ),
                              ], 
                              source: CustomersTableSource(
                                customersDataList: state.filteredCustomersList, 
                                canEdit: context.read<AppInfoProvider>().currentUser?.canEditInventory ?? false, 
                                onEditClick: (customer) => _toggleEditCustomer(customer), 
                                onDeteleClick: (customer) => _toggleDeleteCustomer(customer)
                              )
                            ),
                          )

                        ],
                      );
                    },
                  )
                )
              ],
            ),
          ),
        ),



        // - - - - - - R E G I S T E R _ C U S T O M E R
        if (_showRegisterForm) ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
            child: Scaffold(
              backgroundColor: CColors.dimmedBackgound,
              body: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints( maxWidth: 600 ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CColors.white,
                      borderRadius: BorderRadius.circular(CSizes.largeGap)
                    ),
                    padding: EdgeInsets.all(CSizes.largeGap),
                    margin: EdgeInsets.all(CSizes.largeGap),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          UiTitleWidget(text: 'Register new customer', medium: true,),
                                  
                          SizedBox(height: CSizes.largeGap,),
                      
                          UiTextFieldWidget(
                            textController: _customerNameController,
                            label: 'customer name',
                            validator: (value) => _validateCustomerName(value),
                            fieldSubmit: (_) => _handleFormSubmit(),
                          ),
                          
                          SizedBox(height: CSizes.largeGap,),
                          
                          UiTextFieldWidget(
                            textController: _customerPhoneNumberController,
                            label: 'phone number',
                            validator: (value) => _validateCustomerPhoneNumber(value),
                          ),
                      
                          SizedBox(height: CSizes.largeGap,),
                          
                          UiTextFieldWidget(
                            textController: _addressController,
                            label: 'address',
                          ),
                      
                          SizedBox(height: CSizes.largeGap,),
                          
                          UiTextFieldWidget(
                            textController: _tinNumberController,
                            label: 'tin number',
                          ),
                      
                          SizedBox(height: CSizes.largeGap,),
                      
                          UiFormMessage(
                            message: _successMessage ?? _errorMessage,
                            isSuccess: _successMessage != null,
                          ),
                          
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: CSizes.mediumGap),
                                  child: UiButtonWidget(
                                    tranparent: true,
                                    text: 'cancel',
                                    isDisabled: _isLoading,
                                    onClick: _toggleShowRegisterForm,
                                  ),
                                ),
                              ),
                                  
                              Expanded(
                                child: UiButtonWidget(
                                  text: _isLoading ? 'Loading...' : 'submit',
                                  isDisabled: _isLoading,
                                  onClick: _handleFormSubmit,
                                ),
                              ),
                                  
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )



      ],
    );
  }




  // - - - - - -
  // - - - M E T H O D S
  // - - - - - -




  // - - - 
  IntrinsicHeight _topSectionMethod() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // ConstrainedBox(
              //   constraints: BoxConstraints(maxWidth: 300),
              //   child: UiTextFieldWidget(
              //     label: 'Search customer name or number',
              //     defaultLabel: true,
              //     // textController: _searchController,
              //     // onChange: (value) => _handleSearch(value),
              //   ),
              // ),

              // // if (_searchController.text.isNotEmpty) Container(
              // Container(
              //   margin: EdgeInsets.only(left: CSizes.mediumGap,),
              //   child: UiButtonWidget(
              //     icon: CIcons.eraseIcon,
              //     vericalPadding: CSizes.smallGap,
              //     horizontalPadding: CSizes.smallGap,
              //     // onClick: _handleSearchReset,
              //     onClick: () {},
              //   ),
              // ),

              // SizedBox(width: CSizes.mediumGap,),
          
              UiButtonWidget(
                icon: CIcons.refreshIcon,
                vericalPadding: CSizes.smallGap,
                horizontalPadding: CSizes.smallGap,
                tranparent: true,
                onClick: _refreshCustomers
              )
            ],
          ),
      
          UiButtonWidget(
            text: 'register customer',
            icon: CIcons.addIcon, 
            vericalPadding: CSizes.smallGap,
            // isDisabled: !_canEdit,
            onClick: _toggleShowRegisterForm
          ),
        ],
      ),
    );
  }
}