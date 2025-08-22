import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/features/projects/domain/entities/project_member_entity.dart';
import 'package:to_do/features/projects/presentation/bloc/member_project_cubit.dart';
import 'package:to_do/features/projects/presentation/bloc/project_bloc.dart';
import 'package:to_do/features/projects/presentation/bloc/project_event.dart';
import 'package:to_do/features/projects/presentation/bloc/project_state.dart';
import 'package:to_do/features/projects/presentation/widgets/custom_appbar_member.dart';
import 'package:to_do/features/users/presentation/widgets/member_card.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamMemberView extends StatefulWidget {
  final String projectId;

  const TeamMemberView({super.key, required this.projectId});

  @override
  State<TeamMemberView> createState() => _TeamMemberViewState();
}

class _TeamMemberViewState extends State<TeamMemberView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch members in initState to ensure it's called once
    Future.microtask(() => {
          //context.read<ProjectBloc>().add(FetchMemberByProject(widget.projectId))
          context.read<MemberProjectCubit>().fetchMembers(widget.projectId)
        });
    //
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available')),
      );
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot make phone call')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppbarMember(
            tabController: _tabController,
            onAddMember: () async {
              await context.pushNamed('userSearchScreen',
                  extra: widget.projectId);
              if (mounted) {
                context
                    .read<ProjectBloc>()
                    .add(FetchMemberByProject(widget.projectId));
              }
            }),
        body: BlocBuilder<MemberProjectCubit, List<ProjectMemberEntity>>(
            builder: (context, state) {
          if (state.isEmpty) {
            return Center(child: Text('No members'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: All Members
              ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    child: Text(
                      '${state.length} thành viên',
                      style: GoogleFonts.robotoFlex(fontSize: 20),
                    ),
                  ),
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.length,
                    itemBuilder: (context, index) {
                      final member = state[index];
                      return MemberCard(
                        member,
                        onCall: () => _makePhoneCall(member.phone),
                      );
                    },
                  ),
                ],
              ),
              // Tab 2: Leader Only
              Builder(
                builder: (context) {
                  final leader = state.firstWhere(
                    (member) => member.role == 'Leader',
                  );
                  return Column(
                    children: [
                      if (leader.id.isNotEmpty)
                        MemberCard(
                          leader,
                          onCall: () => _makePhoneCall(leader.phone),
                        )
                      else
                        const Center(child: Text('No leader assigned')),
                    ],
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}
