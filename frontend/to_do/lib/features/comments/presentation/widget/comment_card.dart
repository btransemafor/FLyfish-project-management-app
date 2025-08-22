import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/utils/utils.dart';
import 'package:to_do/features/comments/domain/entity/comment_entity.dart';
import 'package:to_do/features/projects/presentation/widgets/avatar_circle.dart';

class CommentCard extends StatefulWidget {
  final CommentEntity comment;
  final VoidCallback? onReply;
  final VoidCallback? onLike;
  final int level;
  final bool isLast; // Để biết có phải comment cuối không
  
  CommentCard({
    required this.comment,
    this.onReply,
    this.onLike,
    super.key,
    this.level = 0,
    this.isLast = false,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    if (widget.onLike != null) {
      widget.onLike!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReply = widget.level > 0;
    final double leftPadding = widget.level * 5.0;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.only(
              top: 10,
              left: leftPadding,
              bottom: 12,
            ),
            child: Column(
              children: [
                // Main comment
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar với connecting line cho replies
                    Column(
                      children: [
                        Stack(
                          children: [
                            AvatarCircle(
                              avatar: widget.comment.user.avatar,
                              size: isReply ? 15 : 18,
                            ),
                            // Connecting line từ avatar parent xuống
                            if (isReply)
                              Positioned(
                                top: -20,
                                left: 16,
                                child: Container(
                                  width: 2,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Connecting line xuống replies con
                        if (widget.comment.replies.isNotEmpty && !widget.isLast)
                          Container(
                            width: 2,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                      ],
                    ),
                    
                    SizedBox(width: 5),
                    
                    // Comment content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Comment bubble
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isReply 
                                  ? Colors.grey.shade100 
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(20),
                              ),
                              border: isReply 
                                  ? Border.all(color: Colors.grey.shade200, width: 1)
                                  : Border.all(color: Colors.blue.shade100, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // User name
                                Text(
                                  widget.comment.user.name,
                                  style: GoogleFonts.robotoFlex(
                                    fontWeight: FontWeight.w700,
                                    fontSize: isReply ? 13 : 14,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Comment content
                                Text(
                                  widget.comment.content,
                                  style: GoogleFonts.robotoFlex(
                                    fontSize: isReply ? 13 : 14,
                                    color: Colors.grey.shade800,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 8),
                          
                          // Action buttons
                          Row(
                            children: [
                              // Time
                              Text(
                                Utils.formatDateTime(widget.comment.createdAt),
                                style: GoogleFonts.robotoFlex(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              
                              SizedBox(width: 16),
                              
                              // Like button
                              GestureDetector(
                                onTap: _handleLike,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 200),
                                      child: Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        size: 16,
                                        color: isLiked ? Colors.red.shade500 : Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Thích',
                                      style: GoogleFonts.robotoFlex(
                                        fontSize: 12,
                                        color: isLiked ? Colors.red.shade500 : Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(width: 16),
                              
                              // Reply button
                              GestureDetector(
                                onTap: widget.onReply,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.reply_rounded,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Trả lời',
                                      style: GoogleFonts.robotoFlex(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // More options
                              
                             
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Replies - được indent bằng cách wrap trong Container với padding
                if (widget.comment.replies.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(left: 40), // Indent replies
                    child: Column(
                      children: widget.comment.replies.asMap().entries.map((entry) {
                        int index = entry.key;
                        CommentEntity reply = entry.value;
                        bool isLastReply = index == widget.comment.replies.length - 1;
                        
                        return CommentCard(
                          comment: reply,
                          level: widget.level + 1,
                          onReply: widget.onReply,
                          onLike: widget.onLike,
                          isLast: isLastReply,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}