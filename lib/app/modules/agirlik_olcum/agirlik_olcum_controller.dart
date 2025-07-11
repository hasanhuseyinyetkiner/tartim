import 'package:tartim/app/data/models/hayvan_agirlik.dart';
import 'package:tartim/app/data/models/olcum_tipi.dart';
import 'package:tartim/app/services/api/weight_measurement_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AgirlikOlcumController extends GetxController {
  final WeightMeasurementApiService apiService;
  final GetStorage storage = GetStorage();

  AgirlikOlcumController({required this.apiService});

  // Kullanıcı ID'si
  final RxInt userId = 0.obs;

  // Ölçüm listesi ve yükleme durumu
  final RxList<HayvanAgirlik> hayvanListesi = <HayvanAgirlik>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;

  // Sıralama seçenekleri
  final Rx<OlcumTipi> secilenOlcumTipi = OlcumTipi.normal.obs;
  final RxString secilenSiralama = 'agirlik_azalan'.obs;

  // Seçilen hayvan
  final Rx<HayvanAgirlik?> secilenHayvan = Rx<HayvanAgirlik?>(null);

  @override
  void onInit() {
    super.onInit();
    // Kullanıcı ID'sini getir
    userId.value = storage.read('userId') ?? 1;
    // Hayvan listesini yükle
    fetchRfidListesi();
  }

  // RFID listesini getir
  Future<void> fetchRfidListesi() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await apiService.getKullaniciRfidListesi(userId.value);
      if (response.error == null && response.data != null) {
        final List<dynamic> rfidData = response.data!;
        hayvanListesi.assignAll(rfidData
            .map((data) => HayvanAgirlik.fromMap(data as Map<String, dynamic>))
            .toList());
      } else {
        errorMessage.value = response.error?.message ?? 'Veri alınamadı';
      }
    } catch (e) {
      errorMessage.value = 'RFID listesi alınırken hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Sıralı listeyi getir
  Future<void> fetchSiraliListe() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await apiService.getSiraliListele(userId.value,
          secilenOlcumTipi.value.value.toString(), secilenSiralama.value);

      if (response.error == null && response.data != null) {
        final List<dynamic> siraliData = response.data!;
        hayvanListesi.assignAll(siraliData
            .map((data) => HayvanAgirlik.fromMap(data as Map<String, dynamic>))
            .toList());
      } else {
        errorMessage.value = response.error?.message ?? 'Veri alınamadı';
      }
    } catch (e) {
      errorMessage.value = 'Sıralı liste alınırken hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Sıralama değiştir
  void changeSorting(String siralama) {
    secilenSiralama.value = siralama;
    fetchSiraliListe();
  }

  // Ölçüm tipi değiştir
  void changeOlcumTipi(OlcumTipi olcumTipi) {
    secilenOlcumTipi.value = olcumTipi;
    fetchSiraliListe();
  }

  // Hayvan detayı getir
  Future<void> getHayvanDetay(String rfid) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await apiService.getHayvanOlcumleri(rfid);
      if (response.error == null && response.data != null) {
        secilenHayvan.value = HayvanAgirlik.fromMap(response.data!);
      } else {
        errorMessage.value =
            response.error?.message ?? 'Hayvan detayı alınamadı';
      }
    } catch (e) {
      errorMessage.value = 'Hayvan detayı alınırken hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Ölçüm ekle veya güncelle
  Future<bool> olcumEkleGuncelle(
      String rfid, OlcumTipi olcumTipi, double agirlik, DateTime tarih) async {
    isProcessing.value = true;
    errorMessage.value = '';

    try {
      final response = await apiService.olcumEkleGuncelle(
          rfid, olcumTipi.value.toString(), agirlik, tarih);

      if (response.error == null) {
        // İşlem başarılı, yeni listeyi yükle
        await getHayvanDetay(rfid);
        await fetchSiraliListe();
        return true;
      } else {
        errorMessage.value = response.error?.message ?? 'Ölçüm eklenemedi';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Ölçüm eklenirken hata: $e';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // Ölçüm sil
  Future<bool> olcumSil(String rfid, OlcumTipi olcumTipi) async {
    isProcessing.value = true;
    errorMessage.value = '';

    try {
      final response =
          await apiService.olcumSil(rfid, olcumTipi.value.toString());

      if (response.error == null) {
        // İşlem başarılı, yeni listeyi yükle
        await getHayvanDetay(rfid);
        await fetchSiraliListe();
        return true;
      } else {
        errorMessage.value = response.error?.message ?? 'Ölçüm silinemedi';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Ölçüm silinirken hata: $e';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // Ölçüm silme onay dialogu göster
  Future<bool> showDeleteConfirmation(
      BuildContext context, String rfid, OlcumTipi olcumTipi) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ölçüm Silme'),
            content: Text(
                '${olcumTipi.displayName} ölçümünü silmek istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sil'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
