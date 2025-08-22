/* import 'package:flutter/material.dart';

// Xác định xem Nav cần quản lý gì ?

// - Cần biết tab vào item nào ?
// Danh sách các item : cố định or linh hoạt
// CustomBottomNavigation : parent --> Khi nhấn vào một item thì gọi callback truyền ra thằng cha,
// Cha quản lý selectedIndex --> nó

class CustomBottomNavigation extends StatelessWidget {
  final List<IconData> lIconItem;
  final List<String>? llabel; 
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavigation(
      {super.key, required this.lIconItem, required this.selectedIndex, required this.onTap, this.llabel});

  Widget _buildItemNav(IconData icon, int index, String? label) {
  bool isSelected = index == selectedIndex;
  final duration = Duration(milliseconds: 800);

  return Padding(
    padding: const EdgeInsets.only(left: 20, bottom: 10,top: 5),
    child: GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.fastOutSlowIn,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: SizedBox(
              height: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                         TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: isSelected ? 25.0 : 30.0,
                  end: isSelected ? 30.0 : 25.0,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                builder: (context, size, child) {
                  return Icon(
                    icon,
                    size: size,
                    color: isSelected ? Colors.blueAccent : Colors.grey.shade500,
                  );
                },
              ),
                  Expanded(child: const SizedBox(height: 5)),
                isSelected ?   AnimatedOpacity(
                    duration: duration,
                    opacity: isSelected ? 1.0 : 0.0,
                    child: Container(
                      height: 4,
                      width: 20,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ) : label != null ? Text(label, style: TextStyle(fontSize: 10),) : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, -2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 0, bottom: 0),
      margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
      //color: Colors.grey,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(120),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 1/9,
          child: BottomAppBar(
            notchMargin: 1,
            color: Colors.white,
            shape: CircularNotchedRectangle(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(lIconItem.length,
                  (index) => _buildItemNav(lIconItem[index], index, llabel?[index] )),
            ),
          ),
        ),
      ),
    );
  }
}
 */

/* import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final List<IconData> lIconItem;
  final List<String>? llabel; 
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key, 
    required this.lIconItem, 
    required this.selectedIndex, 
    required this.onTap, 
    this.llabel
  });

  Widget _buildItemNav(IconData icon, int index, String? label) {
    bool isSelected = index == selectedIndex;
    const duration = Duration(milliseconds: 300);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.fastOutSlowIn,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? Colors.blueAccent.withOpacity(0.15) : Colors.transparent,
          ),
          child: SizedBox(
            height: 50, // Giới hạn chiều cao để tránh overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon với animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: isSelected ? 20.0 : 24.0,
                    end: isSelected ? 24.0 : 20.0,
                  ),
                  duration: duration,
                  curve: Curves.easeInOut,
                  builder: (context, size, child) {
                    return Icon(
                      icon,
                      size: size,
                      color: isSelected ? Colors.blueAccent : Colors.grey.shade500,
                    );
                  },
                ),
                
                const SizedBox(height: 2),
                
                // Label hoặc Indicator
                if (isSelected)
                  AnimatedOpacity(
                    duration: duration,
                    opacity: 1.0,
                    child: Container(
                      height: 3,
                      width: 16,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  )
                else if (label != null)
                  Flexible(
                    child: AnimatedOpacity(
                      duration: duration,
                      opacity: 0.8,
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -3),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomAppBar(
          height: 95, // Giảm height xuống để tránh overflow
          notchMargin: 8,
          color: Colors.transparent,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                lIconItem.length,
                (index) => _buildItemNav(lIconItem[index], index, llabel?[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Phiên bản tối ưu hơn nếu bạn muốn
class OptimizedCustomBottomNavigation extends StatelessWidget {
  final List<IconData> lIconItem;
  final List<String>? llabel; 
  final int selectedIndex;
  final Function(int) onTap;

  const OptimizedCustomBottomNavigation({
    super.key, 
    required this.lIconItem, 
    required this.selectedIndex, 
    required this.onTap, 
    this.llabel
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 24),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: List.generate(lIconItem.length, (index) {
          final isSelected = index == selectedIndex;
          final hasLabel = llabel != null && llabel!.length > index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected 
                    ? Colors.blueAccent.withOpacity(0.12) 
                    : Colors.transparent,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      lIconItem[index],
                      size: isSelected ? 26 : 24,
                      color: isSelected ? Colors.blueAccent : Colors.grey[500],
                    ),
                    if (hasLabel && !isSelected) ...[
                      const SizedBox(height: 2),
                      Text(
                        llabel![index],
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (isSelected) ...[
                      const SizedBox(height: 3),
                      Container(
                        height: 2,
                        width: 16,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
 */

