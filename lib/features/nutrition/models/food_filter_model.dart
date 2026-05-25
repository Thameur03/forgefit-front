/// Model for admin-managed food search filters.
/// Comes from GET /food/filters (active filters only).
class FoodFilterModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? defaultQuery;
  final List<String> includeKeywords;
  final List<String> excludeKeywords;
  final bool isActive;
  final int sortOrder;

  const FoodFilterModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.defaultQuery,
    this.includeKeywords = const [],
    this.excludeKeywords = const [],
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory FoodFilterModel.fromJson(Map<String, dynamic> json) {
    return FoodFilterModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      defaultQuery: json['default_query'] as String?,
      includeKeywords: ((json['include_keywords'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      excludeKeywords: ((json['exclude_keywords'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
