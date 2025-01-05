import 'package:flutter/material.dart';
import 'package:flutterface/ui/home/widgets/face_detection_view.dart';
import 'package:flutterface/ui/home/widgets/image_controls.dart';
import 'package:flutterface/ui/home/widgets/tabs/attendance_tab.dart';
import 'package:flutterface/ui/home/widgets/tabs/registration_tab.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FaceDetectionView(),
              SizedBox(height: 16.0),
              ImageControls(),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child:  DraggableScrollableSheet(
            initialChildSize: 0.2,
            minChildSize: 0.1,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration:  BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DefaultTabController(
                        length: 2,
                        child:
                          // Tab selector
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    _buildTabButton(context, 'Register', true),
                                    _buildTabButton(context, 'Attendance', false),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.3,
                                child: const TabBarView(
                                  children: [
                                    RegistrationTabContent(),
                                    AttendanceTabContent(),
                                  ],
                                ),
                              ),
                            ],
                          ),

                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

      ],
    );
  }

  Widget _buildTabButton(BuildContext context, String text, bool isSelected) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: MaterialButton(
          onPressed: () {
            // Handle tab selection
          },
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade200,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
