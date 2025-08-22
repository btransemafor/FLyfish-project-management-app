import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_event.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_state.dart';
import 'package:to_do/features/auth/presentation/widgets/custom_button.dart';
import 'package:to_do/features/auth/presentation/widgets/custom_form_field.dart';
import 'package:to_do/features/home/presentation/screens/home.dart';
import 'package:to_do/features/home/presentation/screens/home_screen.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_bloc.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_event.dart';
import 'package:to_do/injection.dart' as di; 
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  bool isDisplayPW = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void displayPassword() {
    setState(() {
      isDisplayPW = !isDisplayPW;
    });
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            'OR',
            style:
                GoogleFonts.poppins(fontSize: 18, color: Colors.blue.shade900),
          ),
          Divider(
            thickness: 1,
            color: Colors.blue.shade900,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimateLogo() {
    return AnimatedBuilder(
        animation: _rotateAnimation,
        builder: (context, child) {
          return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: SweepGradient(
                  startAngle: 0,
                  endAngle: 2 * pi,
                  colors: const [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.indigo,
                    Colors.purple,
                    Colors.red,
                  ],
                  transform: GradientRotation(_controller.value * 2 * pi),
                ),
              ),
              child: Container(
                margin: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    // Title

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 100,
                        width: 200,
                        decoration: BoxDecoration(
                          // border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Image.asset(
                          'assets/logo/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Text(
                      'Fly Fish',
                      style: GoogleFonts.aBeeZee(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900),
                    ),

                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ));
        });
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UserLoginSuccess) {
          final userId = state.user.userId; 
          final notificationBloc = context.read<NotificationBloc>();
            // Join room riêng user
           notificationBloc.add(StartListeningNotifications(userId));
           Navigator.push(
              context, MaterialPageRoute(builder: (context) => Home())); 
        } else if (state is UserLoginFailure) {
          print(state.message); 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Stack(children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      _buildAnimateLogo(),
                      const SizedBox(height: 40),
                      CustomFormField(
                        focusNode: _emailFocusNode,
                        nextFocusNode: _passwordFocusNode,
                        prefixIcon: Icons.email_outlined,
                        label: 'Địa chỉ email',
                        controller: _emailController,
                      ),
                      const SizedBox(height: 20),
                      CustomFormField(
                        focusNode: _passwordFocusNode,
                        prefixIcon: Icons.lock_outline,
                        label: 'Password',
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 180,
                        child: CustomButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (_emailController.text.isEmpty ||
                                _passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Thiếu thông tin đăng nhập')),
                              );
                              return;
                            }
                            print(_passwordController.text);
                            print(_emailController.text.isEmpty);

                            context.read<AuthBloc>().add(
                                  LoginWithEmail(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  ),
                                ); 
                            
                          },
                          elevation: 0,
                          label: 'Đăng Nhập',
                          backgroundColor: Colors.blue.shade900,
                          textColor: Colors.white,
                        ),
                      ),
                      _buildDivider(),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 180,
                        child: CustomButton(
                          elevation: 0,
                          label: 'Đăng ký',
                          backgroundColor: Colors.white,
                          textColor: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Text(
                        'version 1.0.0',
                        style: GoogleFonts.poppins(color: Colors.blue.shade800),
                      ),
                    ],
                  ),
                ),
                if (state is AuthLoading)
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          //color: const Color.fromARGB(255, 0, 0, 0),
                          borderRadius: BorderRadius.circular(15)),
                      child: const Center(
                          child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 255, 8, 8),
                      )),
                    ),
                  ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
