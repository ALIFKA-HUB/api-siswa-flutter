import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../models/siswa_model.dart';

class SiswaCard extends StatefulWidget {
  final Siswa siswa;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SiswaCard({
    super.key,
    required this.siswa,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<SiswaCard> createState() => _SiswaCardState();
}

class _SiswaCardState extends State<SiswaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<Color?> _borderAnim;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _borderAnim = ColorTween(
      begin: AppTheme.border,
      end: AppTheme.primary.withValues(alpha: 0.5),
    ).animate(_hoverController);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool hover) {
    setState(() => _isHovered = hover);
    if (hover) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  // ── Avatar color berdasarkan index ──────────────────────────
  Color _getAvatarColor() {
    final colors = [
      AppTheme.primary,
      const Color(0xFF64B5F6),
      const Color(0xFFFFB74D),
      const Color(0xFFCE93D8),
      const Color(0xFF80CBC4),
      const Color(0xFFEF9A9A),
    ];
    return colors[widget.index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor();
    final initial = widget.siswa.nama.isNotEmpty
        ? widget.siswa.nama[0].toUpperCase()
        : '?';

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isHovered ? AppTheme.surfaceHigh : AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _borderAnim.value ?? AppTheme.border,
                width: 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ── Avatar ────────────────────────────────────────
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: avatarColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.inter(
                      color: avatarColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // ── Info Siswa ────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    Text(
                      widget.siswa.nama,
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // NIS & Kelas row
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.badge_outlined,
                          label: 'NIS: ${widget.siswa.nis}',
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.class_outlined,
                          label: widget.siswa.kelas,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Action Buttons ────────────────────────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Button
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    color: const Color(0xFF64B5F6),
                    tooltip: 'Edit Siswa',
                    onTap: widget.onEdit,
                  ),
                  const SizedBox(width: 8),
                  // Delete Button
                  _ActionButton(
                    icon: Icons.delete_rounded,
                    color: AppTheme.error,
                    tooltip: 'Hapus Siswa',
                    onTap: widget.onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Info Chip Widget ───────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textSecondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Action Button Widget ──────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.2)
                  : widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered
                    ? widget.color.withValues(alpha: 0.5)
                    : widget.color.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
