import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/knowledge_graph/domain/remediation_plan.dart';
import 'features/note/application/tool_workspace_controller.dart';
import 'features/note/domain/problem_attachment.dart';
import 'features/note/presentation/freehand_canvas.dart';
import 'features/prescription/application/daily_prescription_controller.dart';
import 'features/prescription/application/prescription_detail_controller.dart';
import 'features/prescription/domain/daily_prescription.dart';
import 'features/prescription/domain/prescription_task.dart';
import 'features/prescription/domain/weakness.dart';

class MidUpApp extends StatelessWidget {
  const MidUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MidUp Prototype',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  void _onTabSelected(int newIndex) {
    setState(() => _currentIndex = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          CoachTabView(),
          ToolTabView(),
          MyTabPlaceholder(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: '코칭',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: '노트',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
    );
  }
}

class CoachTabView extends ConsumerWidget {
  const CoachTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionAsync = ref.watch(dailyPrescriptionControllerProvider);
    final controller = ref.read(dailyPrescriptionControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 처방'),
        actions: [
          IconButton(
            tooltip: '다시 생성',
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: prescriptionAsync.when(
        data: (plan) => _CoachTabContent(
          plan: plan,
          onToggleTask: controller.toggleTaskStatus,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text('처방을 불러오지 못했어요.\n$error'),
        ),
      ),
    );
  }
}

class _CoachTabContent extends StatelessWidget {
  const _CoachTabContent({
    required this.plan,
    required this.onToggleTask,
  });

  final DailyPrescription plan;
  final void Function(String taskId) onToggleTask;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Header(plan: plan),
        const SizedBox(height: 12),
        Text(
          '오늘의 처방 카드',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (plan.tasks.isEmpty)
          const Text('처방 카드가 아직 없어요.')
        else
          ...plan.tasks.map(
            (task) => _PrescriptionCard(
              task: task,
              onToggleTask: onToggleTask,
            ),
          ),
        const SizedBox(height: 24),
        Text(
          '약점 리포트',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _WeaknessList(weaknesses: plan.weaknesses),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.plan});

  final DailyPrescription plan;

  @override
  Widget build(BuildContext context) {
    final ratio = plan.completionRatio;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 루틴',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: ratio,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .onPrimaryContainer
                  .withValues(alpha: 0.1),
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              '${(ratio * 100).round()}% 완료',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            Text(
              '카드 ${plan.tasks.length}개가 준비됐어요.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({
    required this.task,
    required this.onToggleTask,
  });

  final PrescriptionTask task;
  final void Function(String taskId) onToggleTask;

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == PrescriptionTaskStatus.completed;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _showPlanOverlay(context, task),
        title: Text(task.prompt),
        subtitle: Text('${task.conceptName} • 단계 ${task.depth + 1}'),
        trailing: IconButton(
          onPressed: () => onToggleTask(task.id),
          icon: Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked),
          color: isDone
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }

  void _showPlanOverlay(
    BuildContext context,
    PrescriptionTask task,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProviderScope(
        overrides: [
          prescriptionDetailControllerProvider.overrideWith(
            () => _InlinePlanController(task.remediationPlan),
          ),
        ],
        child: _RemediationBottomSheet(
          task: task,
          onCompleteTask: () => onToggleTask(task.id),
        ),
      ),
    );
  }
}

class _WeaknessList extends StatelessWidget {
  const _WeaknessList({required this.weaknesses});

  final List<Weakness> weaknesses;

