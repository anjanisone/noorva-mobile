import 'package:flutter/material.dart';

import '../../data/guide_plan_models.dart';
import '../../../goals/presentation/widgets/goal_ui.dart';

class GuidePlanCard extends StatelessWidget {
  const GuidePlanCard({
    super.key,
    required this.plan,
    this.leadIn,
  });

  final GuidePlanDocument plan;
  final String? leadIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadIn != null && leadIn!.trim().isNotEmpty) ...[
          Text(
            leadIn!.trim(),
            style: const TextStyle(
              color: Color(0xFFE5E5E7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          plan.title,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        if (plan.researchSummary != null && plan.researchSummary!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GoalUi.inset,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3A3B40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Research',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  plan.researchSummary!.trim(),
                  style: const TextStyle(
                    color: GoalUi.textBody,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (plan.intro != null && plan.intro!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            plan.intro!.trim(),
            style: const TextStyle(
              color: Color(0xFFE5E5E7),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
        ...plan.phases.map(_phaseBlock),
      ],
    );
  }

  Widget _phaseBlock(GuidePlanPhase phase) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phase.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          ...phase.tasks.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Icon(Icons.circle, color: Colors.white38, size: 5),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: const TextStyle(
                              color: Color(0xFFE5E5E7),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          if (t.description != null &&
                              t.description!.trim().isNotEmpty &&
                              t.description != t.title) ...[
                            const SizedBox(height: 2),
                            Text(
                              t.description!.trim(),
                              style: const TextStyle(
                                color: GoalUi.textBody,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                          if (t.minutes != null && t.minutes! > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '~${t.minutes} min',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
