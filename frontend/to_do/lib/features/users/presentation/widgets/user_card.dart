import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';

class UserCard extends StatelessWidget {
  final UserEntity user;
  bool isAdded;
  final void Function(UserEntity)? onAdd;
  final VoidCallback? onMessage;
  final VoidCallback? onCall;
  final VoidCallback? onEmail;
  final Function(BuildContext context)? onDelete; 
  bool isHidden;

  UserCard(this.user,
      {super.key,
      this.onMessage,
      this.onCall,
      this.onEmail,
      this.onAdd,
      this.onDelete, 
      this.isHidden = false,
      this.isAdded = false});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(motion: const ScrollMotion(), children: [
        CustomSlidableAction(
          backgroundColor: Colors.white,
          onPressed: onDelete, 
          
          
           /* (context) {
             // TODO: Xoa user khoi task
              context.pop();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Delete user')));
          }, */
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_forever_outlined, size: 35, color: Colors.red),
              Text('Delete', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ]),
      child: GestureDetector(
          onTap: () => _showMemberDetails(context),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                user.avatar != null && user.avatar!.isNotEmpty
                                    ? NetworkImage(user.avatar!)
                                    : null,
                            radius: 28,
                            onBackgroundImageError: (exception, stackTrace) {
                              // Handle image loading error
                            },
                            child: user.avatar == null || user.avatar!.isEmpty
                                ? Text(
                                    user.name?.isNotEmpty == true
                                        ? user.name![0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? 'No name',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email ?? 'No email',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                isHidden
                    ? SizedBox()
                    : ElevatedButton(
                        onPressed: isAdded ? null : () => onAdd!(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAdded ? Colors.grey : Colors.blue,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          isAdded ? 'Đã Thêm' : 'Thêm',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
              ],
            ),
          )),
    );
  }

  void _doSomething(BuildContext context) {
    // Dispatch a delete event to UserBloc (example)
    // context.read<UserBloc>().add(DeleteUserEvent(userId: user.id ?? ''));
    //  ScaffoldMessenger.of(context).showSnackBar(
    //  SnackBar(content: Text('Deleting user: ${user.fullname ?? 'Unknown'}')),
    //  );
  }

  void _showMemberDetails(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxHeight: 800),
      builder: (context) => _MemberDetailsSheet(
        user: user,
        onMessage: onMessage,
        onCall: onCall,
        onEmail: onEmail,
      ),
    );
  }
}

class _MemberDetailsSheet extends StatelessWidget {
  final UserEntity user;
  final VoidCallback? onMessage;
  final VoidCallback? onCall;
  final VoidCallback? onEmail;

  const _MemberDetailsSheet({
    required this.user,
    this.onMessage,
    this.onCall,
    this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // User Image with overlay
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  image: user.avatar != null && user.avatar!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(user.avatar!),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Handle image error
                          },
                        )
                      : null,
                ),
                child: user.avatar == null || user.avatar!.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(25),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : null,
              ),
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // User info overlay
              Positioned(
                left: 24,
                right: 24,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name ?? 'No name',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email ?? 'No email',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.message_rounded,
                  label: 'Message',
                  color: Colors.blue,
                  onTap: onMessage,
                ),
                _buildActionButton(
                  icon: Icons.call,
                  label: 'Call',
                  color: Colors.green,
                  onTap: onCall,
                ),
                _buildActionButton(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  color: Colors.orange,
                  onTap: onEmail,
                ),
              ],
            ),
          ),
          // Additional info section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                // Add more user details here if available
                Text(
                  'No additional information available.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
