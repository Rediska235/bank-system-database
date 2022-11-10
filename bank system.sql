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

/* task 5
Вывести кол-во банковских карточек для каждого соц статуса (2 реализации, GROUP BY и подзапросом)
*/

SELECT status_name, COUNT(bank_cards.id) AS [card count]
FROM social_statuses
    LEFT JOIN clients ON status_id = social_statuses.id
    LEFT JOIN accounts ON client_id = clients.id
    LEFT JOIN bank_cards ON account_id = accounts.id
GROUP BY status_name
ORDER BY 1
GO

SELECT s.status_name, 
       (SELECT COUNT(*)
        FROM bank_cards 
            JOIN accounts ON account_id = accounts.id
            JOIN clients ON client_id = clients.id
            JOIN social_statuses ON status_id = social_statuses.id
        WHERE social_statuses.id = s.id) AS [card count]
FROM social_statuses as s
ORDER BY 1
GO

/* task 6 
Написать stored procedure которая будет добавлять по 10$ на каждый банковский аккаунт 
для определенного соц статуса (У каждого клиента бывают разные соц. статусы. 
Например, пенсионер, инвалид и прочее). 

Входной параметр процедуры - Id социального статуса. 

Обработать исключительные ситуации (например, был введен неверные номер соц. статуса. 
Либо когда у этого статуса нет привязанных аккаунтов).
*/

CREATE PROC income_for_social_status @status_id INT
AS
DECLARE @max_id INT = 0;
SELECT @max_id = MAX(id) FROM social_statuses;

IF @status_id > @max_id 
BEGIN
    RAISERROR('Invalid index: Index greater than maximum', 16, 1);
    RETURN;
END
IF @status_id < 1 
BEGIN
    RAISERROR('Invalid index: Index less than 1', 16, 1);
    RETURN;
END

IF NOT EXISTS(
    SELECT *
    FROM accounts
    WHERE client_id IN (SELECT id 
                        FROM clients 
                        WHERE status_id = @status_id))
BEGIN
    RAISERROR('Invalid index: Theres no accounts for that social status id', 16, 1);
    RETURN;
END

UPDATE accounts 
    SET balance += 10
WHERE client_id IN (SELECT id 
                    FROM clients 
                    WHERE status_id = @status_id)


GO

SELECT client_id, status_id, status_name, balance
FROM accounts
    JOIN clients ON client_id = clients.id
    JOIN social_statuses ON status_id = social_statuses.id

EXEC income_for_social_status 5

SELECT client_id, status_id, status_name, balance
FROM accounts
    JOIN clients ON client_id = clients.id
    JOIN social_statuses ON status_id = social_statuses.id

/* task 7 
Получить список доступных средств для каждого клиента. 
То есть если у клиента на банковском аккаунте 60 рублей, и у него 2 карточки по 15 рублей на каждой, 
то у него доступно 30 рублей для перевода на любую из карт
*/

SELECT full_name, SUM(available_funds) as available_funds
FROM (SELECT full_name, bank_name, (accounts.balance - SUM(bank_cards.balance)) AS available_funds
      FROM accounts
          JOIN bank_cards ON account_id = accounts.id
          JOIN clients ON client_id = clients.id
          JOIN banks ON bank_id = banks.id
      GROUP BY full_name, bank_name, accounts.balance) AS raw_table
GROUP BY full_name

/* task 8 
Написать процедуру которая будет переводить определённую сумму со счёта на карту этого аккаунта.  
При этом будем считать что деньги на счёту все равно останутся, просто сумма средств на карте увеличится. 
Например, у меня есть аккаунт на котором 1000 рублей и две карты по 300 рублей на каждой. 
Я могу перевести 200 рублей на одну из карт, при этом баланс аккаунта останется 1000 рублей, 
а на картах будут суммы 300 и 500 рублей соответственно. После этого я уже не смогу перевести 400 рублей 
с аккаунта ни на одну из карт, так как останется всего 200 свободных рублей (1000-300-500). 

Переводить БЕЗОПАСНО. То есть использовать транзакцию
*/

DROP PROC money_order
GO
CREATE PROC money_order @amount MONEY, @account_id INT, @card_id INT
AS
BEGIN TRANSACTION remittance;  

DECLARE @max_account_id INT = 0;
SELECT @max_account_id = MAX(id) FROM accounts;
IF @account_id > @max_account_id
    OR @account_id < 1
