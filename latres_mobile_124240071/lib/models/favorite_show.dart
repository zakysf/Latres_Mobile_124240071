import 'package:hive/hive.dart';

part 'favorite_show.g.dart';

/// Model untuk menyimpan Show TV ke Hive Local Database
/// typeId: 0 adalah identifier unik untuk model ini di Hive
@HiveType(typeId: 0)
class FavoriteShow extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? imageUrl;

  @HiveField(3)
  final String rating;

  @HiveField(4)
  final String? genres;

  FavoriteShow({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.rating,
    this.genres,
  });
}
