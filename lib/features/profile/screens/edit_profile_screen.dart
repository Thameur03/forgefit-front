import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/onboarding_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ── Controllers ──────────────────────────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;

  // ── Local state ───────────────────────────────────────────────────────────
  late String _fitnessLevel;
  late String _gender;
  DateTime? _dateOfBirth;

  // Original values — used to compute diff on Save
  late final String _origName;
  late final String _origEmail;
  late final String _origWeight;
  late final String _origHeight;
  late final String _origFitnessLevel;
  late final String _origGender;
  late final DateTime? _origDob;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;

    _origName = user?.fullName ?? '';
    _origEmail = user?.email ?? '';
    _origWeight = user?.weightKg?.toString() ?? '';
    _origHeight = user?.heightCm?.toString() ?? '';
    _origFitnessLevel =
        _capitalize(user?.fitnessLevel ?? 'Intermediate');
    _origGender = _capitalize(user?.gender ?? 'Male');
    _origDob = user?.dateOfBirth;

    _nameCtrl = TextEditingController(text: _origName);
    _emailCtrl = TextEditingController(text: _origEmail);
    _passwordCtrl = TextEditingController();
    _weightCtrl = TextEditingController(text: _origWeight);
    _heightCtrl = TextEditingController(text: _origHeight);

    _fitnessLevel = _origFitnessLevel;
    _gender = _origGender;
    _dateOfBirth = _origDob;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _dobDisplay() {
    if (_dateOfBirth == null) return 'Not set';
    return DateFormat('dd/MM/yyyy').format(_dateOfBirth!);
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final body = <String, dynamic>{};

    if (_nameCtrl.text.trim() != _origName) {
      body['full_name'] = _nameCtrl.text.trim();
    }
    if (_weightCtrl.text.trim() != _origWeight &&
        _weightCtrl.text.trim().isNotEmpty) {
      body['weight_kg'] = double.tryParse(_weightCtrl.text.trim());
    }
    if (_heightCtrl.text.trim() != _origHeight &&
        _heightCtrl.text.trim().isNotEmpty) {
      body['height_cm'] = double.tryParse(_heightCtrl.text.trim());
    }
    if (_fitnessLevel.toLowerCase() != _origFitnessLevel.toLowerCase()) {
      body['fitness_level'] = _fitnessLevel.toLowerCase();
    }
    if (_gender.toLowerCase() != _origGender.toLowerCase()) {
      body['gender'] = _gender.toLowerCase();
    }
    if (_dateOfBirth != _origDob && _dateOfBirth != null) {
      body['date_of_birth'] =
          DateFormat('yyyy-MM-dd').format(_dateOfBirth!);
    }

    if (body.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes to save.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiClient = context.read<ApiClient>();
      await apiClient.put(ApiConstants.authProfile, data: body);

      if (mounted) {
        await context.read<AuthProvider>().getCurrentUser();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // ApiClient._handleError already converts DioException → String
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Bottom sheet — text field ─────────────────────────────────────────────

  void _showTextSheet({
    required String title,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    VoidCallback? onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: OnboardingTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                autofocus: true,
                keyboardType: keyboardType,
                obscureText: obscureText,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: OnboardingTheme.field,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: OnboardingTheme.accent, width: 1.5),
                  ),
                  hintStyle: const TextStyle(color: Colors.white38),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        OnboardingTheme.gradientStart,
                        OnboardingTheme.gradientEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      onSave?.call();
                      setState(() {}); // reflect controller change
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showComingSoonSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  // ── Bottom sheet — option list ────────────────────────────────────────────

  void _showOptionSheet({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OnboardingTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...options.map(
                (opt) => ListTile(
                  title: Text(opt,
                      style: const TextStyle(color: Colors.white)),
                  trailing: opt == selected
                      ? const Icon(Icons.check_circle_rounded,
                          color: OnboardingTheme.accent)
                      : const Icon(Icons.circle_outlined,
                          color: Colors.white38),
                  onTap: () {
                    onSelect(opt);
                    Navigator.pop(sheetCtx);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Date picker ───────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1930),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: OnboardingTheme.accent,
            surface: OnboardingTheme.cardDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page title
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // ── Card 1 — Personal Info ─────────────────────────────────
              _SectionLabel(label: 'PERSONAL INFO'),
              const SizedBox(height: 8),
              _Card(
                children: [
                  _EditRow(
                    label: 'Full Name',
                    value: _nameCtrl.text,
                    onTap: () => _showTextSheet(
                      title: 'Full Name',
                      controller: _nameCtrl,
                      keyboardType: TextInputType.name,
                    ),
                  ),
                  _Divider(),
                  _EditRow(
                    label: 'Email',
                    value: _emailCtrl.text,
                    onTap: () {
                      _showComingSoonSnack();
                    },
                  ),
                  _Divider(),
                  _EditRow(
                    label: 'Password',
                    value: '••••••••',
                    onTap: () {
                      _showComingSoonSnack();
                    },
                  ),
                ],
              ),

              // ── Card 2 — Body Stats ────────────────────────────────────
              const SizedBox(height: 12),
              _SectionLabel(label: 'BODY STATS'),
              const SizedBox(height: 8),
              _Card(
                children: [
                  _EditRow(
                    label: 'Weight (kg)',
                    value: _weightCtrl.text.isEmpty
                        ? 'Not set'
                        : _weightCtrl.text,
                    onTap: () => _showTextSheet(
                      title: 'Weight (kg)',
                      controller: _weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                  ),
                  _Divider(),
                  _EditRow(
                    label: 'Height (cm)',
                    value: _heightCtrl.text.isEmpty
                        ? 'Not set'
                        : _heightCtrl.text,
                    onTap: () => _showTextSheet(
                      title: 'Height (cm)',
                      controller: _heightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                  ),
                  _Divider(),
                  _EditRow(
                    label: 'Date of Birth',
                    value: _dobDisplay(),
                    onTap: _pickDate,
                  ),
                ],
              ),

              // ── Card 3 — Fitness Profile ───────────────────────────────
              const SizedBox(height: 12),
              _SectionLabel(label: 'FITNESS PROFILE'),
              const SizedBox(height: 8),
              _Card(
                children: [
                  _EditRow(
                    label: 'Fitness Level',
                    valueWidget: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: OnboardingTheme.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _fitnessLevel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: OnboardingTheme.accent,
                        ),
                      ),
                    ),
                    onTap: () => _showOptionSheet(
                      title: 'Fitness Level',
                      options: ['Beginner', 'Intermediate', 'Advanced'],
                      selected: _fitnessLevel,
                      onSelect: (v) => _fitnessLevel = v,
                    ),
                  ),
                  _Divider(),
                  _EditRow(
                    label: 'Gender',
                    value: _gender,
                    onTap: () => _showOptionSheet(
                      title: 'Gender',
                      options: ['Male', 'Female', 'Other'],
                      selected: _gender,
                      onSelect: (v) => _gender = v,
                    ),
                  ),
                ],
              ),

              // ── Save button ────────────────────────────────────────────
              const SizedBox(height: 32),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      OnboardingTheme.gradientStart,
                      OnboardingTheme.gradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: _isLoading ? null : _save,
                    child: SizedBox(
                      height: 54,
                      width: double.infinity,
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: Colors.white38,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: OnboardingTheme.border,
      indent: 16,
      endIndent: 16,
    );
  }
}

/// A tappable info row showing a label left and current value right.
class _EditRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final VoidCallback onTap;

  const _EditRow({
    required this.label,
    this.value,
    this.valueWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            if (valueWidget != null)
              valueWidget!
            else
              Flexible(
                child: Text(
                  value ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}
