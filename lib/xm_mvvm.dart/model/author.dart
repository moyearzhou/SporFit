import 'package:json_annotation/json_annotation.dart';

part 'author.g.dart';
@JsonSerializable()
class Author {
    Author();
    // 使用命名构造函数初始化所有非空字段
    // Author({
    //     required this.membershipSchema,
    //     required this.keepValue,
    //     required this.gender,
    //     required this.verifiedIconResourceIdWithSide,
    //     required this.bio,
    //     required this.memberStatus,
    //     required this.avatar,
    //     required this.maxKeepValue,
    //     required this.verifiedIconUrlWithSide,
    //     required this.kgLevel,
    //     required this.verifiedIconResourceId,
    //     required this.verifiedIconUrl,
    //     required this.verifyType,
    //     required this.username,
    // });
    String? membershipSchema;
    num? keepValue;
    String? gender;
    String? verifiedIconResourceIdWithSide;
    String? bio;
    num? memberStatus;
    String avatar = "";
    num? maxKeepValue;
    String? verifiedIconUrlWithSide;
    num? kgLevel;
    String? verifiedIconResourceId;
    String? verifiedIconUrl;
    num? verifyType;
    String? username;
    
    factory Author.fromJson(Map<String,dynamic> json) => _$AuthorFromJson(json);
    Map<String, dynamic> toJson() => _$AuthorToJson(this);
}