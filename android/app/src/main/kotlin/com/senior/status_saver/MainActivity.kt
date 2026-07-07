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
import android.media.MediaScannerConnection
import java.io.InputStream
import java.io.ByteArrayOutputStream
import java.util.ArrayList
import java.util.HashMap

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.senior.status_saver/saf"
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openFolderPicker") {
                val initialPath = call.argument<String>("initialPath")
                openFolderPicker(initialPath, result)
            } else if (call.method == "checkFolderPermission") {
                val uriString = call.argument<String>("uri")
                result.success(checkFolderPermission(uriString))
            } else if (call.method == "listStatusFiles") {
                val uriString = call.argument<String>("uri")
                listStatusFiles(uriString, result)
            } else if (call.method == "getFileContent") {
                val uriString = call.argument<String>("uri")
                getFileContent(uriString, result)
            } else if (call.method == "scanFile") {
                val path = call.argument<String>("path")
                if (path != null) {
                    MediaScannerConnection.scanFile(this, arrayOf(path), null, null)
                }
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun openFolderPicker(initialPath: String?, result: MethodChannel.Result) {
        pendingResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        intent.addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && initialPath != null) {
            try {
                val uri = Uri.parse(initialPath)
                intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, uri)
            } catch (e: Exception) {}
        }
        startActivityForResult(intent, 1001)
    }

    private fun checkFolderPermission(uriString: String?): Boolean {
        if (uriString == null) return false
        val permissions = contentResolver.persistedUriPermissions
        for (p in permissions) {
            if (p.uri.toString() == uriString && p.isReadPermission) {
                return true
            }
        }
        return false
    }

    private fun listStatusFiles(uriString: String?, result: MethodChannel.Result) {
        if (uriString == null) {
            result.error("INVALID_ARGUMENT", "URI string is null", null)
            return
        }
        try {
            val directoryUri = Uri.parse(uriString)
            val root = DocumentFile.fromTreeUri(this, directoryUri)
            val filesList = ArrayList<Map<String, String>>()
            
            val files = root?.listFiles()
            if (files != null) {
                for (file in files) {
                    if (file.isFile) {
                        val name = file.name
                        if (name != null) {
                            val lowerName = name.lowercase()
                            if (lowerName.endsWith(".jpg") || lowerName.endsWith(".jpeg") || 
                                lowerName.endsWith(".png") || lowerName.endsWith(".mp4") ||
                                lowerName.endsWith(".gif") || lowerName.endsWith(".webp")) {

                                val map = HashMap<String, String>()
                                map["name"] = name
                                map["uri"] = file.uri.toString()
                                filesList.add(map)
                            }
                        }
                    }
                }
            }
            result.success(filesList)
        } catch (e: Exception) {
            result.error("LIST_ERROR", e.toString(), null)
        }
    }

    private fun getFileContent(uriString: String?, result: MethodChannel.Result) {
        if (uriString == null) {
            result.error("INVALID_ARGUMENT", "URI string is null", null)
            return
        }
        try {
            val fileUri = Uri.parse(uriString)
            val inputStream = contentResolver.openInputStream(fileUri)
            if (inputStream != null) {
                val buffer = ByteArray(4096)
                val os = ByteArrayOutputStream()
                var bytesRead = inputStream.read(buffer)
                while (bytesRead != -1) {
                    os.write(buffer, 0, bytesRead)
                    bytesRead = inputStream.read(buffer)
                }
                val bytes = os.toByteArray()
                inputStream.close()
                os.close()
                result.success(bytes)
            } else {
                result.error("OPEN_ERROR", "Could not open input stream", null)
            }
        } catch (e: Exception) {
            result.error("READ_ERROR", e.toString(), null)
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
