import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/knowledge_graph/domain/remediation_plan.dart';
import 'features/note/application/tool_workspace_controller.dart';
import 'features/note/application/tool_workspace_state.dart';
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
      theme: AppTheme.light(),
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
  void _onTabSelected(int newIndex) => setState(() => _currentIndex = newIndex);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
          index: _currentIndex,
          children: const [CoachTabView(), ToolTabView(), MyTabPlaceholder()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.spa_outlined),
              selectedIcon: Icon(Icons.spa),
              label: '코칭'),
          NavigationDestination(
              icon: Icon(Icons.edit_note_outlined),
              selectedIcon: Icon(Icons.edit_note),
              label: '노트'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: '마이'),
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
          onSubmitAnswer: controller.gradeTask,
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
    required this.onSubmitAnswer,
  });

  final DailyPrescription plan;
  final void Function(String taskId) onToggleTask;
  final bool Function(String taskId, String answer) onSubmitAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _Header(plan: plan),
                const SizedBox(height: 16),
                Text('오늘 메워줄 구멍', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'AI 코치가 준비해둔 단계별 처방을 따라가며 천천히 복구해요.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (plan.tasks.isEmpty)
                  const Text('처방 카드가 아직 없어요')
                else
                  ...plan.tasks.map(
                    (task) => _PrescriptionCard(
                      task: task,
                      onToggleTask: onToggleTask,
                      onSubmitAnswer: onSubmitAnswer,
                    ),
                  ),
                const SizedBox(height: 24),
                Text('약점 리포트', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                _WeaknessList(weaknesses: plan.weaknesses),
              ],
            ),
          ),
        ),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.spa, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('오늘 루틴', style: theme.textTheme.titleMedium),
              const Spacer(),
              _StatusChip(
                label: '${(ratio * 100).round()}% 치료',
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 8),
          Text(
            '카드 ${plan.tasks.length}개가 준비됐어요. 스트레스 없이 하나씩만 해봐요.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _StepPath extends StatelessWidget {
  const _StepPath({required this.path});

  final List<String> path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = path.take(3).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: display
          .map(
            (p) => Chip(
              label: Text(p),
              backgroundColor: theme.colorScheme.surfaceVariant,
              labelStyle: theme.textTheme.labelMedium,
            ),
          )
          .toList(),
    );
  }
}

class _WeaknessList extends StatelessWidget {
  const _WeaknessList({required this.weaknesses});

  final List<Weakness> weaknesses;

