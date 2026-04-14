package com.forgefit.forgefit

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.view.WindowManager

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    // Remove keyboard animation delay
    window.setSoftInputMode(
      WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE or
      WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE
    )
  }
}
