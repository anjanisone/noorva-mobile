class GuidePlanTask {
  const GuidePlanTask({required this.title, this.description, this.minutes});
  final String title;
  final String? description;
  final int? minutes;
}

class GuidePlanPhase {
  const GuidePlanPhase({required this.name, required this.tasks});
  final String name;
  final List<GuidePlanTask> tasks;
}

class GuidePlanDocument {
  const GuidePlanDocument({
    required this.title,
    this.intro,
    this.researchSummary,
    this.phases = const [],
  });
  final String title;
  final String? intro;
  final String? researchSummary;
  final List<GuidePlanPhase> phases;
}
