import 'package:framework/xm_mvvm.dart/model/hot.dart';

import '../xm_utils/utils.dart';
import 'api.dart';
import 'http_manager.dart';

class Z6Srv {
  static Future<Hot> queryHot(String position, key) async {
    try {
      Map<String, dynamic> hotJson = await Z6HttpManager.get(Api.hot, params: {
        "feedType": "hot",
        "needCommentInfo": "1",
        "needFavoriteInfo": "1",
        "needLikeInfo": "1",
        "needRelationInfo": "1",
        "position": position ?? "0",
        "sort": "byTime",
        "keyword": key
      });
      return Hot.fromJson(hotJson);
    } catch (e) {
      print(e.toString());
      Toast.show(e.toString());
      return null;
    }
  }
}
