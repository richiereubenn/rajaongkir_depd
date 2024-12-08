part of 'pages.dart';

class CostPage extends StatefulWidget {
  const CostPage({super.key});

  @override
  State<CostPage> createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {
  bool isLoading = false; 

  List<String> couriers = ['jne', 'pos', 'tiki'];
  String? kurirTerpilih;
  dynamic provinsiAsalTerpilih;
  dynamic provinsiDestinasiTerpilih;
  dynamic kotaAsalTerpilih;
  dynamic kotaDestinasiTerpilih;

  late HomeViewmodel homeViewmodel;
  final weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    homeViewmodel = HomeViewmodel();
    homeViewmodel.getProvinceList();
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => homeViewmodel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calculate Shipping Cost'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _weightAndCourier(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _dropdown(
                      title: 'Asal',
                      selectedProvince: provinsiAsalTerpilih,
                      selectedCity: kotaAsalTerpilih,
                      onProvinceChanged: (newValue) {
                        setState(() {
                          provinsiAsalTerpilih = newValue;
                          kotaAsalTerpilih = null;
                          homeViewmodel.getOriginCityList(provinsiAsalTerpilih!.provinceId);
                        });
                      },
                      onCityChanged: (newValue) {
                        setState(() {
                          kotaAsalTerpilih = newValue;
                        });
                      },
                      cityList: homeViewmodel.originCityList,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _dropdown(
                      title: 'Tujuan',
                      selectedProvince: provinsiDestinasiTerpilih,
                      selectedCity: kotaDestinasiTerpilih,
                      onProvinceChanged: (newValue) {
                        setState(() {
                          provinsiDestinasiTerpilih = newValue;
                          kotaDestinasiTerpilih = null;
                          homeViewmodel.getDestinationCityList(provinsiDestinasiTerpilih!.provinceId);
                        });
                      },
                      onCityChanged: (newValue) {
                        setState(() {
                          kotaDestinasiTerpilih = newValue;
                        });
                      },
                      cityList: homeViewmodel.destinationCityList,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _button(),
              const SizedBox(height: 20),
              _card(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weightAndCourier() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kurir',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: kurirTerpilih,
          hint: const Text('Pilih'),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          ),
          items: couriers.map((courier) {
            return DropdownMenuItem<String>(
              value: courier,
              child: Text(courier.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              kurirTerpilih = value;
            });
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Berat (gram)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Masukkan berat barang',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _dropdownProvince({
    required dynamic selectedProvince,
    required ApiResponse<List<Province>> provinceList,
    required Function(dynamic) onChanged,
  }) {
    if (provinceList.status == Status.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (provinceList.status == Status.error) {
      return Center(child: Text(provinceList.message ?? 'Error loading provinces'));
    } else if (provinceList.status == Status.completed) {
      return DropdownButtonFormField<dynamic>(
        isExpanded: true,
        value: selectedProvince,
        hint: const Text('Select Province'),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        ),
        items: provinceList.data!.map((province) {
          return DropdownMenuItem<dynamic>(
            value: province,
            child: Text(province.province ?? ''),
          );
        }).toList(),
        onChanged: onChanged,
      );
    }
    return Container();
  }

  Widget _dropdownCity({
    required dynamic selectedCity,
    required ApiResponse<List<City>> cityList,
    required Function(dynamic) onChanged,
  }) {
    if (cityList.status == Status.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (cityList.status == Status.error) {
      return Center(child: Text(cityList.message ?? 'Error loading cities'));
    } else if (cityList.status == Status.completed) {
      return DropdownButtonFormField<dynamic>(
        isExpanded: true,
        value: selectedCity,
        hint: const Text('Pilih Kota'),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        ),
        items: cityList.data!.map((city) {
          return DropdownMenuItem<dynamic>(
            value: city,
            child: Text('${city.cityName} (${city.type})'),
          );
        }).toList(),
        onChanged: onChanged,
      );
    }
    return Container();
  }

  

  Widget _button() {
    final canCalculate = kotaAsalTerpilih != null &&
        kotaDestinasiTerpilih != null &&
        kurirTerpilih != null &&
        weightController.text.isNotEmpty;

    return ElevatedButton(
      onPressed: canCalculate
          ? () {
              setState(() {
                isLoading = true; // Menandakan loading dimulai
              });
              homeViewmodel.calculateCost(
                origin: kotaAsalTerpilih!.cityId,
                destination: kotaDestinasiTerpilih!.cityId,
                weight: int.parse(weightController.text),
                courier: kurirTerpilih!,
              ).then((_) {
                setState(() {
                  isLoading = false; // Menandakan loading selesai
                });
              });
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canCalculate ? Colors.blue : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        minimumSize: Size(double.infinity, 50),
        shadowColor: Colors.black,
        elevation: 2,
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Hitung Estimasi Harga',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _dropdown({
    required String title,
    required dynamic selectedProvince,
    required dynamic selectedCity,
    required Function(dynamic) onProvinceChanged,
    required Function(dynamic) onCityChanged,
    required ApiResponse<List<City>> cityList,
  }) {
    return Consumer<HomeViewmodel>(
      builder: (context, viewModel, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title Province',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _dropdownProvince(
              selectedProvince: selectedProvince,
              provinceList: viewModel.provinceList,
              onChanged: onProvinceChanged,
            ),
            const SizedBox(height: 10),
            if (selectedProvince != null) ...[
              Text(
                '$title City',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _dropdownCity(
                selectedCity: selectedCity,
                cityList: cityList,
                onChanged: onCityChanged,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _card() {
  return Consumer<HomeViewmodel>(
    builder: (context, viewModel, _) {
      if (viewModel.cost.status == Status.loading) {
        return const Center(child: Text("Tidak ada data"));
      } else if (viewModel.cost.status == Status.error) {
        return Center(child: Text(viewModel.cost.message ?? 'Error fetching cost'));
      } else if (viewModel.cost.status == Status.completed) {
        final costs = viewModel.cost.data?.costs;
        if (costs != null && costs.isNotEmpty) {
          return Column(
            children: costs.map((cost) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 5,  // Memberikan efek bayangan pada card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Sudut yang lebih membulat
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),  // Menambahkan padding di dalam card
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cost.service ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Estimasi sampai: ${cost.cost?[0].etd ?? '-'} hari',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rp ${cost.cost?[0].value ?? 0}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent, // Menonjolkan harga dengan warna biru
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.arrow_forward_ios, // Ikon kecil untuk memberi tanda aksi
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
        return const Center(child: Text('No cost data available.'));
      }
      return Container();
    },
  );
}

  }
