/* database creation */
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
    status_id INT NOT NULL,
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

/* database filling */
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

INSERT INTO clients (status_id, full_name)
VALUES (5, 'Мельников Аполлон Владимирович'),
       (1, 'Ковалёв Максим Федорович'),
       (5, 'Доронин Леонид Васильевич'),
       (2, 'Карпов Артур Андреевич'),
       (4, 'Муравьёв Александр Авдеевич');
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

/* task 2
Покажи мне список банков у которых есть филиалы в городе X (выбери один из городов)
*/

SELECT bank_name
FROM banks
    JOIN bank_branches ON bank_id = banks.id
    JOIN cities ON city_id = cities.id
WHERE city_name = 'Минск'
GO

/* task 3
Получить список карточек с указанием имени владельца, баланса и названия банка
*/

SELECT full_name, bank_cards.balance, bank_name
FROM bank_cards
    JOIN accounts ON account_id = accounts.id
    JOIN clients ON client_id = clients.id
    JOIN banks ON bank_id = banks.id
GO

/* task 4
Показать список банковских аккаунтов у которых баланс не совпадает с 
суммой баланса по карточкам. В отдельной колонке вывести разницу
*/

SELECT bank_name, full_name, accounts.balance AS account_balance, SUM(bank_cards.balance) AS cards_total, (accounts.balance - SUM(bank_cards.balance)) as balance_difference
FROM accounts
    JOIN bank_cards ON account_id = accounts.id
    JOIN banks ON bank_id = banks.id
    JOIN clients ON client_id = clients.id
GROUP BY bank_name, full_name, accounts.balance
HAVING accounts.balance - SUM(bank_cards.balance) <> 0
GO
