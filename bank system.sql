CREATE DATABASE bank_system;
GO

USE bank_system;

CREATE TABLE cities(
    id INT PRIMARY KEY IDENTITY,
    city_name VARCHAR(30) NOT NULL
);
GO

CREATE TABLE banks(
    id INT PRIMARY KEY IDENTITY,
    bank_name VARCHAR(30) NOT NULL
);
GO

CREATE TABLE bank_branches(
    id INT PRIMARY KEY IDENTITY,
    bank_id INT NOT NULL,
    city_id INT NOt NULL
);
GO

CREATE TABLE social_statuses(
    id INT PRIMARY KEY IDENTITY,
    status_name VARCHAR(30) NOT NULL
);
GO

CREATE TABLE clients(
    id INT PRIMARY KEY IDENTITY,
    full_name VARCHAR(30) NOT NULL
);
GO

CREATE TABLE accounts(
    id INT PRIMARY KEY IDENTITY,
    bank_id INT NOT NULL,
    client_id INT NOt NULL,
    balance MONEY NOT NULL
);
GO

CREATE TABLE bank_cards(
    id INT PRIMARY KEY IDENTITY,
    account_id INT NOt NULL,
    balance MONEY NOT NULL
);
GO

INSERT INTO cities (city_name)
VALUES ('Минск'),
       ('Витебск'),
       ('Гродно'),
       ('Гомель'),
       ('Могилев'),
       ('Брест');
GO

INSERT INTO banks (bank_name)
VALUES ('Беларусбанк'),
       ('Белинвестбанк'),
       ('Паритетбанк'),
       ('Сбер Банк'),
       ('МТБанк');
GO

INSERT INTO bank_branches (bank_id, city_id)
VALUES (1, 1),
       (2, 1),
       (2, 2),
       (3, 2),
       (4, 3),
       (5, 5);
GO

INSERT INTO social_statuses (status_name)
VALUES ('Пенсионер'),
       ('Инвалид'),
       ('Школьник'),
       ('Студент'),
       ('Рабочий');
GO

INSERT INTO clients (full_name)
VALUES ('Мельников Аполлон Владимирович'),
       ('Ковалёв Максим Федорович'),
       ('Доронин Леонид Васильевич'),
       ('Карпов Артур Андреевич'),
       ('Муравьёв Александр Авдеевич');
GO

INSERT INTO accounts (bank_id, client_id, balance)
VALUES (1, 1, 270),
       (3, 2, 89),
       (2, 1, 152),
       (4, 5, 27),
       (1, 3, 368);
GO

INSERT INTO bank_cards (account_id, balance)
VALUES (1, 130),
       (2, 89),
       (1, 43),
       (3, 97),
       (4, 27);
GO
