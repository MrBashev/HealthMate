#include "DataService.h"
#include <QDate>
#include <QSqlError>
#include <QDebug>

DataService::DataService(QObject *parent) : QObject(parent) {
    m_currentDate = QDate::currentDate().toString("yyyy-MM-dd");
}

bool DataService::initDatabase() {
    qDebug() << "[DB] Инициализация базы данных...";

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName("healthmate.db");

    if (!m_db.open()) {
        qDebug() << "[DB] Ошибка открытия:" << m_db.lastError().text();
        return false;
    }

    qDebug() << "[DB] База открыта успешно!";

    // Создаём таблицу продуктов
    QSqlQuery query;
    query.exec(R"(
        CREATE TABLE IF NOT EXISTS food_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT,
            calories_per_100g INTEGER NOT NULL,
            protein REAL DEFAULT 0,
            fat REAL DEFAULT 0,
            carbs REAL DEFAULT 0
        )
    )");

    if (query.lastError().isValid()) {
        qDebug() << "[DB] Ошибка создания food_items:" << query.lastError().text();
    }

    // Создаём таблицу записей
    query.exec(R"(
        CREATE TABLE IF NOT EXISTS daily_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            food_id INTEGER NOT NULL,
            grams REAL NOT NULL,
            meal TEXT,
            log_date TEXT NOT NULL,
            FOREIGN KEY (food_id) REFERENCES food_items(id)
        )
    )");

    if (query.lastError().isValid()) {
        qDebug() << "[DB] Ошибка создания daily_log:" << query.lastError().text();
    }

    // Проверяем, есть ли продукты
    query.exec("SELECT COUNT(*) FROM food_items");
    int count = 0;
    if (query.next()) {
        count = query.value(0).toInt();
    }

    qDebug() << "[DB] Продуктов в базе:" << count;

    // Если пусто — добавляем тестовые данные
    if (count == 0) {
        qDebug() << "[DB] Добавляем тестовые продукты...";

        query.prepare("INSERT INTO food_items (name, category, calories_per_100g, protein, fat, carbs) VALUES (?, ?, ?, ?, ?, ?)");

        // 1: Куриная грудка
        query.addBindValue("Куриная грудка"); query.addBindValue("Мясо"); query.addBindValue(165);
        query.addBindValue(31.0); query.addBindValue(3.6); query.addBindValue(0.0);
        query.exec();
        qDebug() << "[DB] Добавлена курица, ID:" << query.lastInsertId().toInt();

        // 2: Гречка
        query.addBindValue("Гречка"); query.addBindValue("Крупы"); query.addBindValue(110);
        query.addBindValue(4.2); query.addBindValue(1.1); query.addBindValue(21.3);
        query.exec();

        // 3: Яблоко
        query.addBindValue("Яблоко"); query.addBindValue("Фрукты"); query.addBindValue(52);
        query.addBindValue(0.3); query.addBindValue(0.2); query.addBindValue(14.0);
        query.exec();

        // 4: Творог
        query.addBindValue("Творог 5%"); query.addBindValue("Молочное"); query.addBindValue(121);
        query.addBindValue(17.0); query.addBindValue(5.0); query.addBindValue(1.8);
        query.exec();

        qDebug() << "[DB] Тестовые продукты добавлены!";
    }

    // Проверяем итоговое количество
    query.exec("SELECT COUNT(*) FROM food_items");
    if (query.next()) {
        qDebug() << "[DB] Итого продуктов:" << query.value(0).toInt();
    }

    return true;
}

QVariantList DataService::getAllFoods() {
    QVariantList result;
    QSqlQuery query("SELECT id, name, calories_per_100g FROM food_items");

    qDebug() << "[DB] Запрос продуктов, найдено:";

    while (query.next()) {
        QVariantMap item;
        item["id"] = query.value(0);
        item["name"] = query.value(1);
        item["calories"] = query.value(2);
        result.append(item);
        qDebug() << "  -" << query.value(1).toString() << ":" << query.value(2).toInt() << "ккал";
    }

    return result;
}

bool DataService::addLogEntry(int foodId, double grams, QString meal, QString date) {
    qDebug() << "[DB] Добавление записи: foodId=" << foodId
             << ", grams=" << grams
             << ", date=" << date;  // ← Используем переданную дату

    QSqlQuery query;
    query.prepare("INSERT INTO daily_log (food_id, grams, meal, log_date) VALUES (?, ?, ?, ?)");
    query.addBindValue(foodId);
    query.addBindValue(grams);
    query.addBindValue(meal);
    query.addBindValue(date);  // ← Сохраняем переданную дату

    bool success = query.exec();

    if (!success) {
        qDebug() << "[DB] Ошибка вставки:" << query.lastError().text();
    } else {
        qDebug() << "[DB] Запись добавлена успешно! ID:" << query.lastInsertId().toInt();
        emit dataChanged();
    }

    return success;
}

