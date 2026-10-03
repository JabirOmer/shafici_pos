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
    print(1);

    final branchId = _appInfoProvider.deviceData?.branchId;
    if (branchId == null) {
      emit(state.copyWith( errorMessage: 'Failed to get branch id' ));
    }
    print(2);

    emit(state.copyWith( isLoading: true, clearError: true ));
    print(3);

    // await Future.delayed(Duration(seconds: 2));

    try {
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      print(4);
      final response = await _apiServices.getRequest(url: CUrlStrings.getCustomers, authToken: deviceToken);
      print(5);

      switch (response.statusCode) {
        case 200: {
          print(6);
          final List<dynamic> data = response.data;
          print(7);
          final List<CustomerModel> customers = data.map((customer) => CustomerModel.fromMap(customer)).toList();
          print(8);
          
          emit(state.copyWith( customersDataList: customers, filteredCustomersList: customers ));
          print(9);
        }

        default: {print(9); emit(state.copyWith( errorMessage: response.data ));}
      }

    } 
    catch (e) {
      print(10);
      emit(state.copyWith( errorMessage: 'Failed to get customers data' ));
    }
    finally {
      print('done');
      emit(state.copyWith( isLoading: false ));
    }
  }

}