DROP TABLE IF EXISTS USER;
DROP TABLE IF EXISTS Selding;
DROP TABLE IF EXISTS Task;
DROP TABLE IF EXISTS Test;
DROP TABLE IF EXISTS Company;
DROP TABLE IF EXISTS TaskTest;
DROP TABLE IF EXISTS CompanyTest;

CREATE TABLE User (
  UserID int PRIMARY KEY,
  UserName varchar(50) NOT NULL,
  Address varchar(50) NOT NULL,
  Company varchar NOT NULL,
  Rating int NOT NULL,
  created_at timestamp NOT NULL
);

CREATE TABLE Selding (
  SeldingID int PRIMARY KEY,
  UserID int FOREIGN KEY,
  TestId int FOREIGN KEY,
  Result int NOT NULL,
  Mask int NOT NULL,
  Start timestamp NOT NULL,
  Finish timestamp NOT NULL
);

CREATE TABLE Test (
  TestID int PRIMARY KEY,
  CompanyID int FOREIGN KEY,
  Time int,
  CountTask int NOT NULL
);

CREATE TABLE Task (
  TaskID int PRIMARY KEY,
  data varchar NOT NULL,
  answer int NOT NULL
);

CREATE TABLE Company (
  CompanyID int PRIMARY KEY,
  CompanyName varchar NOT NULL,
  created_at timestamp NOT NULL,
  Rating int NOT NULL
);

CREATE TABLE TaskTest (
  UniqueId int PRIMARY KEY,
  TestID int FOREIGN KEY,
  TaskID int FOREIGN KEY,
  Cost int NOT NULL
);

CREATE TABLE CompanyTest (
  UniqueId int PRIMARY KEY,
  TestID int FOREIGN KEY,
  CompanyID int FOREIGN KEY
);

ALTER TABLE Selding ADD FOREIGN KEY (UserID) REFERENCES User (UserID);

ALTER TABLE Selding ADD FOREIGN KEY (TestId) REFERENCES Test (TestID);

ALTER TABLE TaskTest ADD FOREIGN KEY (TestID) REFERENCES Test (TestID);

ALTER TABLE TaskTest ADD FOREIGN KEY (TaskID) REFERENCES Task (TaskID);

ALTER TABLE CompanyTest ADD FOREIGN KEY (TestID) REFERENCES Test (TestID);

ALTER TABLE CompanyTest ADD FOREIGN KEY (CompanyID) REFERENCES Company (CompanyID);
