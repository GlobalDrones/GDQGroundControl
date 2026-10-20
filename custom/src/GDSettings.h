#pragma once

#include "SettingsGroup.h"

/// Configurações próprias da Global Drones (grupo "GD" no QSettings).
class GDSettings : public SettingsGroup
{
    Q_OBJECT

public:
    GDSettings(QObject* parent = nullptr);

    DEFINE_SETTING_NAME_GROUP()

    /// Integração com o app externo de checklist pré-voo. Desligada por padrão.
    /// Ligada: mostra o botão do checklist e só permite armar depois dele.
    DEFINE_SETTINGFACT(externalChecklistEnabled)
};
