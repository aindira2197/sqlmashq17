START TRANSACTION;

SAVEPOINT InitialState;

UPDATE Products 
SET price = price * 0.9 
WHERE cat_id = (SELECT cat_id FROM Categories WHERE cat_name = 'Electronics');

INSERT INTO SystemLogs (event_type, description)
VALUES ('BULK_DISCOUNT', '10% discount applied to Electronics');

DELETE FROM OrderDetails 
WHERE order_id IN (SELECT order_id FROM Orders WHERE total_amount = 0);

DELETE FROM Orders WHERE total_amount = 0;

IF (SELECT SUM(stock_quantity) FROM Products) < 100 THEN
    ROLLBACK TO SAVEPOINT InitialState;
    INSERT INTO SystemLogs (event_type, description, severity)
    VALUES ('OPERATION_FAILED', 'Discount rolled back due to low total stock', 'WARNING');
ELSE
    COMMIT;
END IF;
