// android/app/src/main/kotlin/com/ssaprktech/scaffassistant/ArMeasurementView.kt

package com.ssaprktech.scaffassistant

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.opengl.Matrix
import android.os.Handler
import android.os.Looper
import android.view.View
import com.google.ar.core.*
import com.google.ar.core.exceptions.*
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10
import kotlin.math.sqrt

class ArMeasurementView(
    private val context: Context,
    private val activity: Activity,
    private val channel: MethodChannel
) : PlatformView, GLSurfaceView.Renderer {

    companion object {
        fun isARCoreSupported(context: Context): Boolean {
            return try {
                val availability = ArCoreApk.getInstance().checkAvailability(context)
                availability == ArCoreApk.Availability.SUPPORTED_INSTALLED ||
                availability == ArCoreApk.Availability.SUPPORTED_APK_TOO_OLD ||
                availability == ArCoreApk.Availability.SUPPORTED_NOT_INSTALLED
            } catch (e: Exception) {
                false
            }
        }
    }

    private val glSurfaceView: GLSurfaceView = GLSurfaceView(context)
    private var session: Session? = null
    private var planeDetected = false
    private val mainHandler = Handler(Looper.getMainLooper())

    // Measurement points (3D world coordinates)
    private val points = mutableListOf<FloatArray>()

    // Rendering
    private var backgroundRenderer: BackgroundRenderer? = null
    private var pointRenderer: PointRenderer? = null
    private var lineRenderer: LineRenderer? = null

    // Matrices
    private val viewMatrix = FloatArray(16)
    private val projectionMatrix = FloatArray(16)

    private var width = 0
    private var height = 0

    init {
        glSurfaceView.preserveEGLContextOnPause = true
        glSurfaceView.setEGLContextClientVersion(2)
        glSurfaceView.setEGLConfigChooser(8, 8, 8, 8, 16, 0)
        glSurfaceView.setRenderer(this)
        glSurfaceView.renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY
    }

    override fun getView(): View = glSurfaceView

    override fun dispose() {
        session?.close()
        session = null
    }

    fun initialize(): Boolean {
        return try {
            // Check if ARCore is installed
            when (ArCoreApk.getInstance().requestInstall(activity, true)) {
                ArCoreApk.InstallStatus.INSTALLED -> {}
                ArCoreApk.InstallStatus.INSTALL_REQUESTED -> {
                    invokeOnMainThread("onError", "Please install ARCore")
                    return false
                }
            }

            session = Session(context)
            val config = Config(session)
            config.planeFindingMode = Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL
            config.updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
            config.focusMode = Config.FocusMode.AUTO
            session?.configure(config)
            session?.resume()
            true
        } catch (e: UnavailableArcoreNotInstalledException) {
            invokeOnMainThread("onError", "ARCore not installed")
            false
        } catch (e: UnavailableDeviceNotCompatibleException) {
            invokeOnMainThread("onError", "Device not compatible with AR")
            false
        } catch (e: UnavailableSdkTooOldException) {
            invokeOnMainThread("onError", "Please update this app")
            false
        } catch (e: UnavailableApkTooOldException) {
            invokeOnMainThread("onError", "Please update ARCore")
            false
        } catch (e: CameraNotAvailableException) {
            invokeOnMainThread("onError", "Camera not available")
            false
        } catch (e: Exception) {
            invokeOnMainThread("onError", e.message ?: "Unknown error")
            false
        }
    }

    fun addPoint() {
        val session = this.session ?: return
        val frame = try {
            session.update()
        } catch (e: Exception) {
            return
        }

        // Hit test at screen center
        val hitResults = frame.hitTest(width / 2f, height / 2f)

        for (hit in hitResults) {
            val trackable = hit.trackable
            if (trackable is Plane && trackable.isPoseInPolygon(hit.hitPose)) {
                val pose = hit.hitPose
                val point = floatArrayOf(
                    pose.tx(),
                    pose.ty(),
                    pose.tz()
                )
                points.add(point)

                invokeOnMainThread("onPointAdded", mapOf(
                    "x" to point[0].toDouble(),
                    "y" to point[1].toDouble(),
                    "z" to point[2].toDouble()
                ))

                invokeOnMainThread("onPointCount", points.size)

                // Calculate distance if 2+ points
                if (points.size >= 2) {
                    val distance = calculateDistance(
                        points[points.size - 2],
                        points[points.size - 1]
                    )
                    invokeOnMainThread("onDistanceCalculated", distance)
                }
                break
            }
        }
    }

    fun undo() {
        if (points.isNotEmpty()) {
            points.removeAt(points.size - 1)
            invokeOnMainThread("onPointCount", points.size)

            if (points.size >= 2) {
                val distance = calculateDistance(
                    points[points.size - 2],
                    points[points.size - 1]
                )
                invokeOnMainThread("onDistanceCalculated", distance)
            }
        }
    }

    fun clear() {
        points.clear()
        invokeOnMainThread("onPointCount", 0)
    }

    fun takeSnapshot(): ByteArray? {
        return try {
            val buffer = ByteBuffer.allocateDirect(width * height * 4)
            buffer.order(ByteOrder.LITTLE_ENDIAN)
            GLES20.glReadPixels(0, 0, width, height, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, buffer)
            buffer.rewind()

            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            bitmap.copyPixelsFromBuffer(buffer)

            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }

    private fun calculateDistance(p1: FloatArray, p2: FloatArray): Double {
        val dx = p2[0] - p1[0]
        val dy = p2[1] - p1[1]
        val dz = p2[2] - p1[2]
        return sqrt((dx * dx + dy * dy + dz * dz).toDouble())
    }

    private fun invokeOnMainThread(method: String, arguments: Any?) {
        mainHandler.post {
            try {
                channel.invokeMethod(method, arguments)
            } catch (e: Exception) {
                // Ignore
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // GLSurfaceView.Renderer
    // ═══════════════════════════════════════════════════════════════════════════

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glClearColor(0.1f, 0.1f, 0.1f, 1.0f)
        GLES20.glEnable(GLES20.GL_DEPTH_TEST)

        try {
            backgroundRenderer = BackgroundRenderer()
            backgroundRenderer?.createOnGlThread(context)

            pointRenderer = PointRenderer()
            lineRenderer = LineRenderer()
        } catch (e: Exception) {
            invokeOnMainThread("onError", "Failed to initialize renderer")
        }
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        this.width = width
        this.height = height
        GLES20.glViewport(0, 0, width, height)
        session?.setDisplayGeometry(activity.windowManager.defaultDisplay.rotation, width, height)
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)

        val session = this.session ?: return

        try {
            session.setCameraTextureName(backgroundRenderer?.textureId ?: 0)
            val frame = session.update()
            val camera = frame.camera

            // Draw camera background
            backgroundRenderer?.draw(frame)

            // Don't render if not tracking
            if (camera.trackingState != TrackingState.TRACKING) {
                return
            }

            // Get projection matrix
            camera.getProjectionMatrix(projectionMatrix, 0, 0.1f, 100.0f)
            camera.getViewMatrix(viewMatrix, 0)

            // Check plane detection
            val planes = session.getAllTrackables(Plane::class.java)
            val hasPlane = planes.any { 
                it.trackingState == TrackingState.TRACKING && 
                it.subsumedBy == null 
            }

            if (hasPlane != planeDetected) {
                planeDetected = hasPlane
                invokeOnMainThread("onPlaneDetected", planeDetected)
            }

            // Draw measurement points
            if (points.isNotEmpty()) {
                pointRenderer?.draw(points, viewMatrix, projectionMatrix)
            }

            // Draw lines between points
            if (points.size >= 2) {
                lineRenderer?.draw(points, viewMatrix, projectionMatrix)
            }

        } catch (e: Exception) {
            // Handle frame update errors silently
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// Background Renderer (Camera Feed)
// ═══════════════════════════════════════════════════════════════════════════

class BackgroundRenderer {
    var textureId: Int = -1
        private set

    private var program = 0
    private var positionAttrib = 0
    private var texCoordAttrib = 0

    private val QUAD_COORDS = floatArrayOf(
        -1.0f, -1.0f, 0.0f,
        -1.0f, +1.0f, 0.0f,
        +1.0f, -1.0f, 0.0f,
        +1.0f, +1.0f, 0.0f
    )

    private val QUAD_TEXCOORDS = floatArrayOf(
        0.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        1.0f, 0.0f
    )

    private var quadCoords: FloatBuffer? = null
    private var quadTexCoords: FloatBuffer? = null

    fun createOnGlThread(context: Context) {
        // Create texture
        val textures = IntArray(1)
        GLES20.glGenTextures(1, textures, 0)
        textureId = textures[0]

        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)

        // Create shader program
        val vertexShader = """
            attribute vec4 a_Position;
            attribute vec2 a_TexCoord;
            varying vec2 v_TexCoord;
            void main() {
                gl_Position = a_Position;
                v_TexCoord = a_TexCoord;
            }
        """.trimIndent()

        val fragmentShader = """
            #extension GL_OES_EGL_image_external : require
            precision mediump float;
            varying vec2 v_TexCoord;
            uniform samplerExternalOES sTexture;
            void main() {
                gl_FragColor = texture2D(sTexture, v_TexCoord);
            }
        """.trimIndent()

        program = createProgram(vertexShader, fragmentShader)
        positionAttrib = GLES20.glGetAttribLocation(program, "a_Position")
        texCoordAttrib = GLES20.glGetAttribLocation(program, "a_TexCoord")

        // Create buffers
        quadCoords = ByteBuffer.allocateDirect(QUAD_COORDS.size * 4)
            .order(ByteOrder.nativeOrder())
            .asFloatBuffer()
            .put(QUAD_COORDS)
        quadCoords?.position(0)

        quadTexCoords = ByteBuffer.allocateDirect(QUAD_TEXCOORDS.size * 4)
            .order(ByteOrder.nativeOrder())
            .asFloatBuffer()
            .put(QUAD_TEXCOORDS)
        quadTexCoords?.position(0)
    }

    fun draw(frame: Frame) {
        if (frame.hasDisplayGeometryChanged()) {
            frame.transformCoordinates2d(
                Coordinates2d.OPENGL_NORMALIZED_DEVICE_COORDINATES,
                quadCoords,
                Coordinates2d.TEXTURE_NORMALIZED,
                quadTexCoords
            )
        }

        GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        GLES20.glDepthMask(false)

        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId)
        GLES20.glUseProgram(program)

        GLES20.glVertexAttribPointer(positionAttrib, 3, GLES20.GL_FLOAT, false, 0, quadCoords)
        GLES20.glVertexAttribPointer(texCoordAttrib, 2, GLES20.GL_FLOAT, false, 0, quadTexCoords)

        GLES20.glEnableVertexAttribArray(positionAttrib)
        GLES20.glEnableVertexAttribArray(texCoordAttrib)

        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)

        GLES20.glDisableVertexAttribArray(positionAttrib)
        GLES20.glDisableVertexAttribArray(texCoordAttrib)

        GLES20.glDepthMask(true)
        GLES20.glEnable(GLES20.GL_DEPTH_TEST)
    }

    private fun createProgram(vertexSource: String, fragmentSource: String): Int {
        val vertexShader = loadShader(GLES20.GL_VERTEX_SHADER, vertexSource)
        val fragmentShader = loadShader(GLES20.GL_FRAGMENT_SHADER, fragmentSource)

        val program = GLES20.glCreateProgram()
        GLES20.glAttachShader(program, vertexShader)
        GLES20.glAttachShader(program, fragmentShader)
        GLES20.glLinkProgram(program)

        return program
    }

    private fun loadShader(type: Int, source: String): Int {
        val shader = GLES20.glCreateShader(type)
        GLES20.glShaderSource(shader, source)
        GLES20.glCompileShader(shader)
        return shader
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// Point Renderer
// ═══════════════════════════════════════════════════════════════════════════

class PointRenderer {
    private var program = 0
    private var positionHandle = 0
    private var colorHandle = 0
    private var mvpMatrixHandle = 0
    private var pointSizeHandle = 0

    private val mvpMatrix = FloatArray(16)

    init {
        val vertexShader = """
            uniform mat4 uMVPMatrix;
            uniform float uPointSize;
            attribute vec4 vPosition;
            void main() {
                gl_Position = uMVPMatrix * vPosition;
                gl_PointSize = uPointSize;
            }
        """.trimIndent()

        val fragmentShader = """
            precision mediump float;
            uniform vec4 vColor;
            void main() {
                float dist = length(gl_PointCoord - vec2(0.5));
                if (dist > 0.5) discard;
                gl_FragColor = vColor;
            }
        """.trimIndent()

        val vShader = loadShader(GLES20.GL_VERTEX_SHADER, vertexShader)
        val fShader = loadShader(GLES20.GL_FRAGMENT_SHADER, fragmentShader)

        program = GLES20.glCreateProgram()
        GLES20.glAttachShader(program, vShader)
        GLES20.glAttachShader(program, fShader)
        GLES20.glLinkProgram(program)

        positionHandle = GLES20.glGetAttribLocation(program, "vPosition")
        colorHandle = GLES20.glGetUniformLocation(program, "vColor")
        mvpMatrixHandle = GLES20.glGetUniformLocation(program, "uMVPMatrix")
        pointSizeHandle = GLES20.glGetUniformLocation(program, "uPointSize")
    }

    fun draw(points: List<FloatArray>, viewMatrix: FloatArray, projectionMatrix: FloatArray) {
        GLES20.glUseProgram(program)

        for (point in points) {
            val vertexBuffer = ByteBuffer.allocateDirect(12)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer()
                .put(point)
            vertexBuffer.position(0)

            Matrix.multiplyMM(mvpMatrix, 0, projectionMatrix, 0, viewMatrix, 0)

            GLES20.glUniformMatrix4fv(mvpMatrixHandle, 1, false, mvpMatrix, 0)
            GLES20.glUniform4f(colorHandle, 1.0f, 1.0f, 1.0f, 1.0f) // White
            GLES20.glUniform1f(pointSizeHandle, 30.0f)

            GLES20.glEnableVertexAttribArray(positionHandle)
            GLES20.glVertexAttribPointer(positionHandle, 3, GLES20.GL_FLOAT, false, 12, vertexBuffer)
            GLES20.glDrawArrays(GLES20.GL_POINTS, 0, 1)
            GLES20.glDisableVertexAttribArray(positionHandle)
        }
    }

    private fun loadShader(type: Int, source: String): Int {
        val shader = GLES20.glCreateShader(type)
        GLES20.glShaderSource(shader, source)
        GLES20.glCompileShader(shader)
        return shader
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// Line Renderer
// ═══════════════════════════════════════════════════════════════════════════

class LineRenderer {
    private var program = 0
    private var positionHandle = 0
    private var colorHandle = 0
    private var mvpMatrixHandle = 0

    private val mvpMatrix = FloatArray(16)

    init {
        val vertexShader = """
            uniform mat4 uMVPMatrix;
            attribute vec4 vPosition;
            void main() {
                gl_Position = uMVPMatrix * vPosition;
            }
        """.trimIndent()

        val fragmentShader = """
            precision mediump float;
            uniform vec4 vColor;
            void main() {
                gl_FragColor = vColor;
            }
        """.trimIndent()

        val vShader = loadShader(GLES20.GL_VERTEX_SHADER, vertexShader)
        val fShader = loadShader(GLES20.GL_FRAGMENT_SHADER, fragmentShader)

        program = GLES20.glCreateProgram()
        GLES20.glAttachShader(program, vShader)
        GLES20.glAttachShader(program, fShader)
        GLES20.glLinkProgram(program)

        positionHandle = GLES20.glGetAttribLocation(program, "vPosition")
        colorHandle = GLES20.glGetUniformLocation(program, "vColor")
        mvpMatrixHandle = GLES20.glGetUniformLocation(program, "uMVPMatrix")
    }

    fun draw(points: List<FloatArray>, viewMatrix: FloatArray, projectionMatrix: FloatArray) {
        if (points.size < 2) return

        GLES20.glUseProgram(program)
        GLES20.glLineWidth(5.0f)

        Matrix.multiplyMM(mvpMatrix, 0, projectionMatrix, 0, viewMatrix, 0)
        GLES20.glUniformMatrix4fv(mvpMatrixHandle, 1, false, mvpMatrix, 0)
        GLES20.glUniform4f(colorHandle, 1.0f, 1.0f, 1.0f, 1.0f) // White

        // Draw lines between consecutive points
        for (i in 0 until points.size - 1) {
            val lineCoords = floatArrayOf(
                points[i][0], points[i][1], points[i][2],
                points[i + 1][0], points[i + 1][1], points[i + 1][2]
            )

            val vertexBuffer = ByteBuffer.allocateDirect(lineCoords.size * 4)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer()
                .put(lineCoords)
            vertexBuffer.position(0)

            GLES20.glEnableVertexAttribArray(positionHandle)
            GLES20.glVertexAttribPointer(positionHandle, 3, GLES20.GL_FLOAT, false, 12, vertexBuffer)
            GLES20.glDrawArrays(GLES20.GL_LINES, 0, 2)
            GLES20.glDisableVertexAttribArray(positionHandle)
        }
    }

    private fun loadShader(type: Int, source: String): Int {
        val shader = GLES20.glCreateShader(type)
        GLES20.glShaderSource(shader, source)
        GLES20.glCompileShader(shader)
        return shader
    }
}

// OpenGL ES 11 Extension constant
object GLES11Ext {
    const val GL_TEXTURE_EXTERNAL_OES = 0x8D65
}