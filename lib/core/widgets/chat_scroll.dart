import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Keeps the chat pinned to the latest message without [ScrollPosition.animateTo]
/// fighting layout updates (typing dots, plan progress, new bubbles).
void pinChatScrollToBottom(ScrollController controller) {
  void jump() {
    if (!controller.hasClients) return;
    final position = controller.position;
    final target = position.maxScrollExtent;
    if ((position.pixels - target).abs() > 0.5) {
      controller.jumpTo(target);
    }
  }

  SchedulerBinding.instance.addPostFrameCallback((_) {
    jump();
    SchedulerBinding.instance.addPostFrameCallback((_) => jump());
  });
}
