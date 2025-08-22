import 'package:bloc/bloc.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/users/domain/usecase/search_user_by_keyword_usecase.dart';
import 'package:to_do/features/users/presentation/bloc/user_event.dart';
import 'package:to_do/features/users/presentation/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final SearchUserByKeywordUsecase _searchUserByKeyWordUC; 
  
  UserBloc(this._searchUserByKeyWordUC): super(UserInitial()) {
    on<SearchUserByKeyWord>(_onSearchUserByKeyword); 
  }

  Future<void> _onSearchUserByKeyword(SearchUserByKeyWord event, Emitter<UserState> emit) async {
    emit(UserLoading()); 
    try {
      final users = await _searchUserByKeyWordUC.execute(event.keyword); 
      
      emit(UserSearchedSuccess(users)); 
    }

    catch(error ) {
      emit(UserError(error.toString())); 
    }
  }
}