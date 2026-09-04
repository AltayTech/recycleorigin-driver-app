# Geolocator foreground location service (Play FGS location).
-keep class com.baseflow.geolocator.** { *; }

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core / in-app updates (used by app)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Firebase Auth and Google Sign-In.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase SDKs use Gson reflection for some internal models.
-keep class com.google.gson.** { *; }
-keep class sun.misc.Unsafe { *; }
-keepattributes Signature
-keepattributes *Annotation*
