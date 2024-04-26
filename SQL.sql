DROP TABLE IF EXISTS Selding;
DROP TABLE IF EXISTS TaskTest;
DROP TABLE IF EXISTS CompanyTest;
DROP TABLE IF EXISTS Task;
DROP TABLE IF EXISTS Test;
DROP TABLE IF EXISTS Company;
DROP TABLE IF EXISTS Person;
DROP PROCEDURE IF EXISTS AddPerson (p_UserName varchar(50),
p_Address varchar(50),
p_Company varchar,
p_Rating int);
DROP PROCEDURE IF EXISTS AddTest (
p_Time int,
p_CountTask int
);
CREATE TABLE Person (
  UserID int PRIMARY KEY,
  UserName varchar(50) NOT NULL,
  Address varchar(50) NOT NULL,
  Company varchar NOT NULL,
  Rating int NOT NULL,
  created_at timestamp NOT NULL
);

COPY Person
FROM 'D:\DB_User.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE Selding (
  SeldingID int PRIMARY KEY,
  UserID int,
  TestId int,
  Result int NOT NULL,
  Mask int NOT NULL,
  Start timestamp NOT NULL,
  Finish timestamp NOT NULL
);

COPY Selding
FROM 'D:\BD_selding.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE Test (
  TestID int PRIMARY KEY,
  Time int,
  CountTask int NOT NULL
);

COPY Test
FROM 'D:\BD_Test.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE Task (
  TaskID int PRIMARY KEY,
  data varchar NOT NULL,
  answer int NOT NULL
);

COPY Task
FROM 'D:\BD_Task.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE Company (
  CompanyID int PRIMARY KEY,
  CompanyName varchar NOT NULL,
  created_at timestamp NOT NULL,
  Rating int NOT NULL
);

COPY Company
FROM 'D:\Company.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE TaskTest (
  UniqueId int PRIMARY KEY,
  TestID int,
  TaskID int,
  Costs int NOT NULL
);

COPY TaskTest
FROM 'D:\TestTask.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE CompanyTest (
  UniqueId int PRIMARY KEY,
  TestID int,
  CompanyID int
);

COPY CompanyTest
FROM 'D:\CompanyTest.csv'
DELIMITER ','
CSV HEADER;

ALTER TABLE Selding ADD FOREIGN KEY (UserID) REFERENCES Person (UserID);

ALTER TABLE Selding ADD FOREIGN KEY (TestId) REFERENCES Test (TestID);

ALTER TABLE TaskTest ADD FOREIGN KEY (TestID) REFERENCES Test (TestID);

ALTER TABLE TaskTest ADD FOREIGN KEY (TaskID) REFERENCES Task (TaskID);

ALTER TABLE CompanyTest ADD FOREIGN KEY (TestID) REFERENCES Test (TestID);

ALTER TABLE CompanyTest ADD FOREIGN KEY (CompanyID) REFERENCES Company (CompanyID);

-- Таблица ранжированных организаций участников и вывод их основыных параметров сравнения
Select Company, Count(UserId), AVG(Rating), MAX(Rating) from Person
Group by Company
Order by Count(UserId) DESC, AVG(Rating) DESC, MAX(Rating) DESC;

-- Таблица ранжированных компаний выпускающих тестики и вывод их параметров
Select Company.CompanyName, Count(CompanyTest.UniqueId) from Company Join CompanyTest ON Company.CompanyID = CompanyTest.CompanyID
Group by Company.CompanyName
Order by Count(CompanyTest.UniqueId) DESC;

-- Таблица ранжированных тестов по количеству побы сылок и среднему/лучшему результату 
Select Test.TestID, Count(Selding.SeldingID), Avg(Selding.Result), Max(Selding.Result) from Test Join Selding ON Test.TestID = Selding.TestID
Group by Test.TestID
Order by Count(Selding.SeldingID) DESC, Avg(Selding.Result) DESC, Max(Selding.Result) DESC;

-- Таблица участников у которых средний балл за тесты выше 7
Select Person.UserName, Count(Selding.TestID), Avg(Selding.Result), Max(Selding.Result) from Person Join Selding ON Person.UserID = Selding.UserID
Group by Person.UserID, Person.UserName
Having Avg(Selding.Result) >= 7
Order by Count(Selding.TestID) DESC, Avg(Selding.Result) DESC, Max(Selding.Result) DESC;

