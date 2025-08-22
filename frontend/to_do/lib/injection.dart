import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:to_do/core/networks/dio_client.dart';
import 'package:to_do/core/networks/interceptor/auth_interceptor.dart';
import 'package:to_do/core/socket/socket_manager.dart';
import 'package:to_do/core/storage/token_manage.dart';
import 'package:to_do/features/auth/data/data_source/auth_data_remote.dart';
import 'package:to_do/features/auth/data/data_source/auth_local_data_source.dart';
import 'package:to_do/features/auth/data/data_source/remember_account_local_data_scource.dart';
import 'package:to_do/features/auth/data/models/user_model.dart';
import 'package:to_do/features/auth/data/repositories/auth_repositories_impl.dart';
import 'package:to_do/features/auth/domain/usecase/get_user_local_usecase.dart';
import 'package:to_do/features/auth/domain/usecase/login_with_email_usecase.dart';
import 'package:to_do/features/auth/domain/usecase/logout_usecase.dart';
import 'package:to_do/features/auth/domain/usecase/refresh_accessToken_usecase.dart';

import 'package:to_do/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_state_manager.dart';
import 'package:to_do/features/comments/data/repository/comment_repository_impl.dart';
import 'package:to_do/features/comments/domain/repository/comment_repository.dart';
import 'package:to_do/features/comments/data/resource/comment_data_remote.dart';
import 'package:to_do/features/comments/domain/usecase/fetch_comment_by_task_usecase.dart';
import 'package:to_do/features/comments/domain/usecase/sendCmt_via_socket_usecase.dart';

import 'package:to_do/features/comments/domain/usecase/stream_comment_usecase.dart';
import 'package:to_do/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:to_do/features/notifications/data/resource/notification_data_remote.dart';
import 'package:to_do/features/notifications/domain/repositories/notification_repository.dart';
import 'package:to_do/features/notifications/domain/usecase/delete_notification_usecase.dart';
import 'package:to_do/features/notifications/domain/usecase/fetch_notification_usecase.dart';
import 'package:to_do/features/notifications/domain/usecase/listen_notification_stream.dart';
import 'package:to_do/features/notifications/domain/usecase/mark_read_notification_usecase.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_bloc.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_event.dart';
import 'package:to_do/features/task/domain/usecase/remove_user_from_task_usecase.dart';
import 'features/comments/presentation/Bloc/comment_bloc.dart';
import 'package:to_do/features/projects/data/data_source/project_data_remote.dart';
import 'package:to_do/features/projects/data/repository/project_repository_impl.dart';
import 'package:to_do/features/projects/domain/usecase/add_member_project_usecase.dart';
import 'package:to_do/features/projects/domain/usecase/create_project_usecase.dart';
import 'package:to_do/features/projects/domain/usecase/fetch_list_project_usecase.dart';
import 'package:to_do/features/projects/domain/usecase/fetch_member_by_project_uc.dart';
import 'package:to_do/features/projects/domain/usecase/fetch_project_by_id_usecase.dart';
import 'package:to_do/features/projects/presentation/bloc/project_bloc.dart';
import 'package:to_do/features/projects/presentation/bloc/member_project_cubit.dart';
import 'package:to_do/features/task/data/resource/task_remote_data.dart';
import 'package:to_do/features/task/data/repository/task_repository_impl.dart';
import 'package:to_do/features/task/domain/usecase/create_task_use_case.dart';
import 'package:to_do/features/task/domain/usecase/delete_task_by_id_usecase.dart';
import 'package:to_do/features/task/domain/usecase/fetch_taskToday_usecase.dart';

import 'package:to_do/features/task/domain/usecase/fetch_task_by_id_usecase.dart';
import 'package:to_do/features/task/domain/usecase/fetch_task_for_project_usecase.dart';
import 'package:to_do/features/task/domain/usecase/fetch_task_usecase.dart';
import 'package:to_do/features/task/domain/usecase/updateTask_usecase.dart';

