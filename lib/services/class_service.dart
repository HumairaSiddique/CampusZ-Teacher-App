import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/class_model.dart';
import '../models/subject_model.dart';

/// Handles everything related to Classes (sections) and the Subjects
/// inside them: creating a Class, generating its join code, adding a
/// Subject to an existing Class, and reading back what the current
/// teacher teaches.
///
/// Firestore layout:
///   classes/{classId}
///     name, department, section, joinCode, createdBy, studentIds, createdAt
///     subjects/{subjectId}
///       name, teacherId, teacherName, createdAt
class ClassService {
  ClassService._();
  static final ClassService instance = ClassService._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _classes =>
      _db.collection('classes');

  String get _currentTeacherId => FirebaseAuth.instance.currentUser?.uid ?? '';

  String get _currentTeacherName =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'Teacher';

  // ---------- Join code ----------

  /// 6-character code, uppercase letters + digits only, skipping
  /// look-alike characters (0/O, 1/I/L) so students can type it without
  /// confusion.
  String _generateCode() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<String> _generateUniqueJoinCode() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _generateCode();
      final existing =
      await _classes.where('joinCode', isEqualTo: code).limit(1).get();
      if (existing.docs.isEmpty) return code;
    }
    throw Exception('Could not generate a unique join code, please retry.');
  }

  // ---------- Finding an existing Class ----------

  /// Looks for a Class with this exact name (e.g. "BSCS - 4th Semester")
  /// so a teacher can add a Subject to it instead of creating a
  /// duplicate section by mistake.
  Future<ClassModel?> findClassByName(String name) async {
    final snap = await _classes
        .where('name', isEqualTo: name.trim())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return ClassModel.fromDoc(snap.docs.first);
  }

  // ---------- Creating a Class ----------

  /// Creates a brand-new Class (section) with a freshly generated join
  /// code, then immediately adds [firstSubjectName] as its first
  /// Subject taught by the current teacher. Returns the new classId.
  Future<String> createClassWithSubject({
    required String className,
    required String department,
    required String section,
    required String firstSubjectName,
  }) async {
    if (_currentTeacherId.isEmpty) {
      throw Exception('You must be signed in to create a class.');
    }

    final joinCode = await _generateUniqueJoinCode();

    final classDoc = await _classes.add(
      ClassModel(
        id: '',
        name: className.trim(),
        department: department.trim(),
        section: section.trim(),
        joinCode: joinCode,
        createdBy: _currentTeacherId,
      ).toMap(),
    );

    await classDoc.collection('subjects').add(
      SubjectModel(
        id: '',
        classId: classDoc.id,
        name: firstSubjectName.trim(),
        teacherId: _currentTeacherId,
        teacherName: _currentTeacherName,
      ).toMap(),
    );

    return classDoc.id;
  }

  // ---------- Adding a Subject to an existing Class ----------

  Future<void> addSubjectToClass({
    required String classId,
    required String subjectName,
  }) async {
    if (_currentTeacherId.isEmpty) {
      throw Exception('You must be signed in to add a subject.');
    }
    await _classes.doc(classId).collection('subjects').add(
      SubjectModel(
        id: '',
        classId: classId,
        name: subjectName.trim(),
        teacherId: _currentTeacherId,
        teacherName: _currentTeacherName,
      ).toMap(),
    );
  }

  // ---------- Reading data ----------

  /// All Subjects the current teacher teaches, across every Class.
  Stream<List<SubjectModel>> myTaughtSubjects() {
    if (_currentTeacherId.isEmpty) return const Stream.empty();
    return _db
        .collectionGroup('subjects')
        .where('teacherId', isEqualTo: _currentTeacherId)
        .snapshots()
        .map((snap) => snap.docs.map(SubjectModel.fromDoc).toList());
  }

  Future<ClassModel?> getClass(String classId) async {
    final doc = await _classes.doc(classId).get();
    if (!doc.exists) return null;
    return ClassModel.fromDoc(doc);
  }

  /// Every Subject inside one Class, newest first.
  Stream<List<SubjectModel>> subjectsForClass(String classId) {
    return _classes
        .doc(classId)
        .collection('subjects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(SubjectModel.fromDoc).toList());
  }

  /// The distinct Classes the current teacher teaches in (derived from
  /// [myTaughtSubjects], since a teacher may teach more than one subject
  /// in the same Class).
  Stream<List<ClassModel>> myClasses() {
    return myTaughtSubjects().asyncMap((subjects) async {
      final classIds = subjects.map((s) => s.classId).toSet();
      final classes = await Future.wait(classIds.map(getClass));
      return classes.whereType<ClassModel>().toList();
    });
  }
}