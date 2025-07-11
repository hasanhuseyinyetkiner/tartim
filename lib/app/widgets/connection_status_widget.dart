import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tartim/app/services/sync_service.dart';

/// Bağlantı durumunu gösteren ve senkronizasyon işlemini başlatma imkanı sağlayan widget
class ConnectionStatusWidget extends StatelessWidget {
  final RxBool isOnline;
  final RxBool isSyncing;
  final VoidCallback onSync;
  final bool showPendingCount;

  const ConnectionStatusWidget({
    Key? key,
    required this.isOnline,
    required this.isSyncing,
    required this.onSync,
    this.showPendingCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Bekleyen işlem sayısını al
      int pendingCount = 0;
      if (showPendingCount && Get.isRegistered<SyncService>()) {
        pendingCount = Get.find<SyncService>().getPendingOperationsCount();
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOnline.value
              ? Colors.green.withOpacity(0.8)
              : Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOnline.value ? Icons.cloud_done : Icons.cloud_off,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(width: 5),
            Text(
              isOnline.value ? 'Çevrimiçi' : 'Çevrimdışı',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            if (pendingCount > 0) ...[
              SizedBox(width: 5),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$pendingCount',
                  style: TextStyle(
                    color: isOnline.value ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (!isOnline.value || pendingCount > 0) ...[
              SizedBox(width: 5),
              InkWell(
                onTap: isSyncing.value ? null : onSync,
                child: isSyncing.value
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.sync,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

/// Daha kompakt bir bağlantı göstergesi (sadece simge)
class ConnectionStatusIcon extends StatelessWidget {
  final RxBool isOnline;
  final RxBool isSyncing;
  final VoidCallback onSync;

  const ConnectionStatusIcon({
    Key? key,
    required this.isOnline,
    required this.isSyncing,
    required this.onSync,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Bekleyen işlem sayısını al
      int pendingCount = 0;
      if (Get.isRegistered<SyncService>()) {
        pendingCount = Get.find<SyncService>().getPendingOperationsCount();
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(
              isOnline.value ? Icons.cloud_done : Icons.cloud_off,
              color: isOnline.value ? Colors.green : Colors.red,
            ),
            onPressed: isSyncing.value ? null : onSync,
          ),
          if (isSyncing.value)
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isOnline.value ? Colors.green : Colors.red,
              ),
            ),
          if (pendingCount > 0)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$pendingCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
