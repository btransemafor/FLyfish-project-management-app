import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:to_do/core/app_providers.dart';
import 'package:to_do/core/app_router.dart';
import 'package:to_do/core/boxes.dart';
import 'package:to_do/core/networks/dio_client.dart';
import 'package:to_do/core/storage/token_manage.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_bloc.dart';
import 'package:to_do/features/auth/data/models/user_model.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_state_manager.dart';
import 'package:to_do/features/comments/domain/usecase/fetch_comment_by_task_usecase.dart';
import 'package:to_do/features/comments/domain/usecase/sendCmt_via_socket_usecase.dart';
import 'package:to_do/features/comments/domain/usecase/stream_comment_usecase.dart';
import 'package:to_do/features/home/presentation/bloc/home_bloc.dart';
import 'package:to_do/features/home/presentation/bloc/home_event.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_bloc.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_event.dart';
import 'package:to_do/features/projects/presentation/bloc/member_project_cubit.dart';
import 'package:to_do/features/projects/presentation/bloc/project_bloc.dart';
import 'package:to_do/features/stats/presentation/blocs/stats_bloc.dart';
import 'package:to_do/features/stats/presentation/blocs/stats_event.dart';
import 'package:to_do/features/task/presentation/bloc/task_bloc.dart';
import 'package:to_do/features/users/presentation/bloc/user_bloc.dart';
import 'package:to_do/injection.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:to_do/core/app_router.dart' show navigatorKey;
import 'dart:async';

import 'features/comments/presentation/Bloc/comment_bloc.dart';

// Global subscription để manage listener
StreamSubscription<bool>? _authSubscription;

void setupAuthListener() {
  // Cancel existing subscription nếu có
  _authSubscription?.cancel();

  final authStateManager = di.getIt<AuthStateManager>();

  _authSubscription = authStateManager.authStateStream.listen(
    (isLoggedIn) {
      print('Auth state changed: isLoggedIn = $isLoggedIn');

      if (!isLoggedIn) {
        _handleLogout();
      }
    },
    onError: (error) {
      print('Auth listener error: $error');
    },
  );
}

void _handleLogout() async {
  try {
    print('Handling logout...');

    // Clear all tokens
    await di.getIt<TokenManage>().clearToken();

    // Clear all BLoC states nếu cần
    _clearBlocStates();

    // Navigate to login screen
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      // Sử dụng pushNamedAndClearStack để clear toàn bộ navigation stack
      context.pushReplacementNamed('signInScreen');

      // Hoặc nếu bạn muốn clear toàn bộ stack:
      // while (context.canPop()) {
      //   context.pop();
      // }
      // context.pushReplacementNamed('signInScreen');

      // Hiển thị thông báo logout
      // _showLogoutSnackBar(context);
    }
  } catch (e) {
    print('Error during logout handling: $e');
  }
}

void _clearBlocStates() {
  try {
    // Reset các BLoC về initial state nếu cần
    // Ví dụ:
    // di.getIt<HomeBloc>().add(ResetHomeData());
    // di.getIt<ProjectBloc>().add(ResetProjects());
    // di.getIt<TaskBloc>().add(ResetTasks());

    print('BLoC states cleared');
  } catch (e) {
    print('Error clearing BLoC states: $e');
  }
}

void _showLogoutSnackBar(BuildContext context) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Session expired. Please login again.'),
      backgroundColor: Colors.orange,
      duration: Duration(seconds: 3),
    ),
  );
}

