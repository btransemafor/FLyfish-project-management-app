// lib/app_providers.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/auth/domain/usecase/get_user_local_usecase.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:to_do/features/auth/domain/usecase/login_with_email_usecase.dart';
import 'package:flutter/material.dart';
import 'package:to_do/features/projects/presentation/bloc/project_bloc.dart';
import 'package:to_do/features/task/presentation/bloc/task_bloc.dart';
import 'package:to_do/features/users/presentation/bloc/user_bloc.dart';
import 'package:to_do/injection.dart';

/* class AppProviders {
  static MultiBlocProvider build({
    required Widget child,
    required LoginWithEmailUsecase loginWithEmailUsecase,
    required GetUserLocalUsecase getUserLocalUsecase,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(loginWithEmailUsecase, getUserLocalUsecase),
        ),

         BlocProvider(create: (_) => getIt<TaskBloc>()),
      BlocProvider(create: (_) => getIt<ProjectBloc>()),
      BlocProvider(create: (_) => getIt<UserBloc>())
  
      ],
      child: child,
    );
  }
} */