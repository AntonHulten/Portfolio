USE master
GO
 
--Tar bort connection till databasen och raderar den
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'TestKöping')
   BEGIN
	  ALTER DATABASE TestKöping SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
      DROP DATABASE TestKöping
   END
GO
 
-- Skapa databasen
CREATE DATABASE TestKöping; 
GO
 
--Byt till den skapade databasen
USE TestKöping
GO
 
-- Skapa Hushåll-tabellen med HushållsID P.K
CREATE TABLE Hushåll (
    HushållsID INT IDENTITY(1,1) PRIMARY KEY,
    Adress NVARCHAR(100) NOT NULL
);

-- Skapa Personer-tabellen med PersonID P.K
CREATE TABLE Personer (
    PersonID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Namn NVARCHAR (50),
    Kön NVARCHAR (5),
    Födelsedatum DATE,
    Inkomst DECIMAL (18,2),
	ParentID1 INT,
	ParentID2 INT,
    HushållsID INT NOT NULL,
    FOREIGN KEY (HushållsID) REFERENCES Hushåll(HushållsID),
	FOREIGN KEY (ParentID1) REFERENCES Personer(PersonID),
	FOREIGN KEY (ParentID2) REFERENCES Personer(PersonID)
);

GO
INSERT INTO Hushåll (Adress)
VALUES 
    ('Huvudgatan 1'),
    ('Södra Vägen 12'),
    ('Norra Torget 5'),
    ('Långgatan 45'),
    ('Centralvägen 7'),
    ('Parkvägen 14'),
    ('Skogsvägen 21'),
    ('Kyrkogatan 33'),
    ('Åsvägen 8'),
    ('Gränsgatan 2'),
    ('Södraparkvägen 15'),
    ('Norraparkvägen 2'),
    ('Bergvägen 18'),
    ('Smalgatan 22'),
    ('Västra Storgatan 9'),
    ('Österlånggatan 11'),
    ('Vägen mot Skogen 17'),
    ('Grusvägen 3'),
    ('Lilla Parkvägen 10'),
    ('Solstigen 6'),
	('Genvägen 4'),
	('Östraågatan 65'),
	('Vågvägen 16'),
    ('Bäckgatan 3'),
    ('Himmelvägen 7'),
    ('Lindgatan 2'),
    ('Gårdsvägen 13'),
    ('Torggatan 25'),
    ('Ekbacken 19'),
    ('Rådhusgatan 11'),
    ('Fältgatan 6'),
    ('Solbacken 8'),
    ('Nyhemsvägen 21'),
    ('Sjövägen 5')
	;
GO
-- Lägg till 100 personer i Personer-tabellen
INSERT INTO Personer (
	Namn, 
	Kön, 
	Födelsedatum, 
	Inkomst, 
	ParentID1, 
	ParentID2, 
	HushållsID)
