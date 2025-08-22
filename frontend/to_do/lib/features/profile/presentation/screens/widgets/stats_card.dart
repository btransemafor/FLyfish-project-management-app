import 'package:flutter/material.dart';

class StatsCard extends StatefulWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final String? suffix;
  VoidCallback? onTap; 

  StatsCard({
    Key? key,
    this.onTap,
    required this.label,
    required this.count,
    required this.icon,
    this.iconColor = Colors.white,
    this.gradientColors = const [Color(0xFF667eea), Color(0xFF764ba2)],
    this.suffix,
  }) : super(key: key);

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Auto animate on build
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.forward().then((_) => _controller.reverse());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.gradientColors,
                      stops: [0.0, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      // Main shadow
                      BoxShadow(
                        color: widget.gradientColors.first.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                        spreadRadius: 0,
                      ),
                      // Glow effect
                      BoxShadow(
                        color: widget.gradientColors.last.withOpacity(_glowAnimation.value),
                        blurRadius: 30,
                        offset: const Offset(0, 0),
                        spreadRadius: -5,
                      ),
                      // Inner highlight
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 0,
                        offset: const Offset(0, 1),
                        spreadRadius: 0,
                       // inset: true,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with animated background
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          size: 28,
                          color: widget.iconColor,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Count with animated number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.9),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              widget.count.toString(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.suffix != null) ...[
                            SizedBox(width: 4),
                            Text(
                              widget.suffix!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Label with glassmorphism effect
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 0.5,
                          ),
                        ///  backdropFilter: BlurEffect(),
                        ),
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Animated progress indicator
                      Container(
                        width: double.infinity,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _glowAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.8),
                                  Colors.white.withOpacity(0.4),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Custom BlurEffect class (simplified)
class BlurEffect {
  // This is a placeholder - you might need to implement proper backdrop filter
  // or use a package like flutter_glassmorphism
}

// Usage examples with different gradient combinations:
/*
StatsCard(
  label: 'Hoàn thành',
  count: 24,
  icon: Icons.check_circle_rounded,
  gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)], // Purple Blue
),

StatsCard(
  label: 'Đang thực hiện',
  count: 12,
  icon: Icons.schedule_rounded,
  gradientColors: [Color(0xFFf093fb), Color(0xFFf5576c)], // Pink Red
),

StatsCard(
  label: 'Chờ xử lý',
  count: 8,
  icon: Icons.pending_rounded,
  gradientColors: [Color(0xFF4facfe), Color(0xFF00f2fe)], // Blue Cyan
),

StatsCard(
  label: 'Tổng dự án',
  count: 156,
  icon: Icons.folder_rounded,
  suffix: '+',
  gradientColors: [Color(0xFF43e97b), Color(0xFF38f9d7)], // Green Mint
),
*/