/*
class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, -2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 1/10,
          child: BottomAppBar(
            color: Colors.transparent,
            elevation: 0,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: Container(
              margin: EdgeInsets.all(0),
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: _buildNavItem(0, Icons.home_rounded, 'Trang chủ')),
                  _buildNavItem(1, Icons.task_alt_rounded, 'Nhiệm vụ'),
                  const SizedBox(width: 40), // Space for FAB
                  _buildNavItem(2, Icons.notifications_rounded, 'Thông báo'),
                  _buildNavItem(3, Icons.person_rounded, 'Cá nhân'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected 
            ? Colors.blueAccent.withOpacity(0.1) 
            : Colors.transparent,
        ),
        child:
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Icon(
                  icon,
                  size: isSelected ? 23 : 21,
                  color: isSelected ? Colors.blueAccent : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  color: isSelected ? Colors.blueAccent : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(label),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                width: isSelected ? 20 : 0,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      
    );
  }
}

// Alternative simpler version without labels
class SimpleCustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const SimpleCustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -5),
            blurRadius: 25,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSimpleNavItem(0, Icons.home_rounded),
          _buildSimpleNavItem(1, Icons.task_alt_rounded),
          const SizedBox(width: 40), // Space for FAB
          _buildSimpleNavItem(2, Icons.notifications_rounded),
          _buildSimpleNavItem(3, Icons.person_rounded),
        ],
      ),
    );
  }

  Widget _buildSimpleNavItem(int index, IconData icon) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
            ? Colors.blueAccent.withOpacity(0.15) 
            : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? Colors.blueAccent : Colors.grey[500],
        ),
      ),
    );
  }
} */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavigation extends StatelessWidget {
  final List<IconData> listIcon;
  final List<String> listLabel;
  final int selectedIndex;
  final Function(int) onTap;
  final int unreadCount;
  const CustomBottomNavigation(
      {super.key,
      required this.onTap,
      required this.selectedIndex,
      required this.listIcon,
      required this.listLabel,
      this.unreadCount = 0});
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(100, 100, 111, 0.2),
            blurRadius: 29,
            spreadRadius: 0,
            offset: Offset(
              0,
              7,
            ),
          ),
        ], color: Colors.white, borderRadius: BorderRadius.circular(35)),
        margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
        height: 70,
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(listIcon.length, (index) {
              if (index == 2) {
                return Row(
                  children: [
                    const SizedBox(
                      width: 35,
                    ),
                    _buildNavItem(
                        index, listIcon[index], listLabel[index], unreadCount)
                  ],
                );
              }
              return _buildNavItem(
                  index, listIcon[index], listLabel[index], unreadCount);
            })));
  }

  Widget _buildNavItem(int index, IconData icon, String label, int numberNoti) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Stack(clipBehavior: Clip.none, children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Icon(
                  icon,
                  size: isSelected ? 23 : 21,
                  color: isSelected ? Colors.blueAccent : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  color: isSelected ? Colors.blueAccent : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(
                  label,
                  style: GoogleFonts.afacad(fontSize: 12),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                width: isSelected ? 20 : 0,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          numberNoti > 0 && index == 2
              ? Positioned(
                  top: -13,
                  right: !isSingleDigit(numberNoti) ? -7 : -5,
                  child: Container(
                    padding: isSingleDigit(numberNoti)
                        ? const EdgeInsets.all(6)
                        : const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                    child: Text(
                      '${numberNoti}',
                      style: GoogleFonts.roboto(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              : SizedBox()
        ]),
      ),
    );
  }
}

bool isSingleDigit(int number) {
  return number <= 9 && number >= 0;
}
