import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/utils/helpers/error.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_event.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_state.dart';
import 'package:to_do/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:to_do/features/profile/presentation/screens/today_task_screen.dart';
import 'package:to_do/features/profile/presentation/screens/widgets/item_profile_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/profile/presentation/screens/widgets/stats_card.dart';
import 'package:to_do/features/stats/presentation/blocs/stats_bloc.dart';
import 'package:to_do/features/stats/presentation/blocs/stats_state.dart';

class ProfileScreen extends StatelessWidget {
//  final String userId;

  const ProfileScreen({
    // required this.userId,
    Key? key,
  }) : super(key: key);

  void _onLogoutPressed(BuildContext context) {
    // Xử lý logout ở đây, ví dụ gọi API hoặc clear token rồi navigate
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Đăng xuất",
            style: GoogleFonts.roboto(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.w800)),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // hủy
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade400),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: Text(
              "Đăng xuất",
              style: GoogleFonts.robotoSlab(fontSize: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('Auth State Current: $state');
        if (state is AuthLogoutSuccess) {
          // context.pushReplacementNamed('signInScreen');
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return SignInScreen();
          }));
        } else if (state is AuthLogoutFailure) {
          ErrorHelper.showError(
              context, 'Đăng xuất thất bại, vui lòng thử lại sau... ');
          context.read<AuthBloc>().add(LoadCacheUser());
        }
      },
      child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.grey.shade100,
                centerTitle: true,
                title: Text(
                  'Hồ Sơ Cá Nhân',
                  style: GoogleFonts.openSans(fontWeight: FontWeight.w700),
                ),
              ),
              _buildInfo(),
              _buildStatsCard(),
              _buildItemSection(),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                ),
              )
            ],
          )),
    );
  }

  Widget _buildItemSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, // màu nền
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            ItemProfileCard(
              icon: Icons.person,
              label: 'Tài khoản của tôi',
              colorBackgroundIcon: Colors.blueAccent.withOpacity(0.4),
              colorIcon: Colors.blueAccent,
            ),
            SizedBox(height: 12),
            ItemProfileCard(
              icon: Icons.password_outlined,
              label: 'Thay đổi mật khẩu',
              colorBackgroundIcon: Colors.blueAccent.withOpacity(0.4),
              colorIcon: Colors.blueAccent,
            ),
            SizedBox(height: 12),
            ItemProfileCard(
              icon: Icons.support_outlined,
              label: 'Hỗ trợ & phản hồi',
              colorBackgroundIcon: Colors.blueAccent.withOpacity(0.4),
              colorIcon: Colors.blueAccent,
            ),
            SizedBox(height: 12),
            ItemProfileCard(
              onTap: (context) {
                _onLogoutPressed(context);
              },
              icon: Icons.logout_outlined,
              label: 'Đăng xuất',
              colorBackgroundIcon: Color(0x66F44336),
              colorIcon: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is GetLocalUserSuccess) {
        final user = state.user;
        return SliverToBoxAdapter(
          child: Column(
            children: [
              // Thêm hero animation cho avatar
              Hero(
                  tag: 'user-avatar',
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.blue.shade300],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
                    padding: EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: NetworkImage(user.avatar),
                    ),
                  )),

              const SizedBox(
                height: 10,
              ),
              Text(
                user.name,
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w700, fontSize: 22),
              ),
              Text(
                user.email,
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.grey),
              )
            ],
          ),
        );
      }
      return SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        ),
      );
    });
  }

  Widget _buildStatsCard() {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        if (state is StatsLoaded) {
          final stat = state.data;
          return SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                StatsCard(
                  label: 'Tổng Nhiệm vụ',
                  count: stat.totalTask,
                  icon: Icons.schedule_rounded,
                  gradientColors: [
                    Colors.deepPurple,
                    Colors.deepPurple.shade300
                  ], // Pink Red
                ),
                StatsCard(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TodayTaskScreen()));
                  },
                  label: 'Task Hôm nay',
                  count: stat.totalTodayTask,
                  icon: Icons.pending_rounded,
                  gradientColors: [
                    const Color.fromARGB(255, 68, 227, 255),
                    Color.fromARGB(255, 29, 131, 233)
                  ], // Blue Cyan
                ),
                StatsCard(
                  label: 'Tổng dự án',
                  count: stat.totalProject,
                  icon: Icons.folder_rounded,
                  suffix: '+',
                  gradientColors: [
                    Colors.pink,
                    Colors.pink.shade300
                  ], // Green Mint
                ),
              ],
            ),
          ));
        }
        return SliverToBoxAdapter(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
