package com.getmaya.android.termux

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle

class TermuxPermissionActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Check or request Termux permissions
        finish()
    }
}
