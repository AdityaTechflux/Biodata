
// // package com.iw.lagnbiodatarmarathi

// // import io.flutter.embedding.android.FlutterActivity
// // import io.flutter.embedding.engine.FlutterEngine
// // import io.flutter.plugins.GeneratedPluginRegistrant
// // import androidx.annotation.NonNull

// // class MainActivity: FlutterActivity() {
// //     override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
// //         GeneratedPluginRegistrant.registerWith(flutterEngine)
// //     }
// // }


// 28/1/25
// # Flutter Wrapper
// -keep class io.flutter.app.** { *; }
// -keep class io.flutter.plugin.**  { *; }
// -keep class io.flutter.util.**  { *; }
// -keep class io.flutter.view.**  { *; }
// -keep class io.flutter.** { *; }
// -keep class io.flutter.plugins.** { *; }

// # Razorpay
// -keepclassmembers class * implements com.razorpay.PaymentResultWithDataListener {
//     public void onPaymentSuccess(String, com.razorpay.PaymentData);
//     public void onPaymentError(int, String, com.razorpay.PaymentData);
// }
// -keep class com.razorpay.** { *; }
// -keep interface com.razorpay.** { *; }
// -dontwarn com.razorpay.**

// # Google Pay
// -keep class com.google.android.gms.** { *; }
// -dontwarn com.google.android.gms.**
// -keep class com.google.android.apps.nbu.paisa.inapp.** { *; }
// -dontwarn com.google.android.apps.nbu.paisa.inapp.**

// # Basic Android
// -keepattributes *Annotation*
// -keepattributes SourceFile,LineNumberTable
// -keep public class * extends java.lang.Exception
// -keep class androidx.** { *; }

// # Keep native methods
// -keepclasseswithmembers class * {
//     native <methods>;
// }

// # Keep Activities, Services, etc.
// -keep public class * extends android.app.Activity
// -keep public class * extends android.app.Service
// -keep public class * extends android.content.BroadcastReceiver
// -keep public class * extends android.content.ContentProvider
// -keep public class * extends android.app.backup.BackupAgentHelper
// -keep public class * extends android.preference.Preference

// # Gson
// -keepattributes Signature
// -keep class sun.misc.Unsafe { *; }
// -keep class com.google.gson.** { *; }
// -keep class * implements com.google.gson.TypeAdapterFactory
// -keep class * implements com.google.gson.JsonSerializer
// -keep class * implements com.google.gson.JsonDeserializer

// # Google Play Services
// -keep class com.google.android.play.core.splitcompat.** { *; }
// -dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
// -keep public class com.google.android.gms.common.internal.safeparcel.SafeParcelable {
//     public static final *** NULL;
// }

// # Multidex
// -keep class com.google.android.material.** { *; }
// -dontwarn com.google.android.material.**
// -keep class androidx.multidex.** { *; }