-- Таблица результатов участников из учащихся на ФПМИ
Select Person.UserName, Count(Selding.TestID), Avg(Selding.Result), Max(Selding.Result) from Person Join Selding ON Person.UserID = Selding.UserID
WHERE Person.company like 'Б05-%'
Group by Person.UserID, Person.UserName
Order by Count(Selding.TestID) DESC, Avg(Selding.Result) DESC, Max(Selding.Result) DESC;

-- Тесты над созданием, которых трудились несколько компаний
Select Test.TestId, count(CompanyTest.CompanyId)
FROM Test JOIN CompanyTest ON Test.TestID = CompanyTest.TestID
GROUP BY Test.TestId
HAVING count(CompanyTest.CompanyId) > 1;

-- Компании которые разрабатsвали тесты совместно хотя бы с двумя другими комапиниями
Select DISTINCT Company.CompanyName
from Company Join CompanyTest ON Company.CompanyID = CompanyTest.CompanyID
where Company.CompanyID in (Select CompanyID From CompanyTest 
where TestId in (
Select Test.TestId
FROM Test JOIN CompanyTest ON Test.TestID = CompanyTest.TestID
GROUP BY Test.TestId
HAVING count(CompanyTest.CompanyId) > 2));

-- Участники, которые делали несколько попыток на один тест
Select DISTINCT Person.UserName, Selding.TestId
from Person Join Selding ON Person.UserID = Selding.UserID
where (Person.UserID, Selding.TestId) in (Select UserID, TestId From Selding 
Group by UserID, TestId
Having Count(SeldingId) > 1);

-- Задачи про циклы
Select TaskId, data from Task 
where data like '%цикл%';

-- Посылки отправленные в январе
select seldingid, userid, EXTRACT(Day FROM start) as date, result from selding
where EXTRACT(Month FROM start) = 1;

-- Хранимая процедура для добавления нового пользователя
CREATE PROCEDURE AddPerson (p_UserName varchar(50),
p_Address varchar(50),
p_Company varchar,
p_Rating int)
LANGUAGE SQL
AS $$
INSERT INTO Person (UserName, Address, Company, Rating, created_at)
VALUES (p_UserName, p_Address, p_Company, p_Rating, NOW());
$$;

-- Хранимая процедура для добавления нового теста
CREATE PROCEDURE AddTest (
p_Time int,
p_CountTask int
)
LANGUAGE SQL
AS $$
INSERT INTO Test (Time, CountTask)
VALUES (p_Time, p_CountTask);
$$;

-- Хранимая функция вывода последней попытки на пользователя на тест
CREATE OR REPLACE FUNCTION get_last_selding_id(user_id INT, test_id INT)
RETURNS INT 
LANGUAGE plpgsql
AS
$$ 
DECLARE selding_id INT;
BEGIN
	SELECT SeldingID INTO selding_id
	FROM Selding
	WHERE UserID = user_id AND TestId = test_id
	ORDER BY Finish DESC
	LIMIT 1;
	RETURN selding_id;
END; $$;

-- Триггер для автоматического увеличения рейтинга компании при добавлении нового теста
CREATE OR REPLACE FUNCTION increase_company_rating()
RETURNS TRIGGER
AS $$
BEGIN
	UPDATE Company SET Rating = Rating + 1
	WHERE CompanyID = NEW.CompanyID;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER increase_company_rating_trigger AFTER INSERT ON Test 
FOR EACH ROW EXECUTE FUNCTION increase_company_rating();

-- Триггер автоматического добавления времени при добавление новой поссылки и зануления результата если тест просрочен
CREATE OR REPLACE FUNCTION insert_selding()
RETURNS TRIGGER
AS $$
BEGIN
	NEW.FINISH = NOW();
	IF (NEW.FINISH - NEW.START > (SELECT time FROM test WHERE TestID = NEW.TestId)) THEN
	NEW.result = 0;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_selding_trigger AFTER INSERT ON Selding 
FOR EACH ROW EXECUTE FUNCTION insert_selding();

 -- Триггер для автоматического удаления задачи из теста при изменении стоимости на 0
 CREATE OR REPLACE FUNCTION delete_task_from_test() RETURNS TRIGGER
 AS $$ 
 BEGIN 
	 IF NEW.Costs = 0 THEN 
	 	DELETE FROM TaskTest WHERE TaskID = NEW.TaskID; 
	 END IF;
	 RETURN NEW; 
 END; 
 $$ LANGUAGE plpgsql; 
 
 CREATE TRIGGER delete_task_from_test_trigger AFTER UPDATE OF Costs ON TaskTest 
 FOR EACH ROW EXECUTE FUNCTION delete_task_from_test();
