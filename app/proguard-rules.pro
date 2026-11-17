# AuraVoice Proguard rules
-keep class com.auravoice.assistant.data.** { *; }
-keepclassmembers class * extends androidx.room.RoomDatabase { *; }
