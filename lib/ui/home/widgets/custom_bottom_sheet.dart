
import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/widgets/attendance_tab.dart';
import 'package:flutterface/ui/home/widgets/tabs/attendance_tab.dart';
import 'package:flutterface/ui/home/widgets/tabs/register_tab.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.person_add_outlined),
                        text: 'Register',
                      ),
                      Tab(
                        icon: Icon(Icons.fact_check_outlined),
                        text: 'Check Attendance',
                      ),
                    ],
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        RegisterTab(),
                        AttendanceTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 4,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}