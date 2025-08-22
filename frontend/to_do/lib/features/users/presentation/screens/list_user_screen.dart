import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/projects/domain/entities/project_member_entity.dart';
import 'package:to_do/features/projects/presentation/bloc/project_bloc.dart';
import 'package:to_do/features/projects/presentation/bloc/project_event.dart';
import 'package:to_do/features/projects/presentation/bloc/project_state.dart';
import 'package:to_do/features/users/presentation/bloc/user_bloc.dart';
import 'package:to_do/features/users/presentation/bloc/user_event.dart';
import 'package:to_do/features/users/presentation/bloc/user_state.dart';
import 'package:to_do/features/users/presentation/widgets/user_card.dart';

class ListUserScreen extends StatefulWidget {
  final String projectId;

  const ListUserScreen({super.key, required this.projectId});

  @override
  State<ListUserScreen> createState() => _ListUserScreenState();
}

class _ListUserScreenState extends State<ListUserScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  List<UserEntity> _results = [];
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final Set<String> _addedUserIds = {};
  //  List<ProjectMemberEntity> memberOfProject = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Fetch project members to initialize _addedUserIds
    context.read<ProjectBloc>().add(FetchMemberByProject(widget.projectId));
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        setState(() {
          isExpanded = true;
          _animationController.forward();
        });
        context.read<UserBloc>().add(SearchUserByKeyWord(query));
      } else {
        setState(() {
          _results = [];
          isExpanded = false;
          _animationController.reverse();
        });
      }
    });
  }

  void _onAddUser(UserEntity user) {
    context.read<ProjectBloc>().add(AddMemberIntoProject(
          widget.projectId,
          user!.userId,
        ));
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProjectBloc, ProjectState>(
            listener: (context, state) {
              if (state is MembersOfProjectSuccess) {
                for (var i in state.members) {
                  _addedUserIds.add(i.id);
                }
              }
            },
          ),
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is UserSearchedSuccess) {
                setState(() {
                  _results = state.users;
                });
              } else if (state is UserError) {
                setState(() {
                  _results = [];
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.error}')),
                );
              }
            },
          ),
          BlocListener<ProjectBloc, ProjectState>(
            listener: (context, state) {
              if (state is ProjectMemberAddedSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Đã thêm thành viên thành công')),
                );

                setState(() {
                  _addedUserIds.add(state.user_id);
                });

                // print(_addedUserIds.length);
              } else if (state is ProjectError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${state.error}')),
                );
              }
            },
          ),
        ],
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              expandedHeight: 120,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.pop();
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(10),
                            child:
                                const Icon(Icons.arrow_back_ios_new_outlined),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              onChanged: _onSearchChanged,
                              controller: searchController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                hintText: 'Tìm kiếm',
                                hintStyle: GoogleFonts.inter(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoading && isExpanded) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return SlideTransition(
                    position: _slideAnimation,
                    child: _results.isEmpty && isExpanded
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No results found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              for (var user in _results)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: UserCard(
                                    user,
                                    isAdded:
                                        _addedUserIds.contains(user.userId),
                                    onAdd: _onAddUser,
                                    onMessage: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Messaging ${user.name}')),
                                      );
                                    },
                                    onCall: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Calling ${user.name}')),
                                      );
                                    },
                                    onEmail: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Emailing ${user.name}')),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
