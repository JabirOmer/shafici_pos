import 'package:equatable/equatable.dart';
import 'package:shafici_pos/models/credit_model.dart';
import 'package:shafici_pos/models/customer_model.dart';

class CreditState extends Equatable {
  final List<CreditModel> creditsDataList;
  final List<CreditModel> filteredCreditsList;
  final bool isLoading;
  final String? errorMessage;

  
  const CreditState({
    required this.creditsDataList,
    required this.filteredCreditsList,
    this.isLoading = false,
    this.errorMessage,
  });


  factory CreditState.initail() {
    return CreditState(
      creditsDataList: [], 
      filteredCreditsList: []
    );
  }


  CreditState copyWith({
    List<CreditModel>? creditsDataList,
    List<CreditModel>? filteredCreditsList,
    bool? isLoading,
    String? errorMessage,
    bool clearMessage = false
  }) {
    return CreditState(
      creditsDataList: creditsDataList ?? this.creditsDataList, 
      filteredCreditsList: filteredCreditsList ?? this.filteredCreditsList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearMessage ? null : (errorMessage ?? this.errorMessage)
    );
  }

  
  @override
  List<Object?> get props => [
    creditsDataList,
    filteredCreditsList,
    isLoading,
    errorMessage
  ];
}