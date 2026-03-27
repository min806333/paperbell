package com.example.life_admin_assistant

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.OpenableColumns
import android.webkit.MimeTypeMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.Locale

class MainActivity : FlutterActivity(), EventChannel.StreamHandler {
    companion object {
        private const val METHOD_CHANNEL_NAME = "life_admin_assistant/share_intent"
        private const val EVENT_CHANNEL_NAME = "life_admin_assistant/share_intent_events"
    }

    private var eventSink: EventChannel.EventSink? = null
    private var pendingSharedMedia: List<Map<String, String?>> = emptyList()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pendingSharedMedia = extractSharedMedia(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL_NAME,
        ).setMethodCallHandler(::handleMethodCall)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL_NAME,
        ).setStreamHandler(this)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val sharedMedia = extractSharedMedia(intent)
        if (sharedMedia.isEmpty()) {
            return
        }

        pendingSharedMedia = sharedMedia
        eventSink?.success(sharedMedia)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getLatestSharedMedia" -> result.success(pendingSharedMedia)
            "markLatestSharedMediaHandled" -> {
                pendingSharedMedia = emptyList()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun extractSharedMedia(intent: Intent?): List<Map<String, String?>> {
        if (intent == null) {
            return emptyList()
        }

        val uris = when (intent.action) {
            Intent.ACTION_SEND -> readSingleSharedUri(intent)?.let(::listOf) ?: emptyList()
            Intent.ACTION_SEND_MULTIPLE -> readMultipleSharedUris(intent)
            else -> emptyList()
        }

        val declaredMimeType = intent.type
        return uris.mapNotNull { uri ->
            val mimeType = resolveMimeType(uri, declaredMimeType)
            if (!isSupportedMimeType(uri, mimeType)) {
                return@mapNotNull null
            }

            copySharedUriToCache(uri, mimeType)
        }
    }

    private fun readSingleSharedUri(intent: Intent): Uri? {
        intent.clipData?.let { clipData ->
            if (clipData.itemCount > 0) {
                return clipData.getItemAt(0).uri
            }
        }

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }
    }

    private fun readMultipleSharedUris(intent: Intent): List<Uri> {
        val uris = mutableListOf<Uri>()

        intent.clipData?.let { clipData ->
            repeat(clipData.itemCount) { index ->
                clipData.getItemAt(index).uri?.let(uris::add)
            }
        }

        val extraUris = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM)
        }

        extraUris?.let(uris::addAll)
        return uris.distinctBy(Uri::toString)
    }

    private fun resolveMimeType(uri: Uri, declaredMimeType: String?): String? {
        val normalizedDeclared = declaredMimeType?.takeIf { it.isNotBlank() && it != "*/*" }
        if (normalizedDeclared != null) {
            return normalizedDeclared
        }

        val resolverType = contentResolver.getType(uri)
        if (!resolverType.isNullOrBlank()) {
            return resolverType
        }

        val extension = MimeTypeMap.getFileExtensionFromUrl(uri.toString())
            ?.lowercase(Locale.ROOT)
            ?.takeIf { it.isNotBlank() }

        return extension?.let(MimeTypeMap.getSingleton()::getMimeTypeFromExtension)
    }

    private fun isSupportedMimeType(uri: Uri, mimeType: String?): Boolean {
        val normalizedMimeType = mimeType?.lowercase(Locale.ROOT).orEmpty()
        if (normalizedMimeType.startsWith("image/") || normalizedMimeType == "application/pdf") {
            return true
        }

        val extension = MimeTypeMap.getFileExtensionFromUrl(uri.toString())
            ?.lowercase(Locale.ROOT)
            .orEmpty()

        return extension in setOf("jpg", "jpeg", "png", "webp", "heic", "pdf")
    }

    private fun copySharedUriToCache(uri: Uri, mimeType: String?): Map<String, String?>? {
        val fileName = resolveFileName(uri, mimeType)
        val targetDirectory = File(cacheDir, "shared_imports").apply { mkdirs() }
        val targetFile = File(
            targetDirectory,
            "${System.currentTimeMillis()}_${sanitizeFileName(fileName)}",
        )

        return try {
            when (uri.scheme?.lowercase(Locale.ROOT)) {
                "content" -> {
                    contentResolver.openInputStream(uri)?.use { input ->
                        FileOutputStream(targetFile).use { output ->
                            input.copyTo(output)
                        }
                    } ?: return null
                }
                "file" -> {
                    val sourcePath = uri.path ?: return null
                    File(sourcePath).inputStream().use { input ->
                        FileOutputStream(targetFile).use { output ->
                            input.copyTo(output)
                        }
                    }
                }
                else -> return null
            }

            mapOf(
                "path" to targetFile.absolutePath,
                "mimeType" to mimeType,
                "fileName" to fileName,
            )
        } catch (_: Exception) {
            targetFile.delete()
            null
        }
    }

    private fun resolveFileName(uri: Uri, mimeType: String?): String {
        val displayName = queryDisplayName(uri)
        if (!displayName.isNullOrBlank()) {
            return ensureFileExtension(displayName, mimeType, uri)
        }

        val pathName = uri.lastPathSegment
            ?.substringAfterLast('/')
            ?.takeIf { it.isNotBlank() }
        if (!pathName.isNullOrBlank()) {
            return ensureFileExtension(pathName, mimeType, uri)
        }

        val baseName = when {
            mimeType == "application/pdf" -> "shared_document"
            mimeType?.startsWith("image/") == true -> "shared_image"
            else -> "shared_file"
        }
        return ensureFileExtension(baseName, mimeType, uri)
    }

    private fun queryDisplayName(uri: Uri): String? {
        if (uri.scheme?.lowercase(Locale.ROOT) != "content") {
            return null
        }

        return contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            ?.use { cursor ->
                if (!cursor.moveToFirst()) {
                    return@use null
                }

                val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index == -1) {
                    null
                } else {
                    cursor.getString(index)
                }
            }
    }

    private fun ensureFileExtension(
        fileName: String,
        mimeType: String?,
        uri: Uri,
    ): String {
        if (fileName.substringAfterLast('.', "").isNotBlank()) {
            return fileName
        }

        val extension = when {
            !mimeType.isNullOrBlank() -> {
                MimeTypeMap.getSingleton()
                    .getExtensionFromMimeType(mimeType.lowercase(Locale.ROOT))
            }
            else -> MimeTypeMap.getFileExtensionFromUrl(uri.toString())
        }?.lowercase(Locale.ROOT)

        if (extension.isNullOrBlank()) {
            return fileName
        }

        return "$fileName.$extension"
    }

    private fun sanitizeFileName(fileName: String): String {
        val cleaned = fileName.replace(Regex("[\\\\/:*?\"<>|\\r\\n]"), "_").trim()
        return cleaned.ifBlank { "shared_file" }
    }
}
