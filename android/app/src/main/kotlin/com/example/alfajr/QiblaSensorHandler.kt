package com.example.alfajr

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin

class QiblaSensorHandler(private val context: Context) :
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler,
    SensorEventListener,
    LocationListener {

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
    private val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
    private val mainHandler = Handler(Looper.getMainLooper())

    private var rotationVectorSensor: Sensor? = null
    private var accelerometerSensor: Sensor? = null
    private var magnetometerSensor: Sensor? = null

    private val gravity = FloatArray(3)
    private val geomagnetic = FloatArray(3)
    private var hasGravity = false
    private var hasGeomagnetic = false

    private var currentHeading: Double? = null
    private var smoothedSin: Double = 0.0
    private var smoothedCos: Double = 1.0
    private var hasSmoothedHeading = false

    private var currentLocation: Location? = null
    private var sensorAccuracy: Int = SensorManager.SENSOR_STATUS_ACCURACY_HIGH
    private var hasCompassSensor: Boolean = false
    private var lastEmitTimeMs: Long = 0L

    fun register(messenger: BinaryMessenger) {
        methodChannel = MethodChannel(messenger, "com.othman.mawaqitquds/qibla").also {
            it.setMethodCallHandler(this)
        }
        eventChannel = EventChannel(messenger, "com.othman.mawaqitquds/qibla_stream").also {
            it.setStreamHandler(this)
        }
    }

    fun unregister() {
        stopListening()
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStatus" -> {
                result.success(buildPayloadMap())
            }
            "refreshLocation" -> {
                startLocationUpdates()
                emitUpdate(force = true)
                result.success(true)
            }
            "openLocationSettings" -> {
                try {
                    val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    context.startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SETTINGS_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        startListening()
        emitUpdate(force = true)
    }

    override fun onCancel(arguments: Any?) {
        stopListening()
        eventSink = null
    }

    private fun startListening() {
        // Initialize sensors
        rotationVectorSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        accelerometerSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        magnetometerSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        hasCompassSensor = rotationVectorSensor != null ||
            (accelerometerSensor != null && magnetometerSensor != null)

        hasSmoothedHeading = false

        if (rotationVectorSensor != null) {
            sensorManager?.registerListener(
                this,
                rotationVectorSensor,
                SensorManager.SENSOR_DELAY_GAME
            )
            // Also register magnetometer if available just to monitor magnetic accuracy status
            if (magnetometerSensor != null) {
                sensorManager?.registerListener(
                    this,
                    magnetometerSensor,
                    SensorManager.SENSOR_DELAY_UI
                )
            }
        } else if (accelerometerSensor != null && magnetometerSensor != null) {
            sensorManager?.registerListener(
                this,
                accelerometerSensor,
                SensorManager.SENSOR_DELAY_GAME
            )
            sensorManager?.registerListener(
                this,
                magnetometerSensor,
                SensorManager.SENSOR_DELAY_GAME
            )
        }

        startLocationUpdates()
    }

    private fun stopListening() {
        sensorManager?.unregisterListener(this)
        try {
            locationManager?.removeUpdates(this)
        } catch (_: SecurityException) {
        } catch (_: Exception) {
        }
    }

    private fun hasLocationPermission(): Boolean {
        val fine = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        val coarse = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        return fine || coarse
    }

    private fun isLocationServicesEnabled(): Boolean {
        val lm = locationManager ?: return false
        return try {
            lm.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        } catch (_: Exception) {
            false
        }
    }

    private fun startLocationUpdates() {
        if (!hasLocationPermission()) return
        val lm = locationManager ?: return

        try {
            val providers = listOf(
                LocationManager.GPS_PROVIDER,
                LocationManager.NETWORK_PROVIDER,
                LocationManager.PASSIVE_PROVIDER
            )
            var bestLocation: Location? = currentLocation
            for (provider in providers) {
                if (lm.AllProvidersSafe().contains(provider)) {
                    val loc = lm.getLastKnownLocation(provider)
                    if (loc != null) {
                        if (bestLocation == null || loc.time > bestLocation.time) {
                            bestLocation = loc
                        }
                    }
                }
            }
            if (bestLocation != null) {
                currentLocation = bestLocation
            }

            if (lm.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                lm.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    2000L,
                    2f,
                    this,
                    Looper.getMainLooper()
                )
            }
            if (lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
                lm.requestLocationUpdates(
                    LocationManager.NETWORK_PROVIDER,
                    2000L,
                    2f,
                    this,
                    Looper.getMainLooper()
                )
            }
        } catch (_: SecurityException) {
        } catch (_: Exception) {
        }
    }

    private fun LocationManager.AllProvidersSafe(): List<String> {
        return try {
            allProviders
        } catch (_: Exception) {
            emptyList()
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return

        var rawAzimuthDeg: Double? = null

        if (event.sensor.type == Sensor.TYPE_ROTATION_VECTOR) {
            val rotationMatrix = FloatArray(9)
            SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
            val orientation = FloatArray(3)
            SensorManager.getOrientation(rotationMatrix, orientation)
            val azimuthRad = orientation[0].toDouble()
            rawAzimuthDeg = (Math.toDegrees(azimuthRad) + 360.0) % 360.0
        } else if (rotationVectorSensor == null) {
            if (event.sensor.type == Sensor.TYPE_ACCELEROMETER) {
                System.arraycopy(event.values, 0, gravity, 0, 3)
                hasGravity = true
            } else if (event.sensor.type == Sensor.TYPE_MAGNETIC_FIELD) {
                System.arraycopy(event.values, 0, geomagnetic, 0, 3)
                hasGeomagnetic = true
            }
            if (hasGravity && hasGeomagnetic) {
                val r = FloatArray(9)
                val i = FloatArray(9)
                if (SensorManager.getRotationMatrix(r, i, gravity, geomagnetic)) {
                    val orientation = FloatArray(3)
                    SensorManager.getOrientation(r, orientation)
                    val azimuthRad = orientation[0].toDouble()
                    rawAzimuthDeg = (Math.toDegrees(azimuthRad) + 360.0) % 360.0
                }
            }
        }

        if (rawAzimuthDeg != null) {
            // Adjust for True North using geomagnetic declination when GPS location is available
            val loc = currentLocation
            val trueAzimuthDeg = if (loc != null) {
                val geoField = GeomagneticField(
                    loc.latitude.toFloat(),
                    loc.longitude.toFloat(),
                    loc.altitude.toFloat(),
                    System.currentTimeMillis()
                )
                (rawAzimuthDeg + geoField.declination + 360.0) % 360.0
            } else {
                rawAzimuthDeg
            }

            // Circular low-pass filter to keep needle smooth across 0°/360°
            val rad = Math.toRadians(trueAzimuthDeg)
            val alpha = 0.22
            if (!hasSmoothedHeading) {
                smoothedSin = sin(rad)
                smoothedCos = cos(rad)
                hasSmoothedHeading = true
            } else {
                smoothedSin = smoothedSin + alpha * (sin(rad) - smoothedSin)
                smoothedCos = smoothedCos + alpha * (cos(rad) - smoothedCos)
            }
            currentHeading = (Math.toDegrees(atan2(smoothedSin, smoothedCos)) + 360.0) % 360.0
            emitUpdate(force = false)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        if (sensor?.type == Sensor.TYPE_MAGNETIC_FIELD || sensor?.type == Sensor.TYPE_ROTATION_VECTOR) {
            sensorAccuracy = accuracy
            emitUpdate(force = true)
        }
    }

    override fun onLocationChanged(location: Location) {
        currentLocation = location
        emitUpdate(force = true)
    }

    @Deprecated("Deprecated in Android API")
    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}

    override fun onProviderEnabled(provider: String) {
        startLocationUpdates()
        emitUpdate(force = true)
    }

    override fun onProviderDisabled(provider: String) {
        emitUpdate(force = true)
    }

    private fun buildPayloadMap(): Map<String, Any?> {
        val loc = currentLocation
        val needsCalibration = sensorAccuracy == SensorManager.SENSOR_STATUS_UNRELIABLE ||
            sensorAccuracy == SensorManager.SENSOR_STATUS_ACCURACY_LOW
        return mapOf(
            "heading" to currentHeading,
            "latitude" to loc?.latitude,
            "longitude" to loc?.longitude,
            "hasCompass" to hasCompassSensor,
            "needsCalibration" to needsCalibration,
            "permissionGranted" to hasLocationPermission(),
            "locationEnabled" to isLocationServicesEnabled()
        )
    }

    private fun emitUpdate(force: Boolean) {
        val sink = eventSink ?: return
        val now = System.currentTimeMillis()
        if (!force && now - lastEmitTimeMs < 28L) {
            return
        }
        lastEmitTimeMs = now
        val payload = buildPayloadMap()
        mainHandler.post {
            eventSink?.success(payload)
        }
    }
}
