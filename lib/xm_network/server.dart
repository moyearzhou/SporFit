import 'package:framework/xm_mvvm.dart/model/hot.dart';

import '../xm_utils/utils.dart';
import 'api.dart';
import 'http_manager.dart';

class Z6Srv {
  static Future<Hot?> queryHot(String position, key) async {
    try {
      final Map<dynamic, dynamic> hotJsonDynamic = await Z6HttpManager.get(Api.hot, params: {
        "feedType": "hot",
        "needCommentInfo": "1" as String,
        "needFavoriteInfo": "1" as String,
        "needLikeInfo": "1" as String,
        "needRelationInfo": "1" as String,
        "position": position ?? "0",
        "sort": "byTime",
        "keyword": key
      });
      final Map<String, dynamic> hotJson = Map<String, dynamic>.from(hotJsonDynamic);
      return Hot.fromJson(hotJson);
    } catch (e) {
      print(e.toString());
      Toast.show(e.toString());
      return null;
    }
  }
}
