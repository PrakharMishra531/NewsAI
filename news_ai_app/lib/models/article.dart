class Article {
  final String id;
  final String sourceUrl;
  final String summaryText;
  final String? imageUrl;

  Article({
    required this.id,
    required this.sourceUrl,
    required this.summaryText,
    this.imageUrl,
  });

  // This is a factory constructor.
  // It's a special constructor for creating an instance from a data source,
  // in our case, a JSON map.
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      sourceUrl: json['source_url'] as String,
      summaryText: json['summary_text'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }
}