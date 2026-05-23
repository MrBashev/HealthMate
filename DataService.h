#ifndef DATASERVICE_H
#define DATASERVICE_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QVariantList>
#include <QVariantMap>

class DataService : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentDate READ currentDate WRITE setCurrentDate NOTIFY dateChanged)

public:
    explicit DataService(QObject *parent = nullptr);


    Q_INVOKABLE void cleanTrash();
    Q_INVOKABLE void copyDayLogs(QString date);
    Q_INVOKABLE bool hasCopiedLogs();
    Q_INVOKABLE int copiedLogsCount();
    Q_INVOKABLE void pasteCopiedLogs(QString targetDate);
    Q_INVOKABLE QString getBackupDir();
    Q_INVOKABLE QString getFirstLogDate();
    Q_INVOKABLE QString exportToCSV(const QString &targetPath);
    Q_INVOKABLE QString importFromCSV(const QString &filePath);
    Q_INVOKABLE QVariantList getWeekCalories(QString endDate);
    Q_INVOKABLE bool initDatabase();
    Q_INVOKABLE QVariantMap getGoals(QString date);
    Q_INVOKABLE bool saveGoals(QString date, int calories, double protein, double fat, double carbs, int water);
    Q_INVOKABLE int getWaterSum(QString date);
    Q_INVOKABLE bool addWater(QString date, int ml);
    Q_INVOKABLE bool clearWater(QString date);
    Q_INVOKABLE QVariantMap getTodayMacros();
    Q_INVOKABLE bool clearDayLogs(QString date);
    Q_INVOKABLE QVariantList searchFoods(QString query);
    Q_INVOKABLE QVariantList getAllFoods();
    Q_INVOKABLE bool addLogEntry(int foodId, double grams, QString meal, QString date);
    Q_INVOKABLE QVariantList getDayLogs(QString date);
    Q_INVOKABLE QVariantMap getDaySummary(QString date);
    Q_INVOKABLE QVariantList getWeekStats(QString endDate);
    Q_INVOKABLE bool deleteLogEntry(int entryId);

    QString currentDate() const { return m_currentDate; }

public slots:
    void setCurrentDate(const QString &date);

signals:
    void dataChanged();
    void dateChanged();

private:
    QVariantList m_copiedLogs;  // Буфер для копирования дня
    QSqlDatabase m_db;
    QString m_currentDate;
};

#endif