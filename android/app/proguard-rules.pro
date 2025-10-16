# Keep ML Kit classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Ignore missing classes for optional ML Kit languages
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep text recognition classes
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }

# Keep Flutter classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
