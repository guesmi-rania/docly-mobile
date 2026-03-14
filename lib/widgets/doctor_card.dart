import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../theme/app_theme.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const DoctorCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            const Text('👨‍⚕️', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dr. ${doctor.name}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(doctor.specialty, style: const TextStyle(fontSize: 13, color: AppTheme.primary)),
                  Text('📍 ${doctor.city}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  Text('💰 ${doctor.price.toInt()} TND', style: const TextStyle(fontSize: 12, color: AppTheme.success)),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Icons.star, color: Color(0xFFf9a825), size: 16),
                Text(doctor.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}