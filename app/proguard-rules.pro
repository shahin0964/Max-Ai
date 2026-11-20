# Maya AI Assistant Proguard rules
-keep class com.getmaya.android.data.** { *; }
-keepclassmembers class * extends androidx.room.RoomDatabase { *; }
-keep class com.getmaya.android.agentic.** { *; }
-keep class com.getmaya.android.automation.** { *; }
-keep class com.getmaya.android.termux.** { *; }
