import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDxOAU4fKpJ6CGZ26-jV_VQl4IbVdG-FFI',
      appId: '1:425680522376:android:e60ad100709e29106b233d',
      messagingSenderId: '425680522376',
      projectId: 'b-tech-e6556',
      authDomain: 'b-tech-e6556.firebaseapp.com',
      databaseURL:
          'https://b-tech-e6556-default-rtdb.asia-southeast1.firebasedatabase.app',
      storageBucket: 'b-tech-e6556.firebasestorage.app',
    );
  }
}
