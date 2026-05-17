import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/siswa_model.dart';
import '../../viewmodel/siswa_viewmodel.dart';

class SiswaFormScreen extends StatefulWidget {
  /// Jika [siswa] tidak null, berarti mode Edit. Jika null, mode Tambah.
  final Siswa? siswa;

  const SiswaFormScreen({super.key, this.siswa});

  @override
  State<SiswaFormScreen> createState() => _SiswaFormScreenState();
}

class _SiswaFormScreenState extends State<SiswaFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kelasController = TextEditingController();
  final _nisController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool get _isEditMode => widget.siswa != null;

  @override
  void initState() {
    super.initState();

    // Pre-fill jika mode edit
    if (_isEditMode) {
      _namaController.text = widget.siswa!.nama;
      _kelasController.text = widget.siswa!.kelas;
      _nisController.text = widget.siswa!.nis;
    }

    // Entrance animations
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kelasController.dispose();
    _nisController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── Submit form ───────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<SiswaViewModel>();

    final siswa = Siswa(
      id: _isEditMode ? widget.siswa!.id : null,
      nama: _namaController.text.trim(),
      kelas: _kelasController.text.trim(),
      nis: _nisController.text.trim(),
    );

    bool success;
    if (_isEditMode) {
      success = await vm.updateSiswa(widget.siswa!.id!, siswa);
    } else {
      success = await vm.createSiswa(siswa);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.primary, size: 18),
                const SizedBox(width: 10),
                Text(
                  _isEditMode
                      ? 'Data siswa berhasil diperbarui!'
                      : 'Siswa baru berhasil ditambahkan!',
                  style: GoogleFonts.inter(color: AppTheme.textPrimary),
                ),
              ],
            ),
            backgroundColor: AppTheme.surfaceHigh,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded,
                    color: AppTheme.error, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Gagal: ${vm.errorMessage}',
                    style: GoogleFonts.inter(color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.surfaceHigh,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textSecondary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (_isEditMode
                        ? const Color(0xFF64B5F6)
                        : AppTheme.primary)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isEditMode
                    ? Icons.edit_rounded
                    : Icons.person_add_rounded,
                color: _isEditMode
                    ? const Color(0xFF64B5F6)
                    : AppTheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _isEditMode ? 'Edit Siswa' : 'Tambah Siswa',
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),

      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Card ─────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.person_rounded,
                              color: AppTheme.primary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEditMode
                                  ? 'Perbarui Data Siswa'
                                  : 'Data Siswa Baru',
                              style: GoogleFonts.inter(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isEditMode
                                  ? 'Ubah informasi siswa di bawah ini'
                                  : 'Isi semua field yang diperlukan',
                              style: GoogleFonts.inter(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Form Section Label ──────────────────────────
                  _SectionLabel(label: 'INFORMASI SISWA'),
                  const SizedBox(height: 12),

                  // ── Nama Field ──────────────────────────────────
                  _FormField(
                    controller: _namaController,
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap siswa',
                    icon: Icons.person_outline_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      if (v.trim().length < 2) {
                        return 'Nama minimal 2 karakter';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // ── NIS Field ───────────────────────────────────
                  _FormField(
                    controller: _nisController,
                    label: 'NIS (Nomor Induk Siswa)',
                    hint: 'Contoh: 2024001',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'NIS tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // ── Kelas Field ─────────────────────────────────
                  _FormField(
                    controller: _kelasController,
                    label: 'Kelas',
                    hint: 'Contoh: X IPA 1, XI TKJ 2',
                    icon: Icons.class_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Kelas tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── Submit Button ───────────────────────────────
                  Consumer<SiswaViewModel>(
                    builder: (_, vm, __) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: vm.isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isEditMode
                                ? const Color(0xFF64B5F6)
                                : AppTheme.primary,
                            foregroundColor: AppTheme.background,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                            disabledBackgroundColor:
                                AppTheme.textSecondary.withValues(alpha: 0.3),
                          ),
                          child: vm.isSubmitting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppTheme.background,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _isEditMode
                                          ? 'Menyimpan...'
                                          : 'Menambahkan...',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isEditMode
                                          ? Icons.save_rounded
                                          : Icons.add_circle_rounded,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isEditMode
                                          ? 'Simpan Perubahan'
                                          : 'Tambah Siswa',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ── Cancel Button ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        foregroundColor: AppTheme.textSecondary,
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.08,
          ),
        ),
      ],
    );
  }
}

// ── Form Field Component ──────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
        color: AppTheme.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
        labelStyle: GoogleFonts.inter(
          color: AppTheme.textSecondary,
          fontSize: 13,
        ),
        hintStyle: GoogleFonts.inter(
          color: AppTheme.textSecondary.withValues(alpha: 0.5),
          fontSize: 13,
        ),
      ),
    );
  }
}
