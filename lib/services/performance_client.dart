import 'package:firebase_performance/firebase_performance.dart';
import 'package:http/http.dart';

class PerformanceHttpClient extends BaseClient {
  final Client _httpClient = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    HttpMethod method = HttpMethod.Get;
    switch (request.method) {
      case "GET":
        method = HttpMethod.Get;
        break;
      case "POST":
        method = HttpMethod.Post;
        break;
      case "PUT":
        method = HttpMethod.Put;
        break;
      case "DELETE":
        method = HttpMethod.Delete;
        break;
      case "PATCH":
        method = HttpMethod.Patch;
        break;
      case "HEAD":
        method = HttpMethod.Head;
        break;
      case "OPTIONS":
        method = HttpMethod.Options;
        break;
      case "TRACE":
        method = HttpMethod.Trace;
        break;
      case "CONNECT":
        method = HttpMethod.Connect;
        break;
      default:
        method = HttpMethod.Get;
        break;
    }
    final HttpMetric metric = FirebasePerformance.instance
        .newHttpMetric(request.url.toString(), method);
    metric.start();
    try {
      final response = await _httpClient.send(request);
      String contentType = response.headers["content-type"] != null
          ? response.headers["content-type"]!
          : response.headers["Content-Type"] != null
              ? response.headers["Content-Type"]!
              : "";
      metric
        ..responsePayloadSize = response.contentLength
        ..responseContentType = contentType
        ..requestPayloadSize = request.contentLength?.toInt() ?? 0
        ..httpResponseCode = response.statusCode;
      return response;
    } finally {
      metric.stop();
    }
  }
}