VALUES
    ('Anna Johansson', 'F', '1985-01-01', 25000, NULL, NULL, 1),
    ('Erik Larsson', 'M', '1980-02-01', 30000, NULL, NULL, 2),
    ('Karin Svensson', 'F', '1982-03-01', 35000, NULL, NULL, 3),
    ('Johan Andersson', 'M', '1980-04-01', 28000, NULL, NULL, 4),
    ('Maria Olsson', 'F', '1984-05-01', 32000, NULL, NULL, 5),
    ('Oskar Persson', 'M', '1975-06-01', 40000, NULL, NULL, 6),
    ('Elin Lindberg', 'F', '1990-07-01', 27000, NULL, NULL, 7),
    ('Peter Nilsson', 'M', '1985-08-01', 35000, NULL, NULL, 8),
    ('Ulrika Gustafsson', 'F', '1987-09-01', 33000, NULL, NULL, 9),
    ('Mats Jonsson', 'M', '1982-10-01', 31000, NULL, NULL, 10),
    ('Sofia Andersson', 'F', '1992-11-01', 0, NULL, NULL, 11),
    ('Tomas Eriksson', 'M', '1986-12-01', 0, NULL, NULL, 12),
    ('Tommy Johansson', 'M', '2010-01-01', 0, 1, 2, 1),
    ('Lisa Larsson', 'F', '2011-02-01', 0, 3, 4, 2),
    ('Mats Svensson', 'M', '2013-03-01', 0, 3, 4, 3),
    ('Emma Andersson', 'F', '2015-04-01', 0, 1, 2, 4),
    ('Alma Olsson', 'F', '2016-05-01', 0, 5, 6, 5),
    ('Hannes Persson', 'M', '2017-06-01', 0, 5, 6, 6),
    ('Isabel Nilsson', 'F', '2008-07-01', 0, 7, 8, 7),
    ('David Lindberg', 'M', '2009-08-01', 0, 7, 8, 8),
    ('Oliver Gustafsson', 'M', '2011-09-01', 0, 9, 10, 9),
    ('Livia Jonsson', 'F', '2013-10-01', 0, 9, 10, 10),
    ('Maya Eriksson', 'F', '2014-11-01', 0, 11, 12, 11),
    ('Axel Gustafsson', 'M', '2015-12-01', 0, 9, 10, 12),
    ('Elsa Olsson', 'F', '2002-01-01', 27000, NULL, NULL, 1),
    ('Samuel Larsson', 'M', '1993-02-01', 35000, NULL, NULL, 2),
    ('Freja Svensson', 'F', '1990-03-01', 29000, NULL, NULL, 3),
    ('William Andersson', 'M', '1988-04-01', 32000, NULL, NULL, 4),
    ('Felicia Jonsson', 'F', '1995-05-01', 28000, NULL, NULL, 5),
    ('Nils Nilsson', 'M', '1994-06-01', 31000, NULL, NULL, 6),
    ('Hanna Lindberg', 'F', '1989-07-01', 33000, NULL, NULL, 7),
    ('Viktor Eriksson', 'M', '1991-08-01', 34000, NULL, NULL, 8),
    ('Elvira Gustafsson', 'F', '1986-09-01', 36000, NULL, NULL, 9),
    ('Simon Jonsson', 'M', '1992-10-01', 33000, NULL, NULL, 10),
    ('Alfred Persson', 'M', '1993-11-01', 35000, NULL, NULL, 11),
    ('Alicia Olsson', 'F', '1990-12-01', 38000, NULL, NULL, 12),
    ('Oliver Johansson', 'M', '2011-01-01', 10000, 1, 2, 13),
    ('Ella Larsson', 'F', '2012-02-01', 0, 3, 4, 14),
    ('Anton Svensson', 'M', '2014-03-01', 0, 3, 4, 14),
    ('Stella Andersson', 'F', '2016-04-01', 0, 1, 2, 14),
    ('Sebastian Olsson', 'M', '2017-05-01', 0, 5, 6, 34),
    ('Tilda Persson', 'F', '2018-06-01', 0, 7, 8, 7),
    ('Tyra Lindberg', 'F', '2019-07-01', 0, 7, 8, 7),
    ('Jacob Gustafsson', 'M', '2020-08-01', 0, 9, 10, 33),
    ('Lea Jonsson', 'F', '2021-09-01', 0, 9, 10, 14),
    ('Maja Nilsson', 'F', '2022-10-01', 0, 7, 8, 23),
	('Maja Larsson', 'F', '1988-10-01', 100000, NULL, NULL, 23),
	('Anders Larsson', 'M', '1978-09-01', 25000, NULL, NULL, 23),
	('Annika Larsson', 'F', '2022-10-01', 0, 47, 48, 23),
	('Olof Larsson', 'M', '2020-09-04', 0, 47, 48, 23),
	('Elsa Olofsson', 'F', '1964-10-01', 20000, NULL, NULL, 24),
	('Mats Olofsson', 'M', '1964-10-01', 23000, NULL, NULL, 24),
	('Elisa Olofsson', 'F', '2011-01-02', 0, 51, 52, 24),
	('Olle Olofsson', 'M', '2013-08-05', 0, 51, 52, 24),
	('Annika Olofsson', 'F', '2015-10-01', 0, 51, 52, 24),
	('Peter Berg', 'M', '1961-10-01', 10000, NULL, NULL, 25),
	('Greta Berg', 'F', '1963-05-01', 23000, NULL, NULL, 25),
	('Per Berg', 'M', '2019-08-01', 0, 56, 57, 25),
	('Petra Berg', 'F', '2020-08-01', 0, 56, 57, 25),
	('Pelle Berg', 'M', '2018-02-01', 0, 56, 57, 25),
	('Ivar Borg', 'M', '1950-04-01', 55000, NULL, NULL, 26),
	('Gunilla Borg', 'F', '1951-08-11', 35000, NULL, NULL, 26),
	('Mats Kronberg', 'M', '1972-05-01', 10000, NULL, NULL, 27),
	('Rut Kronberg', 'F', '1972-05-23', 20000, NULL, NULL, 27),
	('Ivar Kronberg', 'M', '2015-05-01', 0, 63, 64, 27),
	('Greta Kronberg', 'F', '2015-05-01', 0, 63, 64, 27),
	('Hugo Bergqvist', 'M', '1967-05-01', 13000, NULL, NULL, 28),
	('Stina Bergqvist', 'F', '1968-04-20', 16000, NULL, NULL, 28),
	('Gregor Bergqvist', 'M', '1999-05-01', 13000, 67, 68, 28),
	('Elin Bergqvist', 'F', '2001-05-01', 10000, 67, 68, 28),
	('Elin Bynke', 'F', '1999-07-12', 35000, 72, 73, 29),
	('Jesper Bynke', 'M', '1997-08-29', 36000, 72, 73, 29),
	('Lotta Bynke', 'F', '1964-01-07', 56000, NULL, NULL, 29),
	('Johan Bynke', 'M', '1999-07-12', 90000, NULL, NULL, 29),
	('Carolina Ronsjö', 'F', '1999-03-05', 35000, NULL, NULL, 30),
	('Erik Hansson', 'M', '1988-07-12', 45000, NULL, NULL, 30),
	('Elina Jonsson', 'F', '1988-04-11', 35000, NULL, NULL, 13),
	('Tobias Jonsson', 'M', '1989-03-01', 25000, NULL, NULL, 31),
	('Elias Jonsson', 'F', '2015-02-21', 0, 77, 78, 31),
	('Tim Jonsson', 'M', '2013-04-11', 0, NULL, NULL, 31),
	('Elina Jonsson', 'F', '1988-04-11', 35000, NULL, NULL, 31),
	('Britta Hansson', 'F', '1984-02-09', 67000, NULL, NULL, 32),
	('Sven Hansson', 'M', '1987-04-12', 6000, NULL, NULL, 32),
	('Hanna Hansson', 'F', '2000-02-23', 0, 81, 80, 32),
	('Viktor Hansson', 'M', '2001-03-09', 0, 81, 80, 32),
	('Dominick Cruz', 'M', '1981-06-12', 45000, NULL, NULL, 22),
	('Rickard Lada', 'M', '1998-03-18', 25000, 67, 68, 21),
	('Paul Morphy', 'M', '1958-12-05', 90000, NULL, NULL, 20),
	('Ada Morphy', 'F', '1955-10-14', 0, NULL, NULL, 20),
	('Dignier Morphy', 'M', '1981-09-13', 0, 88, 89, 20), 
	('Pertil Pada', 'M', '1992-06-06', 24300, NULL, NULL, 19),
	('Kartil Martil', 'F', '1998-12-23', 35000, NULL, NULL, 19),
	('Blimbo Blungo', 'M', '1958-06-12', 0, NULL, NULL, 34),
	('Artil Bartil', 'M', '2000-01-01', 24000, NULL, NULL, 17),
	('Skooby Dooby', 'F', '1999-04-11', 71000, NULL, NULL, 16),
	('Tingu Tangu', 'F', '1996-11-24', 12000, NULL, NULL, 15),
	('Kalko Balko', 'M', '1971-12-11', 31000, NULL, NULL, 33),
	('Flisko Plisko', 'M', '1961-06-01', 45500, NULL, NULL, 14),
	('Trapets Sooigo', 'F', '1998-03-12', 50000, NULL, NULL, 14),
	('Anton Hultén', 'M', '1991-08-11', 33500, NULL, NULL, 18)
