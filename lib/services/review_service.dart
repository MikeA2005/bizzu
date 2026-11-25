import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bizzu/models/review_model.dart';

// Servicio remoto para consultar y registrar reseñas de productos.
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final CollectionReference _reviewsRef = FirebaseFirestore.instance.collection(
    'reviews',
  );

  /// Stream en tiempo real de las reseñas de un producto
  Stream<List<ReviewModel>> getReviewsStreamByProductId(String productId) {
    return _reviewsRef.where('productId', isEqualTo: productId).snapshots().map(
      (snapshot) {
        final reviews = snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList();
        reviews.sort((a, b) => b.date.compareTo(a.date));
        return reviews;
      },
    );
  }

  /// Calcula el promedio a partir de la lista recibida por el Stream
  double calculateAverageRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0.0, (double sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  /// Registrar una nueva reseña en Firestore
  Future<void> addReview({
    required String productId,
    required String authorId,
    required double rating,
    required String comment,
  }) async {
    final newReview = ReviewModel(
      id: '',
      productId: productId,
      authorId: authorId,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );
    await _reviewsRef.add(newReview.toMap());
  }
}
