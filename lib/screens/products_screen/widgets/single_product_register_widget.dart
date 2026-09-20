import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/shared_prefs_keys.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/product_category_model.dart';
import 'package:shafici_pos/models/register_product_model.dart';
import 'package:shafici_pos/screens/products_screen/register_products_screen.dart';
import 'package:shafici_pos/services/shared_preferences_services.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_drop_down_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:shafici_pos/ui/ui_toggle_button_widget.dart';

class SingleProductRegisterWidget extends StatefulWidget {
  final List<ProductCategoryModel> categoryList;
  final void Function(Map<String, dynamic> productMap) onSubmit;
  final void Function() onBack;
  final void Function(RegisterProductType type) onBulkClick;

  const SingleProductRegisterWidget({
    super.key,
    required this.categoryList,
    required this.onSubmit,
    required this.onBack,
    required this.onBulkClick,
  });

  @override
  State<SingleProductRegisterWidget> createState() => _SingleProductRegisterWidgetState();
}

class _SingleProductRegisterWidgetState extends State<SingleProductRegisterWidget> {
  final CSharedPreferencesServices _sharedPreferencesServices = CSharedPreferencesServices();

  final GlobalKey<FormState> _productFormKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _barcodeController = TextEditingController();
  bool _openCategoriesDropDown = false;
  ProductCategoryModel? _selectedCategory;
  final _expireDateController = TextEditingController();
  bool _basedOnUSD = true;
  bool _isTaxable = false;
  late String _exchangeRate;
  final _usdCostController = TextEditingController();
  final _birrCostController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _profitController = TextEditingController();
  final _stockQtyController = TextEditingController();
  final _alertQtyController = TextEditingController();

  // - - - - - - >>
  // - - - V A L I D A T O R S
  String? _validateProductName(String? value) {
    if (value == null || value.isEmpty) return 'product name is missing';
    return null;
  }


  String? _validateUSDCost(String? value) {
    if (!_basedOnUSD) return null;
    if (value == null || value.isEmpty) return 'USD cost is missing';
    if (double.tryParse(value) == null) return 'invalid USD price';
    return null;
  }


  String? _validateBirrCost(String? value) {
    if (_basedOnUSD) return null;
    if (value == null || value.isEmpty) return 'Cost is missing';
    if (double.tryParse(value) == null) return 'Invalid price';
    return null;
  }

  String? _validateSellingPrice(String? value) {
    if (value == null || value.isEmpty) return 'selling price is missing';
    if (double.tryParse(value) == null) return 'invalid price';
    return null;
  }
  
  // String? _validateProfit(String? value) {
  //   double? sellingPrice = double.tryParse(_sellingPriceController.text);
  //   double? costInBirr = double.tryParse(_birrCostController.text);
  //   if (sellingPrice == null || costInBirr == null) return null;
  //   if (value == null || value.isEmpty) return 'profit is missing';
  //   if (double.tryParse(value) == null) return 'invalid profit';
  //   if (double.parse(value) < 1) return 'loss calculation';
  //   return null;
  // }

  String? _validateProfit(String? value) {
    if (value == null || value.isEmpty) return 'profit is missing';
    final formattedValue = CHelperFunctions.formatStringToDouble(value);
    if (formattedValue == null) return 'invalid profit';
    if (formattedValue < 1) return 'loss calculation';
    return null;
  }

  String? _validateStockQty(String? value) {
    if (value == null || value.isEmpty) return 'stock quantity is missing';
    if (int.tryParse(value) == null) return 'invalid quantity';
    if (int.parse(value).isNegative) return 'invalid quantity';
    return null;
  }

  String? _validateAlertQty(String? value) {
    if (value == null || value.isEmpty) return 'alert quantity is missing';
    if (int.tryParse(value) == null) return 'invalid quantity';
    if (int.parse(value).isNegative) return 'invalid quantity';
    return null;
  }

