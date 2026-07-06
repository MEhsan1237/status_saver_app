package com.senior.status_saver

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.DocumentsContract
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.senior.status_saver/saf"
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openFolderPicker" -> {
                    val initialPath = call.argument<String>("initialPath")
                    openFolderPicker(initialPath, result)
                }
                "checkFolderPermission" -> {
                    val uriString = call.argument<String>("uri")
                    result.success(checkFolderPermission(uriString))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openFolderPicker(initialPath: String?, result: MethodChannel.Result) {
        pendingResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && initialPath != null) {
                val uri = Uri.parse(initialPath)
                putExtra(DocumentsContract.EXTRA_INITIAL_URI, uri)
            }
        }
        startActivityForResult(intent, 1001)
    }

    private fun checkFolderPermission(uriString: String?): Boolean {
        if (uriString == null) return false
        return try {
            val uri = Uri.parse(uriString)
            val persistedUriPermissions = contentResolver.persistedUriPermissions
            persistedUriPermissions.any { it.uri == uri && it.isReadPermission }
        } catch (e: Exception) {
            false
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1001) {
            if (resultCode == Activity.RESULT_OK) {
                val uri: Uri? = data?.data
                if (uri != null) {
                    contentResolver.takePersistableUriPermission(
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION
                    )
                    pendingResult?.success(uri.toString())
                } else {
                    pendingResult?.error("NULL_URI", "Folder URI was null", null)
                }
            } else {
                pendingResult?.error("CANCELLED", "User cancelled folder picker", null)
            }
            pendingResult = null
        }
    }
}
