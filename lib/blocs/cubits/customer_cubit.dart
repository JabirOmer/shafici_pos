import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shafici_pos/blocs/states/customer_state.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/models/customer_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/sales_provider.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';

class CustomerCubit extends Cubit<CustomerState> {
  late final AppInfoProvider _appInfoProvider;

  final _secureStorageService = CSecureStorageService();
  final _apiServices = CApiServices();

  
  CustomerCubit({
    required this._appInfoProvider
  }) : super(CustomerState.initial());

  
  
  
  // - - - - - - F E T C H _ C U S T O M E R S
  Future<void> fetchCustomers() async {
    if (state.isLoading) return;

    final branchId = _appInfoProvider.deviceData?.branchId;
    if (branchId == null) emit(state.copyWith( errorMessage: 'Failed to get branch id' ));

    emit(state.copyWith( isLoading: true, clearError: true ));

    try {
      final queryParams = { 'user_id': _appInfoProvider.currentUser?.userId };

      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.getRequest(url: CUrlStrings.getCustomers, queryParams: queryParams, authToken: deviceToken);

      switch (response.statusCode) {
        case 200: {
          final List<dynamic> data = response.data;
          final List<CustomerModel> customers = data.map((customer) => CustomerModel.fromMap(customer)).toList();
          emit(state.copyWith( customersDataList: customers, filteredCustomersList: customers ));
        }

        default: emit(state.copyWith( errorMessage: response.data ));
      }

    } 
    catch (e) {
      emit(state.copyWith( errorMessage: 'Failed to get customers data' ));
    }
    finally {
      emit(state.copyWith( isLoading: false ));
    }
  }

}