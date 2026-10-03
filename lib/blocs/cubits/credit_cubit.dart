import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shafici_pos/blocs/states/credit_state.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/models/credit_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';

class CreditCubit extends Cubit<CreditState> {
  late final AppInfoProvider _appInfoProvider;

  final _secureStorageService = CSecureStorageService();
  final _apiServices = CApiServices();

  CreditCubit({
    required this._appInfoProvider
  }) : super( CreditState.initail() );




  // - - - - - - F E T C H _ C R E D I T
  Future<void> fetchCredits() async {
    try {
      emit(state.copyWith( isLoading: true, clearMessage: true ));
      final branchId = _appInfoProvider.deviceData?.branchId ?? '-';

      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.getRequest(url: CUrlStrings.getBranchCredits+branchId, authToken: deviceToken);

      switch (response.statusCode) {
        case 200: {
          final List<dynamic> data = response.data;
          final List<CreditModel> credits = data.map((credit) => CreditModel.fromMap(credit)).toList();
          emit(state.copyWith( creditsDataList: credits, filteredCreditsList: credits ));
        }

        default: emit(state.copyWith( errorMessage: response.data ));
      }
    } 
    catch (e) {
      if (kDebugMode) print('Failed to fetch credits: $e');
      emit(state.copyWith( errorMessage: 'Failed to get credits data' ));
    }
    finally {
      emit(state.copyWith( isLoading: false ));
    }
  }




  // - - - - - - F I L T E R
  void filterCredit(List<CreditModel> list) {
    emit( state.copyWith( filteredCreditsList: list ) );
  }




  // - - - - - - C L E A R _ F I L T E R
  void clearFilter() {
    emit( state.copyWith( filteredCreditsList: state.creditsDataList ) );
  }
}