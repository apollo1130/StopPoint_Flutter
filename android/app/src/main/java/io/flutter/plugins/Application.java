package io.flutter.plugins;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.GeneratedPluginRegistrant;
// import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;
// import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService;

public class Application extends FlutterApplication implements PluginRegistrantCallback {
  // ...
  @Override
  public void onCreate() {
    super.onCreate();
    FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this);
  }

  @Override
  public void registerWith(PluginRegistry registry) {
    // GeneratedPluginRegistrant.registerWith(registry);
  }
  // ...
}
// public class Application extends FlutterApplication implements PluginRegistrantCallback {
//     @Override
//     public void onCreate() {
//         super.onCreate();
//         FlutterFirebaseMessagingService.setPluginRegistrant(this);
//     }

//     @Override
//     public void registerWith(PluginRegistry registry) {
//         FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
//     }
// }