import 'package:to_do/features/task/presentation/bloc/task_bloc.dart';
import 'package:to_do/features/users/data/data_source/user_remote_data.dart';
import 'package:to_do/features/users/data/repository/user_repository_impl.dart';
import 'package:to_do/features/users/domain/usecase/search_user_by_keyword_usecase.dart';
import 'package:to_do/features/users/presentation/bloc/user_bloc.dart';
import 'package:to_do/features/attachments/data/resource/attachment_data_remote.dart';
import 'package:to_do/features/attachments/data/repositories/attachment_repository_impl.dart';
import 'package:to_do/features/attachments/domain/usecase/fetch_files_by_task_usecase.dart';
import 'package:to_do/features/attachments/domain/usecase/upload_file_usecase.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_bloc.dart';
import 'package:to_do/features/stats/data/source/stats_remote.dart';
import 'package:to_do/features/stats/data/repository/stats_repository_impl.dart';
import 'package:to_do/features/stats/domain/usecase/fetch_overview_user_usecase.dart';
import 'package:to_do/features/stats/presentation/blocs/stats_bloc.dart';
import 'package:to_do/features/home/presentation/bloc/home_bloc.dart';

//import 'setup.dart'; // Import setupDependencies and other functions
final GetIt getIt = GetIt.instance;

