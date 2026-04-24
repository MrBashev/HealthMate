#ifndef HEALTHCORE_H
#define HEALTHCORE_H

#include <QObject>
#include <QVariantMap>

class HealthCore : public QObject {
    Q_OBJECT
    Q_PROPERTY(int targetCalories READ targetCalories NOTIFY targetChanged)

public:
    explicit HealthCore(QObject *parent = nullptr);

    Q_INVOKABLE int calculateBMR(QString gender, int age, double height, double weight);
    Q_INVOKABLE int calculateTDEE(int bmr, int activity);
    Q_INVOKABLE bool isSafeGoal(int calories, QString gender);
    Q_INVOKABLE int recommendGoal(int tdee, QString goalType);
    Q_INVOKABLE QVariantMap calculateMacros(int calories, QString goalType);

    int targetCalories() const { return m_targetCalories; }

signals:
    void targetChanged();

private:
    int m_targetCalories = 2000;
};
#endif // HEALTHCORE_H
