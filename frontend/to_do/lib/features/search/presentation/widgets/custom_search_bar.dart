/* import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  const CustomSearchBar(
      {super.key,
      required this.controller,
      this.onChanged,
      this.hintText = 'Tìm kiếm dự án ...'});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  void initState() {
    super.initState();
    print("✅ initState chạy");
  }

  @override
  void didUpdateWidget(covariant CustomSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("🔄 didUpdateWidget chạy (widget thay đổi)");
  }

  @override
  void dispose() {
    print("🗑 dispose chạy (widget bị huỷ)");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("🎨 build() chạy (UI được dựng lại)");
    return Form(
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: TextFormField(
              onChanged: (val) {
                setState(() {}); // rebuild mỗi khi gõ
                if (widget.onChanged != null) widget.onChanged!(val);
              },
              cursorWidth: 2,
              cursorRadius: Radius.circular(20),
              cursorColor: Colors.blue.shade700,
              style: GoogleFonts.roboto(fontSize: 15),
              controller: widget.controller,
              // style
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(width: 1, color: Colors.blueGrey)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                hintText: widget.hintText,
                hintStyle: GoogleFonts.roboto(fontSize: 15),
                suffixIcon: widget.controller.text.isEmpty
                    ? SizedBox.shrink()
                    : GestureDetector(
                        onTap: () {
                          widget.controller.clear();
                          setState(() {}); // rebuild lại 
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 13,
                                color: Colors.white,
                              )),
                        ),
                      ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.search_outlined),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 30,
                  minHeight: 30,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextButton(
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(
                      Colors.transparent), // tắt splash + hover
                  foregroundColor:
                      WidgetStateProperty.all(Colors.blue.shade600), // màu chữ
                  backgroundColor:
                      WidgetStateProperty.all(Colors.transparent), // nền
                  shadowColor: WidgetStateProperty.all(
                      Colors.transparent), // tắt shadow nếu có
                  surfaceTintColor: WidgetStateProperty.all(
                      Colors.transparent), // tắt hiệu ứng surface
                ),
                autofocus: false,
                isSemanticButton: false,
                onPressed: () {},
                child: Text(
                  'Tìm kiếm',
                  style: GoogleFonts.roboto(color: Colors.blue.shade600),
                )),
          )
        ],
      ),
    );
  }
}

 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final Function()? onSearch;
  final VoidCallback? onClear;

  const CustomSearchBar(
      {super.key,
      required this.controller,
      this.onChanged,
      this.onSearch,
      this.hintText = 'Tìm kiếm dự án ...',
      this.onClear});

  @override
  Widget build(BuildContext context) {
    print("build() chạy 1 lần cho SearchBar");

    return Row(
      children: [
        Expanded(
          flex: 7,
          child: TextFormField(
            onChanged: (val) {
              // chỉ gọi callback, không cần setState nữa
              if (onChanged != null) onChanged!(val);
            },
            controller: controller,
            cursorWidth: 2,
            cursorRadius: const Radius.circular(20),
            cursorColor: Colors.blue.shade700,
            style: GoogleFonts.roboto(fontSize: 15),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(width: 1, color: Colors.blueGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              hintText: hintText,
              hintStyle: GoogleFonts.roboto(fontSize: 15),

              // chỉ rebuild icon khi text thay đổi
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () {
                      controller.clear();
                      if (onClear != null) {
                        onClear!();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 13, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),

              prefixIcon: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.search_outlined),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextButton(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              foregroundColor:
                  WidgetStateProperty.all(Colors.blue.shade600), // màu chữ
              backgroundColor:
                  WidgetStateProperty.all(Colors.transparent), // nền
              shadowColor: WidgetStateProperty.all(Colors.transparent),
              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
            ),
            onPressed: onSearch, 
            child: Text(
              'Tìm kiếm',
              style: GoogleFonts.roboto(color: Colors.blue.shade600),
            ),
          ),
        ),
      ],
    );
  }
}
