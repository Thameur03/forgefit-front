import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../models/program_model.dart';
import '../providers/program_provider.dart';
import 'program_day_screen.dart';



class ProgramDetailScreen extends StatefulWidget {
  final int programId;

  const ProgramDetailScreen({super.key, required this.programId});

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  ProgramModel? _program;
  bool _isLoading = true;
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = context.read<ProgramProvider>();
    final p = await provider.loadProgramDetail(widget.programId);
    if (mounted) {
      setState(() {
        _program = p;
        _isLoading = false;
      });
    }
  }

  Future<void> _activate() async {
    if (_program == null) return;
    setState(() => _isActivating = true);
    final success =
        await context.read<ProgramProvider>().activateProgram(_program!.id);
    if (mounted) {
      setState(() => _isActivating = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_program!.name} is now your active program'),
            backgroundColor: OnboardingTheme.card,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _delete() async {
    if (_program == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: OnboardingTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Program?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Delete "${_program!.name}"? This cannot be undone.',
            style: const TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<ProgramProvider>().deleteProgram(_program!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      appBar: AppBar(
        backgroundColor: OnboardingTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _program?.name ?? 'Program',
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_program != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _delete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: OnboardingTheme.accent))
          : _program == null
              ? const Center(
                  child: Text('Program not found',
                      style: TextStyle(color: Colors.white60)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final p = _program!;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OnboardingTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: OnboardingTheme.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(p.subtitle,
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (p.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: OnboardingTheme.success.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: OnboardingTheme.success.withAlpha(80)),
                          ),
                          child: const Text('Active',
                              style: TextStyle(
                                  color: OnboardingTheme.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Workout Days',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Day cards
                ...p.days.map((day) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () async {
                          final refreshed = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProgramDayScreen(
                                day: day,
                                programId: p.id,
                              ),
                            ),
                          );
                          if (refreshed == true) _load();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: OnboardingTheme.card,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: OnboardingTheme.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      OnboardingTheme.accent.withAlpha(25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.dayNumber}',
                                  style: const TextStyle(
                                      color: OnboardingTheme.accent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(day.dayName,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${day.exercises.length} exercises',
                                      style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Colors.white38),
                            ],
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _showAddDaySheet,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: OnboardingTheme.accent.withAlpha(80),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: OnboardingTheme.accent, size: 20),
                        const SizedBox(width: 8),
                        const Text('Add Day',
                            style: TextStyle(
                                color: OnboardingTheme.accent,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom button
        if (!p.isActive)
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isActivating ? null : _activate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OnboardingTheme.accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _isActivating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Activate Program',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showAddDaySheet() async {
    final nameController = TextEditingController();
    bool isAdding = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: OnboardingTheme.bg,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Add Day',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: OnboardingTheme.card,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white60, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Day Name',
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: OnboardingTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: OnboardingTheme.border),
                      ),
                      child: TextField(
                        controller: nameController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Push Day, Day A, Leg Day...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isAdding
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                if (name.isEmpty) return;
                                setSheetState(() => isAdding = true);

                                final newDay = await context
                                    .read<ProgramProvider>()
                                    .addDayToProgram(
                                      widget.programId,
                                      dayName: name,
                                    );

                                if (ctx.mounted) Navigator.pop(ctx);
                                if (newDay != null && mounted) {
                                  _load();
                                } else if (newDay == null && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Failed to add day. Please try again.'),
                                      backgroundColor: OnboardingTheme.danger,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OnboardingTheme.accent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: isAdding
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Add Day',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
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
}
