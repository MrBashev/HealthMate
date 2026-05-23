#include "DataService.h"
#include <QDate>
#include <QSqlError>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>
#include <QDir>
#include <QDate>
#include <QUrl>


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

    query.exec(R"(
    CREATE TABLE IF NOT EXISTS user_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        calories INTEGER DEFAULT 2000,
        protein REAL DEFAULT 150,
        fat REAL DEFAULT 70,
        carbs REAL DEFAULT 250,
        water INTEGER DEFAULT 2000
    )
)");

    query.exec(R"(
    CREATE TABLE IF NOT EXISTS water_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        ml INTEGER NOT NULL
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

    // === ТАБЛИЦА ШАБЛОНОВ ===
    query.exec(R"(
        CREATE TABLE IF NOT EXISTS meal_templates (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at TEXT DEFAULT (datetime('now','localtime'))
        )
    )");

    query.exec(R"(
        CREATE TABLE IF NOT EXISTS template_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            template_id INTEGER NOT NULL,
            food_id INTEGER NOT NULL,
            grams REAL NOT NULL,
            meal TEXT NOT NULL,
            FOREIGN KEY(template_id) REFERENCES meal_templates(id) ON DELETE CASCADE,
            FOREIGN KEY(food_id) REFERENCES food_items(id)
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

QVariantList DataService::getWeekCalories(QString endDate) {
    QVariantList result;
    QSqlQuery query;

    // Запрос: сумма калорий по дням за последние 7 дней
    query.prepare(R"(
        SELECT
            log_date,
            SUM(f.calories_per_100g * d.grams / 100.0) as total_cal
        FROM daily_log d
        JOIN food_items f ON d.food_id = f.id
        WHERE log_date <= ? AND log_date >= date(?, '-6 days')
        GROUP BY log_date
        ORDER BY log_date ASC
    )");
    query.addBindValue(endDate);
    query.addBindValue(endDate);

    qDebug() << "[DB] Запрос графика за неделю до:" << endDate;

    if (query.exec()) {
        while (query.next()) {
            QVariantMap day;
            day["date"] = query.value(0);  // "2025-04-25"
            day["calories"] = query.value(1).toInt();  // 1450
            result.append(day);
            qDebug() << "  " << query.value(0).toString()
                     << ":" << query.value(1).toInt() << "ккал";
        }
    } else {
        qDebug() << "[DB] Ошибка запроса графика:" << query.lastError().text();
    }

    return result;
}

QVariantList DataService::getAllFoods() {
    QVariantList result;
    // ✅ Запрашиваем ВСЕ нутриенты, а не только калории
    QSqlQuery query("SELECT id, name, calories_per_100g, protein, fat, carbs FROM food_items ORDER BY name ASC");
    qDebug() << "[DB] Запрос продуктов, найдено:";
    while (query.next()) {
        QVariantMap item;
        item["id"] = query.value(0);
        item["name"] = query.value(1);
        item["calories"] = query.value(2).toInt();
        item["protein"] = query.value(3).toDouble();
        item["fat"] = query.value(4).toDouble();
        item["carbs"] = query.value(5).toDouble();
        result.append(item);
        qDebug() << "  -" << query.value(1).toString()
                 << ":" << query.value(2).toInt() << "ккал"
                 << "| Б:" << query.value(3).toDouble()
                 << "Ж:" << query.value(4).toDouble()
                 << "У:" << query.value(5).toDouble();
    }
    return result;
}

bool DataService::addLogEntry(int foodId, double grams, QString meal, QString date) {
    qDebug() << "[DB] Добавление записи: foodId=" << foodId
             << ", grams=" << grams
             << ", meal=" << meal
             << ", date=" << date;

    QSqlDatabase db = QSqlDatabase::database();

    // 1️⃣ Проверяем: есть ли уже такая запись за этот день?
    QSqlQuery check(db);
    check.prepare("SELECT id, grams FROM daily_log WHERE log_date = ? AND food_id = ? AND meal = ?");
    check.addBindValue(date);
    check.addBindValue(foodId);
    check.addBindValue(meal);

    if (check.exec() && check.next()) {
        // ✅ Запись есть → СУММИРУЕМ граммы
        double existingGrams = check.value(1).toDouble();
        double newGrams = existingGrams + grams;
        int logId = check.value(0).toInt();

        QSqlQuery upd(db);
        upd.prepare("UPDATE daily_log SET grams = ? WHERE id = ?");
        upd.addBindValue(newGrams);
        upd.addBindValue(logId);

        bool success = upd.exec();

        if (success) {
            qDebug() << "[DB] 🔄 Обновлено:" << foodId
                     << existingGrams << "г + " << grams << "г = " << newGrams << "г";
            emit dataChanged();
        } else {
            qDebug() << "[DB] Ошибка обновления:" << upd.lastError().text();
        }

        return success;

    } else {
        // ❌ Записи нет → СОЗДАЁМ новую
        QSqlQuery query(db);
        query.prepare("INSERT INTO daily_log (food_id, grams, meal, log_date) VALUES (?, ?, ?, ?)");
        query.addBindValue(foodId);
        query.addBindValue(grams);
        query.addBindValue(meal);
        query.addBindValue(date);

        bool success = query.exec();

        if (success) {
            qDebug() << "[DB] ➕ Добавлено:" << foodId << grams << "г на" << date;
            emit dataChanged();
        } else {
            qDebug() << "[DB] Ошибка вставки:" << query.lastError().text();
        }

        return success;
    }
}

QVariantList DataService::searchFoods(QString query) {
    QVariantList result;
    QSqlQuery q;

    // ✅ Используем q, а не sqlQuery
    q.prepare(R"(
        SELECT id, name, calories_per_100g, protein, fat, carbs
        FROM food_items
        WHERE LOWER(name) LIKE LOWER(?)
        ORDER BY name ASC
    )");

    // ✅ Используем параметр query (не searcText!)
    q.addBindValue("%" + query + "%");

    if (!q.exec()) {
        qDebug() << "[SEARCH] Ошибка:" << q.lastError().text();
        return result;
    }

    while (q.next()) {
        QVariantMap item;
        item["id"] = q.value(0);
        item["name"] = q.value(1);
        item["calories"] = q.value(2).toInt();
        item["protein"] = q.value(3).toDouble();
        item["fat"] = q.value(4).toDouble();
        item["carbs"] = q.value(5).toDouble();
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

    // ✅ Добавляем нутриенты в SELECT
    query.prepare("SELECT d.id, f.name, d.grams, d.meal, "
                  "f.calories_per_100g, f.protein, f.fat, f.carbs "
                  "FROM daily_log d "
                  "JOIN food_items f ON d.food_id = f.id "
                  "WHERE d.log_date = ? "
                  "ORDER BY "
                  "  CASE d.meal "
                  "    WHEN 'breakfast' THEN 1 "
                  "    WHEN 'lunch' THEN 2 "
                  "    WHEN 'dinner' THEN 3 "
                  "    WHEN 'snack' THEN 4 "
                  "    ELSE 5 "
                  "  END, "
                  "  d.id");
    query.addBindValue(date);

    if (!query.exec()) {
        qDebug() << "[DB] Ошибка запроса:" << query.lastError().text();
        return result;
    }

    while (query.next()) {
        QVariantMap entry;
        double grams = query.value(2).toDouble();
        double calPer100 = query.value(4).toDouble();

        entry["id"] = query.value(0);
        entry["name"] = query.value(1);
        entry["grams"] = grams;
        entry["meal"] = query.value(3);

        // ✅ Рассчитываем КБЖУ для конкретных граммов
        entry["calories"] = calPer100 * grams / 100.0;
        entry["protein"] = query.value(5).toDouble() * grams / 100.0;
        entry["fat"] = query.value(6).toDouble() * grams / 100.0;
        entry["carbs"] = query.value(7).toDouble() * grams / 100.0;

        result.append(entry);

        qDebug() << "  -" << query.value(1).toString()
                 << ":" << grams << "г"
                 << "| К:" << entry["calories"].toDouble()
                 << "Б:" << entry["protein"].toDouble()
                 << "Ж:" << entry["fat"].toDouble()
                 << "У:" << entry["carbs"].toDouble();
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
QVariantMap DataService::getTodayMacros() {
    QVariantMap result;
    QString today = QDate::currentDate().toString("yyyy-MM-dd");

    QSqlQuery query;
    query.prepare(R"(
        SELECT
            SUM(f.protein * d.grams / 100.0) as total_protein,
            SUM(f.fat * d.grams / 100.0) as total_fat,
            SUM(f.carbs * d.grams / 100.0) as total_carbs
        FROM daily_log d
        JOIN food_items f ON d.food_id = f.id
        WHERE d.log_date = ?
    )");
    query.addBindValue(today);

    double protein = 0, fat = 0, carbs = 0;

    if (query.exec() && query.next()) {
        protein = query.value(0).toDouble();
        fat = query.value(1).toDouble();
        carbs = query.value(2).toDouble();
    }

    result["protein"] = protein;
    result["fat"] = fat;
    result["carbs"] = carbs;
    result["total"] = protein + fat + carbs;

    qDebug() << "[DB] БЖУ за сегодня:";
    qDebug() << "  Белки:" << protein << "г";
    qDebug() << "  Жиры:" << fat << "г";
    qDebug() << "  Углеводы:" << carbs << "г";

    return result;
}

int DataService::getWaterSum(QString date) {
    QSqlQuery q;
    q.prepare("SELECT SUM(ml) FROM water_logs WHERE date = ?");
    q.addBindValue(date);
    if (q.exec() && q.next()) return q.value(0).toInt();
    return 0;
}

bool DataService::addWater(QString date, int ml) {
    QSqlQuery q;
    q.prepare("INSERT INTO water_logs (date, ml) VALUES (?, ?)");
    q.addBindValue(date);
    q.addBindValue(ml);
    return q.exec();
}

bool DataService::clearWater(QString date) {
    QSqlQuery q;
    q.prepare("DELETE FROM water_logs WHERE date = ?");
    q.addBindValue(date);
    return q.exec();
}

QVariantMap DataService::getGoals(QString date) {
    QVariantMap result;
    QSqlQuery q;
    q.prepare("SELECT calories, protein, fat, carbs, water FROM user_goals WHERE date = ?");
    q.addBindValue(date);

    // Значения по умолчанию
    result["calories"] = 2000;
    result["protein"] = 150.0;
    result["fat"] = 70.0;
    result["carbs"] = 250.0;
    result["water"] = 2000;

    if (q.exec() && q.next()) {
        result["calories"] = q.value(0).toInt();
        result["protein"] = q.value(1).toDouble();
        result["fat"] = q.value(2).toDouble();
        result["carbs"] = q.value(3).toDouble();
        result["water"] = q.value(4).toInt();
    }

    return result;
}

bool DataService::saveGoals(QString date, int calories, double protein, double fat, double carbs, int water) {
    QSqlQuery q;
    q.prepare(R"(
        INSERT OR REPLACE INTO user_goals (date, calories, protein, fat, carbs, water)
        VALUES (?, ?, ?, ?, ?, ?)
    )");
    q.addBindValue(date);
    q.addBindValue(calories);
    q.addBindValue(protein);
    q.addBindValue(fat);
    q.addBindValue(carbs);
    q.addBindValue(water);
    return q.exec();
}
#include <QUrl>
#include <QFileInfo>
#include <QDir>
#include <QStandardPaths>

QString DataService::getBackupDir() {
    // Android: строго Downloads (единственная папка с гарантированным доступом)
    // Desktop: Documents (привычно для пользователя)
    QString path = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    if (path.isEmpty() || path.contains("Android/data")) {
        path = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    }
    QDir().mkpath(path);
    return path;
}

QString DataService::exportToCSV(const QString &targetUri) {
    qDebug() << "[EXPORT] Получен путь/URI:" << targetUri;

    QString path = targetUri;
    // Преобразуем file:// и content:// в понятный Qt путь
    if (path.startsWith("file://") || path.startsWith("content://")) {
        QUrl url(path);
        path = url.isLocalFile() ? url.toLocalFile() : url.toString();
    }

    // Если пользователь выбрал папку, а не файл, Qt может вернуть путь без имени.
    // Добавляем имя файла, если его нет
    if (!path.contains(".csv", Qt::CaseInsensitive)) {
        path += "/HealthMate_Backup_" + QDate::currentDate().toString("yyyy-MM-dd") + ".csv";
        QDir().mkpath(QFileInfo(path).absolutePath());
    }

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
        qDebug() << "[EXPORT] ❌ Не удалось открыть файл:" << path << "|" << file.errorString();
        return "Ошибка записи: " + file.errorString();
    }

    QTextStream out(&file);
    out.setGenerateByteOrderMark(true);
    out.setEncoding(QStringConverter::Utf8);

    QSqlDatabase db = QSqlDatabase::database();
    int foodCount = 0;
    int logCount = 0;

    // 1. ПРОДУКТЫ
    out << "#FOOD_ITEMS\n";
    QSqlQuery q(db);
    if (!q.exec("SELECT id, name, calories_per_100g, protein, fat, carbs FROM food_items")) {
        qDebug() << "[EXPORT] Ошибка запроса продуктов:" << q.lastError().text();
        out << "# SQL ERROR\n";
    } else {
        while (q.next()) {
            QString n = q.value(1).toString();
            n.replace(",", " ").replace("\"", "\"\"");
            out << q.value(0).toString() << ",\"" << n << "\","
                << q.value(2).toString() << "," << q.value(3).toString() << ","
                << q.value(4).toString() << "," << q.value(5).toString() << "\n";
            foodCount++;
        }
    }

    // 2. ДНЕВНИК
    out << "\n#DAILY_LOGS\n";
    QSqlQuery l(db);
    if (!l.exec("SELECT d.log_date, f.name, d.grams, d.meal FROM daily_log d LEFT JOIN food_items f ON d.food_id = f.id")) {
        qDebug() << "[EXPORT] Ошибка запроса дневника:" << l.lastError().text();
        out << "# SQL ERROR\n";
    } else {
        while (l.next()) {
            QString n = l.value(1).toString();
            n.replace(",", " ").replace("\"", "\"\"");
            out << l.value(0).toString() << ",\"" << n << "\","
                << l.value(2).toString() << "," << l.value(3).toString() << "\n";
            logCount++;
        }
    }

    out.flush();
    file.close();

    qDebug() << "[EXPORT] ✅ Готово. Продуктов:" << foodCount << "| Записей:" << logCount << "| Путь:" << path;

    if (foodCount == 0 && logCount == 0) {
        return "Внимание: База пуста. Файл создан, но данных нет.";
    }
    return "Успех: Сохранено " + QString::number(foodCount) + " продуктов и " + QString::number(logCount) + " записей.";
}

QString DataService::importFromCSV(const QString &filePath) {
    QString path = filePath;
    if (path.startsWith("file://")) {
        QUrl url(path);
        path = url.isLocalFile() ? url.toLocalFile() : url.toString();
    }

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return "Ошибка открытия: " + file.errorString();
    }

    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8);

    QString section = "";
    int imported = 0;
    QSqlDatabase db = QSqlDatabase::database();
    db.transaction();

    try {
        while (!in.atEnd()) {
            QString line = in.readLine().trimmed();
            if (line.isEmpty() || line.startsWith("#")) {
                if (line == "#FOOD_ITEMS") section = "foods";
                else if (line == "#DAILY_LOGS") section = "logs";
                continue;
            }

            QStringList parts = line.split(',');
            if (parts.size() < 4) continue;

            if (section == "foods") {
                QString name = parts[1].remove('"').trimmed();
                int cal = parts[2].toInt();
                double p = parts[3].toDouble();
                double f = parts[4].toDouble();
                double c = parts[5].toDouble();

                // Проверяем, есть ли продукт (без учёта регистра)
                QSqlQuery check(db);
                check.prepare("SELECT id FROM food_items WHERE LOWER(TRIM(name)) = LOWER(?)");
                check.addBindValue(name);

                if (check.exec() && !check.next()) {
                    // Нет → добавляем
                    QSqlQuery ins(db);
                    ins.prepare("INSERT INTO food_items (name, calories_per_100g, protein, fat, carbs) VALUES (?, ?, ?, ?, ?)");
                    ins.addBindValue(name); ins.addBindValue(cal);
                    ins.addBindValue(p); ins.addBindValue(f); ins.addBindValue(c);
                    if (ins.exec()) imported++;
                }
            }
            else if (section == "logs") {
                QString date = parts[0].trimmed();
                QString foodName = parts[1].remove('"').trimmed();
                int grams = parts[2].toInt();
                QString meal = parts[3].trimmed();

                // 1️⃣ Находим продукт (без учёта регистра)
                QSqlQuery findFood(db);
                findFood.prepare("SELECT id FROM food_items WHERE LOWER(TRIM(name)) = LOWER(?)");
                findFood.addBindValue(foodName);

                if (!findFood.exec() || !findFood.next()) {
                    qDebug() << "[IMPORT] ⚠️ Продукт не найден:" << foodName;
                    continue;
                }

                int foodId = findFood.value(0).toInt();

                // 2️⃣ ГЛАВНОЕ: Проверяем, есть ли УЖЕ такая запись за эту дату
                QSqlQuery checkLog(db);
                checkLog.prepare("SELECT id, grams FROM daily_log WHERE log_date = ? AND food_id = ?");
                checkLog.addBindValue(date);
                checkLog.addBindValue(foodId);

                if (checkLog.exec() && checkLog.next()) {
                    // ✅ Запись есть → ОБНОВЛЯЕМ (не добавляем новую!)
                    int logId = checkLog.value(0).toInt();
                    int existingGrams = checkLog.value(1).toInt();

                    QSqlQuery upd(db);
                    upd.prepare("UPDATE daily_log SET grams = ?, meal = ? WHERE id = ?");
                    upd.addBindValue(grams);
                    upd.addBindValue(meal);
                    upd.addBindValue(logId);

                    if (upd.exec()) {
                        imported++;
                        qDebug() << "[IMPORT] 🔄 Обновлено:" << foodName << grams << "г на" << date;
                    }
                } else {
                    // ❌ Записи нет → ДОБАВЛЯЕМ
                    QSqlQuery ins(db);
                    ins.prepare("INSERT INTO daily_log (log_date, food_id, grams, meal) VALUES (?, ?, ?, ?)");
                    ins.addBindValue(date);
                    ins.addBindValue(foodId);
                    ins.addBindValue(grams);
                    ins.addBindValue(meal);

                    if (ins.exec()) {
                        imported++;
                        qDebug() << "[IMPORT] ➕ Добавлено:" << foodName << grams << "г на" << date;
                    }
                }
            }
        }
        db.commit();
        return "Успех: Обработано " + QString::number(imported) + " записей.";
    } catch (...) {
        db.rollback();
        return "Ошибка структуры файла.";
    }
}

void DataService::cleanTrash() {
    qDebug() << "[CLEANUP] 📦 Чтение продуктов в память...";
    QSqlQuery q("SELECT id, name FROM food_items ORDER BY id ASC");

    struct RawItem { int id; QString name; };
    QList<RawItem> items;
    while (q.next()) {
        items.append({q.value(0).toInt(), q.value(1).toString()});
    }

    QMap<QString, int> kept; // "чистое_имя" -> ID

    for (const auto &it : items) {
        // ✅ Исправлено: используем QChar или remove
        QString clean = it.name;
        clean = clean.remove('"').trimmed();  // Убираем кавычки
        QString key = clean.toLower();        // Для сравнения

        if (kept.contains(key)) {
            // 🗑️ Дубль: удаляем
            QSqlQuery del;
            del.prepare("DELETE FROM food_items WHERE id = ?");
            del.addBindValue(it.id);
            del.exec();
            qDebug() << "   ❌ Удалён дубль:" << it.name;
        } else {
            // ✅ Первый раз: запоминаем
            kept.insert(key, it.id);

            // Если были кавычки — исправляем
            if (it.name.contains('"')) {
                QSqlQuery upd;
                upd.prepare("UPDATE food_items SET name = ? WHERE id = ?");
                upd.addBindValue(clean);
                upd.addBindValue(it.id);
                upd.exec();
                qDebug() << "   🧼 Убраны кавычки:" << it.name << "→" << clean;
            }
        }
    }
    qDebug() << "[CLEANUP] ✅ Готово. Осталось уникальных:" << kept.size();
}

QString DataService::getFirstLogDate() {
    QSqlQuery q("SELECT MIN(log_date) FROM daily_log");
    if (q.exec() && q.next() && !q.value(0).isNull()) {
        return q.value(0).toString();
    }
    // Если записей нет, возвращаем 1 января 2020 как безопасный минимум
    return "2020-01-01";
}

void DataService::copyDayLogs(QString date) {
    qDebug() << "[COPY] Копирование записей за" << date;
    m_copiedLogs.clear();

    QSqlQuery query;
    query.prepare("SELECT food_id, grams, meal FROM daily_log WHERE log_date = ?");
    query.addBindValue(date);

    if (query.exec()) {
        while (query.next()) {
            QVariantMap entry;
            entry["food_id"] = query.value(0).toInt();
            entry["grams"] = query.value(1).toDouble();
            entry["meal"] = query.value(2).toString();
            m_copiedLogs.append(entry);
        }
    }

    qDebug() << "[COPY] ✅ Скопировано записей:" << m_copiedLogs.size();
    emit dataChanged();
}

bool DataService::hasCopiedLogs() {
    return !m_copiedLogs.isEmpty();
}

int DataService::copiedLogsCount() {
    return m_copiedLogs.size();
}

void DataService::pasteCopiedLogs(QString targetDate) {
    // ✅ Защита: нельзя вставлять в будущее
    QString today = QDate::currentDate().toString("yyyy-MM-dd");
    if (targetDate > today) {
        qDebug() << "[PASTE] ⛔ Блокировка: нельзя вставлять в будущее (" << targetDate << ")";
        return;
    }

    qDebug() << "[PASTE] Вставка" << m_copiedLogs.size() << "записей в" << targetDate;

    for (const QVariant &entryVar : m_copiedLogs) {
        QVariantMap entry = entryVar.toMap();

        int foodId = entry["food_id"].toInt();
        double grams = entry["grams"].toDouble();
        QString meal = entry["meal"].toString();

        addLogEntry(foodId, grams, meal, targetDate);
    }

    qDebug() << "[PASTE] ✅ Вставка завершена";
    emit dataChanged();
}

bool DataService::saveAsTemplate(QString name) {
    qDebug() << "[TEMPLATE] Сохранение шаблона:" << name;
    QSqlDatabase db = QSqlDatabase::database();

    // Берём записи за ТЕКУЩУЮ дату (m_currentDate)
    QSqlQuery getLogs(db);
    getLogs.prepare("SELECT food_id, grams, meal FROM daily_log WHERE log_date = ?");
    getLogs.addBindValue(m_currentDate);

    if (!getLogs.exec() || !getLogs.next()) {
        qDebug() << "[TEMPLATE] ⚠️ Нет записей для сохранения";
        return false;
    }
    getLogs.previous(); // Возвращаемся к началу

    db.transaction();

    // 1. Создаём шаблон
    QSqlQuery insTpl(db);
    insTpl.prepare("INSERT INTO meal_templates (name) VALUES (?)");
    insTpl.addBindValue(name);
    if (!insTpl.exec()) {
        db.rollback();
        return false;
    }
    int tplId = insTpl.lastInsertId().toInt();

    // 2. Копируем записи в template_items
    QSqlQuery insItem(db);
    insItem.prepare("INSERT INTO template_items (template_id, food_id, grams, meal) VALUES (?, ?, ?, ?)");
    int count = 0;
    while (getLogs.next()) {
        insItem.addBindValue(tplId);
        insItem.addBindValue(getLogs.value(0).toInt());
        insItem.addBindValue(getLogs.value(1).toDouble());
        insItem.addBindValue(getLogs.value(2).toString());
        insItem.exec();
        count++;
    }

    db.commit();
    qDebug() << "[TEMPLATE] ✅ Сохранено:" << count << "записей в шаблон" << name;
    emit dataChanged();
    return true;
}

QVariantList DataService::getTemplates() {
    QVariantList result;
    QSqlQuery q("SELECT id, name FROM meal_templates ORDER BY name ASC");
    while (q.next()) {
        QVariantMap tpl;
        tpl["id"] = q.value(0).toInt();
        tpl["name"] = q.value(1).toString();
        result.append(tpl);
    }
    return result;
}

bool DataService::applyTemplate(int templateId, QString targetDate) {
    // ✅ Защита от будущего
    QString today = QDate::currentDate().toString("yyyy-MM-dd");
    if (targetDate > today) {
        qDebug() << "[TEMPLATE] ⛔ Блокировка: нельзя применять в будущее";
        return false;
    }

    qDebug() << "[TEMPLATE] Применение шаблона" << templateId << "на" << targetDate;
    QSqlDatabase db = QSqlDatabase::database();

    QSqlQuery getItems(db);
    getItems.prepare("SELECT food_id, grams, meal FROM template_items WHERE template_id = ?");
    getItems.addBindValue(templateId);

    if (!getItems.exec()) return false;

    int count = 0;
    while (getItems.next()) {
        addLogEntry(
            getItems.value(0).toInt(),
            getItems.value(1).toDouble(),
            getItems.value(2).toString(),
            targetDate
            );
        count++;
    }

    qDebug() << "[TEMPLATE] ✅ Применено" << count << "записей";
    return true;
}

bool DataService::deleteTemplate(int templateId) {
    QSqlQuery q;
    q.prepare("DELETE FROM meal_templates WHERE id = ?");
    q.addBindValue(templateId);
    bool ok = q.exec();
    if (ok) emit dataChanged();
    return ok;
}