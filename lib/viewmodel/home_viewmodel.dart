import 'package:flutter/material.dart';
import 'package:depd_week7/data/response/api_response.dart';
import 'package:depd_week7/model/city.dart';
import 'package:depd_week7/model/model.dart';
import 'package:depd_week7/model/costs/cost_calculate.dart';
import 'package:depd_week7/repository/home_repository.dart';

class HomeViewmodel with ChangeNotifier {
  final HomeRepository _homeRepo = HomeRepository();

  ApiResponse<List<Province>> provinceList = ApiResponse.loading();

  void setProvinceList(ApiResponse<List<Province>> response) {
    provinceList = response;
    notifyListeners();
  }


  Future<void> getProvinceList() async {
    setProvinceList(ApiResponse.loading());
    try {
      final provinces = await _homeRepo.fetchProvinceList();
      setProvinceList(ApiResponse.completed(provinces));
    } catch (e) {
      setProvinceList(ApiResponse.error(e.toString()));
    }
  }

  ApiResponse<List<City>> originCityList = ApiResponse.completed([]);

  // Origin City List
  void setOriginCityList(ApiResponse<List<City>> response) {
    originCityList = response;
    notifyListeners();
  }

  Future<void> getOriginCityList(String provinceId) async {
    setOriginCityList(ApiResponse.loading());
    try {
      final cities = await _homeRepo.fetchCityList(provinceId);
      setOriginCityList(ApiResponse.completed(cities));
    } catch (e) {
      setOriginCityList(ApiResponse.error(e.toString()));
    }
  }

  ApiResponse<List<City>> destinationCityList = ApiResponse.completed([]);

  // Destination City List
  void setDestinationCityList(ApiResponse<List<City>> response) {
    destinationCityList = response;
    notifyListeners();
  }

  Future<void> getDestinationCityList(String provinceId) async {
    setDestinationCityList(ApiResponse.loading());
    try {
      final cities = await _homeRepo.fetchCityList(provinceId);
      setDestinationCityList(ApiResponse.completed(cities));
    } catch (e) {
      setDestinationCityList(ApiResponse.error(e.toString()));
    }
  }

    ApiResponse<CostCalculate> cost = ApiResponse.loading();

  // Cost Calculation
  void setCost(ApiResponse<CostCalculate> response) {
    cost = response;
    notifyListeners();
  }

  Future<void> calculateCost({
    required String origin,
    required String destination,
    required int weight,
    required String courier,
  }) async {
    setCost(ApiResponse.loading());
    try {
      final costResponse = await _homeRepo.calculateCost(
        citySenderId: origin,
        cityReceiverId: destination,
        weight: weight,
        courier: courier,
      );
      setCost(ApiResponse.completed(costResponse));
    } catch (e) {
      setCost(ApiResponse.error(e.toString()));
    }
  }
}