import 'package:flutter/material.dart';

class StatusTaskCard extends StatelessWidget {
  final String status;
  final bool isCurrent;
  final void Function(bool?)? onChanged;

  const StatusTaskCard({
    super.key,
    required this.status,
    required this.isCurrent,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(16),
        color: isCurrent ? Colors.blue.shade50 : Colors.grey.shade100,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (onChanged != null && !isCurrent) {
              // Chỉ gọi onChanged khi chưa được selected
              // Truyền true để select option này
              onChanged!(true);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isCurrent ? Colors.blueAccent : Colors.black87,
                    ),
                  ),
                ),
                Radio<bool>(
                  value: true,
                  groupValue: isCurrent ? true : false,
                  onChanged: (value) {
                    if (onChanged != null && value == true && !isCurrent) {
                      onChanged!(true);
                    }
                  },
                  activeColor: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