  // - - - V A L I D A T O R S
  // - - - - - - >>



  // - - - - - - >>
  // - - - F U N C T I O N S
  void _resetForm() {
    _productNameController.clear();
    _barcodeController.clear();
    _expireDateController.clear();
    _usdCostController.clear();
    _birrCostController.clear();
    _sellingPriceController.clear();
    _profitController.clear();
    _stockQtyController.clear();
    _alertQtyController.clear();
    setState(() {
      _openCategoriesDropDown = false;
      _selectedCategory = null;
    });
  }

  void _toggleCategoryListOpen() {
    setState(() => _openCategoriesDropDown = !_openCategoriesDropDown,);
  }

  void _handleCategoryChange(String categoryId) {
    setState(() {
      _selectedCategory = widget.categoryList.firstWhereOrNull((c) => c.categoryId == categoryId);
      _openCategoriesDropDown = false;
    });
  }

  void _handleDateChange() {
    showDatePicker(
      context: context, 
      firstDate: DateTime(2000), 
      lastDate: DateTime(2040)
    ).then((value) {
      setState(() {
        value == null ? 
        _expireDateController.clear() : 
        _expireDateController.text = CHelperFunctions.formatDateTime(value, shortBaseMonth: true);
        FocusManager.instance.primaryFocus?.unfocus();
      });
    });
  }

  void _toggleUSDBased() {
    setState(() {
      _usdCostController.clear();
      _birrCostController.clear();
      _sellingPriceController.clear();
      _profitController.clear();
      _basedOnUSD = !_basedOnUSD;
    });
    _calculateProfit();
  }

  void _toggleIsTaxable() {
    setState(() => _isTaxable = !_isTaxable);
  }

  void _calculateExchnage() {
    if (!_basedOnUSD) return;
    double rate = double.parse(_exchangeRate);
    double? usdPrice = double.tryParse(_usdCostController.text);
    if (usdPrice == null) {
      setState(() => _birrCostController.text = '0');
    } else {
      setState(() => _birrCostController.text = (rate * usdPrice).round().toString());
    }
    _calculateProfit();
  }

  void _calculateProfit() {
    double? costInBirr = double.tryParse(_birrCostController.text);
    double? sellingPrice = double.tryParse(_sellingPriceController.text);

    if (costInBirr == null || sellingPrice == null) {
      setState(() => _profitController.clear(),);
      return;
    }

    final profit = sellingPrice - costInBirr;
    final formattedProfit = CHelperFunctions.formatNumberWithComma(profit);

    if (profit.isNegative) {
      setState(() => _profitController.text = '( $formattedProfit Birr )');
    } else {
      setState(() => _profitController.text = '$formattedProfit Birr');
    }

    // if ((costInBirr == null || sellingPrice == null) || sellingPrice < costInBirr) {
    //   setState(() => _profitController.text = '0.00');  
    // } 
    // else {
    //   setState(() => _profitController.text = (sellingPrice - costInBirr).toString());
    // }
  }

