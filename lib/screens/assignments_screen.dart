import 'package:flutter/material.dart';
import 'app_colors.dart';

class _Assignment {
  const _Assignment({
    required this.title,
    required this.className,
    required this.dueDate,
    required this.submitted,
    required this.total,
    required this.color,
  });
  final String title;
  final String className;
  final String dueDate;
  final int submitted;
  final int total;
  final Color color;
}

/// Assignments Screen — list of assignments with submission progress, plus
/// a "New Assignment" bottom-sheet form. Matches the CampusZ purple theme.
///
/// NOTE: Pure UI with placeholder/sample data. Wire `_createAssignment()`
/// to save an AssignmentModel to Firestore once the backend is ready.
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  final List<_Assignment> _assignments = const [
    _Assignment(title: 'Binary Tree Implementation', className: 'Data Structures', dueDate: 'Due Aug 2', submitted: 32, total: 45, color: Color(0xFF4F7DF3)),
    _Assignment(title: 'ER Diagram Design', className: 'Database Systems', dueDate: 'Due Aug 5', submitted: 18, total: 38, color: Color(0xFF3CBF7F)),
    _Assignment(title: 'Sorting Algorithms Report', className: 'Algorithms', dueDate: 'Due Jul 30', submitted: 41, total: 41, color: Color(0xFF8B5CF6)),
    _Assignment(title: 'Process Scheduling Simulation', className: 'Operating Systems', dueDate: 'Due Aug 8', submitted: 5, total: 39, color: Color(0xFFF59E0B)),
  ];

  final List<String> _classes = const ['Data Structures', 'Database Systems', 'Algorithms', 'Operating Systems'];

  void _openNewAssignmentSheet() {
    final titleController = TextEditingController();
    int selectedClass = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: AppColors.text(context).withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    Text('New Assignment', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.text(context))),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Assignment title',
                        filled: true,
                        fillColor: AppColors.bg(context),
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: AppColors.bg(context), borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedClass,
                          items: List.generate(
                            _classes.length,
                                (i) => DropdownMenuItem(value: i, child: Text(_classes[i])),
                          ),
                          onChanged: (val) => setSheetState(() => selectedClass = val ?? 0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;
                          // TODO: save assignment to Firestore here.
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('"${titleController.text}" created for ${_classes[selectedClass]}')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryIndigo,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewAssignmentSheet,
        backgroundColor: primaryIndigo,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Assignment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                itemCount: _assignments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildAssignmentCard(_assignments[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text(context), size: 18),
          ),
          Expanded(
            child: Text('Assignments',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text(context))),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(_Assignment item) {
    final progress = item.total == 0 ? 0.0 : item.submitted / item.total;
    final isComplete = item.submitted == item.total;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open "${item.title}" submissions here')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: item.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.edit_note_rounded, color: item.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.text(context))),
                      const SizedBox(height: 2),
                      Text(item.className, style: TextStyle(fontSize: 11, color: AppColors.text(context).withOpacity(0.5))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isComplete ? const Color(0xFF3CBF7F) : const Color(0xFFF59E0B)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.dueDate,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isComplete ? const Color(0xFF3CBF7F) : const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.text(context).withOpacity(0.06),
                      valueColor: AlwaysStoppedAnimation(item.color),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${item.submitted}/${item.total}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text(context).withOpacity(0.6)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}