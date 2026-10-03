import 'package:equatable/equatable.dart';
import 'package:shafici_pos/models/customer_model.dart';

class CustomerState extends Equatable {
  final List<CustomerModel> customersDataList;
  final List<CustomerModel> filteredCustomersList;
  final bool isLoading;
  final String? errorMessage;

  
  const CustomerState({
    required this.customersDataList,
    required this.filteredCustomersList,
    required this.isLoading,
    required this.errorMessage,
  });


  factory CustomerState.initial() {
    return CustomerState(
      customersDataList: [], 
      filteredCustomersList: [],
      isLoading: false,
      errorMessage: null
    );
  }


  CustomerState copyWith({
    List<CustomerModel>? customersDataList,
    List<CustomerModel>? filteredCustomersList,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false
  }) {
    return CustomerState(
      customersDataList: customersDataList ?? this.customersDataList, 
      filteredCustomersList: filteredCustomersList ?? this.filteredCustomersList, 
      isLoading: isLoading ?? this.isLoading, 
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage)
    );
  }


  @override
  List<Object?> get props => [
    customersDataList,
    filteredCustomersList,
    isLoading,
    errorMessage
  ];
}
