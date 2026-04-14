import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    // Pre-populate if going back
    final op = context.read<OnboardingProvider>();
    _fullNameCtrl.text = op.fullName;
    _dobCtrl.text = op.dateOfBirth;
    if (op.gender.isNotEmpty) _selectedGender = op.gender;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: OnboardingTheme.accent,
              surface: OnboardingTheme.field,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobCtrl.text =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    
    // Save to provider, do not call API
    final op = context.read<OnboardingProvider>();
    op.fullName = _fullNameCtrl.text.trim();
    op.dateOfBirth = _dobCtrl.text;
    op.gender = _selectedGender;
    
    Navigator.pushNamed(context, '/physical-metrics');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                OnboardingHeader(current: 2, total: 5),
                const SizedBox(height: 16),
                
                OnboardingProgressBar(current: 2, total: 5),
                const SizedBox(height: 36),

                // ── Icon ───────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: OnboardingTheme.cardAlt,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: OnboardingTheme.accent.withAlpha(60),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: OnboardingTheme.accent,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Heading ────────────────────────────────────────────────
                const Text(
                  "Let's get started",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We use this information to\npersonalize your fitness journey.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Full Name ──────────────────────────────────────────────
                const OnboardingFieldLabel('Full Name'),
                const SizedBox(height: 6),
                OnboardingTextField(
                  controller: _fullNameCtrl,
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // ── Date of Birth ──────────────────────────────────────────
                const OnboardingFieldLabel('Date of Birth'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: OnboardingTextField(
                      controller: _dobCtrl,
                      hint: 'mm/dd/yyyy',
                      prefixIcon: Icons.calendar_today_outlined,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please select your date of birth';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // ── Gender ─────────────────────────────────────────────────
                const OnboardingFieldLabel('Gender'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _GenderCard(
                        label: 'Male',
                        icon: Icons.male,
                        selected: _selectedGender == 'Male',
                        onTap: () => setState(() => _selectedGender = 'Male'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _GenderCard(
                        label: 'Female',
                        icon: Icons.female,
                        selected: _selectedGender == 'Female',
                        onTap: () => setState(() => _selectedGender = 'Female'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                OnboardingPulseButton(
                  label: 'Next',
                  onPressed: _next,
                ),
                const SizedBox(height: 14),

                // ── Safe & Encrypted badge ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: OnboardingTheme.card,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: OnboardingTheme.border),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline,
                          color: Colors.white38, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Your data is safe and encrypted',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Gender card (with pop scaling animation) ─────────────────────────────────
class _GenderCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_GenderCard> createState() => _GenderCardState();
}

class _GenderCardState extends State<_GenderCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const accent = OnboardingTheme.accent;
    final scale = _isPressed ? 0.96 : (widget.selected ? 1.02 : 1.0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: widget.selected
                ? accent.withAlpha(30)
                : OnboardingTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.selected ? accent : OnboardingTheme.border,
              width: widget.selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.selected ? accent : Colors.white38,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.selected ? Colors.white : Colors.white54,
                  fontWeight:
                      widget.selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
