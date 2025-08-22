import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/utils/utils.dart';
import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:to_do/features/projects/presentation/bloc/project_bloc.dart';
import 'package:to_do/features/projects/presentation/bloc/project_event.dart';
import 'package:to_do/features/projects/presentation/screens/team_member_view.dart';
import 'package:to_do/features/projects/presentation/widgets/avatar_circle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectDetailedCard extends StatelessWidget {
  final ProjectEntity project;

  const ProjectDetailedCard({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
        color: Colors.white,
      ),
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name.isNotEmpty ? project.name : 'Unnamed Project',
            style: GoogleFonts.roboto(
              color: const Color.fromARGB(255, 7, 41, 92),
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              Text('Lead by ', style: GoogleFonts.robotoFlex(
                  color: const Color.fromARGB(255, 16, 17, 19),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),),
                  Text(
            project.members.firstWhere(
                  (item) => item.userId == project.leader_id,
                ).name,
            style: GoogleFonts.robotoFlex(
              color: const Color.fromARGB(255, 16, 17, 19),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
            ],
          ), 
        
          const SizedBox(height: 20),
          _buildDisplayDate(context),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.edit_outlined),
              const SizedBox(width: 5),
              Text(
                'Description',
                style: GoogleFonts.afacad(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ExpandableText(
            trimLines: 3,
            text: project.description.isNotEmpty
                ? project.description
                : 'No description available',
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_3_outlined),
                  const SizedBox(width: 5),
                  Text(
                    'Team Members',
                    style: GoogleFonts.afacad(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Cu the so thanh vien
              Container(
                margin: EdgeInsets.only(right: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300, shape: BoxShape.circle),
                child: Text(
                  project.members.length.toString(),
                  style: GoogleFonts.afacad(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          _buildSectionMember(context),
        ],
      ),
    );
  }

  Widget _buildDisplayComponent(
    BuildContext context, // Added context parameter
    String label,
    DateTime? date,
    Color colorIcon, {
    Function(BuildContext)? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.robotoFlex(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              Text(
                date != null ? Utils.formatDate2(date) : 'Not set',
                style: GoogleFonts.robotoFlex(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap:
                onTap != null ? () => onTap(context) : null, // Simplified onTap
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorIcon,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showPickDate(BuildContext context,
      {required bool isStartDate}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: project.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
  }

  Widget _buildDisplayDate(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildDisplayComponent(
            context, // Pass context
            'Start Date',
            project.startDate,
            Colors.deepPurple.shade300,
            onTap: (ctx) => showPickDate(ctx, isStartDate: true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDisplayComponent(
            context, // Pass context
            'End Date',
            project.endDate,
            const Color.fromARGB(255, 197, 52, 8),
            onTap: (ctx) => showPickDate(ctx, isStartDate: false),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionMember(BuildContext context) {
    final int memberCount = project.members.length;
    const int displayLimit = 5;
    const double avatarOffset = 14.0;

    if (memberCount == 0) {
      return Text(
        'No team members',
        style: GoogleFonts.robotoFlex(
          color: Colors.grey.shade600,
          fontSize: 16,
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
        await context.pushNamed('teamMemberScreen', extra: project.id);
        if (context.mounted) {
          context.read<ProjectBloc>().add(FetchProjectById(project.id));
        }
      },
      child: Row(
        children: [
          for (int i = 0; i < memberCount && i < displayLimit; i++)
            Transform.translate(
              offset: Offset(-i * avatarOffset, 0.0),
              child: AvatarCircle(avatar: project.members[i].avatar, size: 20),
            ),
          if (memberCount > displayLimit)
            Transform.translate(
              offset: Offset(-(displayLimit * avatarOffset), 0.0),
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade400,
                ),
                child: Center(
                  child: Text(
                    '+${memberCount - displayLimit}',
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;

  const ExpandableText({
    super.key,
    required this.text,
    this.trimLines = 3,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with TickerProviderStateMixin {
  bool _readMore = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: widget.text,
          style: GoogleFonts.robotoFlex(
            color: Colors.grey.shade600,
            fontSize: 19,
            fontWeight: FontWeight.w400,
          ),
        );

        final tp = TextPainter(
          text: span,
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        );

        tp.layout(maxWidth: constraints.maxWidth);

        final isOverflow = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: ConstrainedBox(
                constraints: _readMore
                    ? BoxConstraints(maxHeight: tp.height)
                    : const BoxConstraints(),
                child: Text(
                  widget.text,
                  softWrap: true,
                  style: GoogleFonts.afacad(
                    color: Colors.grey.shade600,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            if (isOverflow)
              TextButton(
                child: Text(_readMore ? "View more" : "View less"),
                onPressed: () {
                  setState(() => _readMore = !_readMore);
                },
              ),
          ],
        );
      },
    );
  }
}
