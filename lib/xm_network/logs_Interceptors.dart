import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HttpLogsInterceptors extends InterceptorsWrapper {
  @override
  onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint("请求baseUrl：${options.baseUrl}");
    debugPrint("请求url：${options.path}");
    debugPrint('请求头: ' + options.headers.toString());
    if (options.data != null) {
      debugPrint('请求参数: ' + options.data.toString());
    }
    return handler.next(options); // 继续请求流程
  }

  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response != null) {
      debugPrint('响应数据: ${response.data}');
    }
    return handler.next(response); // 继续响应流程
  }

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    debugPrint('请求异常: ' + err.toString());
    debugPrint('请求异常信息: ' + err.response!.toString() ?? "");
    return handler.next(err); // 继续错误处理
  }
}