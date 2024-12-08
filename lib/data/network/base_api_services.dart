abstract class BaseApiServices {
  Future<dynamic> getApiResponses(String endpoint);
  Future<dynamic> postApiResponses(String url, dynamic data);
}
