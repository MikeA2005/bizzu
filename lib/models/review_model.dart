class ReviewModel {
  final String id;
  final String productId;
  final String authorId;
  final double rating;
  final String comment;
  final DateTime date;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.authorId,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
