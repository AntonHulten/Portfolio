USE master;
GO
 
-- Check if the database exists and drop it if it does
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'Biluthyrning')
BEGIN
    ALTER DATABASE Biluthyrning SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Biluthyrning;
END
GO
 
-- Create the database
CREATE DATABASE Biluthyrning;
GO
 
-- Use the database
USE Biluthyrning;
GO
 
CREATE TABLE CarDetail (
    CarDetailID INT IDENTITY (1,1) PRIMARY KEY,
    CarTypeName NVARCHAR(20) NOT NULL,
    Seats INT NOT NULL,
    Model NVARCHAR(40) NOT NULL,
    Manufacturer NVARCHAR(30) NOT NULL,
    Color NVARCHAR(20)
);
GO
 
CREATE TABLE Car (
    CarID INT IDENTITY (1,1) PRIMARY KEY,
    CarDetailID INT NOT NULL,
    IsActive BIT NOT NULL,
    PricePerDay DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (CarDetailID) REFERENCES CarDetail(CarDetailID)
);
GO
 
CREATE TABLE Customer (
    CustomerID INT IDENTITY (1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL, 
    LastName NVARCHAR(50) NOT NULL,
    CustomerEmail NVARCHAR(50),
    IsActive BIT NOT NULL
);
GO
 
CREATE TABLE Booking (
    BookingID INT IDENTITY (1,1) PRIMARY KEY,
    CarID INT NOT NULL,
    CustomerID INT NOT NULL,
    StartDate DATE DEFAULT GETDATE() NOT NULL,
    EndDate DATE NOT NULL,
    TotalDays AS DATEDIFF(DAY, StartDate, EndDate),
    Paid BIT NOT NULL
    FOREIGN KEY (CarID) REFERENCES Car(CarID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
GO


ALTER TABLE CarDetail
ADD CONSTRAINT CK_CarDetail_Seats CHECK (
    (CarTypeName = 'Sedan' AND Seats BETWEEN 1 AND 5) OR 
    (CarTypeName = 'SUV' AND Seats BETWEEN 1 AND 7) OR
    (CarTypeName NOT IN ('Sedan', 'SUV'))
);

ALTER TABLE Booking ADD TotalPrice DECIMAL(18,2);
GO

CREATE TRIGGER CalculateTotalPriceBooking
ON Booking
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE B
    SET TotalPrice = DATEDIFF(DAY, B.StartDate, B.EndDate) * C.PricePerDay
    FROM Booking B
    JOIN Car C ON B.CarID = C.CarID
    WHERE B.BookingID IN (SELECT BookingID FROM inserted);
END;
GO

CREATE TRIGGER GenerateInvoice
ON Booking
AFTER INSERT, UPDATE
AS
BEGIN
    INSERT INTO Invoice (BookingID, CustomerID, TotalPrice, IsPaid, IsActive)
    SELECT B.BookingID, B.CustomerID, B.TotalPrice, B.Paid, 1
    FROM inserted B
    WHERE NOT EXISTS (
            SELECT 1 
            FROM Invoice I 
            WHERE I.BookingID = B.BookingID
        );
END;
GO

CREATE TABLE Invoice (
    InvoiceID INT IDENTITY (1,1) PRIMARY KEY,
    BookingID INT,
    CustomerID INT,
    InvoiceDate DATE DEFAULT GETDATE(),
    TotalPrice DECIMAL(18,2),
    IsPaid BIT,
    IsActive BIT,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
GO

INSERT INTO Customer (FirstName, LastName, CustomerEmail, IsActive)
VALUES 
    ('Adam', 'Bertilsson', 'adam@hotmail.com', 0),
    ('Bertil', 'Andersson', 'Bertil@mail.se', 0),
    ('Caesar', 'Kaiser', 'Caesar@romanempire.com', 0),
    ('David', 'Goliat', 'Small@islarge.com', 0),
    ('Erik', 'Eriksson', 'Eriksson@gmail.com', 0),
    ('Frank', 'Andersson', 'Frank@mail.se', 0),
    ('Gustav', 'Erikssson', 'Vasa@du.nu', 1),
    ('Hans', 'Gretchen', 'Hasse@hotmail.se', 0),
    ('Ingvar', 'Kamprad', 'Ingvar@IKEA.se', 0),
    ('Jimmy', 'Forsberg', 'Jimpan@lookatme.nu', 1),
    ('Klas', 'Klättermus', 'Klabbe@tree.se', 1),
    ('Linda', 'Lampenius', 'nice@violins.com', 1),
    ('Mickey', 'Mouse', 'Walt@disney.org', 0),
    ('Nicke', 'Nyfiken', 'Niklas@monkeys.se', 0),
    ('The', 'Hoff', 'Hoffmeister@Gorgeoushair.com', 0);
GO

INSERT INTO CarDetail (CarTypeName, Seats, Model, Manufacturer, Color)
VALUES
    ('Sedan', 5, 'Model S', 'Tesla', 'Black'),
    ('Sedan', 5, 'Polestar 2', 'Polestar', 'White'),
    ('SUV', 7, 'Model X', 'Tesla', 'Blue'),
    ('Mini', 4, 'Polestar 0', 'Polestar', 'Green'),
    ('Tank', 4, 'Challenger 2', 'BAE', 'Camo'),
    ('Convertible', 4, 'C70', 'Volvo', 'Black'),
    ('SuperCar', 2, 'Aventador', 'Lamborghini', 'Yellow'),
    ('ToyCar', 4, 'Lightning McQueen', 'PixarCars', 'Red'),
    ('CandyCar', 1, 'Ahlgrens Bilar', 'Ahlgrens Bilar', 'colorless'),
    ('Mini', 4, 'Austin Mini', 'Austin Martin', 'Pink'),
    ('SuperCar', 2, 'DB 10', 'Austin Martin', 'Gray'),
    ('Knight Rider', 2, 'Firebird Trans Am', 'Pontiac', 'Black');
GO

INSERT INTO Car (CarDetailID, IsActive, PricePerDay)
VALUES
    (1, 1, 1200),
    (2, 1, 1500),
    (3, 0, 1700),
    (4, 1, 2499),
    (5, 1, 17000),
    (6, 1, 32000),
    (7, 1, 12),
    (8, 1, 40),
    (9, 1, 29000),
    (10, 1, 5100),
	(11, 1, 12000),
	(12, 1, 14000);

GO


INSERT INTO Booking (CarID, CustomerID, StartDate, EndDate, Paid)
VALUES
					(1, 1, '2024-03-11', '2024-03-12', 1),
					(8, 5, '2025-02-11', '2025-03-11', 1),
					(9, 4, '2024-12-11', '2024-12-15', 1),
					(5, 11, '2024-01-15', '2024-02-11', 1),
					(6, 6, '2025-02-11', '2025-03-01', 1),
					(7, 14, '2025-02-09', '2025-02-11', 1),
					(7, 10, '2025-02-12', '2025-02-14', 1);





GO


---- Exempel och Försök

INSERT INTO CarDetail (CarTypeName, Seats, Model, Manufacturer, Color)
VALUES
    ('Sedan', 8, 'V70', 'Volvo', 'Black')


SELECT * FROM Booking
SELECT * FROM Invoice


INSERT INTO Booking (CarID, CustomerID, StartDate, EndDate, Paid)
VALUES
(12, 15, '1982-09-26', '1986-4-4', 1)

SELECT c.FirstName, c.LastName, cd.CarTypeName, cd.Model, b.TotalDays, b.TotalPrice
FROM Booking b
INNER JOIN Customer c ON c.CustomerID = b.CustomerID
INNER JOIN Car ca ON b.CarID = ca.CarID
INNER JOIN CarDetail cd ON ca.CarDetailID = cd.CarDetailID
WHERE  BookingID = '8'



Select*
from CarDetail cd
Join Car c on c.CarDetailID = cd.CarDetailID
where IsActive = 1
