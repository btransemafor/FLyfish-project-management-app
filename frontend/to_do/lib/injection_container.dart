/* // injections/injection_container.dart

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:to_do/core/networks/dio_client.dart';
import 'package:to_do/features/auth/data/data_source/auth_data_remote.dart';
import 'package:to_do/features/auth/data/data_source/auth_local_data_source.dart';
import 'package:to_do/features/auth/data/data_source/remember_account_local_data_scource.dart';
import 'package:to_do/features/auth/data/models/user_model.dart';
import 'package:to_do/features/auth/data/repositories/auth_repositories_impl.dart';
import 'package:to_do/features/auth/domain/repositories/auth_repository.dart';
import 'package:to_do/features/auth/domain/usecase/get_user_local_usecase.dart';
import 'package:to_do/features/auth/domain/usecase/login_with_email_usecase.dart';
import 'package:to_do/features/projects/data/data_source/project_data_remote.dart';
import 'package:to_do/features/projects/data/repository/project_repository_impl.dart';
import 'package:to_do/features/projects/domain/repository/project_repository.dart';
import 'package:to_do/features/projects/domain/usecase/fetch_list_project_usecase.dart';

@module
abstract class InjectableModule {

  @preResolve
  Future<Box<UserModel>> get userBox async =>
      await Hive.openBox<UserModel>('userBox');

  @preResolve
  Future<Box<Map<String, String>>> get rememberAccountBox async =>
      await Hive.openBox<Map<String, String>>('rememberAccountBox');


  @lazySingleton
  DioClient dioClient(Dio dio) => DioClient();

  @lazySingleton
  AuthDataRemote authRemote(DioClient dioClient) => AuthDataSourceImpl(dioClient);

  @lazySingleton
  AuthLocalDataSource authLocal(Box<UserModel> userBox) =>
      AuthLocalDataSourceImpl(userBox);

  @lazySingleton
  RememberAccountLocalDataScource rememberAccount(
          Box<Map<String, String>> rememberAccountBox) =>
      RememberAccountLocalDataSourceImpl(rememberAccountBox);


  @lazySingleton
  AuthRepository authRepository(
    RememberAccountLocalDataScource rememberAccount,
    AuthDataRemote authRemote,
    AuthLocalDataSource authLocal,
  ) =>
      AuthRepositoriesImpl(rememberAccount, authRemote, authLocal);

  @lazySingleton
  LoginWithEmailUsecase loginWithEmail(AuthRepository repo) => LoginWithEmailUsecase(repo);

  @lazySingleton
  GetUserLocalUsecase getLocalUser(AuthRepository repo) => GetUserLocalUsecase(repo);


  @lazySingleton
  ProjectDataRemote projectDataRemote(DioClient dioClient) => ProjectDataRemoteImpl(dioClient); 

  @lazySingleton
  ProjectRepository projectRepository(
    ProjectDataRemote projectDataRemote
  ) => ProjectRepositoryImpl(projectDataRemote); 

  @lazySingleton
  FetchListProjectUsecase fetchListProject(ProjectRepository repo) => FetchListProjectUsecase(repo); 

} */