  @override
  Widget build(BuildContext context) {
    if (weaknesses.isEmpty) {
      return const Text('현재 등록된 약점이 없어요');
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

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({
    required this.task,
    required this.onToggleTask,
    required this.onSubmitAnswer,
  });

  final PrescriptionTask task;
  final void Function(String taskId) onToggleTask;
  final bool Function(String taskId, String answer) onSubmitAnswer;

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == PrescriptionTaskStatus.completed;
    final theme = Theme.of(context);
    final plan = task.remediationPlan;
    final path = plan.steps.map((s) => s.problem.conceptId).toList();

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      tween: Tween(begin: 0.985, end: 1),
      builder: (context, scale, child) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: isDone ? 0.8 : 1,
          child: Transform.scale(
            scale: isDone ? 0.99 : scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDone
                    ? theme.colorScheme.primaryContainer.withOpacity(0.25)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDone
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow
                        .withOpacity(isDone ? 0.05 : 0.08),
                    blurRadius: isDone ? 8 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusChip(
                label: isDone ? '완료' : '처방',
                color: isDone
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(task.conceptName, style: theme.textTheme.labelLarge),
              const Spacer(),
              IconButton(
                tooltip: isDone ? '완료 취소' : '완료 표시',
                icon: Icon(
                  isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                ),
                color: isDone
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                onPressed: () => onToggleTask(task.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(task.prompt, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          _StepPath(path: path),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.timer_outlined,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text('상위→하위 ${plan.steps.length}단계',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showPlanOverlay(context, task),
                icon: const Icon(Icons.arrow_outward),
                label: const Text('열기'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPlanOverlay(BuildContext context, PrescriptionTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 240),
        vsync: Navigator.of(context),
      ),
      builder: (_) => ProviderScope(
        overrides: [
          prescriptionDetailControllerProvider.overrideWith(
            () => _InlinePlanController(task.remediationPlan),
          ),
        ],
        child: _RemediationBottomSheet(
          task: task,
          onCompleteTask: () => onToggleTask(task.id),
          onSubmitAnswer: (answer) => onSubmitAnswer(task.id, answer),
        ),
      ),
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
    final theme = Theme.of(context);
    final hasUpload = workspace.attachments.isNotEmpty;
    final hasOcrResult = workspace.attachments
        .any((a) => a.status == AttachmentStatus.completed);
    final hasError =
        workspace.attachments.any((a) => a.status == AttachmentStatus.failed);

    return Scaffold(
      appBar: AppBar(
        title: const Text('노트 & 도구'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('문제 업로드', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    '촬영·PDF를 올리면 OCR → AI 답변까지 한 번에 이어질 준비를 해둘게요.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _FlowChip(
                          label: '업로드', isActive: true, isDone: hasUpload),
                      const Icon(Icons.chevron_right),
                      _FlowChip(
                        label: 'OCR',
                        isActive: hasUpload,
                        isDone: hasOcrResult,
                        isError: hasError,
                      ),
                      const Icon(Icons.chevron_right),
                      _FlowChip(
                        label: 'AI 답변',
                        isActive: hasOcrResult,
                        isDone: workspace.lastAnswer != null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () =>
                            controller.addAttachment(AttachmentType.photo),
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('카메라 촬영'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            controller.addAttachment(AttachmentType.pdf),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('PDF 불러오기'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AttachmentList(attachments: workspace.attachments),
                ],
              ),
            ),
          ),
          if (hasOcrResult) const SizedBox(height: 16),
          if (hasOcrResult)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('문제 + 필기', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'OCR로 읽힌 문제 위에 바로 써보세요. 틀려도 괜찮아요.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FreehandCanvas(
                      height: 260,
                      background: _ProblemBackground(
                        prompt: _buildOcrBackground(workspace),
                        imagePath: _pickAttachmentImage(workspace),
                      ),
                      hintText: '여기에 풀이를 적어보세요',
                    ),
                  ],
                ),
              ),
            ),
          if (hasOcrResult) const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI에게 질문하기', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'OCR된 내용과 함께 궁금한 점을 적어주세요.',
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
                        title: const Text('AI 답변'),
                        subtitle: Text(workspace.lastAnswer!),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('필기 연습', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    '풀이를 자유롭게 적어보세요. 펜/지우개 없이 부담없이 연습할 수 있어요.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const FreehandCanvas(
                    height: 320,
                    hintText: '여기에 풀이를 적어보세요',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildOcrBackground(ToolWorkspaceState workspace) {
    final completed = workspace.attachments.firstWhere(
      (a) => a.status == AttachmentStatus.completed && a.ocrText != null,
      orElse: () => workspace.attachments.firstWhere(
        (a) => a.status == AttachmentStatus.completed,
        orElse: () => ProblemAttachment(
          id: '',
          type: AttachmentType.photo,
          fileName: '',
          createdAt: DateTime.now(),
        ),
      ),
    );
    if (completed.id.isEmpty) return '문제 텍스트를 불러오는 중이에요.';
    final text = completed.ocrText ?? completed.fileName;
    return text.length > 260 ? '${text.substring(0, 260)}...' : text;
  }

  String? _pickAttachmentImage(ToolWorkspaceState workspace) {
    final completedImage = workspace.attachments.firstWhere(
      (a) =>
          a.status == AttachmentStatus.completed &&
          a.type == AttachmentType.photo &&
          a.fileName.isNotEmpty,
      orElse: () => ProblemAttachment(
        id: '',
        type: AttachmentType.photo,
        fileName: '',
        createdAt: DateTime.now(),
      ),
    );
    if (completedImage.id.isEmpty) return null;
    return completedImage.fileName;
  }
}

class _FlowChip extends StatelessWidget {
  const _FlowChip({
    required this.label,
    required this.isActive,
    this.isDone = false,
    this.isError = false,
  });

  final String label;
  final bool isActive;
  final bool isDone;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color border = theme.colorScheme.outlineVariant;
    Color fill = theme.colorScheme.surfaceVariant;
    if (isError) {
      border = theme.colorScheme.error;
      fill = theme.colorScheme.errorContainer.withOpacity(0.4);
    } else if (isDone) {
      border = theme.colorScheme.primary;
      fill = theme.colorScheme.primaryContainer.withOpacity(0.5);
    } else if (isActive) {
      border = theme.colorScheme.secondary;
      fill = theme.colorScheme.secondaryContainer.withOpacity(0.5);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isError
                ? Icons.error_outline
                : (isDone ? Icons.check_circle : Icons.circle_outlined),
            size: 16,
            color: border,
          ),
          const SizedBox(width: 6),
          Text(label,
              style: theme.textTheme.labelMedium?.copyWith(color: border)),
        ],
      ),
    );
  }
}

class _ProblemBackground extends StatelessWidget {
  const _ProblemBackground({required this.prompt, this.imagePath});

  final String prompt;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath != null && imagePath!.isNotEmpty)
            Positioned.fill(
              child: Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                color: theme.colorScheme.surface.withOpacity(0.35),
                colorBlendMode: BlendMode.srcATop,
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surfaceVariant.withOpacity(0.65),
                    theme.colorScheme.surface.withOpacity(0.65),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                prompt,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.75),
                ),
              ),
            ),
          ),
        ],
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
        '아직 업로드된 문제가 없어요',
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
        return attachment.errorMessage ?? '처리에 실패했어요';
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
        child: Text('마이 페이지 준비중입니다.'),
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
    required this.onSubmitAnswer,
  });

  final PrescriptionTask task;
  final VoidCallback onCompleteTask;
  final bool Function(String answer) onSubmitAnswer;

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
  Widget build(BuildContext context) {
    final plan = ref.watch(prescriptionDetailControllerProvider);
    final controller = ref.read(prescriptionDetailControllerProvider.notifier);
    final currentStep = plan.steps[plan.focusedIndex];
    final theme = Theme.of(context);

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Tail-to-Tail Flow',
                        style: theme.textTheme.titleMedium),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: '다시 계획 만들기',
                      onPressed: () =>
                          controller.regeneratePlan(widget.task.problemId),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '막히면 아래로 내려가고, 풀리면 다시 올라오면 돼요.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusChip(
                      label: widget.task.conceptName,
                      color: theme.colorScheme.primary,
                    ),
                    _StatusChip(
                      label: '단계 ${plan.focusedIndex + 1}/${plan.steps.length}',
                      color: theme.colorScheme.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currentStep.problem.prompt,
                                    style: theme.textTheme.titleMedium),
                                const SizedBox(height: 12),
                                FreehandCanvas(
                                  height: 220,
                                  background: _ProblemBackground(
                                    prompt: currentStep.problem.prompt,
                                  ),
                                  hintText: '생각나는 풀이를 가볍게 적어보세요',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('정답 입력', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _answerController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            labelText: '정답을 적어주세요',
                            hintText: '숫자나 식, 간단한 설명도 좋아요',
                          ),
                        ),
                        if (_feedback != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _feedback!,
                              style: TextStyle(
                                color: _isCorrect == true
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.error,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        _PlanStepper(
                          plan: plan,
                          onStepTap: controller.focusStep,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: plan.focusedIndex == 0
                                  ? null
                                  : controller.goBackToParent,
                              icon: const Icon(Icons.arrow_upward),
                              label: const Text('상위 문제'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed:
                                  plan.focusedIndex >= plan.steps.length - 1
                                      ? null
                                      : () => controller
                                          .focusStep(plan.focusedIndex + 1),
                              icon: const Icon(Icons.arrow_downward),
                              label: const Text('하위 문제'),
                            ),
                            const Spacer(),
                            FilledButton(
                              onPressed: () {
                                final grading = widget.onSubmitAnswer(
                                  _answerController.text,
                                );
                                setState(() {
                                  _isCorrect = grading;
                                  _feedback = grading
                                      ? '정답이에요! 잠깐 숨 고르고 상위 문제로 돌아가요.'
                                      : '조금만 더! 아래 단계로 내려가 볼까요?';
                                });
                                if (grading) {
                                  widget.onCompleteTask();
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('정답 제출'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanStepper extends StatelessWidget {
  const _PlanStepper({required this.plan, required this.onStepTap});

  final RemediationPlan plan;
  final void Function(int) onStepTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('단계별 힌트', style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        ...plan.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = index == plan.focusedIndex;
          final isLeaf = step.depth == 0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primaryContainer.withOpacity(0.4)
                  : theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isLeaf ? Icons.star : Icons.south_east,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.problem.prompt,
                          style: theme.textTheme.bodyLarge),
                      Text(
                        step.depth == 0 ? '상위 문제' : '하위 문제 레벨 ${step.depth}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => onStepTap(index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
