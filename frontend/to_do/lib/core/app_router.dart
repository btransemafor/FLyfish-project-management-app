import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_bloc.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_event.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:to_do/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:to_do/features/comments/presentation/Bloc/comment_bloc.dart';
import 'package:to_do/features/comments/presentation/Bloc/comment_event.dart';
import 'package:to_do/features/home/presentation/screens/home.dart';
import 'package:to_do/features/projects/presentation/bloc/member_project_cubit.dart';
import 'package:to_do/features/projects/presentation/bloc/project_bloc.dart';
import 'package:to_do/features/projects/presentation/bloc/project_event.dart';
import 'package:to_do/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:to_do/features/projects/presentation/screens/team_member_view.dart';
import 'package:to_do/features/search/presentation/screens/search_project_screen.dart';
import 'package:to_do/features/task/presentation/bloc/task_bloc.dart';
import 'package:to_do/features/task/presentation/bloc/task_event.dart';
import 'package:to_do/features/task/presentation/screens/create_new_task_screen.dart';
import 'package:to_do/features/task/presentation/screens/task_attachment_detail_screen.dart';
import 'package:to_do/features/task/presentation/screens/task_detail_screen.dart';
import 'package:to_do/features/task/presentation/screens/view_list_task_screen.dart';
import 'package:to_do/features/users/presentation/screens/list_user_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/users/presentation/widgets/user_card.dart';
import 'package:to_do/injection.dart';

final routeObserver = RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


class AppRouter {
  /// The route configuration.
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  static final GoRouter router = GoRouter(
    observers: [routeObserver],
    navigatorKey: navigatorKey,
    
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'signInScreen',
        builder: (context, state) {
          print('Vào login'); 
          return SignInScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (BuildContext context, GoRouterState state) {
              context.read<ProjectBloc>().add(FetchProject());
              return Home();
            },
          ),
          GoRoute(
            path: '/project-detail',
            name: 'projectDetail',
            builder: (BuildContext context, GoRouterState state) {
              final projectId = state.extra as String;
              context.read<ProjectBloc>().add(FetchProjectById(projectId));
              context.read<TaskBloc>().add(LoadTaskForAProject(projectId));
              return BlocProvider(
                create: (_) => getIt<TaskBloc>(),
                child: Builder(builder: (context) {
                  context.read<TaskBloc>().add(LoadTaskForAProject(projectId));
                  return ProjectDetailScreen(projectId: projectId);
                }),
              );
            },
          ),
          GoRoute(
              path: '/task-detail-screen',
              name: 'taskDetailScreen',
              builder: (context, state) {
                final task_id = state.extra as String;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => getIt<TaskBloc>()),
                    BlocProvider(create: (_) => getIt<CommentBloc>())
                  ],
                  child: Builder(
                    builder: (context) {
                      Future.microtask(() {
                        context
                            .read<CommentBloc>()
                            .add(FetchCommentsEvent(task_id));
                        context.read<TaskBloc>().add(FetchTaskDetail(task_id));
                      });
                      return TaskDetailScreen(taskId: task_id);
                    },
                  ),
                );
              }),
          GoRoute(
            path: '/user-search-screen',
            name: 'userSearchScreen',
            builder: (context, state) {
              final project_id = state.extra as String;

              return ListUserScreen(
                projectId: project_id,
              );
            },
          ),
          GoRoute(
            path: '/team-member',
            name: 'teamMemberScreen',
            builder: (context, state) {
              final String projectId = state.extra as String;
              return TeamMemberView(projectId: projectId);
            },
          ),
          GoRoute(
              path: '/create-new-task-screen',
              name: 'createNewTaskScreen',
              builder: (context, state) {
                final String projectId = state.extra as String;

                return CreateNewTaskScreen(project_id: projectId);
              }),
          GoRoute(
              path: '/view-list-task-screen',
              name: 'viewListTaskScreen',
              builder: (context, state) {
                final String projectId = state.extra as String;
                context.read<TaskBloc>().add(LoadTaskForAProject(projectId));
                return ViewListTaskScreen(projectId: projectId);
              }),
          GoRoute(
            path: '/task-attachment-detail-screen',
            name: 'taskAttachmentDetailScreen',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              final String taskId = extra['taskId'];
              final String title = extra['title'];
              final String projectId = extra['projectId'];
              final List<UserEntity> users = extra['users'] ?? [];
              return BlocProvider(
                create: (_) => getIt<AttachmentBloc>(),
                child: Builder(builder: (context) {
                  context
                      .read<AttachmentBloc>()
                      .add(FetchTaskFiles(taskId: taskId));
                  return TaskAttachmentDetailScreen(
                    taskId: taskId,
                    assignees: users ?? [],
                    taskTitle: title,
                    projectId: projectId,
                  );
                }),
              );
            },
          ), 


          GoRoute(      
            path: '/search-project-screen',
            name: 'searchProjectScreen', 
            builder: (context, state) {
              return SearchProjectScreen(); 
            }
          )
        ],
      ),
    ],
  );
}
