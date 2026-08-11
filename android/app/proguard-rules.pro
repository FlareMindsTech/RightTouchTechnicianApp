# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Models / JSON Serialization
# Keep your data models to prevent R8 from stripping them or renaming fields
-keep class com.righttouchpartner.app.data.models.** { *; }
-keepclassmembers class com.righttouchpartner.app.data.models.** { *; }

# Dio / Retrofit (if used)
-keepattributes Signature, InnerClasses, EnclosingMethod
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }

# Socket.io / Engine.io
-keep class io.socket.** { *; }
-keep class io.engine.io.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# MapTiler / Mapbox (if native code is used)
-keep class com.maptiler.** { *; }

# Fix for R8 Missing Play Core classes
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
