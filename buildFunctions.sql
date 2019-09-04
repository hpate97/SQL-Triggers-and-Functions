delimiter ;;
DROP PROCEDURE IF EXISTS WithdrawFunds;
CREATE PROCEDURE WithdrawFunds(in AccountName varchar(60), in Value DECIMAL(10,2))
BEGIN
UPDATE Person
SET Balance = Balance - Value
WHERE Person.AccountName = AccountName;
SELECT * FROM Person WHERE Person.AccountName = AccountName;
END;;
delimiter ;



delimiter ;;
DROP PROCEDURE IF EXISTS DepositFunds;
CREATE PROCEDURE DepositFunds(in AccountName varchar(60), in Value DECIMAL(10,2))
BEGIN
UPDATE Person
SET Balance = Balance + Value
WHERE Person.AccountName = AccountName;
SELECT * FROM Person WHERE Person.AccountName = AccountName;
END;
;;
delimiter ;



delimiter ;;
DROP FUNCTION IF EXISTS BuyStock;
CREATE FUNCTION BuyStock(PersonName varchar(60), StockName varchar(60), amount int(11))
RETURNS DECIMAL(14,2)

BEGIN
DECLARE TotCost decimal(14,2);

SET TotCost = 0.00;

SELECT CompanyID into @CompID FROM Company WHERE Company.CompanyName = StockName;
SELECT Balance into @Bal FROM Person WHERE Person.AccountName = PersonName;
SELECT AccountID into @AccID FROM Person WHERE Person.AccountName = PersonName;


WHILE amount > 0 DO
	BEGIN
	SELECT Stock.Quantity, LotID, StockID, AccountID, SellOrder.Price, COUNT(*) into
					@Quant,        @LID,   @SID,     @AID,      @P,            @NumRows
	FROM Stock NATURAL JOIN SellOrder
	WHERE CompanyID = CompID AND AccountID <> AccID
	LIMIT 1;
	
	IF (@NumRows = 0) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Insufficient quantity of stock available for purchase';
		RETURN 0.00;
	END IF;
	
	IF (@Q > amount) THEN
		BEGIN
		INSERT INTO Stock(CompanyID, AccountID, Quantity) VALUES (CompID, AccID, amount);
		UPDATE Stock SET Stock.Quantity = @Q - amount WHERE Stock.StockID = @SID;
		UPDATE Person SET Person.Balance = Person.Balance - (@P * amount) WHERE AccountID = AccID;
		UPDATE Person SET Person.Balance = Person.Balance + (@P * amount) WHERE Person.AccountID = @SID;
		SET TotCost = TotCost + (@P * amount);
		SET amount = 0;
		END;
	ELSE
		BEGIN
		DELETE FROM SellOrder WHERE SellOrder.LotID = @LID;
		UPDATE Stock SET Stock.AccountID = AccID WHERE StockID = @SID;
		UPDATE Person SET Person.Balance = Person.Balance - (@P * @Q) WHERE AccountID = AccID;
		UPDATE Person SET Person.Balance = Person.Balance + (@P * @Q) WHERE Person.AccountID = @SID;
		SET amount  = amount - @Q;
		SET TotCost = TotCost + (@P * @Q);
		END;
	END IF;
	IF amount = 0 THEN RETURN TotCost;
	END IF;
END;
END WHILE;
END;
;;
delimiter ;




delimiter ;;
DROP FUNCTION IF EXISTS SellStock;
CREATE FUNCTION SellStock(PersonName varchar(60), StockName varchar(60), amount int(11), price decimal(14,2))
RETURNS TINYINT
BEGIN

SELECT CompanyID into @CompID FROM Company WHERE Company.CompanyName = StockName;
SELECT AccountID into @AccID FROM Person WHERE Person.AccountName = PersonName;

WHILE amount > 0 DO
	BEGIN
	SELECT Stock.Quantity, StockID, AccountID, COUNT(*) into
					@Quant,        @SID,     @AID ,  @NumRows
	FROM Stock LEFT OUTER JOIN SellOrder
	ON Stock.StockID = SellOrder.StockID
	WHERE CompanyID = @CompID AND AccountID = @AccID AND LotID = NULL
	LIMIT 1;
	
	IF (@NumRows = 0) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Insufficient quantity of stock available for purchase';
		RETURN 0;
	END IF;
	
	IF (@Q > amount) THEN
		BEGIN
		INSERT INTO Stock(CompanyID, AccountID, Quantity) VALUES (CompID, AccID, amount);
		INSERT INTO SellOrder(StockID, Price) VALUES (LAST_INSERT_ID(), price);
		UPDATE Stock SET Quantity = @Q - amount WHERE StockID = @SID;
		SET amount = 0;
		END;
	ELSE
		BEGIN
		INSERT INTO SellOrder(StockID, Price) VALUES (@SID, price);
		SET amount = amount - @Q;
		END;
	END IF;
	IF amount = 0 THEN RETURN 1;
	END IF;
END;
END WHILE;
END;
;;
delimiter ;