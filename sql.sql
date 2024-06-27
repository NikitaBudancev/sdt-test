-- a. Выбрать имена (name) всех клиентов, которые не делали заказы в последние 7 дней.

SELECT name 
FROM clients 
WHERE id NOT IN (
    SELECT customer_id 
    FROM orders 
    WHERE order_date >= NOW() - INTERVAL 7 DAY
);

-- b. Выбрать имена (name) 5 клиентов, которые сделали больше всего заказов в магазине.

SELECT clients.name 
FROM clients 
JOIN orders ON clients.id = orders.customer_id 
GROUP BY clients.id 
ORDER BY COUNT(orders.id) DESC 
LIMIT 5;

-- c. Выбрать имена (name) 10 клиентов, которые сделали заказы на наибольшую сумму.
-- Здесь не понятно цена нигде не указана. Допустим что цена указана в merchandise в поле price

SELECT clients.name, SUM(merchandise.price) as total
FROM clients
JOIN orders ON clients.id = orders.customer_id
JOIN merchandise ON orders.item_id = merchandise.id
GROUP BY clients.id
ORDER BY total DESC
LIMIT 10;

-- d. Товары, по которым не было доставленных заказов

SELECT merchandise.name 
FROM merchandise 
WHERE id NOT IN (
    SELECT item_id 
    FROM orders 
    WHERE status = 'complete'
);


-- ИНДЕКСЫ

-- Улучшение производительности join операций:
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

CREATE INDEX idx_orders_item_id ON orders(item_id);

-- для ускорения выборки заказов по дате:
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- для ускорения выборки заказов по статусу:
CREATE INDEX idx_orders_status ON orders(status);

-- Их эффективность зависит от объема данных и запросов в приложении. Нужно тестировать индексы на реальных данных и анализировать их с помощью команды EXPLAIN или других инструментов чтобы убедиться в их эффективности.