Future<void> setupDependencies(
    {String baseUrl = 'http://192.168.1.5:5000/api'}) async {
  try {
    print('Starting dependency injection setup...');

    // 1. Initialize Hive boxes first
    if (!Hive.isBoxOpen('userBox')) {
      await Hive.openBox<UserModel>('userBox').catchError((e) {
        print('Error opening userBox: $e');
        throw e;
      });
    }
    if (!Hive.isBoxOpen('rememberAccountBox')) {
      await Hive.openBox<Map<String, String>>('rememberAccountBox')
          .catchError((e) {
        print('Error opening rememberAccountBox: $e');
        throw e;
      });
    }
    if (!Hive.isBoxOpen('tokenBox')) {
      await Hive.openBox<String>('tokenBox').catchError((e) {
        print('Error opening tokenBox: $e');
        throw e;
      });
    }
    print('✓ Hive boxes initialized');

    // 2. Core dependencies
    final tokenManage = TokenManage();
    await tokenManage.init();
    getIt.registerSingleton<TokenManage>(tokenManage);
    print('✓ TokenManage registered');
     

    getIt.registerSingleton<AuthStateManager>(AuthStateManager());
    print('✓ AuthStateManager registered');

    getIt.registerSingleton<SocketManager>(SocketManager());
    print('✓ SocketManager registered');
    

    // 3. DioClient
    getIt.registerLazySingleton<DioClient>(
        () => DioClient(authStateManager: getIt<AuthStateManager>()));
    print('✓ DioClient registered');

    // 4. Auth Data Sources
    getIt.registerSingleton<AuthDataRemote>(
        AuthDataSourceImpl(getIt<DioClient>().dio));
    print('✓ AuthDataRemote registered');

    final userBox = Hive.box<UserModel>('userBox');
    final rememberAccountBox =
        Hive.box<Map<String, String>>('rememberAccountBox');

    getIt.registerLazySingleton<AuthLocalDataSourceImpl>(
        () => AuthLocalDataSourceImpl(userBox));
    getIt.registerLazySingleton<RememberAccountLocalDataSourceImpl>(
        () => RememberAccountLocalDataSourceImpl(rememberAccountBox));
    print('✓ Auth local data sources registered');

    // 5. Auth Repository
    getIt
        .registerLazySingleton<AuthRepositoriesImpl>(() => AuthRepositoriesImpl(
              getIt<RememberAccountLocalDataSourceImpl>(),
              getIt<AuthDataRemote>(),
              getIt<AuthLocalDataSourceImpl>(),
            ));
    print('✓ AuthRepositoriesImpl registered');

    // 6. Auth Use Cases
    getIt.registerFactory<LoginWithEmailUsecase>(
        () => LoginWithEmailUsecase(getIt<AuthRepositoriesImpl>()));
    getIt.registerFactory<GetUserLocalUsecase>(
        () => GetUserLocalUsecase(getIt<AuthRepositoriesImpl>()));
    getIt.registerFactory<RefreshAccesstokenUsecase>(
        () => RefreshAccesstokenUsecase(getIt<AuthRepositoriesImpl>()));
    getIt.registerFactory<LogoutUsecase>(
        () => LogoutUsecase(getIt<AuthRepositoriesImpl>()));
    print('✓ Auth use cases registered');

    // 7. Auth Bloc
    getIt.registerFactory<AuthBloc>(() => AuthBloc(
          getIt<LoginWithEmailUsecase>(),
          getIt<GetUserLocalUsecase>(),
          getIt<LogoutUsecase>(),
        ));
    print('✓ AuthBloc registered');

    // 8. Project dependencies
    getIt.registerLazySingleton<ProjectDataRemoteImpl>(
        () => ProjectDataRemoteImpl(getIt<DioClient>().dio));
    getIt.registerLazySingleton<ProjectRepositoryImpl>(
        () => ProjectRepositoryImpl(getIt<ProjectDataRemoteImpl>()));
    getIt.registerFactory<AddMemberProjectUsecase>(
        () => AddMemberProjectUsecase(getIt<ProjectRepositoryImpl>()));
    getIt.registerFactory<FetchListProjectUsecase>(
        () => FetchListProjectUsecase(getIt<ProjectRepositoryImpl>()));

    getIt.registerFactory<FetchMemberByProjectUc>(
        () => FetchMemberByProjectUc(getIt<ProjectRepositoryImpl>()));
    getIt.registerFactory<CreateProjectUsecase>(
        () => CreateProjectUsecase(getIt<ProjectRepositoryImpl>()));
    getIt.registerFactory<FetchProjectByIdUsecase>(
        () => FetchProjectByIdUsecase(getIt<ProjectRepositoryImpl>()));
    getIt.registerFactory<ProjectBloc>(() => ProjectBloc(
          getIt<FetchListProjectUsecase>(),
          getIt<FetchMemberByProjectUc>(),
          getIt<CreateProjectUsecase>(),
          getIt<AddMemberProjectUsecase>(),
          getIt<FetchProjectByIdUsecase>(),
        ));
    getIt.registerFactory<MemberProjectCubit>(
        () => MemberProjectCubit(getIt<FetchMemberByProjectUc>()));
    print('✓ Project dependencies registered');

    // 9. Task dependencies
    getIt.registerLazySingleton<TaskRemoteDataImpl>(
        () => TaskRemoteDataImpl(getIt<DioClient>().dio));
    getIt.registerLazySingleton<TaskRepositoryImpl>(
        () => TaskRepositoryImpl(getIt<TaskRemoteDataImpl>()));
    getIt.registerFactory<FetchTaskUsecase>(
        () => FetchTaskUsecase(getIt<TaskRepositoryImpl>()));
    getIt.registerFactory<FetchTaskForProjectUsecase>(
        () => FetchTaskForProjectUsecase(getIt<TaskRepositoryImpl>()));
    getIt.registerFactory<UpdateTaskUsecase>(
        () => UpdateTaskUsecase(getIt<TaskRepositoryImpl>()));
    getIt.registerFactory<CreateTaskUseCase>(
        () => CreateTaskUseCase(getIt<TaskRepositoryImpl>()));
    getIt.registerFactory<FetchTaskByIdUsecase>(
        () => FetchTaskByIdUsecase(getIt<TaskRepositoryImpl>()));
    getIt.registerFactory<DeleteTaskByIdUsecase>(
        () => DeleteTaskByIdUsecase(getIt<TaskRepositoryImpl>()));
    getIt.registerFactory<FetchTasktodayUsecase>(
        () => FetchTasktodayUsecase(getIt<TaskRepositoryImpl>()));
    getIt.registerFactory<RemoveUserFromTaskUsecase>(() => RemoveUserFromTaskUsecase(getIt<TaskRepositoryImpl>())); 
    getIt.registerFactory<TaskBloc>(() => TaskBloc(
          getIt<FetchTaskUsecase>(),
          getIt<FetchTaskForProjectUsecase>(),
          getIt<UpdateTaskUsecase>(),
          getIt<CreateTaskUseCase>(),
          getIt<FetchTaskByIdUsecase>(),
          getIt<DeleteTaskByIdUsecase>(),
          getIt<FetchTasktodayUsecase>(),
          getIt<RemoveUserFromTaskUsecase>()
        ));
    print('✓ Task dependencies registered');

    // 10. User dependencies
    getIt.registerLazySingleton<UserRemoteDataImpl>(
        () => UserRemoteDataImpl(getIt<DioClient>().dio));
    getIt.registerLazySingleton<UserRepositoryImpl>(
        () => UserRepositoryImpl(getIt<UserRemoteDataImpl>()));
    getIt.registerFactory<SearchUserByKeywordUsecase>(
        () => SearchUserByKeywordUsecase(getIt<UserRepositoryImpl>()));
    getIt.registerFactory<UserBloc>(
        () => UserBloc(getIt<SearchUserByKeywordUsecase>()));
    print('✓ User dependencies registered');

    // 11. Home Bloc
    getIt.registerFactory<HomeBloc>(() => HomeBloc(
          getIt<FetchListProjectUsecase>(),
          getIt<FetchTaskUsecase>(),
        ));
    print('✓ HomeBloc registered');

    // 12. Attachment dependencies
    getIt.registerLazySingleton<AttachmentDataRemoteImpl>(
        () => AttachmentDataRemoteImpl(dioClient: getIt<DioClient>().dio));
    getIt.registerLazySingleton<AttachmentRepositoryImpl>(
        () => AttachmentRepositoryImpl(getIt<AttachmentDataRemoteImpl>()));
    getIt.registerFactory<UploadFileUsecase>(
        () => UploadFileUsecase(getIt<AttachmentRepositoryImpl>()));
    getIt.registerFactory<FetchFilesByTaskUsecase>(
        () => FetchFilesByTaskUsecase(getIt<AttachmentRepositoryImpl>()));
    getIt.registerFactory<AttachmentBloc>(() => AttachmentBloc(
          getIt<FetchFilesByTaskUsecase>(),
          getIt<UploadFileUsecase>(),
        ));
    print('✓ Attachment dependencies registered');

    // 13. Stats dependencies
    getIt.registerLazySingleton<StatsRemoteImpl>(
        () => StatsRemoteImpl(getIt<DioClient>().dio));
    getIt.registerLazySingleton<StatsRepositoryImpl>(
        () => StatsRepositoryImpl(getIt<StatsRemoteImpl>()));
    getIt.registerFactory<FetchOverviewUserUsecase>(
        () => FetchOverviewUserUsecase(getIt<StatsRepositoryImpl>()));
    getIt.registerFactory<StatsBloc>(
        () => StatsBloc(getIt<FetchOverviewUserUsecase>()));
    print('✓ Stats dependencies registered');

// 14. Comment dependencies
// 14. Comment dependencies (moved from initializeSocketAfterLogin)
    getIt.registerLazySingleton<ICommentRemoteDataSource>(() =>
        CommentRemoteDataSource(
            getIt<DioClient>().dio, getIt<SocketManager>()));
    getIt.registerLazySingleton<CommentRepository>(
        () => CommentRepositoryImpl(getIt<ICommentRemoteDataSource>()));
    getIt.registerFactory<FetchCommentByTaskUsecase>(
        () => FetchCommentByTaskUsecase(getIt<CommentRepository>()));
    getIt.registerFactory<StreamCommentsUseCase>(
        () => StreamCommentsUseCase(getIt<CommentRepository>()));
    getIt.registerFactory<SendcmtViaSocketUsecase>(
        () => SendcmtViaSocketUsecase(getIt<CommentRepository>()));

    getIt.registerFactory<CommentBloc>(() => CommentBloc(
        streamCommentsUseCase: getIt<StreamCommentsUseCase>(),
        fetchCommentByTaskUsecase: getIt<FetchCommentByTaskUsecase>(),
        sendcmtViaSocketUsecase: getIt<SendcmtViaSocketUsecase>()));

    // Notification
    getIt.registerLazySingleton<NotificationDataRemote>(
        () => NotificationDataRemoteImpl(getIt<DioClient>().dio, getIt<SocketManager>()));
    getIt.registerLazySingleton<NotificationRepository>(
        () => NotificationRepositoryImpl(getIt<NotificationDataRemote>()));

    getIt.registerFactory<FetchNotificationUsecase>(
        () => FetchNotificationUsecase(getIt<NotificationRepository>()));
    getIt.registerFactory<ListenNotificationStream>(
        () => ListenNotificationStream(getIt<NotificationRepository>()));
    getIt.registerFactory<MarkReadNotificationUsecase>(
        () => MarkReadNotificationUsecase(getIt<NotificationRepository>()));
    getIt.registerFactory<DeleteNotificationUsecase>(() =>DeleteNotificationUsecase(getIt<NotificationRepository>())); 
    getIt.registerSingleton<NotificationBloc>(NotificationBloc(
        getIt<ListenNotificationStream>(),
        getIt<FetchNotificationUsecase>(),
        getIt<MarkReadNotificationUsecase>(), 
        getIt<DeleteNotificationUsecase>()
        ));
  } catch (e, stackTrace) {
    print('❌ Failed to setup dependencies: $e');
    print('Stack trace: $stackTrace');
    throw e;
  }
}

