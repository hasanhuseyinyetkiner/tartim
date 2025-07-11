import 'package:tartim/yeni/models/user_device.dart';
import 'package:get/get.dart';

class ApiService extends GetxService {
  Future<List<UserDevice>> getUserDevices(String deviceType) async {
    // API'den kullanıcının belirli tipteki cihazlarını al
    await Future.delayed(Duration(seconds: 1)); // Simüle edilmiş ağ gecikmesi
    return [
      if (deviceType == 'weight')
        UserDevice(id: '1', name: 'Weight Scale 1', type: 'weight', macAddress: '8fa59861-4245-4c9c-81db-65262c3e204a'),
      if (deviceType == 'milk')
        UserDevice(id: '2', name: 'Milk Meter 1', type: 'milk', macAddress: '8fa59861-4245-4c9c-81db-65262c3e204a'),
    ];
  }
}