BEGIN
    RAISERROR('Invalid account_id', 16, 1);
    ROLLBACK TRAN;
    RETURN;
END

DECLARE @max_card_id INT = 0;
SELECT @max_card_id = MAX(id) FROM bank_cards;
IF @card_id > @max_card_id
    OR @card_id < 1
BEGIN
    RAISERROR('Invalid card_id', 16, 1);
    ROLLBACK TRAN;
    RETURN;
END

IF NOT EXISTS(
    SELECT *
    FROM accounts
    WHERE id = @account_id)
BEGIN
    RAISERROR('Invalid account_id: Theres no accounts for that account_id', 16, 1);
    ROLLBACK TRAN;
    RETURN;
END

IF NOT EXISTS(
    SELECT *
    FROM bank_cards
    WHERE id = @card_id)
BEGIN
    RAISERROR('Invalid card_id: Theres no cards for that card_id', 16, 1);
    ROLLBACK TRAN;
    RETURN;
END

IF @account_id <> (SELECT account_id FROM bank_cards WHERE id = @card_id)
BEGIN
    RAISERROR('Invalid parameters: This account doesnt have this card', 16, 1);
    ROLLBACK TRAN;
    RETURN;
END

DECLARE @free_amount MONEY;
SELECT @free_amount = accounts.balance 
FROM accounts
WHERE accounts.id = @account_id

SELECT @free_amount -= SUM(bank_cards.balance)
FROM bank_cards
WHERE account_id = @account_id

IF @amount > @free_amount
BEGIN
    RAISERROR('Invalid parameters: Account doesnt have enought money', 16, 1);
    ROLLBACK TRAN;
    RETURN;
END

UPDATE bank_cards
    SET balance += @amount
WHERE id = @card_id

COMMIT TRANSACTION remittance;  
GO

SELECT full_name, accounts.id, accounts.balance, bank_cards.id, bank_cards.balance 
FROM accounts
    JOIN clients ON client_id = clients.id
    JOIN bank_cards ON account_id = accounts.id

EXEC money_order 27, 1, 1

SELECT full_name, accounts.id, accounts.balance, bank_cards.id, bank_cards.balance 
FROM accounts
    JOIN clients ON client_id = clients.id
    JOIN bank_cards ON account_id = accounts.id

/* task 9
Написать триггер на таблицы Account/Cards чтобы нельзя было занести значения в поле баланс если это противоречит условиям  
(то есть нельзя изменить значение в Account на меньшее, чем сумма балансов по всем карточкам. 
И соответственно нельзя изменить баланс карты если в итоге сумма на картах будет больше чем баланс аккаунта)
*/

CREATE TRIGGER trg_accounts ON accounts
    AFTER UPDATE
AS
IF EXISTS(SELECT SUM(bank_cards.balance)
    FROM inserted
        JOIN bank_cards ON account_id = inserted.id
    GROUP BY inserted.id, inserted.balance
    HAVING inserted.balance < SUM(bank_cards.balance))
BEGIN
    RAISERROR('The balance on the account cannot be less than the balance on his cards', 16, 2);
    ROLLBACK TRAN;
END
GO

CREATE TRIGGER trg_bank_cards ON bank_cards
    AFTER INSERT, UPDATE
AS
IF EXISTS(SELECT SUM(bank_cards.balance)
    FROM bank_cards
        JOIN accounts ON account_id = accounts.id
    GROUP BY accounts.id, accounts.balance
    HAVING accounts.balance < SUM(bank_cards.balance))
BEGIN
    RAISERROR('The balance on the cards cannot exceed the balance on the account', 16, 2);
    ROLLBACK TRAN;
END
GO

SELECT accounts.id, accounts.balance, SUM(bank_cards.balance) AS cards_total
FROM bank_cards
    JOIN accounts ON account_id = accounts.id
GROUP BY accounts.id, accounts.balance

UPDATE accounts
SET balance = 290
WHERE id = 1;
GO

UPDATE bank_cards
SET balance = 178
WHERE id = 1;
GO

SELECT accounts.id, accounts.balance, SUM(bank_cards.balance) AS cards_total
FROM bank_cards
    JOIN accounts ON account_id = accounts.id
GROUP BY accounts.id, accounts.balance

