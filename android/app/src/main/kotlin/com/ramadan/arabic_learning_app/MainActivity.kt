package com.ramadan.arabic_learning_app

import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {

	private val channelName = "certificate_saver"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"saveImage" -> {
						val bytes = call.argument<ByteArray>("bytes")
						val fileName = call.argument<String>("fileName")
							?: "certificate_${System.currentTimeMillis()}"

						if (bytes == null) {
							result.error("INVALID", "Missing image bytes", null)
							return@setMethodCallHandler
						}

						val uri = saveImageToGallery(bytes, fileName)
						if (uri != null) {
							result.success(
								mapOf(
									"isSuccess" to true,
									"filePath" to uri.toString()
								)
							)
						} else {
							result.error("SAVE_FAILED", "Unable to save image", null)
						}
					}

					else -> result.notImplemented()
				}
			}
	}

	private fun saveImageToGallery(bytes: ByteArray, name: String): Uri? {
		return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
			saveWithMediaStore(bytes, name)
		} else {
			saveLegacy(bytes, name)
		}
	}

	private fun saveWithMediaStore(bytes: ByteArray, name: String): Uri? {
		return try {
			val resolver = applicationContext.contentResolver
			val collection = MediaStore.Images.Media.EXTERNAL_CONTENT_URI

			val contentValues = ContentValues().apply {
				put(MediaStore.MediaColumns.DISPLAY_NAME, "$name.png")
				put(MediaStore.MediaColumns.MIME_TYPE, "image/png")
				put(
					MediaStore.MediaColumns.RELATIVE_PATH,
					Environment.DIRECTORY_PICTURES + "/ArabicLearning"
				)
			}

			val uri = resolver.insert(collection, contentValues) ?: return null

			resolver.openOutputStream(uri)?.use { stream ->
				stream.write(bytes)
				stream.flush()
			} ?: return null

			uri
		} catch (error: Exception) {
			null
		}
	}

	private fun saveLegacy(bytes: ByteArray, name: String): Uri? {
		val picturesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
		if (!picturesDir.exists()) {
			picturesDir.mkdirs()
		}
		val folder = File(picturesDir, "ArabicLearning").apply {
			if (!exists()) mkdirs()
		}
		val file = File(folder, "$name.png")

		return try {
			FileOutputStream(file).use { output ->
				output.write(bytes)
			}

			val values = ContentValues().apply {
				put(MediaStore.Images.Media.DATA, file.absolutePath)
				put(MediaStore.Images.Media.MIME_TYPE, "image/png")
				put(MediaStore.Images.Media.DISPLAY_NAME, file.name)
			}

			applicationContext.contentResolver.insert(
				MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
				values
			)
		} catch (error: Exception) {
			null
		}
	}
}
