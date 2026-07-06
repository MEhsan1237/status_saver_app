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
import androidx.documentfile.provider.DocumentFile

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
                "listStatusFiles" -> {
                    val uriString = call.argument<String>("uri")
                    listStatusFiles(uriString, result)
                }
                "getFileContent" -> {
                    val uriString = call.argument<String>("uri")
                    getFileContent(uriString, result)
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

    private fun listStatusFiles(uriString: String?, result: MethodChannel.Result) {
        if (uriString == null) {
            result.error("INVALID_ARGUMENT", "URI string is null", null)
            return
        }
        try {
            val directoryUri = Uri.parse(uriString)
            val root = DocumentFile.fromTreeUri(this, directoryUri)
            val filesList = mutableListOf<Map<String, String>>()
            
            root?.listFiles()?.forEach { file ->
                if (file.isFile) {
                    val map = mapOf(
                        "name" to (file.name ?: ""),
                        "uri" to file.uri.toString()
                    )
                    filesList.add(map)
                }
            }
            result.success(filesList)
        } catch (e: Exception) {
            result.error("LIST_ERROR", e.message, null)
        }
    }

    private fun getFileContent(uriString: String?, result: MethodChannel.Result) {
        if (uriString == null) {
            result.error("INVALID_ARGUMENT", "URI string is null", null)
            return
        }
        try {
            val fileUri = Uri.parse(uriString)
            contentResolver.openInputStream(fileUri)?.use { inputStream ->
                val bytes = inputStream.readBytes()
                result.success(bytes)
            } ?: result.error("OPEN_ERROR", "Could not open input stream", null)
        } catch (e: Exception) {
            result.error("READ_ERROR", e.message, null)
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
