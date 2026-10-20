#pragma once

#include <QObject>

/// Com alvo Android 11+ (API 30+) o QGC não grava mais em
/// /storage/emulated/0/<app> (logs, missões, parâmetros) sem a permissão
/// "Acesso a todos os arquivos". Na abertura do app, se ela não estiver
/// liberada, abre a tela do Android para o piloto liberar; ao voltar ao app,
/// recria as pastas de salvamento que o QGC não conseguiu criar antes.
class GDAndroidStorage : public QObject
{
    Q_OBJECT

public:
    static void requestAllFilesAccessIfNeeded();

private:
    explicit GDAndroidStorage(QObject* parent);

    void _applicationStateChanged(Qt::ApplicationState state);

    static bool _hasAllFilesAccess();
    static bool _openAllFilesAccessSettings();
    static void _createSaveDirectories();
};
