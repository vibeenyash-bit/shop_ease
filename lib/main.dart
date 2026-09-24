import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/connectivity_service.dart';
import 'services/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final storage = await Storage.open();
  final connectivity = ConnectivityService();
  await connectivity.init();

  runApp(ShopEaseApp(storage: storage, connectivity: connectivity));
}
