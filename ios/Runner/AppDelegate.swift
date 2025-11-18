import Flutter
import UIKit
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "certificate_saver",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "saveImage" else {
        result(FlutterMethodNotImplemented)
        return
      }

      guard
        let arguments = call.arguments as? [String: Any],
        let data = (arguments["bytes"] as? FlutterStandardTypedData)?.data,
        let fileName = arguments["fileName"] as? String
      else {
        result(FlutterError(code: "INVALID", message: "Invalid arguments", details: nil))
        return
      }

      self?.saveImageToLibrary(data: data, name: fileName, result: result)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func saveImageToLibrary(data: Data, name: String, result: @escaping FlutterResult) {
    guard let image = UIImage(data: data) else {
      result(FlutterError(code: "INVALID", message: "Unable to decode image", details: nil))
      return
    }

    PHPhotoLibrary.requestAuthorization { status in
      guard status == .authorized || status == .limited else {
        result(FlutterError(code: "PERMISSION", message: "Photo access denied", details: nil))
        return
      }

      PHPhotoLibrary.shared().performChanges({
        let options = PHAssetResourceCreationOptions()
        options.originalFilename = "\(name).png"
        let request = PHAssetCreationRequest.forAsset()
        if let pngData = image.pngData() {
          request.addResource(with: .photo, data: pngData, options: options)
        }
      }) { success, error in
        if success {
          result(["isSuccess": true])
        } else {
          result(
            FlutterError(
              code: "SAVE_FAILED",
              message: error?.localizedDescription ?? "Unable to save image",
              details: nil
            )
          )
        }
      }
    }
  }
}
