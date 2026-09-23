package org.leoli.plugin.flutter_tencent_bugly

import android.content.Context
import android.os.Build
import com.tencent.bugly.crashreport.BuglyLog
import com.tencent.bugly.crashreport.CrashReport
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterTencentBuglyPlugin */
class FlutterTencentBuglyPlugin : FlutterPlugin, MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_tencent_bugly")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
            "init" -> init(call, result)
            "setUserId" -> setUserId(call, result)
            "setUserTag" -> setUserTag(call, result)
            "setDeviceID" -> setDeviceID(call, result)
            "setDeviceModel" -> setDeviceModel(call, result)
            "setChannel" -> setChannel(call, result)
            "setVersion" -> setVersion(call, result)
            "setPackageName" -> setPackageName(call, result)
            "putUserData" -> putUserData(call, result)
            "postException" -> postException(call, result)
            "log" -> log(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    /**
     * 初始化 Bugly
     *
     * 合规要求（见《开发者合规指南》）：请务必在用户授权《隐私政策》后再调用本方法；
     * 建议通过 deviceId 参数设置业务唯一 id，使 crash 率统计更精准。
     * 注意：为保证运营数据准确性，请勿在异步线程初始化 Bugly（Flutter MethodChannel 调用默认在主线程）。
     */
    private fun init(call: MethodCall, result: Result) {
        val appId = call.argument<String>("appId")
        if (appId.isNullOrEmpty()) {
            result.success(false)
            return
        }

        val strategy = CrashReport.UserStrategy(applicationContext)

        // 配置参数
        withArg<Boolean>(call, "isLogUpload") { strategy.isBuglyLogUpload = it }
        withArg<Boolean>(call, "isDevelopmentDevice") { setIsDevelopmentDevice(it) }
        withNonEmptyStringArg(call, "channel") { strategy.appChannel = it }
        withNonEmptyStringArg(call, "version") { strategy.appVersion = it }
        withNonEmptyStringArg(call, "packageName") { strategy.appPackageName = it }
        withNonEmptyStringArg(call, "deviceId") { strategy.deviceID = it }
        withNonEmptyStringArg(call, "deviceModel") { strategy.deviceModel = it }
        withArg<Number>(call, "reportDelay") { strategy.appReportDelay = it.toLong() }
        withArg<Boolean>(call, "enableCatchAnrTrace") { strategy.isEnableCatchAnrTrace = it }
        withArg<Boolean>(call, "enableRecordAnrMainStack") {
            strategy.isEnableRecordAnrMainStack = it
        }
        val isDebugMode = call.argument<Boolean>("isDebugMode") == true

        // 初始化
        CrashReport.initCrashReport(applicationContext, appId, isDebugMode, strategy)
        if (isDebugMode) Log.i(TAG, "Bugly appId: $appId")
        result.success(true)
    }

    /**
     * 读取 MethodCall 中类型为 [T] 的参数，参数缺失时不执行 [block]
     */
    private inline fun <reified T> withArg(
        call: MethodCall, key: String, crossinline block: (T) -> Unit
    ) {
        call.argument<T>(key)?.let { block(it) }
    }

    /**
     * 读取 MethodCall 中的字符串参数，参数缺失或为空白时不执行 [block]
     */
    private inline fun withNonEmptyStringArg(
        call: MethodCall, key: String, crossinline block: (String) -> Unit
    ) {
        withArg<String>(call, key) { value -> if (value.isNotEmpty()) block(value) }
    }

    /**
     * 设置用户ID
     */
    private fun setUserId(call: MethodCall, result: Result) {
        withNonEmptyStringArg(call, "value") { CrashReport.setUserId(applicationContext, it) }
        result.success(true)
    }

    /**
     * 设置用户标签
     */
    private fun setUserTag(call: MethodCall, result: Result) {
        withArg<Int>(call, "value") { CrashReport.setUserSceneTag(applicationContext, it) }
        result.success(true)
    }

    /**
     * 设置设备ID
     */
    private fun setDeviceID(call: MethodCall, result: Result) {
        withNonEmptyStringArg(call, "value") { CrashReport.setDeviceId(applicationContext, it) }
        result.success(true)
    }

    /**
     * 设置设备型号
     */
    private fun setDeviceModel(call: MethodCall, result: Result) {
        withNonEmptyStringArg(call, "value") { CrashReport.setDeviceModel(applicationContext, it) }
        result.success(true)
    }

    /**
     * 设置渠道
     */
    private fun setChannel(call: MethodCall, result: Result) {
        withNonEmptyStringArg(call, "value") { CrashReport.setAppChannel(applicationContext, it) }
        result.success(true)
    }

    /**
     * 设置版本号
     */
    private fun setVersion(call: MethodCall, result: Result) {
        withNonEmptyStringArg(call, "value") { CrashReport.setAppVersion(applicationContext, it) }
        result.success(true)
    }

    /**
     * 设置包名
     */
    private fun setPackageName(call: MethodCall, result: Result) {
        withNonEmptyStringArg(call, "value") { CrashReport.setAppPackage(applicationContext, it) }
        result.success(true)
    }

    /**
     * 设置自定义的 Key-Value 数据，发生 Crash 时随之上报
     */
    private fun putUserData(call: MethodCall, result: Result) {
        val key = call.argument<String>("key")
        val value = call.argument<String>("value")
        if (!key.isNullOrEmpty() && !value.isNullOrEmpty()) {
            CrashReport.putUserData(applicationContext, key, value)
        }
        result.success(true)
    }

    /**
     * 上报自定义异常
     */
    private fun postException(call: MethodCall, result: Result) {
        withNonEmptyStringArg(call, "detail") {
            CrashReport.postException(
                CRASH_CATEGORY_FLUTTER,
                call.argument<String>("type").takeUnless { t -> t.isNullOrEmpty() }
                    ?: "FlutterException",
                call.argument<String>("message").orEmpty(),
                it,
                call.argument<Map<String, Any?>>("data")?.mapValues { (_, v) -> v.toString() }
            )
        }
        result.success(true)
    }

    /**
     * 写入 Bugly 日志，发生 Crash 时随崩溃报告一并上报
     *
     * 注意：需初始化时将 isBuglyLogUpload 设为 true，日志才会上传到 Bugly 服务器。
     */
    private fun log(call: MethodCall, result: Result) {
        val tag = call.argument<String>("tag")
        val message = call.argument<String>("message")
        withArg<Int>(call, "level") {
            when (it) {
                LOG_LEVEL_ERROR -> BuglyLog.e(tag, message)
                LOG_LEVEL_WARN -> BuglyLog.w(tag, message)
                LOG_LEVEL_INFO -> BuglyLog.i(tag, message)
                LOG_LEVEL_DEBUG -> BuglyLog.d(tag, message)
                LOG_LEVEL_VERBOSE -> BuglyLog.v(tag, message)
            }
        }
        result.success(true)
    }

    /**
     * 设置是否为开发设备
     *
     * 开发设备的 Crash 上报会被标记为"开发设备"，便于在 Bugly 后台过滤调试期间的数据。
     */
    private fun setIsDevelopmentDevice(value: Boolean) {
        CrashReport.setIsDevelopmentDevice(applicationContext, value)
    }

    private companion object {
        const val TAG = "FlutterTencentBugly"

        /** Bugly 自定义异常类别：8 表示 Flutter 异常 */
        const val CRASH_CATEGORY_FLUTTER = 8

        /** 日志级别 */
        const val LOG_LEVEL_ERROR = 1
        const val LOG_LEVEL_WARN = 2
        const val LOG_LEVEL_INFO = 3
        const val LOG_LEVEL_DEBUG = 4
        const val LOG_LEVEL_VERBOSE = 5
    }
}