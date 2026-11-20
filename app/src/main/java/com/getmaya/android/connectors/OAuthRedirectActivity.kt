package com.getmaya.android.connectors

import android.app.Activity
import android.os.Bundle

class OAuthRedirectActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Handle OAuth callback token
        finish()
    }
}