// Helper function to check registered dependencies
void debugDependencies() {
  print('=== Registered Dependencies ===');
  print('AuthStateManager: ${getIt.isRegistered<AuthStateManager>()}');
  print('TokenManage: ${getIt.isRegistered<TokenManage>()}');
  print('DioClient: ${getIt.isRegistered<DioClient>()}');
  print('AuthBloc: ${getIt.isRegistered<AuthBloc>()}');
  print('ProjectBloc: ${getIt.isRegistered<ProjectBloc>()}');
  print('TaskBloc: ${getIt.isRegistered<TaskBloc>()}');
  print('UserBloc: ${getIt.isRegistered<UserBloc>()}');
  print('CommentBloc: ${getIt.isRegistered<CommentBloc>()}');
  print(
      'ICommentRemoteDataSource: ${getIt.isRegistered<ICommentRemoteDataSource>()}');
  print('CommentRepository: ${getIt.isRegistered<CommentRepository>()}');
  print('AttachmentBloc: ${getIt.isRegistered<AttachmentBloc>()}');
  print('StatsBloc: ${getIt.isRegistered<StatsBloc>()}');
  print('HomeBloc: ${getIt.isRegistered<HomeBloc>()}');
  print('MemberProjectCubit: ${getIt.isRegistered<MemberProjectCubit>()}');
  print('=== End Debug ===');
}

