import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:to_do/core/common/custom_loading.dart';
import 'package:to_do/core/utils/utils.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_event.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_state.dart';
import 'package:to_do/features/home/presentation/bloc/home_bloc.dart';
import 'package:to_do/features/home/presentation/bloc/home_event.dart';
import 'package:to_do/features/home/presentation/bloc/home_state.dart';
import 'package:to_do/features/projects/presentation/bloc/project_bloc.dart';
import 'package:to_do/features/projects/presentation/bloc/project_event.dart';
import 'package:to_do/features/projects/presentation/widgets/project_card.dart';
import 'package:to_do/features/task/presentation/widgets/task_card.dart';
import 'package:to_do/injection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void didPopNext() {
    // Gọi khi quay lại HomeScreen từ màn hình khác
    if (mounted) {
      context.read<ProjectBloc>().add(FetchProject());
      print('Quay lại HomeScreen, gọi FetchProject');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Gọi mỗi lần widget được mount lại sau khi quay lại
    print("HomeScreen đang hiển thị lại");
    context.read<ProjectBloc>().add(FetchProject());
  }

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(GetLocalUser());
    context.read<ProjectBloc>().add(FetchProject());
  }

  Future<void> _handleRefresh() async {
    context.read<HomeBloc>().add(LoadHomeData(countNearestCurrent: 7));
  }

  String _mapErrorToMessage(String error) {
    if (error.contains('DioError') || error.contains('Connection')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    } else if (error.contains('Unauthorized')) {
      return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
    }
    return 'Đã xảy ra lỗi: $error';
  }

  Widget _buildHeaderHome(BuildContext context, UserEntity user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.sort,
                size: 35,
              ),
              const SizedBox(width: 20),
              CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(user.avatar),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Hi, ${user.name}',
                style: GoogleFonts.afacad(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromARGB(255, 14, 31, 61),
                ),
              ),
              const SizedBox(width: 10),
              Lottie.asset(
                'assets/animation/hand_waving.json',
                width: 35,
                height: 35,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                print('Nhấn vào search'); 
                context.pushNamed('searchProjectScreen'); 
              },
              child: IgnorePointer(
                child: TextFormField(
                  showCursor: false,
                  decoration: InputDecoration(
                    
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search for Tasks',
                    hintStyle: GoogleFonts.afacad(),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 15, 36, 226),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(27, 10, 93, 0.22),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(
              Icons.filter_alt_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListProject() {
    return BlocConsumer<HomeBloc, HomeState>(listener: (context, state) {
      // ignore: avoid_print
      print('Current State $state');

      if (state is HomeLoading) {
      } else if (state is HomeLoadSuccess) {
      } else if (state is HomeFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }, builder: (context, state) {
      if (state is HomeLoading) {
        return SliverToBoxAdapter(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ShimmerWidget.rectangular(height: 200),
          )),
        );
      } else if (state is HomeLoadSuccess) {

        if (state.projects!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Text(
                'Chưa có dự án nào.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        final color = Utils.randomColor(); 

        return SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.projects!.length,
              itemBuilder: (context, index) {
                print('${state.projects![0].numberTask}');
                final project = state.projects![index];
                return SizedBox(
                  width: 400,
                  child: ProjectCard(
                    background: color,
                    project: project,
                    onTap: () {
                      context.pushNamed('projectDetail', extra: project.id);
                    },
                  ),
                );
              },
            ),
          ),
        );
      } else if (state is HomeFailure) {
        return SliverToBoxAdapter(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _mapErrorToMessage(state.message),
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<ProjectBloc>().add(FetchProject()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        );
      }
      return SliverToBoxAdapter(child: Text('No Data'));
    });
  }

  Widget _buildTitleSection(String label, String subLabel,
      [VoidCallback? onPress]) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.afacad(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            TextButton(
              onPressed: onPress,
              child: Text(
                subLabel,
                style: GoogleFonts.afacad(
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is HomeLoadSuccess) {
          if (state.tasks!.isEmpty) {
            return const SliverToBoxAdapter(
              child: Center(
                child: Text(
                  'Chưa có công việc nào.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = state.tasks![index];
                if (index == state.tasks!.length - 1) {
                  return Column(
                    children: [
                      TaskCard(task: item),
                      const SizedBox(height: 150),
                    ],
                  );
                }
                return TaskCard(task: item);
              },
              childCount: state.tasks!.length,
            ),
          );
        } else if (state is HomeFailure) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text(
                _mapErrorToMessage(state.message),
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(
          child: Center(
            child: Text(
              'Chưa có dữ liệu',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProjectBloc>()..add(FetchProject()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            color: Colors.white, // màu vòng xoay
            backgroundColor: Colors.blue.shade900, // màu nền vòng xoay
            strokeWidth: 1.0, // độ dày
            displacement: 40, // khoảng cách kéo xuống
            onRefresh: _handleRefresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is GetLocalUserSuccess) {
                        return _buildHeaderHome(context, state.user);
                      } else if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is AuthError) {
                        return Center(
                          child: Text(
                            _mapErrorToMessage(state.message),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const Center(
                        child: Text(
                          'Đang tải...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSearchFilter(),
                ),
                _buildTitleSection('In Progress', 'See all'),
                _buildListProject(),
                _buildTitleSection('Upcoming Tasks', 'View all'),
                _buildTaskList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
