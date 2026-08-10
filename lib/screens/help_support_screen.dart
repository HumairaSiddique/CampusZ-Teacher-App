import 'package:flutter/material.dart';
import 'app_colors.dart';

class _Faq {
  const _Faq({required this.question, required this.answer});
  final String question;
  final String answer;
}

/// Help & Support Screen — expandable FAQ list + contact-support card +
/// app version info. Matches the CampusZ purple theme.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  static const List<_Faq> _faqs = [
    _Faq(
      question: 'How do I take attendance for a class?',
      answer: 'Go to Dashboard or Classes > Attendance, pick your class, mark each student Present/Absent/Leave, then tap Submit Attendance.',
    ),
    _Faq(
      question: 'How can students see their grades?',
      answer: 'Once you save grades in Grade Management, students can view their marks from their own CampusZ Student app.',
    ),
    _Faq(
      question: 'Can I edit an assignment after publishing it?',
      answer: 'Yes — open the assignment from the Assignments screen and update the due date or description before students submit.',
    ),
    _Faq(
      question: 'How do I switch between dark and light mode?',
      answer: 'Go to Profile > Settings & Theme and choose Light, Dark, or System default.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildContactCard(context),
            const SizedBox(height: 20),
            Text('Frequently Asked Questions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text(context))),
            const SizedBox(height: 12),
            ..._faqs.map((faq) => _buildFaqTile(faq, context)),
            const SizedBox(height: 20),
            Center(
              child: Text('CampusZ Teacher App · v1.0.0', style: TextStyle(fontSize: 11, color: AppColors.text(context).withOpacity(0.35))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text(context), size: 18),
        ),
        Expanded(
          child: Text('Help & Support', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text(context))),
        ),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [gradientStart, gradientEnd]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Need more help?', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('support@campusz.edu', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11.5)),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Open email/contact support here')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: const Text('Contact', style: TextStyle(color: primaryIndigo, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(_Faq faq, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 8)],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Text(faq.question, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text(context))),
          iconColor: primaryIndigo,
          collapsedIconColor: AppColors.text(context).withOpacity(0.4),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(faq.answer, style: TextStyle(fontSize: 12, color: AppColors.text(context).withOpacity(0.6), height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}