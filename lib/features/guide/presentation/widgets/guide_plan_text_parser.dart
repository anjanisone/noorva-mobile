import '../../data/guide_plan_models.dart';

/// Heuristic parser for assistant replies that embed day-by-day or sectioned plans.
class GuidePlanTextParser {
  static GuidePlanDocument? tryParse(String raw) {
    var text = _normalize(raw.trim());
    if (text.length < 80) return null;

    final hasPlanCue = RegExp(
      r'(\*\*[^*]{3,}\*\*|#{1,3}\s|Days?\s+\d|Day\s+\d|Phase\s+\d|\d+\.\s+\*\*|Where to learn|step[- ]by[- ]step)',
      caseSensitive: false,
    ).hasMatch(text);
    if (!hasPlanCue) return null;

    final lines = text.split('\n');
    String? title;
    String? intro;
    final phases = <GuidePlanPhase>[];
    String? currentPhaseName;
    final currentTasks = <GuidePlanTask>[];

    void flushPhase() {
      if (currentPhaseName != null && currentPhaseName!.trim().isNotEmpty) {
        phases.add(GuidePlanPhase(
          name: currentPhaseName!.trim(),
          tasks: List.from(currentTasks),
        ));
      }
      currentPhaseName = null;
      currentTasks.clear();
    }

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      final dayColon = RegExp(
        r'^(Days?\s+[\d\s–—\-]+|Day\s+\d+)\s*:\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(line);
      if (dayColon != null) {
        flushPhase();
        _applyDaySection(
          dayColon.group(1)!,
          dayColon.group(2)!,
          (name) => currentPhaseName = name,
          (task) => currentTasks.add(task),
        );
        continue;
      }

      final boldHeader = RegExp(r'^\*\*(.+)\*\*:?$').firstMatch(line);
      final mdHeader = RegExp(r'^#{1,3}\s+(.+)$').firstMatch(line);
      final dayHeader = RegExp(
        r'^(Days?\s+\d[\d\s–—\-]*(?::)?.*|Day\s+\d\b.+)$',
        caseSensitive: false,
      ).hasMatch(line);

      if (boldHeader != null || mdHeader != null || dayHeader) {
        flushPhase();
        final name = boldHeader?.group(1) ?? mdHeader?.group(1) ?? line.replaceAll('**', '');
        if (title == null && !name.toLowerCase().contains('day')) {
          title = name;
        } else {
          currentPhaseName = name.replaceAll(RegExp(r'\*+'), '').trim();
        }
        continue;
      }

      final bullet = RegExp(r'^[-•*]\s+(.+)$').firstMatch(line);
      final numbered = RegExp(r'^\d+\.\s+(.+)$').firstMatch(line);
      final item = bullet?.group(1) ?? numbered?.group(1);
      if (item != null) {
        if (currentPhaseName == null) {
          currentPhaseName = 'Steps';
        }
        currentTasks.add(GuidePlanTask(title: item.trim()));
        continue;
      }

      if (phases.isEmpty && currentPhaseName == null && currentTasks.isEmpty) {
        intro = intro == null ? line : '$intro $line';
      } else if (currentPhaseName != null) {
        currentTasks.add(GuidePlanTask(title: line));
      }
    }
    flushPhase();

    if (phases.isEmpty) return null;
    return GuidePlanDocument(
      title: title ?? 'Your plan',
      intro: intro,
      phases: phases,
    );
  }

  static String _normalize(String raw) {
    var t = raw.replaceAll('\r\n', '\n');
    t = t.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (m) => '\n## ${m.group(1)!.trim()}\n',
    );
    t = t.replaceAllMapped(
      RegExp(
        r'(?<!\n)\s*(?=(Days?\s+\d+[\d\s–—\-]*(?:\s*[–—\-]\s*\d+)?\s*:))',
        caseSensitive: false,
      ),
      (_) => '\n\n',
    );
    t = t.replaceAllMapped(
      RegExp(r'(?<!\n)\s*(?=(Day\s+\d+\s*:))', caseSensitive: false),
      (_) => '\n\n',
    );
    t = t.replaceAllMapped(
      RegExp(
        r'(?<!\n)\s*(?=(Where to learn|Resources|General advice)\s*:)',
        caseSensitive: false,
      ),
      (_) => '\n\n',
    );
    return t.trim();
  }

  static void _applyDaySection(
    String dayLabel,
    String body,
    void Function(String name) setPhaseName,
    void Function(GuidePlanTask task) addTask,
  ) {
    final parts = body.split(RegExp(r'\s+[-–—]\s+'));
    if (parts.length >= 2) {
      setPhaseName('${dayLabel.trim()}: ${parts.first.trim()}');
      for (var i = 1; i < parts.length; i++) {
        _splitTaskPieces(parts[i], addTask);
      }
      return;
    }
    setPhaseName(dayLabel.trim());
    _splitTaskPieces(body, addTask);
  }

  static void _splitTaskPieces(String chunk, void Function(GuidePlanTask task) addTask) {
    final pieces = chunk.split(RegExp(r'(?<=[.!?])\s+|,\s+(?=[A-Za-z])'));
    for (final piece in pieces) {
      final t = piece.trim();
      if (t.length > 2) addTask(GuidePlanTask(title: t));
    }
  }
}
