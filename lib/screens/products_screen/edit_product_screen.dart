import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/shared_prefs_keys.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/product_category_model.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/services/shared_preferences_services.dart';
import 'package:shafici_pos/ui/ui_animated_mini_message_widget.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_drop_down_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;
  final bool isBasedOnUSD;
  final List<ProductCategoryModel> categoryList;
  final void Function(ProductModel newProduct) onChangeSend;
  final void Function() onBackClick;

  const EditProductScreen({
    super.key,
    required this.product,
    required this.isBasedOnUSD,
    required this.categoryList,
    required this.onChangeSend,
    required this.onBackClick
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {  
  late double _exchangeRate;
  final CSharedPreferencesServices _sharedPreferencesServices = CSharedPreferencesServices();
  bool _openCategoriesDropDown = false;
  ProductCategoryModel? _selectedCategory;
  
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _productCodeController = TextEditingController();
  final _expireDateController = TextEditingController();
  final _exchangeRateController = TextEditingController();
  final _usdCostController = TextEditingController();
  final _birrCostController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _profitController = TextEditingController();
  final _stockQtyController = TextEditingController();
  final _alertQtyController = TextEditingController();

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  // - - - - - - >>
  // - - - V A L I D A T O R S
  String? _validateProductName(String? value) {
    // if ((value == null || value.isEmpty) && widget.) return 'product name is missing';
    return null;
  }

  String? _validateUSDCost(String? value) {
    if (!widget.isBasedOnUSD) return null;
    if (value == null || value.isEmpty) return null;
    final formattedValue = CHelperFunctions.formatStringToDouble(value);
    if (formattedValue == null) return 'invalid USD price';
    return null;
  }

  String? _validateBirrCost(String? value) {
    if (widget.isBasedOnUSD) return null;
    if (value == null || value.isEmpty) return null;
    if (double.tryParse(value) == null) return 'Invalid price';
    return null;
  }

  String? _validateSellingPrice(String? value) {
    if (value == null || value.isEmpty) return null;
    if (double.tryParse(value) == null) return 'invalid price';
    return null;
  }
  
  String? _validateProfit(String? value) {
    if (value == null || value.isEmpty) return null;
    final formattedValue = CHelperFunctions.formatStringToDouble(value);
    if (formattedValue == null) return 'invalid profit';
    if (formattedValue < 1) return 'loss calculation';
    return null;
  }

  String? _validateStockQty(String? value) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null) return 'invalid quantity';
    return null;
  }

  String? _validateAlertQty(String? value) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null) return 'invalid quantity';
    return null;
  }
  // - - - V A L I D A T O R S
  // - - - - - - >>
  
  
  // - - - - - - >>
  // - - - F U N C T I O N S
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
      barrierColor: CColors.transparent,
      context: context, 
      firstDate: DateTime(2000), 
      lastDate: DateTime(2040),
      initialDate: widget.product.expireDate,
    ).then((value) {
      setState(() {
        value == null ? 
        _expireDateController.clear() : 
        _expireDateController.text = CHelperFunctions.formatDateTime(value, shortBaseMonth: true);
      });
    });
  }

  void _calculateExchnage() {
    double rate = _exchangeRate;
    double? usdPrice = double.tryParse(_usdCostController.text);
    if (usdPrice != null) {
      setState(() => _birrCostController.text = '${CHelperFunctions.formatNumberWithComma(rate * usdPrice)} Birr');
    } else {
      setState(() => _birrCostController.text = '');
    }
    _calculateProfit();
  }

  void _calculateProfit() {
    double formattedSellingPrice = CHelperFunctions.formatStringToDouble(_sellingPriceController.text) ?? widget.product.sellingPrice;
    double formattedCostInBirr = CHelperFunctions.formatStringToDouble(_birrCostController.text) ?? widget.product.unitCost;

    final profit = formattedSellingPrice - formattedCostInBirr;
    final formattedProfit = CHelperFunctions.formatNumberWithComma(profit);

    if (profit.isNegative) {
      setState(() => _profitController.text = '( $formattedProfit Birr )');
    } else {
      setState(() => _profitController.text = '$formattedProfit Birr');
    }
  }

  Future<void> _handleSetChange() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
          final newData = ProductModel(
            productId: widget.product.productId, 
            categoryId: _selectedCategory != null ? _selectedCategory!.categoryId : widget.product.categoryId, 
            categoryName: _selectedCategory != null ? _selectedCategory!.categoryName : widget.product.categoryName, 
            productBarcode: _barcodeController.text.isNotEmpty ? _barcodeController.text : widget.product.productBarcode, 
            productName: _productNameController.text.isNotEmpty ? _productNameController.text : widget.product.productName, 

            unitCostInUSD: _usdCostController.text.isEmpty ? widget.product.unitCostInUSD : CHelperFunctions.formatStringToDouble(_usdCostController.text)!,
            unitCost: _birrCostController.text.isEmpty ? widget.product.unitCost : CHelperFunctions.formatStringToDouble(_birrCostController.text)!,  
            sellingPrice: _sellingPriceController.text.isEmpty ? widget.product.sellingPrice : CHelperFunctions.formatStringToDouble(_sellingPriceController.text)!,
            onDiscountPrice: _sellingPriceController.text.isEmpty ? widget.product.onDiscountPrice : CHelperFunctions.formatStringToDouble(_sellingPriceController.text)!,
          
            stock: _stockQtyController.text.isNotEmpty ? int.parse(_stockQtyController.text) : widget.product.stock, 
            alertQuantity: _alertQtyController.text.isNotEmpty ? int.parse(_alertQtyController.text) : widget.product.alertQuantity, 
            expireDate: _expireDateController.text.isNotEmpty ? CHelperFunctions.formateStringToDate(value: _expireDateController.text) : widget.product.expireDate, 
            isTaxable: widget.product.isTaxable,
            createdAt: widget.product.createdAt,
            updatedAt: DateTime.now()
          );
          
          widget.onChangeSend(newData);
        } catch (e) {
          setState(() => _errorMessage = 'Failed to make change');

          await Future.delayed(Duration(seconds: 2));
          if (!mounted) return;
          
          _successMessage != null ? widget.onBackClick : setState(() => _errorMessage = null);
        } finally {
          setState(() => _isLoading = false);
        }
    }
  }
  // - - - F U N C T I O N S
  // - - - - - - >>


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rate = _sharedPreferencesServices.getString(CSharedPrefsKeys.exchangeRate) ?? '180';
    _exchangeRate = double.parse(rate);
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _barcodeController.dispose();
    _productCodeController.dispose();
    _expireDateController.dispose();
    _exchangeRateController.dispose();
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
    return GestureDetector(
      onTap: widget.onBackClick,
      child: Scaffold(
        backgroundColor: CColors.dimmedBackgound,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: CSizes.largeGap+CSizes.largeGap,
                horizontal: CSizes.largeGap,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              
                  Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 1000),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CColors.white,
                            borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                          ),
                          padding: EdgeInsets.all(CSizes.largeGap),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [

                                UiTitleWidget(
                                  text: 'edit product',
                                  bigger: true,
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: CSizes.largeGap,),
                                          
                                // - - - E D I T _ I N F O
                                UiTitleWidget(
                                  text: 'Edit product info', 
                                  bigger: true,
                                  bold: false,
                                ),
                                          
                                SizedBox(height: CSizes.largeGap,),
                                          
                                _editProductTitle(
                                  label: 'product name', 
                                  initial: widget.product.productName,
                                  controller: _productNameController, 
                                  validator: (value) => _validateProductName(value),
                                  onChange: (value) {},
                                ),
                                                                
                                SizedBox(height: CSizes.largeGap,),
                                                                
                                // Brand Code
                                _editProductTitle(
                                  label: 'Brand Code', 
                                  initial: widget.product.productCode ?? '---',
                                  controller: _barcodeController, 
                                  validator: (value) {return null;},
                                  onChange: (value) {},
                                ),
                                      
                                SizedBox(height: CSizes.largeGap,),

                                // Barcode
                                _editProductTitle(
                                  label: 'barcode', 
                                  initial: widget.product.productBarcode,
                                  controller: _barcodeController, 
                                  validator: (value) {return null;},
                                  onChange: (value) {},
                                ),
                                      
                                SizedBox(height: CSizes.largeGap,),
                                
                                // Category
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: UiTextFieldWidget(
                                        initialValue: widget.product.categoryName,
                                        readOnly: true,
                                        enabled: false,
                                      ),
                                    ),
                                                                
                                    SizedBox(width: CSizes.mediumGap,),
                                                                
                                    Expanded(
                                      flex: 3,
                                      child: UiDropDownWidget(
                                        value: _selectedCategory?.categoryName, 
                                        hint: 'select category', 
                                        items: ProductCategoryModel.toDropDownMap(widget.categoryList),
                                        openDropDown: _openCategoriesDropDown, 
                                        dropDownClick: _toggleCategoryListOpen, 
                                        optionClick: (key) => _handleCategoryChange(key),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: CSizes.largeGap,),
                                      
                                // Expire Date
                                _editProductTitle(
                                  label: 'new expire date', 
                                  initial: widget.product.expireDate == null ? '---' : CHelperFunctions.formatDateTime(widget.product.expireDate!),
                                  isDate: true,
                                  onDateClick: _handleDateChange,
                                  controller: _expireDateController, 
                                  validator: (value) {return null;},
                                  onChange: (value) {},
                                ),
              
                                SizedBox(height: CSizes.largeGap,),
                                          
                                
                                // - - - E D I T _ P R I C I N G
                                UiTitleWidget(
                                  text: 'edit pricing', 
                                  bigger: true,
                                  bold: false,
                                ),
                                          
                                SizedBox(height: CSizes.largeGap,),
              
                                _editProductTitle(
                                  label: 'new cost (USD)', 
                                  initial: widget.product.unitCostInUSD == null ? '---' : '\$${CHelperFunctions.formatNumberWithComma(widget.product.unitCostInUSD!)}',
                                  controller: _usdCostController, 
                                  validator: (value) => _validateUSDCost(value),
                                  onChange: (value) => _calculateExchnage(),
                                  enabled: widget.isBasedOnUSD
                                ), 
                                              
                                SizedBox(height: CSizes.largeGap,),
                                
                                // Cost In Birr
                                _editProductTitle(
                                  label: 'new cost (Birr)', 
                                  initial: '${CHelperFunctions.formatNumberWithComma(widget.product.unitCost)} Birr',
                                  controller: _birrCostController, 
                                  validator: (value) => _validateBirrCost(value),
                                  onChange: (value) => _calculateProfit(),
                                  enabled: !widget.isBasedOnUSD
                                ),
                                      
                                SizedBox(height: CSizes.largeGap,),
                                              
                                // Selling Price
                                _editProductTitle(
                                  label: 'selling price', 
                                  initial: '${CHelperFunctions.formatNumberWithComma(widget.product.sellingPrice)} Birr',
                                  controller: _sellingPriceController, 
                                  validator: (value) => _validateSellingPrice(value),
                                  onChange: (value) => _calculateProfit(),
                                ),
                                      
                                SizedBox(height: CSizes.largeGap,),
                                              
                                // Profit
                                _editProductTitle(
                                  label: 'new profit', 
                                  initial: '${CHelperFunctions.formatNumberWithComma(widget.product.sellingPrice - widget.product.unitCost)} Birr',
                                  controller: _profitController,
                                  readOnly: true,
                                  validator: (value) => _validateProfit(value),
                                  onChange: (value) {},
                                ),
                                          
                                
                                // - - - E D I T _ S T O C K
                                SizedBox(height: CSizes.largeGap,),
              
                                UiTitleWidget(
                                  text: 'edit stock', 
                                  bigger: true,
                                  bold: false,
                                ),
              
                                SizedBox(height: CSizes.largeGap,),
              
                                // Stock Quantity
                                _editProductTitle(
                                  label: 'new stock quantity', 
                                  initial: CHelperFunctions.formatNumberWithComma(widget.product.stock),
                                  controller: _stockQtyController,
                                  validator: (value) => _validateStockQty(value),
                                  onChange: (value) {},
                                ),
                                
                                SizedBox(height: CSizes.largeGap,),
              
                                // Stock Alert
                                _editProductTitle(
                                  label: 'new stock alert', 
                                  initial: CHelperFunctions.formatNumberWithComma(widget.product.alertQuantity),
                                  controller: _alertQtyController,
                                  validator: (value) => _validateAlertQty(value),
                                  onChange: (value) {},
                                ),
              
                                SizedBox(height: CSizes.largeGap,),

                                UiAnimatedMiniMessageWidget(
                                  displayText: _successMessage ?? _errorMessage,
                                  isSuccess: _successMessage != null,
                                ),

                                SizedBox(height: CSizes.largeGap,),
              
                                Row(
                                  children: [
                                    Expanded(
                                      child: UiButtonWidget(
                                        text: 'cancel',
                                        tranparent: true,
                                        onClick: widget.onBackClick
                                      )
                                    ),
              
                                    SizedBox(width: CSizes.mediumGap,),
              
                                    Expanded(
                                      child: UiButtonWidget(
                                        text: 'change',
                                        onClick: _handleSetChange,
                                        isDisabled: _isLoading || _successMessage != null,
                                      )
                                    ),
                                  ],
                                )
                              ],
                            )
                          ),
                        ),
                      ),
                    ),
                  )
              
                ]
              ),
            ),
          ),
        )           
      ),
    );
  }





  // - - - - - - 
  // - - - M E T H O D S
  // - - - - - - 




  // - - - E D I T _ P R O D U C T _ T I L E
  Container _editProductTitle({
    required TextEditingController controller,
    required String label,
    required String initial,
    bool isDate = false,
    void Function()? onDateClick,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String? value) validator,
    required void Function(String? value) onChange,
    bool enabled = true,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: UiTextFieldWidget(
              initialValue: initial,
              readOnly: true,
              // enabled: false,
            ),
          ),

          SizedBox(width: CSizes.mediumGap,),

          Expanded(
            flex: 3,
            child: UiTextFieldWidget(
              textController: controller,
              label: label,
              keyboardType: keyboardType,
              validator: (value) => validator(value),
              onChange: (value) => onChange(value),
              onTap: onDateClick ?? () {},
              readOnly: isDate || readOnly,
              enabled: enabled,
            ),
          ),
        ],
      ),
    );
  }

}