# Global Drones: uma árvore, cinco produtos.
#
#   qmake <fonte>/qgroundcontrol.pro GD_VARIANT=gd60
#
# src/ é o QGroundControl modificado pela SiYi (583c15a). Tudo que a Global
# Drones acrescenta fica em custom/: o que é comum aos produtos na raiz de
# custom/ e o que é de um produto só em custom/variants/<variante>/.

GD_VARIANTS = gd25 gd30 gd60 gd70 gd150

isEmpty(GD_VARIANT) {
    error("Informe a variante: qmake qgroundcontrol.pro GD_VARIANT=<$$join(GD_VARIANTS, "|")>")
}
!contains(GD_VARIANTS, $$GD_VARIANT) {
    error("GD_VARIANT desconhecida: $$GD_VARIANT. Opções: $$GD_VARIANTS")
}

# Uma pasta de build por variante. Reaproveitar a pasta de outra variante


GD_VARIANT_DIR = $$PWD/variants/$$GD_VARIANT

# variant.pri define:
#   GD_PRODUCT          nome exibido (GD60)
#   GD_TARGET           nome do executável / biblioteca Android
#   GD_APP_NAME         nome do produto nos metadados do executável
#   GD_SETTINGS_NAME    QCoreApplication::applicationName. Define o arquivo de
#                       QSettings e a pasta de dados: trocar zera as
#                       configurações dos tablets já em campo.
#   GD_ANDROID_PACKAGE  package Android: trocar instala um app novo em vez de atualizar
#   GD_ANDROID_LABEL    nome do ícone no Android
#   GD_VERSION          versão do produto (x.y.z)
#   GD_BUILD            número de build dentro da versão (opcional, 0..999)
#   GD_FEATURES         recursos ligados no produto (rc_override, ...)
include($$GD_VARIANT_DIR/variant.pri)

message("Global Drones $$GD_PRODUCT ($$GD_VARIANT) versão $$GD_VERSION")

#-------------------------------------------------------------------------------
# Identidade

DEFINES += CUSTOMHEADER=\"\\\"GDCorePlugin.h\\\"\"
DEFINES += CUSTOMCLASS=GDCorePlugin

TARGET              = $$GD_TARGET
QGC_APP_NAME        = $$GD_APP_NAME
QGC_ORG_NAME        = "QGroundControl.org"
QGC_ORG_DOMAIN      = "org.qgroundcontrol"
QGC_ANDROID_PACKAGE = $$GD_ANDROID_PACKAGE
QGC_APP_DESCRIPTION = "Global Drones $$GD_PRODUCT ground control station"
QGC_APP_COPYRIGHT   = "Copyright (C) Global Drones. Based on QGroundControl."

# Os builds anteriores não eram custom build e usavam estes valores padrão do
# QGC. Eles entram no caminho do QSettings, então permanecem iguais.
DEFINES += QGC_APPLICATION_NAME=\"\\\"$$GD_SETTINGS_NAME\\\"\"
DEFINES += QGC_ORG_NAME=\"\\\"QGroundControl.org\\\"\"
DEFINES += QGC_ORG_DOMAIN=\"\\\"org.qgroundcontrol\\\"\"

DEFINES += GD_VARIANT_$$upper($$GD_VARIANT)
DEFINES += GD_PRODUCT_NAME=\"\\\"$$GD_PRODUCT\\\"\"
DEFINES += GD_VERSION_STR=\"\\\"$$GD_VERSION\\\"\"
for(feature, GD_FEATURES) {
    DEFINES += GD_FEATURE_$$upper($$feature)
}

WindowsBuild {
    RC_ICONS = $$PWD/res/icons/qgroundcontrol.ico
}

#-------------------------------------------------------------------------------
# Versão
#
# O QGCCommon.pri calcula a versão a partir do git describe, que num repositório
# com cinco produtos pegaria a tag de qualquer um deles. A versão vem do
# variant.pri. O versionCode Android precisa sempre crescer em relação ao APK
# instalado no tablet, senão o Android recusa a atualização.

