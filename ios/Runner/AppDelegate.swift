import CoreLocation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var qiblaManager: QiblaLocationHeadingManager?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "QiblaLocationHeadingPlugin") {
      let manager = QiblaLocationHeadingManager()
      manager.register(with: registrar.messenger())
      qiblaManager = manager
    }
  }
}

class QiblaLocationHeadingManager: NSObject, FlutterStreamHandler, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  private var methodChannel: FlutterMethodChannel?
  private var eventChannel: FlutterEventChannel?
  private var eventSink: FlutterEventSink?

  private var currentHeading: Double?
  private var currentLocation: CLLocation?
  private var needsCalibration: Bool = false
  private var isListening: Bool = false

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 2.0
    locationManager.headingFilter = 0.5
  }

  func register(with messenger: FlutterBinaryMessenger) {
    let method = FlutterMethodChannel(
      name: "com.othman.mawaqitquds/qibla",
      binaryMessenger: messenger
    )
    method.setMethodCallHandler { [weak self] call, result in
      self?.handleMethodCall(call, result: result)
    }
    methodChannel = method

    let event = FlutterEventChannel(
      name: "com.othman.mawaqitquds/qibla_stream",
      binaryMessenger: messenger
    )
    event.setStreamHandler(self)
    eventChannel = event
  }

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getStatus":
      result(buildPayload())
    case "requestPermission":
      let status = currentAuthStatus()
      if status == .notDetermined {
        locationManager.requestWhenInUseAuthorization()
        result(true)
      } else {
        startUpdatesIfAuthorized()
        emitUpdate()
        result(isAuthorized(status))
      }
    case "refreshLocation":
      startUpdatesIfAuthorized()
      emitUpdate()
      result(true)
    case "openLocationSettings":
      if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url, options: [:]) { ok in
          result(ok)
        }
      } else {
        result(false)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    isListening = true
    let status = currentAuthStatus()
    if status == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    } else {
      startUpdatesIfAuthorized()
    }
    if CLLocationManager.headingAvailable() {
      locationManager.startUpdatingHeading()
    }
    emitUpdate()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    isListening = false
    locationManager.stopUpdatingLocation()
    if CLLocationManager.headingAvailable() {
      locationManager.stopUpdatingHeading()
    }
    eventSink = nil
    return nil
  }

  private func currentAuthStatus() -> CLAuthorizationStatus {
    if #available(iOS 14.0, *) {
      return locationManager.authorizationStatus
    } else {
      return CLLocationManager.authorizationStatus()
    }
  }

  private func isAuthorized(_ status: CLAuthorizationStatus) -> Bool {
    return status == .authorizedWhenInUse || status == .authorizedAlways
  }

  private func startUpdatesIfAuthorized() {
    let status = currentAuthStatus()
    if isAuthorized(status) {
      if let lastLoc = locationManager.location {
        currentLocation = lastLoc
      }
      locationManager.startUpdatingLocation()
    }
    if CLLocationManager.headingAvailable() {
      locationManager.startUpdatingHeading()
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if isListening {
      startUpdatesIfAuthorized()
    }
    emitUpdate()
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if isListening {
      startUpdatesIfAuthorized()
    }
    emitUpdate()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let loc = locations.last {
      currentLocation = loc
      emitUpdate()
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    let accuracy = newHeading.headingAccuracy
    needsCalibration = accuracy < 0 || accuracy > 35
    let rawHeading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    if rawHeading >= 0 {
      currentHeading = (rawHeading + 360.0).truncatingRemainder(dividingBy: 360.0)
      emitUpdate()
    }
  }

  func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    return false
  }

  private func buildPayload() -> [String: Any?] {
    let status = currentAuthStatus()
    let granted = isAuthorized(status)
    let permanentlyDenied = status == .denied || status == .restricted
    let servicesEnabled = CLLocationManager.locationServicesEnabled()
    return [
      "heading": currentHeading,
      "latitude": currentLocation?.coordinate.latitude,
      "longitude": currentLocation?.coordinate.longitude,
      "hasCompass": CLLocationManager.headingAvailable(),
      "needsCalibration": needsCalibration,
      "permissionGranted": granted,
      "permanentlyDenied": permanentlyDenied,
      "locationEnabled": servicesEnabled
    ]
  }

  private func emitUpdate() {
    guard let sink = eventSink else { return }
    let payload = buildPayload()
    DispatchQueue.main.async {
      sink(payload)
    }
  }
}
