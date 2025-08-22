// lib/features/projects/presentation/widgets/project_card.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/utils/utils.dart';
import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:to_do/features/projects/presentation/widgets/avatar_circle.dart';


// Hàm randomColor 

Color randomColor() {
  final List<Color> colors = [
    Colors.blueAccent.shade200,
    const Color.fromARGB(255, 134, 7, 7),
    const Color.fromARGB(255, 9, 73, 42),
    const Color.fromARGB(255, 210, 138, 29),
  ];
  final Random random = Random();
  return colors[random.nextInt(colors.length)];
}

class ProjectCard extends StatefulWidget {
  final ProjectEntity project;
  Color? background;
  VoidCallback? onTap;

  ProjectCard({
    required this.project,
    this.background,
    this.onTap,
    super.key,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  void onChangeColor(Color c) {
    setState(() {
      widget.background = c;
    });
  }
  late Color colorBGRadom; 
  @override
  void initState() {
    super.initState(); 
    colorBGRadom = randomColor();
  }

  Widget _buildDisplayAvatar() {
    final members = widget.project.members;
    if (members.isEmpty) {
      return const SizedBox.shrink(); // Handle empty members list
    }

    const avatarSize = 15.0; // Size of each avatar
    const overlap = 1; // Overlap between avatars
    const maxAvatars = 5; // Max avatars to display

    // Calculate number of avatars to show (up to maxAvatars)
    final displayCount =
        members.length > maxAvatars ? maxAvatars : members.length;
    final extraCount = members.length - maxAvatars; // Count of extra members

    return Stack(
      clipBehavior: Clip.none, // Allow avatars to overflow
      children: [
        // Avatars
        for (var i = 0; i < displayCount; i++)
          Positioned(
            left: i * (avatarSize + 5 - overlap), // Dynamic positioning
            child: AvatarCircle(
              avatar: members[i].avatar,
              size: avatarSize,
              // initials: members[i].name.isNotEmpty ? members[i].name[0] : '',
            ),
          ),
        // "+N" badge for extra members
        if (extraCount > 0)
          Positioned(
            left: displayCount * (avatarSize + 7 - overlap),
            top: 5,
            child: Container(
              width: avatarSize + 10,
              height: avatarSize + 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[700],
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '+$extraCount',
                  style: GoogleFonts.afacad(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDeadlineProject() {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.lock_clock,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              'Start: ',
              style: GoogleFonts.afacad(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            Text(
                Utils.formatDate(
                  widget.project.startDate,
                ),
                style: GoogleFonts.afacad(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.flip_camera_android_sharp,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              'End: ',
              style: GoogleFonts.afacad(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            Text(
                Utils.formatDate(
                          widget.project.endDate,
                        ) ==
                        ''
                    ? 'Chưa xác định'
                    : Utils.formatDate(
                        widget.project.endDate,
                      ),
                style: GoogleFonts.afacad(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  // Build Bar Task
  Widget _buildTaskProgressBar() {
    final double percentage = widget.project.numberTask == 0
        ? 0
        : (widget.project.numberCompletedTask / widget.project.numberTask);
    final bool isComplete =
        widget.project.numberTask == widget.project.numberCompletedTask &&
            widget.project.numberTask != 0;
    return Padding(
      padding: const EdgeInsets.only(right: 15, top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isComplete
                    ? 'Completed'
                    : 'In Progress: [${(percentage * 100).toStringAsFixed(1)} %]',
                style: GoogleFonts.afacad(
                    fontSize: 17, fontWeight: FontWeight.w500),
              ),
              Text(
                'Tasks: ' + widget.project.numberTask.toString(),
                style: GoogleFonts.afacad(
                    fontSize: 17, fontWeight: FontWeight.w500),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 15,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                  const Color.fromARGB(255, 13, 31, 81)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final colorBGRandom = randomColor(); 
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              widget.background ??
                  colorBGRadom, // Fallback to blueAccent
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.project.name,
                    style: GoogleFonts.afacad(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_outlined, size: 20),
                  onPressed: () {
                    _showProjectMenu(context);
                  },
                ),
              ],
            ),
            Text(
              widget.project.description,
              style: GoogleFonts.afacad(
                fontSize: 15,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(height: 25, child: _buildDisplayAvatar()),
                ),
                Expanded(child: _buildDeadlineProject()),
              ],
            ),
            _buildTaskProgressBar(), 

            const SizedBox(height: 15,)
          ],
        ),
      ),
    );
  }

  void _showProjectMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Change Color'),
              onTap: () {
                Navigator.pop(context);
                _showColorPicker(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Hidden Project'),
              onTap: () {
                Navigator.pop(context);
                // Trigger delete action
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Pick a color', style: GoogleFonts.afacad()),
        content: SingleChildScrollView(
          child: BlockPicker(
              pickerColor: widget.background, onColorChanged: onChangeColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done', style: GoogleFonts.afacad(fontSize: 19)),
          ),
        ],
      ),
    );
  }
}