GO
-- Sätter arbetslös till 1 om man inte har någon inkomst detta måste köras efter inmatningen av personer
ALTER TABLE Personer
ADD Arbetslös AS CASE 
    WHEN Inkomst = 0 THEN 1
    ELSE 0
END
GO


--• Hur många pojkar och flickor kommer börja skolan år X? (SQL Query)
SELECT 
	Namn AS Skolstart, 
	YEAR(GETDATE()) - YEAR(Födelsedatum) AS Ålder
FROM Personer
WHERE YEAR(GETDATE()) - YEAR(Födelsedatum) = 7

--• Ta fram en lista på deras föräldrar så man kan skicka ut post till dom (STORED PROC)
GO
CREATE PROCEDURE Föräldralista
    @year INT
AS
BEGIN
    SELECT 
        p.Namn AS Barn, 
        p1.Namn AS Parent1, 
        p2.Namn AS Parent2,
        h.Adress
    FROM Personer AS p
    LEFT JOIN Personer AS p1 ON p.ParentID1 = p1.PersonID
    LEFT JOIN Personer AS p2 ON p.ParentID2 = p2.PersonID
    JOIN Hushåll AS h ON p.HushållsID = h.HushållsID
    WHERE @year - YEAR(p.Födelsedatum) = 7;  -- Barn som är 7 år gamla