  @override
  Widget build(BuildContext context) {
    if (weaknesses.isEmpty) {
      return const Text('현재 등록된 약점이 없어요.');
    }
    return Column(
      children: weaknesses
          .map(
            (weakness) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(weakness.conceptName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: weakness.severity.clamp(0, 1).toDouble(),
                    ),
                    const SizedBox(height: 4),
                    Text('치료율 ${(weakness.severity * 100).round()}%'),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class ToolTabView extends ConsumerStatefulWidget {
  const ToolTabView({super.key});

  @override
  ConsumerState<ToolTabView> createState() => _ToolTabViewState();
}

class _ToolTabViewState extends ConsumerState<ToolTabView> {
  final _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(toolWorkspaceControllerProvider);
    final controller = ref.read(toolWorkspaceControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('노트 & 도구'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              '문제 캡처 업로드',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => controller.addAttachment(AttachmentType.photo),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('카메라 촬영'),
                ),
                OutlinedButton.icon(
                  onPressed: () => controller.addAttachment(AttachmentType.pdf),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF 업로드'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AttachmentList(attachments: workspace.attachments),
            const SizedBox(height: 24),
            Text(
              'AI에게 질문하기',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '예) OCR된 풀이 중 어디에서 실수했는지 알려줘.',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: workspace.isBusy
                      ? null
                      : () {
                          final text = _questionController.text;
                          _questionController.clear();
                          controller.askQuestion(text);
                        },
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (workspace.isBusy) const LinearProgressIndicator(),
            if (workspace.lastAnswer != null)
              Card(
                margin: const EdgeInsets.only(top: 12),
                child: ListTile(
                  title: const Text('AI 응답'),
                  subtitle: Text(workspace.lastAnswer!),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              '필기 연습장',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'perfect_freehand 기반의 벡터 필기 캔버스입니다. 손가락이나 펜으로 자유롭게 적어보세요.',
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: FreehandCanvas(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentList extends StatelessWidget {
  const _AttachmentList({required this.attachments});

  final List<ProblemAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return Text(
        '아직 업로드된 문제가 없어요.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return Column(
      children: attachments
          .map(
            (attachment) => Card(
              child: ListTile(
                leading: Icon(
                  attachment.type == AttachmentType.photo
                      ? Icons.photo
                      : Icons.picture_as_pdf,
                ),
                title: Text(attachment.fileName),
                subtitle: Text(_statusText(attachment)),
                trailing: _buildTrailing(attachment, context),
              ),
            ),
          )
          .toList(),
    );
  }

  String _statusText(ProblemAttachment attachment) {
    switch (attachment.status) {
      case AttachmentStatus.pending:
        return '대기 중';
      case AttachmentStatus.processing:
        return 'OCR 분석 중...';
      case AttachmentStatus.completed:
        return attachment.ocrText ?? 'OCR 완료';
      case AttachmentStatus.failed:
        return attachment.errorMessage ?? '처리에 실패했어요.';
    }
  }

  Widget _buildTrailing(ProblemAttachment attachment, BuildContext context) {
    switch (attachment.status) {
      case AttachmentStatus.pending:
        return const Icon(Icons.hourglass_empty);
      case AttachmentStatus.processing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case AttachmentStatus.completed:
        return const Icon(Icons.check_circle);
      case AttachmentStatus.failed:
        return Consumer(
          builder: (context, ref, _) => IconButton(
            tooltip: '다시 시도',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(toolWorkspaceControllerProvider.notifier)
                .retryAttachment(attachment.id),
          ),
        );
    }
  }
}

class MyTabPlaceholder extends StatelessWidget {
  const MyTabPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('마이 페이지 준비 중입니다.'),
      ),
    );
  }
}

class _InlinePlanController extends PrescriptionDetailController {
  _InlinePlanController(this.initialPlan);

  final RemediationPlan initialPlan;

  @override
  RemediationPlan build() => initialPlan;
}

class _RemediationBottomSheet extends ConsumerStatefulWidget {
  const _RemediationBottomSheet({
    required this.task,
    required this.onCompleteTask,
  });

  final PrescriptionTask task;
  final VoidCallback onCompleteTask;

  @override
  ConsumerState<_RemediationBottomSheet> createState() =>
      _RemediationBottomSheetState();
}

class _RemediationBottomSheetState
    extends ConsumerState<_RemediationBottomSheet> {
  final _answerController = TextEditingController();
  String? _feedback;
  bool? _isCorrect;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(prescriptionDetailControllerProvider);
    final controller = ref.read(prescriptionDetailControllerProvider.notifier);
    final currentStep = plan.steps[plan.focusedIndex];

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Tail-to-Tail Flow',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '다시 연계 만들기',
                onPressed: () => controller.regeneratePlan(widget.task.problemId),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '현재 단계: ${currentStep.problem.prompt}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _answerController,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: '정답 입력',
              hintText: '풀이를 적어보세요',
            ),
          ),
          if (_feedback != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _feedback!,
                style: TextStyle(
                  color: _isCorrect == true
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 8),
          _PlanStepper(
            plan: plan,
            onStepTap: controller.focusStep,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: plan.focusedIndex == 0
                    ? null
                    : controller.goBackToParent,
                icon: const Icon(Icons.arrow_upward),
                label: const Text('상위 문제로'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final grading = ref
                        .read(dailyPrescriptionControllerProvider.notifier)
                        .gradeTask(
                          widget.task.id,
                          _answerController.text,
                        );
                    setState(() {
                      _isCorrect = grading;
                      _feedback = grading ? '정답이에요! 🎉' : '아쉽다, 다시 시도해볼까요?';
                    });
                    if (grading) {
                      widget.onCompleteTask();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('정답 제출'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanStepper extends StatelessWidget {
  const _PlanStepper({
    required this.plan,
    required this.onStepTap,
  });

  final RemediationPlan plan;
  final void Function(int) onStepTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: plan.steps
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isActive = index == plan.focusedIndex;
            final isLeaf = step.depth == 0;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              title: Text(step.problem.prompt),
              subtitle: Text(
                step.depth == 0 ? '상위 문제' : '하위 문제 단계 ${step.depth}',
              ),
              trailing: isLeaf
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      tooltip: '다음 하위 문제로',
                      onPressed: () => onStepTap(index + 1),
                    ),
              onTap: () => onStepTap(index),
            );
          })
          .toList(),
    );
  }
}