QVariantList DataService::searchFoods(QString query) {
    QVariantList result;
    QSqlQuery sqlQuery;
    sqlQuery.prepare("SELECT id, name, calories_per_100g FROM food_items WHERE name LIKE ?");
    sqlQuery.addBindValue("%" + query + "%");
    sqlQuery.exec();

    while (sqlQuery.next()) {
        QVariantMap item;
        item["id"] = sqlQuery.value(0);
        item["name"] = sqlQuery.value(1);
        item["calories"] = sqlQuery.value(2).toInt();
        result.append(item);
    }

    return result;
}

bool DataService::clearDayLogs(QString date) {
    qDebug() << "[DB] Очистка записей за дату:" << date;
    QSqlQuery query;
    query.prepare("DELETE FROM daily_log WHERE log_date = ?");
    query.addBindValue(date);
    bool success = query.exec();
    if (success) {
        emit dataChanged();
    }
    return success;
}
QVariantList DataService::getDayLogs(QString date) {
    qDebug() << "[DB] Запрос записей за дату:" << date;

    QVariantList result;
    QSqlQuery query;
    query.prepare("SELECT d.id, f.name, d.grams, d.meal FROM daily_log d "
                  "JOIN food_items f ON d.food_id = f.id "
                  "WHERE d.log_date = ?");
    query.addBindValue(date);

    if (!query.exec()) {
        qDebug() << "[DB] Ошибка запроса:" << query.lastError().text();
        return result;
    }

    while (query.next()) {
        QVariantMap entry;
        entry["id"] = query.value(0);
        entry["name"] = query.value(1);
        entry["grams"] = query.value(2);
        entry["meal"] = query.value(3);
        result.append(entry);
        qDebug() << "  -" << query.value(1).toString() << ":" << query.value(2).toDouble() << "г";
    }

    qDebug() << "[DB] Найдено записей:" << result.size();
    return result;
}

QVariantMap DataService::getDaySummary(QString date) {
    QVariantMap result;
    QSqlQuery query;

    // Запрос с расчётом всех нутриентов
    query.prepare(R"(
        SELECT
            SUM(f.calories_per_100g * d.grams / 100.0) as total_cal,
            SUM(f.protein * d.grams / 100.0) as total_protein,
            SUM(f.fat * d.grams / 100.0) as total_fat,
            SUM(f.carbs * d.grams / 100.0) as total_carbs
        FROM daily_log d
        JOIN food_items f ON d.food_id = f.id
        WHERE d.log_date = ?
    )");
    query.addBindValue(date);

    int calories = 0;
    double protein = 0, fat = 0, carbs = 0;

    if (query.exec() && query.next()) {
        calories = query.value(0).toInt();
        protein = query.value(1).toDouble();
        fat = query.value(2).toDouble();
        carbs = query.value(3).toDouble();
    }

    qDebug() << "[DB] Итого за" << date << ":";
    qDebug() << "  Ккал:" << calories;
    qDebug() << "  Белки:" << protein << "г";
    qDebug() << "  Жиры:" << fat << "г";
    qDebug() << "  Углеводы:" << carbs << "г";

    result["calories"] = calories;
    result["protein"] = protein;
    result["fat"] = fat;
    result["carbs"] = carbs;

    return result;
}

QVariantList DataService::getWeekStats(QString endDate) {
    QVariantList result;
    QSqlQuery query;

    query.prepare(R"(
        SELECT
            log_date,
            SUM(f.calories_per_100g * d.grams / 100.0) as total_cal,
            SUM(f.protein * d.grams / 100.0) as total_protein,
            SUM(f.fat * d.grams / 100.0) as total_fat,
            SUM(f.carbs * d.grams / 100.0) as total_carbs
        FROM daily_log d
        JOIN food_items f ON d.food_id = f.id
        WHERE log_date <= ? AND log_date >= date(?, '-7 days')
        GROUP BY log_date
        ORDER BY log_date DESC
    )");
    query.addBindValue(endDate);
    query.addBindValue(endDate);

    qDebug() << "[DB] Запрос статистики за неделю...";

    if (query.exec()) {
        while (query.next()) {
            QVariantMap day;
            day["date"] = query.value(0);
            day["calories"] = query.value(1).toInt();
            day["protein"] = query.value(2).toDouble();
            day["fat"] = query.value(3).toDouble();
            day["carbs"] = query.value(4).toDouble();
            result.append(day);
            qDebug() << "  " << query.value(0).toString()
                     << ":" << query.value(1).toInt() << "ккал";
        }
    } else {
        qDebug() << "[DB] Ошибка запроса:" << query.lastError().text();
    }

    return result;
}

bool DataService::deleteLogEntry(int entryId) {
    qDebug() << "[DB] Удаление записи ID:" << entryId;

    QSqlQuery query;
    query.prepare("DELETE FROM daily_log WHERE id = ?");
    query.addBindValue(entryId);

    bool success = query.exec();
    if (success) {
        emit dataChanged();
    }

    return success;
}

void DataService::setCurrentDate(const QString &date) {
    if (m_currentDate != date) {
        m_currentDate = date;
        emit dateChanged();
    }
}