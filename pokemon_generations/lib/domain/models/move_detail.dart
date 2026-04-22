import 'package:freezed_annotation/freezed_annotation.dart';

part 'move_detail.freezed.dart';
part 'move_detail.g.dart';

@freezed
class MoveDetail with _$MoveDetail {
  const factory MoveDetail({
    required String name,
    required String type,
    required String damageClass,
    required int? power,
    required int? accuracy,
    required int pp,
    required String description,
  }) = _MoveDetail;

  factory MoveDetail.fromJson(Map<String, dynamic> json) => _$MoveDetailFromJson(json);
}
