import 'package:cloud_firestore/cloud_firestore.dart';

/// A single subject inside a Class (e.g. "Data Structures" inside
/// "BSCS - 4th Semester"). Each subject has its own teacher, so two
/// different teachers can teach two different subjects under the same
/// Class without stepping on each other.
///
/// Firestore path: classes/{classId}/subjects/{subjectId}
class SubjectModel {
  final String id;
  final String classId;
  final String name;
  final String teacherId;
  final String teacherName;
  final DateTime? createdAt;

  const SubjectModel({
    required this.id,
    required this.classId,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    this.createdAt,
  });

  factory SubjectModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SubjectModel(
      id: doc.id,
      classId: doc.reference.parent.parent?.id ?? '',
      name: (data['name'] as String?) ?? '',
      teacherId: (data['teacherId'] as String?) ?? '',
      teacherName: (data['teacherName'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}