END;
GO
-- Välj året du vill få fram
EXEC Föräldralista @YEAR = 2025



--• Ta fram lista på alla som kommer bli ålderspensionärer (fylla 67) år X (SQL Query)
--För att få ett visst år
GO
SELECT 
	Namn AS Ålderspensionär, 
	2028 - YEAR(Födelsedatum) AS Ålder
FROM Personer
WHERE 2028 - YEAR(Födelsedatum) = 67


--För att få fram vilket år alla blir pensionärer
GO
SELECT 
    Namn AS Ålderspensionär, 
    YEAR(Födelsedatum) + 67 AS Pensioneringsår
FROM Personer
WHERE YEAR(GETDATE()) <= YEAR(Födelsedatum) + 67
ORDER BY Pensioneringsår ASC;

--• Hur många hushåll består av minst X personer (SQL Query)
GO
SELECT p.HushållsID, COUNT(p.HushållsID) AS Personer
FROM Hushåll AS h
JOIN Personer AS p
ON p.HushållsID = h.HushållsID
GROUP BY p.HushållsID

--• Hur många hushåll har minst en medlem som är arbetslös (VIEW)
GO
CREATE VIEW HushållmedArbetslös AS
 
SELECT h.HushållsID, SUM(p.Arbetslös) AS ArbetslösAntal
FROM Hushåll h
INNER JOIN Personer p ON h.HushållsID = p.HushållsID
WHERE YEAR(GETDATE()) - YEAR(p.Födelsedatum) > 18
GROUP BY h.HushållsID
HAVING SUM(p.Arbetslös) > 0
GO
-- För att se hur många hushåll som har minst en i hushållet som är arbetslösa vi tar inte med barn under 18 som arbetslösa

SELECT COUNT (*) AS HushållMedArbetslösa
FROM HushållmedArbetslös
GO
--Se vilka hushåll och hur många som är arbetslösa
SELECT *
FROM HushållmedArbetslös

--• Hur många hushåll tjänar totalt mindre än X kronor, dvs. kan vara aktuella för socialbidrag 
--Alla hushåll med en årsinkomst mindre än 150 000 är aktuella för socialbidrag
GO
SELECT HushållsID, SUM(Inkomst * 12) AS Årsinkomst
FROM Personer
GROUP BY HushållsID
HAVING SUM(Inkomst * 12) < 150000
