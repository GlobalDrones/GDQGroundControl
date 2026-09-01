

# QGroundControl Ground Control Station

[![Releases](https://img.shields.io/github/release/mavlink/QGroundControl.svg)](https://github.com/mavlink/QGroundControl/releases)
[![Travis Build Status](https://travis-ci.org/mavlink/qgroundcontrol.svg?branch=master)](https://travis-ci.org/mavlink/qgroundcontrol)
[![Appveyor Build Status](https://ci.appveyor.com/api/projects/status/crxcm4qayejuvh6c/branch/master?svg=true)](https://ci.appveyor.com/project/mavlink/qgroundcontrol)

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/mavlink/qgroundcontrol?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


*QGroundControl* (QGC) is an intuitive and powerful ground control station (GCS) for UAVs.

The primary goal of QGC is ease of use for both first time and professional users.
It provides full flight control and mission planning for any MAVLink enabled drone, and vehicle setup for both PX4 and ArduPilot powered UAVs. Instructions for *using QGroundControl* are provided in the [User Manual](https://docs.qgroundcontrol.com/en/) (you may not need them because the UI is very intuitive!)

All the code is open-source, so you can contribute and evolve it as you want.
The [Developer Guide](https://dev.qgroundcontrol.com/en/) explains how to [build](https://dev.qgroundcontrol.com/en/getting_started/) and extend QGC.


Key Links:
* [Website](http://qgroundcontrol.com) (qgroundcontrol.com)
* [User Manual](https://docs.qgroundcontrol.com/en/)
* [Developer Guide](https://dev.qgroundcontrol.com/en/)
* [Discussion/Support](https://docs.qgroundcontrol.com/en/Support/Support.html)
* [Contributing](https://dev.qgroundcontrol.com/en/contribute/)
* [License](https://github.com/mavlink/qgroundcontrol/blob/master/COPYING.md)

## Ativando Video Stream com GStreamer para android
Para ativar o GStreamer em build android é necessário ter o [pacote gstreamer](https://gstreamer.freedesktop.org/data/pkg/android/1.18.6/gstreamer-1.0-android-universal-1.18.6.tar.xz) baixado e indicar PATH no arquivo [Videoreceiver.pri](https://github.com/GlobalDrones/GDQGroundControl/blob/main/src/VideoReceiver/VideoReceiver.pri#L79)

## Como ativar Release Mode no QT Creator
1) Tente realizar o build uma vez para que as pastas sejam criadas

2) Na pasta build/QT_5_15_2_for_Android_Multi_Abi-Release\android-build\ abre o arquivo "build.gradle" e substitua por estes dados:


                buildscript {
                    repositories {
                        google()
                        jcenter()
                    }

                    dependencies {
                        classpath 'com.android.tools.build:gradle:3.6.0'
                    }
                        }

                repositories {
                    google()
                    jcenter()
                }

                apply plugin: 'com.android.application'

                dependencies {
                    implementation fileTree(dir: 'libs', include: ['*.jar', '*.aar'])
                }

                android {
                    /*******************************************************
                     * The following variables:
                     * - androidBuildToolsVersion,
                     * - androidCompileSdkVersion
                     * - qt5AndroidDir - holds the path to qt android files
                     *                   needed to build any Qt application
                     *                   on Android.
                     *
                     * are defined in gradle.properties file. This file is
                     * updated by QtCreator and androiddeployqt tools.
                     * Changing them manually might break the compilation!
                     *******************************************************/

            compileSdkVersion androidCompileSdkVersion.toInteger()

            buildToolsVersion '28.0.3'

            sourceSets {
                main {
                    manifest.srcFile 'AndroidManifest.xml'
                    java.srcDirs = [qt5AndroidDir + '/src', 'src', 'java']
                    aidl.srcDirs = [qt5AndroidDir + '/src', 'src', 'aidl']
                    res.srcDirs = [qt5AndroidDir + '/res', 'res']
                    resources.srcDirs = ['resources']
                    renderscript.srcDirs = ['src']
                    assets.srcDirs = ['assets']
                    jniLibs.srcDirs = ['libs']
               }
            }

            tasks.withType(JavaCompile) {
                options.incremental = true
            }

            compileOptions {
                sourceCompatibility JavaVersion.VERSION_1_8
                targetCompatibility JavaVersion.VERSION_1_8
            }

            lintOptions {
                abortOnError false
            }

            // Do not compress Qt binary resources file
            aaptOptions {
                noCompress 'rcc'
            }

            defaultConfig {
                resConfig "en"
                minSdkVersion = qtMinSdkVersion
                targetSdkVersion = qtTargetSdkVersion
            }
                }

3) Na mesma pasta, substitua o arquivo gradle.properties por este:

            org.gradle.jvmargs=-Xmx2048m

            android.bundle.enableUncompressedNativeLibs=false
            androidBuildToolsVersion=31.0.0
            androidCompileSdkVersion=31
            buildDir=build
            qt5AndroidDir=C:/Qt/5.15.2/android/src/android/java
            qtMinSdkVersion=21
            qtTargetSdkVersion=28
            org.gradle.java.home = C:/Users/Russi/Documents/javacoisas/jdk-11.0.29+7
            android.bundle.enableUncompressedNativeLibs=false
            androidBuildToolsVersion=31.0.0
            androidCompileSdkVersion=31
            buildDir=build
            qt5AndroidDir=C:/Qt/5.15.2/android/src/android/java
            qtMinSdkVersion=21
            qtTargetSdkVersion=28
            android.bundle.enableUncompressedNativeLibs=false
            androidBuildToolsVersion=31.0.0
            androidCompileSdkVersion=31
            buildDir=build
            qt5AndroidDir=C:/Qt/5.15.2/android/src/android/java
            qtMinSdkVersion=21
            qtTargetSdkVersion=28
            android.bundle.enableUncompressedNativeLibs=false
            androidBuildToolsVersion=31.0.0
            androidCompileSdkVersion=31
            buildDir=build
            qt5AndroidDir=C:/Qt/5.15.2/android/src/android/java
            qtMinSdkVersion=21
            qtTargetSdkVersion=28
            android.bundle.enableUncompressedNativeLibs=false
            androidBuildToolsVersion=31.0.0
            androidCompileSdkVersion=31
            buildDir=build
            qt5AndroidDir=C:/Qt/5.15.2/android/src/android/java
            qtMinSdkVersion=21
            qtTargetSdkVersion=28
            android.bundle.enableUncompressedNativeLibs=false


            androidBuildToolsVersion=31.0.0
            androidCompileSdkVersion=31
            buildDir=build
            qt5AndroidDir=C:/Qt/5.15.2/android/src/android/java
            qtMinSdkVersion=21
            qtTargetSdkVersion=28
            android.bundle.enableUncompressedNativeLibs=false
            android.bundle.enableUncompressedNativeLibs=false


            androidBuildToolsVersion=31.0.0
            androidCompileSdkVersion=31
            buildDir=build
            qt5AndroidDir=C:/Qt/5.15.2/android/src/android/java
            qtMinSdkVersion=21
            qtTargetSdkVersion=28
            android.bundle.enableUncompressedNativeLibs=false

