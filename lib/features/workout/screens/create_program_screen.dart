import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/widgets/onboarding_widgets.dart';
import '../providers/program_provider.dart';
import 'program_detail_screen.dart';

class CreateProgramScreen extends StatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  State<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen> {
  final _nameController = TextEditingController();
  final _weeksController = TextEditingController();
  final _daysController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _weeksController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a program name')),
      );
      return;
    }
    setState(() => _isCreating = true);
    final weeks = int.tryParse(_weeksController.text.trim());
    final days = int.tryParse(_daysController.text.trim());
    final program = await context.read<ProgramProvider>().createProgram(
          name: name,
          weeks: weeks,
          daysPerWeek: days,
        );
    if (mounted) {
      setState(() => _isCreating = false);
      if (program != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProgramDetailScreen(programId: program.id),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create program')),
        );
      }
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
          icon:
              const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Program',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Program Name'),
            const SizedBox(height: 8),
            _field(_nameController, 'e.g. My Push Pull Legs',
                TextInputType.text),
            const SizedBox(height: 20),
            _label('Duration (weeks) — optional'),
            const SizedBox(height: 8),
            _field(_weeksController, 'e.g. 8',
                TextInputType.number),
            const SizedBox(height: 20),
            _label('Days per week — optional'),
            const SizedBox(height: 8),
            _field(_daysController, 'e.g. 4',
                TextInputType.number),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OnboardingTheme.accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Create Program',
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
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w600));
  }

  Widget _field(TextEditingController ctrl, String hint, TextInputType type) {
    return Container(
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OnboardingTheme.border),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
