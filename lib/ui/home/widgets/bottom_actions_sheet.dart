import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/widgets/attendance_tab.dart';
import 'package:flutterface/ui/home/widgets/drag_handle.dart';
import 'package:flutterface/ui/home/widgets/registration_tab.dart';


class BottomActionsSheet extends StatelessWidget {
  const BottomActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 0.8,
      builder: (context, controller) => Container(
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
             const DragHandle(),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    _buildTabBar(context),
                    const Expanded(
                      child: TabBarView(
                        children: [
                          RegistrationTab(),
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
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: theme.colorScheme.primary,
        ),
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onSurface,
        tabs: const [
          Tab(text: 'Register'),
          Tab(text: 'Attendance'),
        ],
      ),
    );
  }
}