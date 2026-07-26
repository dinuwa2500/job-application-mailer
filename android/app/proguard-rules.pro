## Flutter wrapper rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugin.editing.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.plugin.platform.** { *; }
-dontwarn io.flutter.embedding.**

## Prevent R8 stripping generated plugins
-keep class com.email.sender.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class com.sidloder.flutter_email_sender.** { *; }