// Helper function to initialize socket after user login
Future<void> initializeSocketAfterLogin() async {
  try {
    await getIt<SocketManager>().init();
    print('Socket initialized successfully');

    // Sau khi init xong mới trigger listen notifications
    //getIt<NotificationBloc>().add(StartListeningNotifications());

    // Tương tự với comment nếu cần
    //getIt<CommentBloc>(); // tạo nếu cần, rồi stream comments
  } catch (e) {
    print('Socket init failed: $e');
  }
}


// Clean up function
/* Future<void> resetDependencies() async {
  try {
    await getIt.reset();
    print('Dependencies reset successfully');
  } catch (e) {
    print('Error resetting dependencies: $e');
  }
}
 */

Future<void> testCommentBlocRegistration() async {
  try {
    if (getIt.isRegistered<CommentBloc>()) {
      print('CommentBloc already registered, unregistering...');
      await getIt.unregister<CommentBloc>();
    }
    getIt.registerFactory<CommentBloc>(() => CommentBloc(
          streamCommentsUseCase: getIt<StreamCommentsUseCase>(),
          fetchCommentByTaskUsecase: getIt<FetchCommentByTaskUsecase>(),
          sendcmtViaSocketUsecase: getIt<SendcmtViaSocketUsecase>(),
        ));
    print(
        'CommentBloc registration attempted: ${getIt.isRegistered<CommentBloc>()}');
  } catch (e) {
    print('Error registering CommentBloc: $e');
  }
}
