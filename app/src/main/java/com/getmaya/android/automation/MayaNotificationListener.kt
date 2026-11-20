package com.getmaya.android.automation

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class MayaNotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn ?: return
        val pkg = sbn.packageName ?: ""
        val extras = sbn.notification?.extras ?: return
        val title = extras.getString("android.title") ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""

        if (pkg.contains("whatsapp") || pkg.contains("telegram") || pkg.contains("dialer")) {
            Log.d("MayaNotification", "[$pkg] $title: $text")
            synchronized(recentNotifications) {
                recentNotifications.add(0, NotificationItem(pkg, title, text, System.currentTimeMillis()))
                if (recentNotifications.size > 50) recentNotifications.removeLast()
            }
        }
    }

    data class NotificationItem(
        val packageName: String,
        val sender: String,
        val content: String,
        val timestamp: Long
    )

    companion object {
        val recentNotifications = mutableListOf<NotificationItem>()

        fun getLatestFor(keyword: String): List<NotificationItem> {
            synchronized(recentNotifications) {
                return recentNotifications.filter {
                    it.packageName.contains(keyword, ignoreCase = true) ||
                    it.sender.contains(keyword, ignoreCase = true) ||
                    it.content.contains(keyword, ignoreCase = true)
                }
            }
        }
    }
}
