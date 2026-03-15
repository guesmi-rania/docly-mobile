import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonDoctorCard extends StatelessWidget {
  const SkeletonDoctorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2d3f50) : const Color(0xFFe0e0e0),
      highlightColor: isDark ? const Color(0xFF3d5060) : const Color(0xFFf5f5f5),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(width: 140, height: 14),
                  const SizedBox(height: 6),
                  _box(width: 100, height: 12),
                  const SizedBox(height: 6),
                  _box(width: 80, height: 12),
                ],
              ),
            ),
            Column(
              children: [
                _box(width: 40, height: 12),
                const SizedBox(height: 4),
                _box(width: 30, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({required double width, required double height}) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      );
}

class SkeletonList extends StatelessWidget {
  final int count;
  const SkeletonList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (_, __) => const SkeletonDoctorCard(),
    );
  }
}