  void handleSubmitClick() {
    if (_productFormKey.currentState!.validate() && _selectedCategory != null) {
      final productData = RegisterProductModel(
        productBarcode: _barcodeController.text.trim(), 
        productName: _productNameController.text.trim(), 
        categoryId: _selectedCategory!.categoryId, 
        expireDate: CHelperFunctions.formateStringToDate(value: _expireDateController.text), 
        costInUsd: double.tryParse(_usdCostController.text), 
        costInBirr: double.parse(_birrCostController.text), 
        sellingPrice: double.parse(_sellingPriceController.text), 
        onDiscountPrice: double.parse(_sellingPriceController.text), 
        isTaxable: _isTaxable,
        stockQuanity: int.parse(_stockQtyController.text), 
        alertQuantity: int.parse(_alertQtyController.text)
      ).toJson();
      widget.onSubmit(productData); 
    }
  }
  // - - - F U N C T I O N S
  // - - - - - - >>


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _exchangeRate = _sharedPreferencesServices.getString(CSharedPrefsKeys.exchangeRate) ?? '180';
  }


  @override
  void dispose() {
  // _productFormKey.currentState?.dispose();
  _productNameController.dispose();
  _barcodeController.dispose();
  _expireDateController.dispose();
  _usdCostController.dispose();
  _birrCostController.dispose();
  _sellingPriceController.dispose();
  _profitController.dispose();
  _stockQtyController.dispose();
  _alertQtyController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        child: Padding(
          padding: EdgeInsetsGeometry.all(CSizes.largeGap),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              // 
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 900),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CColors.white,
                      borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                    ),
                    padding: EdgeInsets.all(CSizes.largeGap),
                    child: Form(
                      key: _productFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              UiTitleWidget(
                                text: 'register product',
                                bigger: true,
                                textAlign: TextAlign.center,
                                capitalizeWords: true,
                              ),


                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    UiButtonWidget(
                                      icon: CIcons.refreshIcon,
                                      tranparent: true,
                                      vericalPadding: CSizes.smallGap,
                                      horizontalPadding: CSizes.smallGap,
                                      onClick: _resetForm
                                    ),
                                
                                    SizedBox(width: CSizes.mediumGap,),
                                
                                    UiButtonWidget(
                                      text: 'bulk',
                                      icon: CIcons.file2Icon,
                                      vericalPadding: CSizes.smallGap,
                                      onClick: () => widget.onBulkClick(RegisterProductType.bulk)
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
    
                          SizedBox(height: CSizes.xLargeGap,),
                          
                          // - - - N A M E _ A N D _ B A R C O D E
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: UiTextFieldWidget(
                                  textController: _productNameController,
                                  label: 'product name',
                                  validator: (value) => _validateProductName(value),
                                ),
                              ),
    
                              SizedBox(width: CSizes.mediumGap,),
    
                              Expanded(
                                child: UiTextFieldWidget(
                                  textController: _barcodeController,
                                  label: 'product barcode',
                                ),
                              ),
                            ],
                          ),
                    
                          
                          SizedBox(height: CSizes.largeGap,),
                    
                          
                          // - - - C A T E G O R Y _ & _ E X P I R E _ D A T E
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: UiDropDownWidget(
                                  value: _selectedCategory?.categoryName, 
                                  hint: 'select category', 
                                  items: ProductCategoryModel.toDropDownMap(widget.categoryList),
                                  openDropDown: _openCategoriesDropDown, 
                                  dropDownClick: _toggleCategoryListOpen , 
                                  optionClick: (key) => _handleCategoryChange(key),
                                ),
                              ),
                              
                              SizedBox(width: CSizes.mediumGap,),
                                                  
                              Expanded(
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: UiTextFieldWidget(
                                          textController: _expireDateController,
                                          label: 'expire date',
                                          onTap: _handleDateChange,
                                          readOnly: true,
                                        ),
                                      ),
                                  
                                      SizedBox(width: CSizes.mediumGap,),
                                  
                                      UiButtonWidget(
                                        icon: CIcons.calendar,
                                        vericalPadding: 0,
                                        onClick: _handleDateChange
                                      )
                                    ],
                                  ),
                                )
                              )
                            ],
                          ),
                    
                          
                          SizedBox(height: CSizes.largeGap,),
    
    
                          // - - - T O G G L E _ U S D _ E F F E C T
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CColors.whiteShade1,
                                    border: Border.all(width: 1, color: CColors.whiteShade2),
                                    borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                  ),
                                  padding: EdgeInsets.all(CSizes.mediumGap),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      UiTitleWidget(text: 'Based on USD', defaultText: true, bold: false,),
                                  
                                      SizedBox(width: CSizes.mediumGap,),
                                  
                                      UiToggleButtonWidget(
                                        isOn: _basedOnUSD,
                                        onClick: _toggleUSDBased,
                                      )
                                    ],
                                  ),
                                ),
                              ),
    
                              SizedBox(width: CSizes.mediumGap,),
    
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CColors.whiteShade1,
                                    border: Border.all(width: 1, color: CColors.whiteShade2),
                                    borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                  ),
                                  padding: EdgeInsets.all(CSizes.mediumGap),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      UiTitleWidget(text: 'taxable'),
                                  
                                      SizedBox(width: CSizes.mediumGap,),
                                  
                                      UiToggleButtonWidget(
                                        isOn: _isTaxable,
                                        onClick: _toggleIsTaxable
                                      )
                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
    
    
                          SizedBox(height: CSizes.largeGap,),
    
                          
                          // - - - C O S T
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: UiTextFieldWidget(
                                  label: 'exchange rate',
                                  initialValue: _exchangeRate,
                                  readOnly: true,
                                ),
                              ),
    
                              SizedBox(width: CSizes.mediumGap,),
    
                              Expanded(
                                child: UiTextFieldWidget(
                                  textController: _usdCostController,
                                  label: 'Unit cost (USD)',
                                  defaultLabel: true,
                                  validator: (value) => _validateUSDCost(value),
                                  onChange: (value) => _calculateExchnage(),
                                  enabled: _basedOnUSD,
                                ),
                              ),
    
                              SizedBox(width: CSizes.mediumGap,),
    
                              Expanded(
                                child: UiTextFieldWidget(
                                  textController: _birrCostController,
                                  label: 'Unit cost (Birr)',
                                  validator: (value) => _validateBirrCost(value),
                                  onChange: (value) => _calculateProfit(),
                                  enabled: !_basedOnUSD,
                                ),
                              ),
                            ],
                          ),
                    
                          
                          SizedBox(height: CSizes.largeGap,),
                    
                          
                          // - - - S E L L I N G _ P R I C E_ & _ P R O F I T
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: UiTextFieldWidget(
                                  textController: _sellingPriceController,
                                  label: 'selling price',
                                  validator: (value) => _validateSellingPrice(value),
                                  onChange: (value) => _calculateProfit(),
                                ),
                              ),
                        
                              SizedBox(width: CSizes.mediumGap,),
                        
                              Expanded(
                                child: UiTextFieldWidget(
                                  textController: _profitController,
                                  label: 'profit',
                                  validator: (value) => _validateProfit(value),
                                  readOnly: true,
                                  // enabled: false,
                                ),
                              ),
                            ],
                          ),
                    
                          
                          SizedBox(height: CSizes.largeGap,),
                    
                          
                          // - - - Q U A N T I T Y
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: UiTextFieldWidget(
                                  textController: _stockQtyController,
                                  label: 'stock qty',
                                  validator: (value) => _validateStockQty(value),
                                ),
                              ),
                        
                              SizedBox(width: CSizes.mediumGap,),
                        
                              Expanded(
                                child: UiTextFieldWidget(
                                  textController: _alertQtyController,
                                  label: 'alert qty',
                                  validator: (value) => _validateAlertQty(value),
                                ),
                              ),
                            ],
                          ),
    

                          SizedBox(height: CSizes.largeGap,),
    
    
                          // - - - B U T T O N S
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: UiButtonWidget(
                                  text: 'back',
                                  tranparent: true,
                                  onClick: widget.onBack
                                ),
                              ),
    
                              SizedBox(width: CSizes.mediumGap,),
                              
                              Expanded(
                                flex: 2,
                                child: UiButtonWidget(
                                  text: 'submit',
                                  icon: CIcons.sendIcon,
                                  onClick: handleSubmitClick
                                )
                              ),
                            ],
                          )
                    
                        ],
                      ),
                    ),
                  ),
                ),
              )
    
            ],
          ),
        ),
      ),
    );
  }
}