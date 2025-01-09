// lib/services/database/face_database_service.dart

import 'package:flutterface/services/database/repositories/attendance_repository.dart';
import 'package:flutterface/services/database/repositories/box_repository.dart';
import 'package:flutterface/services/database/repositories/face_repository.dart';

class FaceDatabaseService {
  static final FaceDatabaseService instance = FaceDatabaseService._init();

  late final BoxRepository boxes;
  late final FaceRepository faces;
  late final AttendanceRepository attendance;

  FaceDatabaseService._init() {
    boxes = BoxRepository();
    faces = FaceRepository();
    attendance = AttendanceRepository();
  }
}