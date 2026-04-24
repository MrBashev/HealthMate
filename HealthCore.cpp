#include "HealthCore.h"
#include <cmath>

HealthCore::HealthCore(QObject *parent) : QObject(parent) {}

int HealthCore::calculateBMR(QString gender, int age, double height, double weight) {
    double s = (gender == "M") ? 5.0 : -161.0;
    return qRound((10.0 * weight) + (6.25 * height) - (5.0 * age) + s);
}

int HealthCore::calculateTDEE(int bmr, int activity) {
    const double multipliers[] = {1.2, 1.375, 1.55, 1.725, 1.9};
    int idx = qBound(0, activity - 1, 4);
    return qRound(bmr * multipliers[idx]);
}

bool HealthCore::isSafeGoal(int calories, QString gender) {
    int min = (gender == "M") ? 1500 : 1200;
    return calories >= min && calories <= 4000;
}

int HealthCore::recommendGoal(int tdee, QString goalType) {
    if (goalType == "Похудение") return qMax(tdee - 500, 1200);
    if (goalType == "Набор массы") return tdee + 300;
    return tdee;
}

QVariantMap HealthCore::calculateMacros(int calories, QString goalType) {
    double p = 0.25, f = 0.30, c = 0.45;  // Стандартные пропорции

    if (goalType == "Похудение") {
        p = 0.30; f = 0.30; c = 0.40;  // Больше белка для похудения
    } else if (goalType == "Набор массы") {
        p = 0.25; f = 0.25; c = 0.50;  // Больше углеводов для набора
    }

    QVariantMap result;
    result["protein"] = (calories * p) / 4.0;   // 4 ккал на 1г белка
    result["fat"] = (calories * f) / 9.0;       // 9 ккал на 1г жира
    result["carbs"] = (calories * c) / 4.0;     // 4 ккал на 1г углеводов

    return result;
}