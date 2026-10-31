import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shafici_pos/blocs/states/credit_state.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/models/credit_model.dart';
import 'package:shafici_pos/models/credit_record_model.dart';
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
    emit(state.copyWith( isLoading: true, ));

    await Future.delayed(Duration(seconds: 2));

    try {
      emit(state.copyWith( isLoading: true, clearMessage: true ));
      final branchId = _appInfoProvider.deviceData?.branchId ?? '-';
      final queryParams = { 'user_id': _appInfoProvider.currentUser?.userId };

      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.getRequest(url: CUrlStrings.getBranchCredits+branchId, queryParams: queryParams, authToken: deviceToken);

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




  // - - - - - - D E L E T E _ R E C O R D
  Future<void> deleteCreditRecord(CreditRecordModel record) async {
    emit(state.copyWith( isLoading: true, ));
    try {
      final data = { 
        'credit_id': record.creditId,
        'record_id': record.recordId
      };
      final queryParams = { 'user_id': _appInfoProvider.currentUser?.userId };
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.deleteRequest(url: CUrlStrings.deleteCreditRecord, queryParams: queryParams, data: data, authToken: deviceToken);
      
      switch(response.statusCode) {
        case 200: fetchCredits();
        default: emit(state.copyWith( errorMessage: response.data ));
      }
    } catch (e) {
      if (kDebugMode) print('!---> Delete Credit: $e');
      emit(state.copyWith( errorMessage: 'Failed to delete record' ));
    } finally {
      emit(state.copyWith( isLoading: false, ));
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



  // - - - - - - C L E A R _ M E S S A G E
  void clearErrorMessage() {
    emit(state.copyWith( clearMessage: true ));
  }
}