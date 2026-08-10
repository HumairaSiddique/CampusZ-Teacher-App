import 'package:cloud_firestore/cloud_firestore.dart';

/// A Class = a section/department group (e.g. "BSCS - 4th Semester").
/// It has exactly ONE join code. Students join once with this code and
/// get access to every Subject inside it, even if those subjects are
/// taught by different teachers.
///
/// Firestore path: classes/{classId}
/// Subjects live in the subcollection: classes/{classId}/subjects/{subjectId}
class ClassModel {
  final String id;
  final String name; // e.g. "BSCS - 4th Semester"
  final String department; // e.g. "BSCS"
  final String section; // e.g. "4th Semester" / "Section A"
  final String joinCode;
  final String createdBy; // teacherId who created the Class
  final List<String> studentIds;
  final DateTime? createdAt;

  const ClassModel({
    required this.id,
    required this.name,
    required this.department,
    required this.section,
    required this.joinCode,
    required this.createdBy,
    this.studentIds = const [],
    this.createdAt,
  });

  factory ClassModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ClassModel(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      department: (data['department'] as String?) ?? '',
      section: (data['section'] as String?) ?? '',
      joinCode: (data['joinCode'] as String?) ?? '',
      createdBy: (data['createdBy'] as String?) ?? '',
      studentIds: List<String>.from(data['studentIds'] as List? ?? const []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'department': department,
      'section': section,
      'joinCode': joinCode,
      'createdBy': createdBy,
      'studentIds': studentIds,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}