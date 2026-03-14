import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final int maxRating;
  final double size;
  final Function(int)? onRate;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 32,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxRating, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: onRate != null ? () => onRate!(i + 1) : null,
          child: Icon(
            filled ? Icons.star : Icons.star_border,
            color: filled ? const Color(0xFFf9a825) : Colors.grey[300],
            size: size,
          ),
        );
      }),
    );
  }
}