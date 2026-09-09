import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/goal_model.dart';
import 'goals_event.dart';
import 'goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  GoalsBloc() : super(GoalsState(goals: _seedGoals())) {
    on<GoalTaskCompleted>(_onTaskCompleted);
    on<GoalDeleted>(_onGoalDeleted);
  }

  void _onTaskCompleted(GoalTaskCompleted event, Emitter<GoalsState> emit) {
    final goals = List<Goal>.from(state.goals);
    final goalIndex = goals.indexWhere((g) => g.id == event.goalId);
    if (goalIndex == -1) return;

    final goal = goals[goalIndex];
    final taskIndex = goal.tasks.indexWhere((t) => t.id == event.taskId);
    if (taskIndex == -1) return;

    goal.tasks[taskIndex].isCompleted = true;

    final allDone = goal.tasks.every((t) => t.isCompleted);
    goals[goalIndex] = allDone
        ? goal.copyWith(isCompleted: true, bottomText: 'Goal ended today')
        : goal.copyWith(bottomText: 'Current Progress');

    emit(state.copyWith(goals: goals));
  }

  void _onGoalDeleted(GoalDeleted event, Emitter<GoalsState> emit) {
    final goals = state.goals.where((g) => g.id != event.goalId).toList();
    emit(state.copyWith(goals: goals));
  }

  static List<Goal> _seedGoals() => [
        Goal(
          id: 'inner-peace',
          title: 'Cultivate inner peace',
          description: 'A 21-day morning practice focusing on breath and presence to anchor the day.',
          priority: 'High Priority',
          bottomText: 'Goal starts from tomorrow',
          startedOnText: 'Goal starts from tomorrow',
          planTitle: '21 Days to Inner Peace',
          planSize: '1.5MB',
          tasks: [
            GoalTask(
              id: 1,
              title: 'Day 1',
              subtitle: '23 Apr 2026, 7AM',
              content: 'The sudden contrast between a busy life and absolute stillness can feel uncomfortable at first. Today is not about achieving perfect silence; it is simply about practicing the art of the pause\n\n'
                  'Step 1: The physical setup You do not need a perfect meditation cushion. Sit on the edge of your bed or in a supportive chair. Plant both feet flat on the floor to feel grounded. Let your hands rest naturally in your lap.\n\n'
                  'Step 2: The expectation The moment you close your eyes, your brain will likely remind you of three urgent things you need to do today. This is not a failure; it is just your mind emptying its inbox.\n\n'
                  'Step 3: The mental shift Do not fight the thoughts. Today is simply about noticing the urge to move, and choosing to sit still for just 5 minutes anyway. Let your shoulders drop and simply breathe.',
            ),
            GoalTask(
              id: 2,
              title: 'Day 2',
              subtitle: '24 Apr 2026, 7AM',
              content: 'Focusing on the breath. Today, we bring awareness to the natural rhythm of our inhalations and exhalations without trying to alter them.\n\n'
                  'Step 1: Find your seat. Sit upright and comfortable. Let your eyes gently close or find a soft gaze on the floor in front of you.\n\n'
                  'Step 2: Follow the breath. Notice where you feel the breath most prominently—the nostrils, the chest, or the abdomen. Stay with that sensation for 5 full cycles.',
            ),
            GoalTask(
              id: 3,
              title: 'Day 3',
              subtitle: '25 Apr 2026, 7AM',
              content: 'Scanning the body. A practice to connect mind and body by systematically scanning for tension and releasing it.\n\n'
                  'Step 1: Start at the crown. Begin by bringing awareness to the top of your head, slowly moving down through your face, jaw, and neck.\n\n'
                  'Step 2: Soften and release. As you notice areas of tightness, inhale space into them, and exhale to let the tension melt away.',
            ),
            GoalTask(
              id: 4,
              title: 'Day 4',
              subtitle: '26 Apr 2026, 7AM',
              content: 'Loving-kindness. Cultivating compassion for yourself and others through silent wishes of peace and well-being.\n\n'
                  'Step 1: Self-compassion. Repeat silently: \'May I be happy. May I be healthy. May I be safe. May I live with ease.\'\n\n'
                  'Step 2: Expand outward. Think of a loved one and repeat the wishes for them: \'May you be happy...\'',
            ),
            GoalTask(
              id: 5,
              title: 'Day 5',
              subtitle: '27 Apr 2026, 7AM',
              content: 'Sounds and space. Expanding awareness to the environment, learning to let sounds come and go without judgement.\n\n'
                  'Step 1: Listen actively. Close your eyes and tune into the furthest sound you can hear. Do not label it, just feel the vibration.\n\n'
                  'Step 2: Rest in silence. Bring your attention back to the silence underneath all sounds.',
            ),
            GoalTask(
              id: 6,
              title: 'Day 6',
              subtitle: '28 Apr 2026, 7AM',
              content: 'Gratitude reflection. Anchoring the day in appreciation for small, simple gifts of life.\n\n'
                  'Step 1: Recall three things. Think of three small things from yesterday that brought you a smile or a sense of warmth.\n\n'
                  'Step 2: Savor the feeling. Let the feeling of appreciation fill your chest as you take three slow, deep breaths.',
            ),
          ],
        ),
        Goal(
          id: 'fundamentals-code',
          title: 'Master the fundamentals of code',
          description: 'A 12-week focused sprint to learn front-end web development and build three interactive projects',
          priority: 'Medium Priority',
          bottomText: 'Week 3: Introduction to JavaScript',
          startedOnText: 'Goal started on 01 May 2026',
          planTitle: '12 Weeks of mastering code',
          planSize: '2MB',
          tasks: List.generate(12, (index) {
            const weekDates = [
              '01 May 2026', '08 May 2026', '15 May 2026', '22 May 2026',
              '29 May 2026', '05 Jun 2026', '12 Jun 2026', '19 Jun 2026',
              '26 Jun 2026', '03 Jul 2026', '10 Jul 2026', '17 Jul 2026',
            ];
            const weekContents = [
              'Introduction to web development. Understanding how the internet works, browsers, and the role of HTML, CSS, and JavaScript.\n\nStep 1: Watch the intro video series.\n\nStep 2: Set up your development environment (VS Code, browser DevTools).',
              'Structuring the web with HTML and CSS. Learn semantic HTML elements and how to apply foundational CSS styling.\n\nStep 1: Build a static webpage using headings, paragraphs, lists, and links.\n\nStep 2: Style it with colours, fonts, and the box model.',
              'Introduction to JavaScript. Variables, data types, functions, and control flow.\n\nStep 1: Complete the JS fundamentals module.\n\nStep 2: Write a small script that interacts with the browser console.',
              'DOM Manipulation. Selecting elements, changing content, responding to events.\n\nStep 1: Build a to-do list app with add and delete functionality.\n\nStep 2: Style the app using CSS transitions.',
              'Responsive design. Flexbox, CSS Grid, and media queries.\n\nStep 1: Refactor your to-do app to be fully responsive.\n\nStep 2: Test across different screen sizes.',
              'Asynchronous JavaScript. Promises, async/await, and the Fetch API.\n\nStep 1: Fetch data from a public API and display it on a page.\n\nStep 2: Handle loading and error states gracefully.',
              'Introduction to React. Components, props, and state.\n\nStep 1: Set up a React project using Vite.\n\nStep 2: Build a simple component library (button, card, input).',
              'React hooks and state management. useState, useEffect, and context.\n\nStep 1: Convert the to-do app to React with hooks.\n\nStep 2: Add persistence with localStorage.',
              'APIs and backend basics. Working with REST APIs and understanding HTTP.\n\nStep 1: Connect your React app to a real REST API.\n\nStep 2: Build a weather dashboard using a free weather API.',
              'Version control and collaboration. Git, GitHub, branches, and pull requests.\n\nStep 1: Initialise a Git repo and push your project to GitHub.\n\nStep 2: Create a feature branch and open a pull request.',
              'Project 1 — Portfolio site. Design and build a personal portfolio using everything learned so far.\n\nStep 1: Plan the layout and content.\n\nStep 2: Build, polish, and deploy to GitHub Pages.',
              'Project 2 — Interactive app. Build a fully functional interactive web app of your choice.\n\nStep 1: Define scope and wireframe.\n\nStep 2: Build, test, and present your project.',
            ];
            return GoalTask(
              id: index + 1,
              title: 'Week ${index + 1}',
              subtitle: '${weekDates[index]}, 9AM',
              content: weekContents[index],
              isCompleted: index < 2,
            );
          }),
        ),
        // Pre-completed goals
        Goal(
          id: 'financial-resilience',
          title: 'Build a resilient financial foundation',
          description: 'A 6-month plan to audit expenses, eliminate high-interest debt, and fully fund a 3-month emergency reserve',
          priority: 'High Priority',
          bottomText: 'Goal ended on 12 Apr 2026',
          startedOnText: 'Goal ended on 12 Apr 2026',
          planTitle: 'Building financial foundation.pdf',
          planSize: '2MB',
          isCompleted: true,
          tasks: [
            GoalTask(
              id: 1,
              title: 'Audit Expenses',
              subtitle: '12 Oct 2025, 9AM',
              content: 'Review all bank statements and credit card bills from the last three months. Categorize spending into essential and non-essential buckets to identify potential savings.\n\nStep 1: Download past bank statements.\n\nStep 2: List recurring expenses.',
              isCompleted: true,
            ),
            GoalTask(
              id: 2,
              title: 'Create Budget Plan',
              subtitle: '12 Nov 2025, 9AM',
              content: 'Establish monthly spending limits based on the expense audit. Allocate funds for savings and debt repayment first.\n\nStep 1: Set spending limits per category.\n\nStep 2: Automate primary bills.',
              isCompleted: true,
            ),
            GoalTask(
              id: 3,
              title: 'Debt Payoff Strategy',
              subtitle: '12 Dec 2025, 9AM',
              content: 'List all outstanding debts. Prioritize paying off high-interest cards using the debt avalanche method.\n\nStep 1: Map all high-interest liabilities.\n\nStep 2: Pay off first targets.',
              isCompleted: true,
            ),
            GoalTask(
              id: 4,
              title: 'Setup Emergency Fund',
              subtitle: '12 Jan 2026, 9AM',
              content: 'Open a high-yield savings account dedicated solely to emergency reserves. Automate monthly transfers.\n\nStep 1: Choose high-yield savings provider.\n\nStep 2: Set monthly automated transfers.',
              isCompleted: true,
            ),
            GoalTask(
              id: 5,
              title: 'Grow Reserves',
              subtitle: '12 Feb 2026, 9AM',
              content: 'Maintain discipline and direct all bonus income or windfalls towards your high-yield savings.\n\nStep 1: Cut down luxury subscriptions.\n\nStep 2: Redirect savings automatically.',
              isCompleted: true,
            ),
            GoalTask(
              id: 6,
              title: 'Resilient Foundation',
              subtitle: '12 Mar 2026, 9AM',
              content: 'Audit the final reserve balance to verify a full three months of basic living expenses has been safely accrued.\n\nStep 1: Review bank accounts.\n\nStep 2: Lock the reserves.',
              isCompleted: true,
            ),
          ],
        ),
        Goal(
          id: 'reading-habit',
          title: 'Cultivate a deep reading habit',
          description: 'Transition away from short-form digital scrolling by committing to 20 pages of focused reading every evening',
          priority: 'Medium Priority',
          bottomText: 'Goal ended on 30 Mar 2026',
          startedOnText: 'Goal ended on 30 Mar 2026',
          planTitle: 'Deep reading handbook.pdf',
          planSize: '1.8MB',
          isCompleted: true,
          tasks: [
            GoalTask(
              id: 1,
              title: 'Select Material',
              subtitle: '01 Mar 2026, 9AM',
              content: 'Select a book that genuinely interests you, rather than something you feel you "should" read.\n\nStep 1: List three target genres.\n\nStep 2: Buy the paperback edition.',
              isCompleted: true,
            ),
            GoalTask(
              id: 2,
              title: 'Establish Routine',
              subtitle: '08 Mar 2026, 9AM',
              content: 'Block out 30 minutes every evening, free of digital distractions, to focus solely on reading.\n\nStep 1: Leave phone in another room.\n\nStep 2: Set reading alarm.',
              isCompleted: true,
            ),
            GoalTask(
              id: 3,
              title: 'Maintain Momentum',
              subtitle: '15 Mar 2026, 9AM',
              content: 'Aim for a consistent 20 pages per day. Keep a log of your daily progress.\n\nStep 1: Track pages read in a notebook.\n\nStep 2: Do not skip consecutive days.',
              isCompleted: true,
            ),
            GoalTask(
              id: 4,
              title: 'Perfect Space',
              subtitle: '22 Mar 2026, 9AM',
              content: 'Set up a comfortable, well-lit space dedicated solely to reading.\n\nStep 1: Set comfortable seating.\n\nStep 2: Get a reading light.',
              isCompleted: true,
            ),
            GoalTask(
              id: 5,
              title: 'Reflect and Review',
              subtitle: '29 Mar 2026, 9AM',
              content: 'Write a brief summary or reflection after finishing each chapter to deepen comprehension.\n\nStep 1: Write reflections in margins or journal.\n\nStep 2: Discuss insights with friends.',
              isCompleted: true,
            ),
          ],
        ),
      ];
}
