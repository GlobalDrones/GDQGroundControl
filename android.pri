include($$PWD/libs/qtandroidserialport/src/qtandroidserialport.pri)
message("Adding Serial Java Classes")
QT += androidextras

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

exists($$PWD/custom/android) {
    message("Merging $$PWD/custom/android/ -> $$PWD/android/")

    ANDROID_PACKAGE_SOURCE_DIR = $$OUT_PWD/ANDROID_PACKAGE_SOURCE_DIR
    android_source_dir_target.target = android_source_dir
    PRE_TARGETDEPS += $$android_source_dir_target.target
    QMAKE_EXTRA_TARGETS += android_source_dir_target

    # The manifest is generated at qmake time with the package and label filled in:
    # the build-time "qmake -install sed -i" did not work on Windows hosts (no -i),
    # and cmd.exe rejects forward slashes in mkdir/xcopy (hence shell_path).
    CUSTOM_MANIFEST = $$cat($$PWD/custom/android/AndroidManifest.xml, blob)
    CUSTOM_MANIFEST = $$replace(CUSTOM_MANIFEST, "package=\"org.mavlink.qgroundcontrol\"", "package=\"$$QGC_ANDROID_PACKAGE\"")
    !isEmpty(CUSTOM_ANDROID_LABEL) {
        CUSTOM_MANIFEST = $$replace(CUSTOM_MANIFEST, CUSTOM_ANDROID_LABEL, $$CUSTOM_ANDROID_LABEL)
    }
    CUSTOM_MANIFEST_FILE = $$OUT_PWD/AndroidManifest.generated.xml
    write_file($$CUSTOM_MANIFEST_FILE, CUSTOM_MANIFEST)

    ANDROID_SOURCE_DIR_SHELL = $$shell_path($$ANDROID_PACKAGE_SOURCE_DIR)
    android_source_dir_target.commands = ( $$sprintf($$QMAKE_MKDIR_CMD, $$ANDROID_SOURCE_DIR_SHELL) ) && \
            $$QMAKE_COPY_DIR $$shell_path($$PWD/android/*) $$ANDROID_SOURCE_DIR_SHELL && \
            $$QMAKE_COPY_DIR $$shell_path($$PWD/custom/android/*) $$ANDROID_SOURCE_DIR_SHELL
    # Custom builds with product variants: overlay the variant directory
    !isEmpty(CUSTOM_ANDROID_VARIANT_DIR):exists($$CUSTOM_ANDROID_VARIANT_DIR) {
        android_source_dir_target.commands += && $$QMAKE_COPY_DIR $$shell_path($$CUSTOM_ANDROID_VARIANT_DIR/*) $$ANDROID_SOURCE_DIR_SHELL
    }
    android_source_dir_target.commands += && $$QMAKE_COPY $$shell_path($$CUSTOM_MANIFEST_FILE) $$shell_path($$ANDROID_PACKAGE_SOURCE_DIR/AndroidManifest.xml)
    # Extra gradle.properties entries (e.g. org.gradle.java.home); androiddeployqt keeps them
    !isEmpty(CUSTOM_GRADLE_PROPERTIES) {
        android_source_dir_target.commands += && $$QMAKE_COPY $$shell_path($$CUSTOM_GRADLE_PROPERTIES) $$shell_path($$ANDROID_PACKAGE_SOURCE_DIR/gradle.properties)
    }
    android_source_dir_target.depends = FORCE
}

exists($$PWD/custom/android/AndroidManifest.xml) {
    OTHER_FILES += \
    $$PWD/custom/android/AndroidManifest.xml
} else {
    OTHER_FILES += \
    $$PWD/android/AndroidManifest.xml
}

OTHER_FILES += \
    $$PWD/android/res/xml/device_filter.xml \
    $$PWD/android/src/com/hoho/android/usbserial/driver/CdcAcmSerialDriver.java \
    $$PWD/android/src/com/hoho/android/usbserial/driver/CommonUsbSerialDriver.java \
    $$PWD/android/src/com/hoho/android/usbserial/driver/Cp2102SerialDriver.java \
    $$PWD/android/src/com/hoho/android/usbserial/driver/FtdiSerialDriver.java \
    $$PWD/android/src/com/hoho/android/usbserial/driver/ProlificSerialDriver.java \
    $$PWD/android/src/com/hoho/android/usbserial/driver/UsbId.java \
    $$PWD/android/src/com/hoho/android/usbserial/driver/UsbSerialDriver.java \
    $$PWD/android/src/com/hoho/android/usbserial/driver/UsbSerialProber.java \
    $$PWD/android/src/com/hoho/android/usbserial/driver/UsbSerialRuntimeException.java \
    $$PWD/android/src/org/mavlink/qgroundcontrol/QGCActivity.java \
    $$PWD/android/src/org/mavlink/qgroundcontrol/UsbIoManager.java \
    $$PWD/android/src/org/mavlink/qgroundcontrol/TaiSync.java \
    $$PWD/android/src/org/freedesktop/gstreamer/androidmedia/GstAhcCallback.java \
    $$PWD/android/src/org/freedesktop/gstreamer/androidmedia/GstAhsCallback.java \
    $$PWD/android/src/org/freedesktop/gstreamer/androidmedia/GstAmcOnFrameAvailableListener.java


DISTFILES += \
    $$PWD/android/gradle/wrapper/gradle-wrapper.jar \
    $$PWD/android/gradlew \
    $$PWD/android/res/values/libs.xml \
    $$PWD/android/build.gradle \
    $$PWD/android/gradle/wrapper/gradle-wrapper.properties \
    $$PWD/android/gradlew.bat
