import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../theme/app_theme.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;
  final VoidCallback? onViewDoctor;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
    this.onReview,
    this.onViewDoctor,
  });

  Map<String, dynamic> get _statusInfo {
    switch (appointment.status) {
      case 'confirmed': return {'label': 'Confirmé', 'color': AppTheme.success, 'bg': const Color(0xFFe8f5e9)};
      case 'completed': return {'label': 'Terminé', 'color': AppTheme.primary, 'bg': AppTheme.primaryLight};
      case 'cancelled': return {'label': 'Annulé', 'color': AppTheme.danger, 'bg': const Color(0xFFfdecea)};
      default:          return {'label': 'En attente', 'color': AppTheme.warning, 'bg': const Color(0xFFfffde7)};
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Text('👨‍⚕️', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. ${appointment.doctorName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(appointment.specialty, style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
                      Text('📅 ${appointment.date} — ${appointment.time}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      Text('💰 ${appointment.price.toInt()} TND', style: const TextStyle(fontSize: 12, color: AppTheme.success)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: status['bg'], borderRadius: BorderRadius.circular(20)),
                  child: Text(status['label'], style: TextStyle(fontSize: 11, color: status['color'], fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                if (onViewDoctor != null)
                  Expanded(child: _actionBtn('Voir médecin', AppTheme.primary, AppTheme.primaryLight, onViewDoctor!)),
                if (onCancel != null) ...[
                  const SizedBox(width: 8),
                  Expanded(child: _actionBtn('Annuler', AppTheme.danger, const Color(0xFFfdecea), onCancel!)),
                ],
                if (onReview != null) ...[
                  const SizedBox(width: 8),
                  Expanded(child: _actionBtn('⭐ Avis', AppTheme.warning, const Color(0xFFfffde7), onReview!)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ),
    );
  }
}