// Cleanup function để call khi app dispose
void disposeAuthListener() {
  _authSubscription?.cancel();
  _authSubscription = null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  //  Nếu dùng Hive với custom object (UserModel) thì cần register adapter
  Hive.registerAdapter(UserModelAdapter());

  //  Mở box đúng cách
  final Box<UserModel> userBox =
      await Hive.openBox<UserModel>(HiveBoxes.userBox);
  final Box<Map<String, String>> rememberAccountBox =
      await Hive.openBox(HiveBoxes.rememberAccountBox);
  // In setupDependencies (e.g., injection.dart)
  print('GetIt instance in setupDependencies: ${di.getIt}');
  await di.setupDependencies();
  await di.testCommentBlocRegistration();

  print(
      'Send Comment registered? ${di.getIt.isRegistered<SendcmtViaSocketUsecase>()}');
  print('StreamComment ${di.getIt.isRegistered<StreamCommentsUseCase>()}');
  print('Fetch Commnent ${di.getIt.isRegistered<FetchCommentByTaskUsecase>()}');
  print('BlocCommnent ${di.getIt.isRegistered<CommentBloc>()}');
  // Setup auth listener NGAY SAU KHI setup dependencies
  WidgetsBinding.instance.addPostFrameCallback((_) {
  setupAuthListener();
});


  runApp(MultiBlocProvider(
    providers: [
       BlocProvider<CommentBloc>(
        create: (context) => di.getIt<CommentBloc>(),
      ), 
      BlocProvider(create: (context) => di.getIt<MemberProjectCubit>()),
      BlocProvider(
          create: (context) => di.getIt<HomeBloc>()
            ..add(LoadHomeData(countNearestCurrent: 100))),
      BlocProvider<AuthBloc>(
        create: (context) => di.getIt<AuthBloc>(),
      ),
      BlocProvider<TaskBloc>(
        create: (context) => di.getIt<TaskBloc>(),
      ),
      BlocProvider<ProjectBloc>(
        create: (context) => di.getIt<ProjectBloc>(),
      ),
      BlocProvider<UserBloc>(
        create: (context) => di.getIt<UserBloc>(),
      ),
      BlocProvider<NotificationBloc>(
          create: (context) =>
              di.getIt<NotificationBloc>()..add(FetchNotification())), 
      BlocProvider<AttachmentBloc>(
          create: (context) => di.getIt<AttachmentBloc>()),
      BlocProvider<StatsBloc>(
          create: (context) => di.getIt<StatsBloc>()..add(LoadStatsUser()))
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Kiểm tra token validity khi app start
    _checkInitialAuthState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disposeAuthListener();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Khi app resume, kiểm tra lại auth state
    if (state == AppLifecycleState.resumed) {
      _checkAuthStateOnResume();
    }
  }

  void _checkInitialAuthState() async {
  try {
    final tokenManager = di.getIt<TokenManage>();
    final authStateManager = di.getIt<AuthStateManager>();

    final token = tokenManager.getToken();
    final refreshToken = tokenManager.getRefreshToken();

    // Nếu chưa có token bao giờ, không cần gọi logout
    if (token == null && refreshToken == null) {
      print('User never logged in, no logout needed');
      return;
    }

    final hasValidTokens = token != null && refreshToken != null;

    if (!hasValidTokens) {
      print('Tokens invalid, logging out...');
      authStateManager.setLoggedOut();
    } else {
      print('Valid tokens found on app start');
      await _verifyTokenWithServer();
    }
  } catch (e) {
    print('Error checking initial auth state: $e');
  }
}


  void _checkAuthStateOnResume() async {
    try {
      final dioClient = di.getIt<DioClient>();
      final isValid = await dioClient.isTokenValid();

      if (!isValid) {
        print('Tokens invalid on app resume');
        di.getIt<AuthStateManager>().setLoggedOut();
      }
    } catch (e) {
      print('Error checking auth state on resume: $e');
    }
  }

  Future<void> _verifyTokenWithServer() async {
    try {
      // Make a simple API call to verify token
      final dioClient = di.getIt<DioClient>();
      // Ví dụ call một endpoint đơn giản
      // await dioClient.dio.get('/auth/verify');
    } catch (e) {
      print('Token verification failed: $e');
      di.getIt<AuthStateManager>().setLoggedOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
    ///  scaffoldMessengerKey: ,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
      // Handle navigation errors
    );
  }
}
