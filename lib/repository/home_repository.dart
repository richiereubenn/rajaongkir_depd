import 'package:depd_week7/data/app_exception.dart';
import 'package:depd_week7/data/network/network_api_services.dart';
import 'package:depd_week7/model/city.dart';
import 'package:depd_week7/model/model.dart';
import 'package:depd_week7/model/costs/cost_calculate.dart';

class HomeRepository {
  final _apiServices = NetworkApiServices();

  Future<List<Province>> fetchProvinceList() async {
    try {
      dynamic response = await _apiServices.getApiResponses('starter/province');
      List<Province> result = [];

      if (response['rajaongkir']['status']['code'] == 200) {
        result = (response['rajaongkir']['results'] as List)
            .map((e) => Province.fromJson(e))
            .toList();
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<City>> fetchCityList(var provId) async {
    try {
      dynamic response = await _apiServices.getApiResponses('starter/city');
      List<City> result = [];

      if (response['rajaongkir']['status']['code'] == 200) {
        result = (response['rajaongkir']['results'] as List)
            .map((e) => City.fromJson(e))
            .toList();
      }
      List<City> selectedCities = [];
      for(var c in result){
        if(c.provinceId == provId){
          selectedCities.add(c);
        }
      }
      return selectedCities;
    } catch (e) {
      rethrow;
    }
  }


  Future<CostCalculate> calculateCost({
    required String citySenderId,
    required String cityReceiverId,
    required int weight,
    required String courier,
  }) async {
    try {
      dynamic response = await _apiServices.postApiResponses('/starter/cost', {
        "origin": citySenderId,
        "destination": cityReceiverId,
        "weight": weight.toString(),
        "courier": courier,
      });

      if (response['rajaongkir']['status']['code'] == 200) {
        if ((response['rajaongkir']['results'] as List).isNotEmpty) {
          return CostCalculate.fromJson(response['rajaongkir']['results'][0]);
        }
        throw FetchDataException('No cost data found');
      }
      throw FetchDataException('Something went wrong');
    } catch (e) {
      print("Error calculating cost: $e");
      throw e;
    }
  }
}