isEmpty(GD_BUILD): GD_BUILD = 0
VERSION = $${GD_VERSION}.$${GD_BUILD}

AndroidBuild {
    GD_MAJOR = $$section(GD_VERSION, ".", 0, 0)
    GD_MINOR = $$section(GD_VERSION, ".", 1, 1)
    GD_PATCH = $$section(GD_VERSION, ".", 2, 2)
    GD_DEV   = $$GD_BUILD

    greaterThan(GD_MAJOR, 9): error("Versão principal com mais de 1 dígito: $$GD_MAJOR")
    greaterThan(GD_MINOR, 9): error("Versão secundária com mais de 1 dígito: $$GD_MINOR")
    greaterThan(GD_PATCH, 99): error("Patch com mais de 2 dígitos: $$GD_PATCH")
    greaterThan(GD_DEV, 999): error("GD_BUILD com mais de 3 dígitos: $$GD_DEV")

    lessThan(GD_PATCH, 10): GD_PATCH = $$join(GD_PATCH, "", "0")
    lessThan(GD_DEV, 10):   GD_DEV = $$join(GD_DEV, "", "0")
    lessThan(GD_DEV, 100):  GD_DEV = $$join(GD_DEV, "", "0")

    # Mesmo formato do QGC: BBMIPPDDD (BB = 66 para arm64, 34 para 32 bits)
    equals(ANDROID_TARGET_ARCH, arm64-v8a) {
        GD_BITNESS = 66
    } else {
        GD_BITNESS = 34
    }
    ANDROID_VERSION_CODE = $${GD_BITNESS}$${GD_MAJOR}$${GD_MINOR}$${GD_PATCH}$${GD_DEV}
    ANDROID_VERSION_NAME = $$GD_VERSION
    message("Android versionCode $$ANDROID_VERSION_CODE versionName $$ANDROID_VERSION_NAME")
}

#-------------------------------------------------------------------------------
# Opções de build comuns a todos os produtos

CONFIG  += DISABLE_AIRMAP
DEFINES += DISABLE_AIRMAP
DEFINES += GLIB_DISABLE_DEPRECATION_WARNINGS
DEFINES += QGC_DISABLE_QTNFC
CONFIG  += QGC_DISABLE_PX4_PLUGIN_FACTORY

#-------------------------------------------------------------------------------
# Código comum

INCLUDEPATH += \
    $$PWD/src \
    $$PWD/../src/SiYi

HEADERS += \
    $$PWD/src/GDCorePlugin.h \
    $$PWD/src/GDSettings.h \
    $$PWD/src/GDUrlInterceptor.h

SOURCES += \
    $$PWD/src/GDCorePlugin.cc \
    $$PWD/src/GDSettings.cc \
    $$PWD/src/GDUrlInterceptor.cc

# Cada módulo comum tem seu .pri em custom/src/<módulo>/<módulo>.pri
GD_MODULES = telemetry rcoverride checklist fence
for(module, GD_MODULES) {
    include($$PWD/src/$${module}/$${module}.pri)
}

# Recursos comuns. QMLs que substituem arquivos da base ficam com o prefixo
# /gdc e o mesmo caminho do original (ver GDUrlInterceptor).
RESOURCES += $$files($$PWD/qrc/*.qrc)

# Recursos e substituições da variante (prefixo /gdv)
RESOURCES += $$files($$GD_VARIANT_DIR/*.qrc)

#-------------------------------------------------------------------------------
# Android: o android.pri mescla android/ (base), custom/android (manifesto e
# ícones GD) e custom/variants/<variante>/android, se existir. O package vem de
# QGC_ANDROID_PACKAGE e o nome do ícone de CUSTOM_ANDROID_LABEL.

CUSTOM_ANDROID_VARIANT_DIR = $$GD_VARIANT_DIR/android
CUSTOM_ANDROID_LABEL       = $$GD_ANDROID_LABEL
