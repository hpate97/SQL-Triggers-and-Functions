DROP Trigger IF EXISTS posBalanceUpdate;
delimiter $$

CREATE TRIGGER posBalanceUpdate 
BEFORE INSERT ON Person
FOR EACH ROW 
BEGIN 
    DECLARE msg VARCHAR(255);
    IF NEW.Balance < 0 THEN
        set msg = ('Account Balance must be greater than 0');
        signal sqlstate '45000' set message_text = msg;
    END IF;
END$$
delimiter ;


CREATE TRIGGER posBalanceUpdate 
BEFORE INSERT ON Student
FOR EACH ROW 
BEGIN 
    DECLARE msg VARCHAR(255);
    IF NEW.Balance < 0 THEN
        set msg = ('Account Balance must be greater than 0');
        signal sqlstate '45000' set message_text = msg;
    END IF;
END$$
delimiter ;

DROP Trigger IF EXISTS posBalanceUpdate2;
delimiter $$

CREATE TRIGGER posBalanceUpdate2 
BEFORE UPDATE ON Person
FOR EACH ROW 
BEGIN 
    DECLARE msg VARCHAR(255);
    IF NEW.Balance < 0 THEN
        set msg = ('Account Balance must be greater than 0');
        signal sqlstate '45000' set message_text = msg;
    END IF;
END$$
delimiter ;


DROP Trigger IF EXISTS isValidSell;
delimiter $$

CREATE TRIGGER isValidSell  
BEFORE INSERT ON SellOrder
FOR EACH ROW 
BEGIN 
    DECLARE msg VARCHAR(255); 
    IF NEW.Price < 0.05 THEN
        set msg = ('Minimum transaction price of 0.05');
        signal sqlstate '45000' set message_text = msg;
    END IF;
END$$
delimiter ;


DROP Trigger IF EXISTS isValidSell2;
delimiter $$

CREATE TRIGGER isValidSell2  
BEFORE UPDATE ON SellOrder
FOR EACH ROW 
BEGIN 
    DECLARE msg VARCHAR(255); 
    IF NEW.Price < 0.05 THEN
        set msg = ('Minimum transaction price of 0.05');
        signal sqlstate '45000' set message_text = msg;
    END IF;
END$$
delimiter ;



DROP Trigger IF EXISTS isStockAvailable;
delimiter $$

CREATE TRIGGER isStockAvailable 
BEFORE INSERT ON Stock
FOR EACH ROW 
BEGIN 
    DECLARE msg VARCHAR(255);
    IF NEW.Quantity <= 0 THEN 
        set msg = ('Stock Quantity must be greater than 0');
        signal sqlstate '45000' set message_text = msg;
    END IF;
END$$
delimiter ;


DROP Trigger IF EXISTS isStockAvailable2;
delimiter $$

CREATE TRIGGER isStockAvailable2 
BEFORE UPDATE ON Stock
FOR EACH ROW 
BEGIN 
    DECLARE msg VARCHAR(255);
    IF NEW.Quantity <= 0 THEN 
        set msg = ('Stock Quantity must be greater than 0');
        signal sqlstate '45000' set message_text = msg;
    END IF;
END$$
delimiter ;


