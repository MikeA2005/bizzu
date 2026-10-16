import 'package:flutter/material.dart';
import 'package:bizzu/models/review_model.dart';

class ReviewService extends ChangeNotifier {
  // Singleton pattern, so we can access the same instance of ReviewService throughout the app
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  // Review data
  final List<ReviewModel> _reviews = [
    ReviewModel(
      id: '1',
      productId: '1',
      authorId: '1',
      rating: 5.0,
      comment: '¡Excelente pizza! Muy sabrosa y con ingredientes frescos.',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ReviewModel(
      id: '2',
      productId: '2',
      authorId: '2',
      rating: 4.0,
      comment: 'La hamburguesa estaba buena, pero un poco grasosa.',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // Get reviews by product ID
  List<ReviewModel> getReviewsByProductId(String productId) {
    return _reviews.where((r) => r.productId == productId).toList();
  }

  // Calculate average rating for a product
  double getAverageRating(String productId) {
    final productReviews = getReviewsByProductId(productId);
    if (productReviews.isEmpty) return 0.0;
    final totalRating = productReviews.fold<double>(
      0.0,
      (sum, r) => sum + r.rating,
    );
    return totalRating / productReviews.length;
  }

  // Add a new review
  void addReview({
    required String productId,
    required String authorId,
    required double rating,
    required String comment,
  }) {
    final newReview = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: productId,
      authorId: authorId,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );
    _reviews.insert(0, newReview);
    notifyListeners();
  }
}
