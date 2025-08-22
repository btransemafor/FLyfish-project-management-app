import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppbarMember extends StatefulWidget implements PreferredSizeWidget {
  final double heightAppBar;
  final TabController tabController;
  final VoidCallback? onAddMember;

  const CustomAppbarMember(
      {super.key,
      this.heightAppBar = 110,
      required this.tabController,
      this.onAddMember});

  @override
  State<CustomAppbarMember> createState() => _CustomAppbarMemberState();

  @override
  Size get preferredSize => Size.fromHeight(heightAppBar);
}

class _CustomAppbarMemberState extends State<CustomAppbarMember> {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(widget.heightAppBar),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade300),
                            child: const Icon(
                              Icons.arrow_back_ios_new_outlined,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 20,
                        ),

                        Text('Thành Viên',
                            style: GoogleFonts.afacad(
                                fontWeight: FontWeight.w700, fontSize: 22)),
                        // Button
                      ],
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            elevation: 0,
                            backgroundColor: Colors.white),
                        onPressed: widget.onAddMember,
                        child: Text(
                          'Thêm',
                          style: GoogleFonts.afacad(
                              fontSize: 18, color: Colors.blue),
                        ))
                  ],
                ),
              ),
              Expanded(
                child: CustomTabBar(tabController: widget.tabController),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTabBar extends StatelessWidget {
  final TabController tabController;

  const CustomTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 1, left: 10, right: 10, bottom: 5),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        //color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: TabBar(
          controller: tabController,
          isScrollable: false,
          tabs: const [
            Tab(text: "Tất cả"),
            Tab(text: "Nhóm trưởng"),
          ],
          unselectedLabelColor: Colors.black,
          labelColor: Colors.blue,
          labelStyle: GoogleFonts.afacad(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          unselectedLabelStyle: GoogleFonts.afacad(
              fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black),
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(2),
          labelPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          tabAlignment: TabAlignment.fill,
        ),
      ),
    );
  }
}
