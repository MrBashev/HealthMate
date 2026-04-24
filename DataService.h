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

    // ← ДОБАВЬ ВСЕ ЭТИ ОБЪЯВЛЕНИЯ
    Q_INVOKABLE bool initDatabase();
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
    QSqlDatabase m_db;
    QString m_currentDate;
};

#endif