# Описание проекта "База данных системы онлайн тестирования"

Данный проект представляет собой базу данных для хранения информации об участниках тестирования, компаниях, тестах, задачах и результатах тестирования. В базе данных реализованы таблицы и хранимые процедуры для добавления новых данных, а также триггеры для автоматического выполнения определенных действий при добавлении или изменении данных.

### Структура базы данных:

1. Таблица `Person` хранит информацию о пользователях, их идентификаторы, имена, адреса, компании, рейтинг и даты создания записей.
2. Таблица `Selding` содержит данные о прохождении тестов участниками, их идентификаторы, идентификаторы тестов, результаты, время начала и окончания тестирования.
3. Таблица `Test` содержит информацию о самих тестах, их идентификаторы, временные ограничения и количество задач.
4. Таблица `Task` хранит описания заданий для тестов и правильные ответы на них.
5. Таблица `Company` содержит информацию о компаниях, их идентификаторы, названия, даты создания и рейтинг.
6. Таблицы `TaskTest` и `CompanyTest` используются для связывания тестов с задачами и компаниями соответственно.

### Запросы анализа данных:

1. Ранжирование организаций участников по количеству участников, среднему и максимальному рейтингу.
2. Ранжирование компаний, выпускающих тесты, по количеству проведенных тестов.
3. Ранжирование тестов по количеству попыток, среднему и максимальному результатам.
4. Участники средний балл за тесты выше 7.
5. Результаты участников, которые учатся на ФПМИ.
6. Тесты, над созданием которых трудились несколько компаний.
7. Компании, которые разрабатывали тесты с двумя и более другими компаниями.
8. Участники, которые делали несколько попыток на один тест.
9. Задачи, где встречается слово "цикл".
10. Попытки, отправленные в январе.

### Хранимые процедуры и функции:

1. Процедура `AddPerson` для добавления нового пользователя.
2. Процедура `AddTest` для добавления нового теста.
3. Функция `get_last_selding_id` для получения последней попытки пользователя на тест.
4. Триггер `increase_company_rating`, который увеличивает рейтинг компании при добавлении нового теста.
5. Триггер `insert_selding` для автоматического добавления времени и результата при добавлении новой попытки.
6. Триггер `delete_task_from_test` для удаления задачи из теста при изменении стоимости на 0.

Данный проект позволяет хранить и анализировать информацию о тестировании и его результатам, а также автоматизировать некоторые процессы при добавлении и изменении данных в базе.
