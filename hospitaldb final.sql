USE master;

IF EXISTS
	(
		SELECT *
		FROM sys.databases
		WHERE name = 'HospitalDB'
	)
	

BEGIN
	ALTER DATABASE HospitalDB
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE HospitalDB;
END

CREATE DATABASE HospitalDB;

USE HospitalDB;
GO

CREATE SCHEMA Employee;

GO
CREATE SCHEMA Hospital;
GO
CREATE SCHEMA Patient;
GO
CREATE SCHEMA Room;

GO

CREATE TABLE Patient.Patient
	(
		PatientID   INT IDENTITY (1,1) PRIMARY KEY NOT NULL                          ,
		FirstName   NVARCHAR(100) NOT NULL                                           ,
		LastName    NVARCHAR(100) NOT NULL                                           ,
		DateofBirth DATE NOT NULL                                                    ,
		Gender      NVARCHAR(10) NOT NULL                                            ,
		Email       NVARCHAR(100) NOT NULL UNIQUE                                    ,
		Phone       NVARCHAR(30) NOT NULL                                            ,
		Address     NVARCHAR(50) NOT NULL                                            ,
		PostalCode  NVARCHAR(20) NOT NULL                                            ,
		PostalArea  NVARCHAR(30) NOT NULL                                            ,
		IsActive    BIT DEFAULT 1                                                    ,
		CONSTRAINT check_FirstName CHECK(FirstName LIKE '%[A-Za-zÅÄÖåäö -]%')        ,
		CONSTRAINT check_LastName CHECK(LastName   LIKE '%[A-Za-zÅÄÖåäö -]%')        ,
		CONSTRAINT check_Gender CHECK (Gender IN ('Male', 'Female', 'Man', 'Kvinna')),
		CONSTRAINT check_Email CHECK(email LIKE '_%@_%._%' AND email LIKE
		'%[A-Za-z0-9._+-]@[A-Za-z0-9.-]%.[A-Za-z]%')                             ,
		CONSTRAINT check_Phone CHECK(Phone          LIKE '%[0-9+]%')             ,
		CONSTRAINT check_Address CHECK(address      LIKE '%[0-9A-za-zÅÄÖåäö -]%'),
		CONSTRAINT check_Post_code CHECK(PostalCode LIKE '%[0-9]%')              ,
		CONSTRAINT check_Post_area CHECK(PostalArea LIKE '%[A-Za-zÅÄÖåäö]%')
	);
CREATE TABLE Employee.EmployeeType
	(
		EmployeeTypeID INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
		TypeName       NVARCHAR(50) NOT NULL                  ,
		IsActive       BIT DEFAULT 1
	);
CREATE TABLE Employee.EmployeeSpecialisation
	(
		EmployeeSpecialisationID INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
		SpecialisationName       NVARCHAR(50) NOT NULL                  ,
		IsActive                 BIT DEFAULT 1
	);
CREATE TABLE Hospital.Department
	(
		DepartmentID   INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
		DepartmentName NVARCHAR(50) NOT NULL                  ,
		IsActive       BIT DEFAULT 1
	);
CREATE TABLE Employee.Employee
	(
		EmployeeID               INT IDENTITY (1,1) PRIMARY KEY NOT NULL        ,
		EmployeeTypeID           INT NOT NULL                                   ,
		EmployeeSpecialisationID INT NOT NULL                                   ,
		DepartmentID             INT NOT NULL                                   ,
		FirstName                NVARCHAR(100) NOT NULL                         ,
		LastName                 NVARCHAR(100) NOT NULL                         ,
		Email                    NVARCHAR(50) NOT NULL UNIQUE                   ,
		Phone                    NVARCHAR(30) NOT NULL                          ,
		HireDate                 DATE NOT NULL                                  ,
		TerminationDATE          DATE                                           ,
		IsAvailable              BIT DEFAULT 1                                  ,
		IsActive                 BIT DEFAULT 1                                  ,
		CONSTRAINT check_EmpFirstName CHECK(FirstName LIKE '%[A-Za-zÅÄÖåäö -]%'),
		CONSTRAINT check_EmpLastName CHECK(LastName   LIKE '%[A-Za-zÅÄÖåäö -]%'),
		CONSTRAINT check_EmpEmail CHECK(email         LIKE '_%@_%._%' AND email LIKE
		'%[A-Za-z0-9._+-]@[A-Za-z0-9.-]%.[A-Za-z]%')													 ,
		CONSTRAINT check_EmpPhone CHECK(Phone LIKE '%[0-9+]%')											 ,
		CONSTRAINT check_EmpTerminationDate CHECK(TerminationDATE IS NULL OR TerminationDATE >= HireDate),
		FOREIGN KEY (EmployeeTypeID) REFERENCES Employee.EmployeeType(EmployeeTypeID)							 ,
		FOREIGN KEY (DepartmentID) REFERENCES Hospital.Department(DepartmentID)									 ,
		FOREIGN KEY (EmployeeSpecialisationID) REFERENCES Employee.EmployeeSpecialisation(EmployeeSpecialisationID)
	);
CREATE TABLE Employee.EmployeeDetail
	(
		EmployeeDetailID INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
		EmployeeID       INT UNIQUE NOT NULL                    ,
		DateofBirth      DATE NOT NULL                          ,
		Gender           NVARCHAR(10) NOT NULL                  ,
		Address          NVARCHAR(50) NOT NULL                  ,
		PostalCode       NVARCHAR(20) NOT NULL                  ,
		PostalArea       NVARCHAR(30) NOT NULL                  ,
		IsActive         BIT DEFAULT 1                          ,
		CONSTRAINT check_EmpDateofbirth CHECK (DATEDIFF(YEAR, DateofBirth, GETDATE()) >= 18),
		CONSTRAINT check_EmpGender CHECK (Gender IN ('Male', 'Female','Man', 'Kvinna'))		,
		CONSTRAINT check_EmpAddress CHECK(address LIKE '%[0-9A-za-zÅÄÖåäö -]%')				,
		CONSTRAINT check_EmpPost_code CHECK(PostalCode LIKE '%[0-9]%')						,
		CONSTRAINT check_EmpPost_area CHECK(PostalArea LIKE '%[A-Za-zÅÄÖåäö]%')				,
		FOREIGN KEY (EmployeeID) REFERENCES Employee.Employee(EmployeeID)
	);
CREATE TABLE Room.RoomType
	(
		RoomTypeID      INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
		RoomTypeName    NVARCHAR(30) NOT NULL                  ,
		RoomCapacity    INT NOT NULL                           ,
		RoomDescription NVARCHAR(200)                          ,
		IsActive        BIT DEFAULT 1                          ,
	);
CREATE TABLE Room.Room
	(
		RoomID          INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
		RoomTypeID      INT NOT NULL                           ,
		RoomNumber      NVARCHAR(10) NOT NULL                  ,
		IsBooked        BIT DEFAULT 0                          ,
		IsActive        BIT DEFAULT 1                          ,
		FOREIGN KEY (RoomTypeID) REFERENCES Room.RoomType(RoomTypeID)
	);
CREATE TABLE Patient.Appointment
	(
		AppointmentID     INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
		PatientID         INT NOT NULL                           ,
		EmployeeID        INT NOT NULL                           ,
		AppointmentDate   DATETIME DEFAULT GETUTCDATE() NOT NULL ,
		AppointmentReason NVARCHAR(255) NOT NULL                 ,
		AppointmentStatus NVARCHAR(50) NOT NULL                  ,
		FollowUpDate      DATE                                   ,
		IsActive		  BIT DEFAULT 1						     ,
		CONSTRAINT check_AppointmentStatus CHECK (AppointmentStatus IN ('Complete','Scheduled','Cancelled')),
		FOREIGN KEY (PatientID) REFERENCES Patient.Patient(PatientID)												,
		FOREIGN KEY (EmployeeID) REFERENCES Employee.Employee(EmployeeID)
	);
CREATE TABLE Patient.Admission
	(
		AdmissionID     INT IDENTITY (1,1) PRIMARY KEY NOT NULL                            ,
		PatientID       INT NOT NULL                                                       ,
		EmployeeID      INT NOT NULL                                                       ,
		RoomID          INT NOT NULL                                                       ,
		AdmissionDate   DATETIME DEFAULT GETUTCDATE()                                      ,
		AdmissionReason NVARCHAR(255) NOT NULL                                             ,
		DischargeDate   DATETIME                                                           ,
		IsCritical      BIT DEFAULT 0                                                      ,
		IsActive        BIT DEFAULT 1													   ,
		FOREIGN KEY (PatientID) REFERENCES Patient.Patient(PatientID)							   ,
		FOREIGN KEY (EmployeeID) REFERENCES Employee.Employee(EmployeeID)                           ,
		FOREIGN KEY (RoomID) REFERENCES Room.Room(RoomID)
	);
CREATE TABLE Patient.Prescriptions
	(
		PrescriptionID   INT IDENTITY (1,1) PRIMARY KEY NOT NULL                            ,
		PatientID        INT NOT NULL                                                       ,
		EmployeeID       INT NOT NULL                                                       ,
		PrescriptionDate DATETIME DEFAULT GETUTCDATE()                                      ,
		MedicationName   NVARCHAR(50) NOT NULL                                              ,
		Dosage           NVARCHAR(50) NOT NULL                                              ,
		Duration         NVARCHAR(20) NOT NULL                                              ,
		Instructions     NVARCHAR(255) NOT NULL                                             ,
		IsActive         BIT DEFAULT 1													    , 
		FOREIGN KEY (PatientID) REFERENCES Patient.Patient(PatientID)								,
		FOREIGN KEY (EmployeeID) REFERENCES Employee.Employee(EmployeeID)
	);
CREATE TABLE Patient.MedicalRecord
	(
		MedicalRecordID INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
		EmployeeID      INT NOT NULL                           ,
		PatientID       INT NOT NULL                           ,
		RecordDate      DATETIME DEFAULT GETUTCDATE()          ,
		Allergies       NVARCHAR(255)                          ,
		LabResults      NVARCHAR(255)                          ,
		Diagnosis       NVARCHAR(50)                           ,
		TreatmentPlan   NVARCHAR(50)                           ,
		Comments        NVARCHAR(250)                          ,
		FOREIGN KEY (PatientID) REFERENCES Patient.Patient(PatientID)  ,
		FOREIGN KEY (EmployeeID) REFERENCES Employee.Employee(EmployeeID)
	);
	
GO
--------------------PROCEDURE LAND--------------------PROCEDURE LAND--------------------PROCEDURE LAND------------------------------
CREATE Procedure SP_AdmitPatient
	@PatientID INT,
	@EmployeeID INT,
	@RoomID INT,
	@AdmissionReason NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	IF NOT EXISTS 
		(
			SELECT 1 
			FROM Patient.Patient 
			WHERE PatientID = @PatientID AND IsActive = 1
		)
    BEGIN
        PRINT '
			< < Error: Patient does not exist. > >
			';
        RETURN;
    END
	IF NOT EXISTS 
		(
			SELECT 1 
			FROM Employee.Employee 
			WHERE EmployeeID = @EmployeeID AND IsAvailable = 1 AND IsActive = 1
		)
    BEGIN
        PRINT '
				< < Error: Doctor is not available or does not exist. > >
				';
        RETURN;
    END
	IF NOT EXISTS 
		(
			SELECT 1 
			FROM Room.Room 
			WHERE RoomID = @RoomID AND IsBooked = 0 AND IsActive = 1
		)
    BEGIN
        PRINT '
				< < Error: Room is is already booked or does not exist. > >
				';
        RETURN;
    END
	INSERT INTO Patient.Admission 
		(
			PatientID, 
			EmployeeID, 
			RoomID, 
			AdmissionReason
		)
	VALUES 
		(
			@PatientID, @EmployeeID, @RoomID, @AdmissionReason
		);
	UPDATE Room.Room
	SET IsBooked = 1
	WHERE RoomID = @RoomID;
    PRINT ' 
			< < Success: Patient admitted successfully. > >
			';
END;

GO

CREATE PROCEDURE SP_BookAppointment
    @PatientID INT,
    @EmployeeID INT,
    @AppointmentDate DATETIME,
    @AppointmentReason NVARCHAR(255),
    @AppointmentStatus NVARCHAR(50) = 'Scheduled',
    @FollowUpDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS 
		(
			SELECT 1 
			FROM Patient.Patient 
			WHERE PatientID = @PatientID AND IsActive = 1
		)
    BEGIN
        PRINT '
				< < Appointment error: Patient does not exist. > >
				';
        RETURN;
    END
    IF NOT EXISTS 
		(
			SELECT 1 
			FROM Employee.Employee 
			WHERE EmployeeID = @EmployeeID AND IsAvailable = 1 AND IsActive = 1
		)
    BEGIN
        PRINT '
				< < Appointment error: Doctor is not available  or does not exist. >>
				';
        RETURN;
    END
	IF EXISTS 
		(
			SELECT 1 FROM Patient.Appointment 
            WHERE EmployeeID = @EmployeeID 
            AND CAST(AppointmentDate AS DATE) = CAST(@AppointmentDate AS DATE)
            AND CAST(AppointmentDate AS TIME) = CAST(@AppointmentDate AS TIME)
            AND AppointmentStatus <> 'Cancelled'
			)
    BEGIN
        PRINT ' 
				< < Appointment error: Doctor already has an appointment at this time. > >
				';
        RETURN;
    END
    INSERT INTO Patient.Appointment 
		(
			PatientID, 
			EmployeeID, 
			AppointmentDate, 
			AppointmentReason, 
			AppointmentStatus, 
			FollowUpDate
		)
    VALUES 
		(
			@PatientID, @EmployeeID, @AppointmentDate, @AppointmentReason, @AppointmentStatus, @FollowUpDate
		);
    PRINT 'Appointment successfully scheduled.';
END;

GO

--------------------INSERTLAND--------------------INSERTLAND--------------------INSERTLAND--------------------
INSERT INTO Patient.Patient 
	(
		FirstName, 
		LastName, 
		DateofBirth, 
		Gender, 
		Email, 
		Phone, 
		Address, 
		PostalCode, 
		PostalArea
	)
VALUES
	('John', 'Doe'		, '1990-05-15', 'Male'	, 'john.doe@email.com'		, '+123456789', '123 Main St', '1001', 'New York'),
	('Jane', 'Smith'	, '1985-09-25', 'Female', 'jane.smith@email.com'	, '+987654321', '456 Elm St', '1002', 'Los Angeles'),
	('Mark', 'Johnson'	, '1978-03-10', 'Male'	, 'mark.johnson@email.com'	, '+112233445', '789 Pine St', '1003', 'Chica'),
	('Lisa', 'Brown'   , '1992-07-30', 'Female', 'lisa.brown@email.com'   , '+445566778', '321 Oak St', '1004', 'Miami'),
    ('David', 'Lee'    , '1983-11-12', 'Male'   , 'david.lee@email.com'    , '+556677889', '654 Maple St', '1005', 'Boston'),
    ('Emily', 'Davis'  , '1995-01-22', 'Female', 'emily.davis@email.com'  , '+667788990', '987 Cedar St', '1006', 'Dallas'),
    ('Michael', 'Clark', '1987-06-18', 'Male'   , 'michael.clark@email.com', '+778899001', '159 Birch St', '1007', 'Atlanta'),
    ('Sophia', 'Miller', '1989-09-09', 'Female', 'sophia.miller@email.com', '+889900112', '753 Pine St', '1008', 'San Francisco'),
    ('Daniel', 'Wilson', '1981-02-04', 'Male'   , 'daniel.wilson@email.com', '+990011223', '246 Willow St', '1009', 'Seattle'),
	('Olivia', 'Taylor', '1993-03-28', 'Female', 'olivia.taylor@email.com', '+001122334', '369 Elm St', '1010', 'Houston');

INSERT INTO Employee.EmployeeType 
	(
		TypeName
	)
VALUES
	('Doctor'),
	('Nurse'),
	('Surgeon'),
    ('Technician'),
    ('Pharmacist'),
    ('Therapist'),
    ('Receptionist'),
    ('Lab Technician'),
    ('Radiologist'),
    ('Paramedic');

INSERT INTO Employee.EmployeeSpecialisation 
	(
		SpecialisationName
	)
VALUES
	('General Practitioner'),
    ('Cardiologist'),
    ('Pediatrician'),
    ('Neurologist'),
    ('Orthopedist'),
    ('Dermatologist'),
    ('Oncologist'),
    ('Psychiatrist'),
    ('Ophthalmologist'),
    ('Endocrinologist');

INSERT INTO Hospital.Department 
	(
		DepartmentName
	)
VALUES
    ('General Medicine'),
    ('Cardiology'),
    ('Pediatrics'),
    ('Neurology'),
    ('Orthopedics'),
    ('Dermatology'),
    ('Oncology'),
    ('Psychiatry'),
    ('Ophthalmology'),
    ('Endocrinology');

INSERT INTO Employee.Employee 
	(
		EmployeeTypeID, 
		EmployeeSpecialisationID, 
		DepartmentID, 
		FirstName, 
		LastName, 
		Email, 
		Phone, 
		HireDate, 
		IsAvailable
	)
VALUES
	(1, 1, 1, 'Emily', 'Clark', 'emily.clark@email.com'			, '+1001001001', '2015-07-01', 1),
	(1, 2, 2, 'Robert', 'Williams', 'robert.williams@email.com'	, '+2002002002', '2012-04-15', 1),
	(1, 3, 3, 'Alice', 'Brown', 'alice.brown@email.com'			, '+3003003003', '2018-09-22', 1),
    (2, 4, 4, 'Lisa', 'Martinez', 'lisa.martinez@email.com'  , '+4004004004', '2016-03-05', 1),
    (2, 5, 5, 'John', 'Smith', 'john.smith@email.com'        , '+5005005005', '2011-11-20', 1),
    (3, 6, 6, 'Sarah', 'Taylor', 'sarah.taylor@email.com'      , '+6006006006', '2014-08-10', 1),
    (3, 7, 7, 'James', 'Anderson', 'james.anderson@email.com'  , '+7007007007', '2010-06-25', 1),
    (4, 8, 8, 'Michael', 'Harris', 'michael.harris@email.com' , '+8008008008', '2013-12-18', 1),
    (4, 9, 9, 'Rachel', 'Young', 'rachel.young@email.com'     , '+9009009009', '2017-05-30', 1),
    (2, 1, 1, 'David', 'Miller', 'david.miller@email.com'    , '+1010101010', '2019-01-14', 1);

INSERT INTO Employee.EmployeeDetail 
	(
		EmployeeID, 
		DateofBirth, 
		Gender, 
		Address, 
		PostalCode, 
		PostalArea
	)
VALUES
    (1, '1980-06-10', 'Female', '101 Hospital St', '2001', 'New York'),
    (2, '1975-08-20', 'Male', '202 Clinic Rd', '2002', 'Los Angeles'),
    (3, '1982-11-05', 'Female', '303 Medical Blvd', '2003', 'Chica'),
    (4, '1990-02-14', 'Female', '404 Health St', '2004', 'Miami'),
    (5, '1983-05-22', 'Male', '505 Wellness Blvd', '2005', 'Boston'),
    (6, '1995-08-10', 'Female', '606 Care Ave', '2006', 'Dallas'),
    (7, '1987-12-30', 'Male', '707 Cure Rd', '2007', 'Atlanta'),
    (8, '1992-04-18', 'Female', '808 Healing St', '2008', 'San Francisco'),
    (9, '1981-09-08', 'Male', '909 Remedy Rd', '2009', 'Seattle'),
    (10, '1993-11-25', 'Female', '1010 Recovery Blvd', '2010', 'Houston');

INSERT INTO Room.RoomType 
    (
        RoomTypeName, 
        RoomCapacity, 
        RoomDescription
    )
VALUES
    ('General Ward'    , 4, 'Shared ward for general patients'),
    ('Private Room'    , 1, 'Single private room with attached bathroom'),
    ('ICU'             , 1, 'Intensive Care Unit for critical patients'),
    ('Semi-Private Room', 2, 'Shared by two patients with partial privacy'),
    ('Maternity Ward'  , 3, 'Ward for mothers and newborns'),
    ('Surgery Room'    , 1, 'Room equipped for surgical procedures'),
    ('Recovery Room'   , 2, 'For patients post-surgery'),
    ('Observation Room', 1, 'For close patient monitoring'),
    ('Emergency Room'  , 1, 'For emergency cases and quick treatment'),
    ('Isolation Room'  , 1, 'For patients needing isolation and special care');

INSERT INTO Room.Room 
    (
        RoomTypeID, 
        RoomNumber
    )
VALUES
    (1, 101),
    (2, 102),
    (3, 303),
    (1, 104),
    (2, 205),
    (3, 306),
    (4, 127),
    (5, 118),
    (6, 301),
    (7, 401);

INSERT INTO Patient.Appointment 
	(
		PatientID, 
		EmployeeID, 
		AppointmentDate, 
		AppointmentReason, 
		AppointmentStatus, 
		FollowUpDate
	)
VALUES
	(1, 1, '2025-03-10 10:00:00', 'Routine Checkup'		, 'Scheduled', '2025-03-17'),
	(2, 2, '2025-03-11 14:30:00', 'Heart Consultation'	, 'Scheduled', '2025-03-18'),
	(3, 3, '2025-03-12 09:00:00', 'Pediatric Checkup'     , 'Scheduled', '2025-03-19'),
    (4, 4, '2025-03-13 11:00:00', 'Neurology Consultation', 'Scheduled', '2025-03-20'),
    (5, 5, '2025-03-14 15:00:00', 'Orthopedic Exam'       , 'Scheduled', '2025-03-21'),
    (6, 6, '2025-03-15 08:30:00', 'Dermatology Exam'      , 'Scheduled', '2025-03-22'),
    (7, 7, '2025-03-16 10:30:00', 'Oncology Consultation' , 'Scheduled', '2025-03-23'),
    (8, 8, '2025-03-17 13:00:00', 'Psychiatric Assessment', 'Scheduled', '2025-03-24'),
    (9, 9, '2025-03-18 09:30:00', 'Ophthalmology Exam'    , 'Scheduled', '2025-03-25'),
    (10, 10, '2025-03-19 12:00:00', 'Endocrinology Checkup', 'Scheduled', '2025-03-26');

INSERT INTO Patient.Prescriptions 
	(
		PatientID, 
		EmployeeID, 
		MedicationName, 
		Dosage, 
		Duration, 
		Instructions
	)
VALUES
	(1, 1,'Ligmasion', '300 mg', '2 weeks', 'Take two daily')

INSERT INTO Patient.MedicalRecord 
    (	
		EmployeeID, 
		PatientID, 
		RecordDate, Allergies, 
		LabResults, 
		Diagnosis, 
		TreatmentPlan, 
		Comments
	)
VALUES
    (1, 1, '2024-03-11', 'Shellfish', 'Blood test: Elevated Level of Cortison', 'Hypertension', 'Medication & Diet Change', 'Patient advised to reduce salt intake'),
	(1, 1, '2025-01-11', 'Shellfish', 'Blood test: Normal', 'Broken Leg', 'Cast & Plaster', 'Surgery not required'),
	(2, 2, GETDATE(), 'None', 'Blood Test: Normal', 'Leg Injury', 'Bandage & Rest', '8 cm cut on leg'),
	(3, 4, '2025-01-08', 'None', 'No Bloodwork Done', 'Persisting Headache', 'Prescription of Medication', 'he head do a heckin hurt'),
	(5, 3, '2024-08-16', 'Lactose', 'Stomach Flora: Normal', 'Infection of Stomach Lining', 'Surgery', 'Surgery required, schedule it promptly');

--------------------VIEW--------------------VIEW--------------------VIEW--------------------VIEW--------------------

GO

CREATE OR ALTER VIEW VIEW_Employee_Overview
AS
SELECT 
	e.EmployeeID,
	et.TypeName,
	e.FirstName,
	e.LastName,
	es.SpecialisationName,
	d.DepartmentName
FROM Employee.Employee e
JOIN Hospital.Department d				ON e.DepartmentID = d.DepartmentID
JOIN Employee.EmployeeDetail ed 		ON e.EmployeeID = ed.EmployeeID
JOIN Employee.EmployeeType et			ON e.EmployeeTypeID = et.EmployeeTypeID
JOIN Employee.EmployeeSpecialisation es ON es.EmployeeSpecialisationID = e.EmployeeSpecialisationID;


GO

SELECT * FROM VIEW_Employee_Overview

-----------EXEC-------------------------------


SELECT * FROM Patient.Admission



EXEC SP_AdmitPatient 
	@PatientID = 1, 
	@EmployeeID = 1, 
	@RoomID = 1, 
	@AdmissionReason = 'Ligma'

EXEC SP_AdmitPatient 
	@PatientID = 2, 
	@EmployeeID = 1, 
	@RoomID = 1, 
	@AdmissionReason = 'Broken Bone'

EXEC SP_AdmitPatient 
	@PatientID = 3, 
	@EmployeeID = 2, 
	@RoomID = 1, 
	@AdmissionReason = 'High Fever'

EXEC SP_AdmitPatient 
	@PatientID = 3, 
	@EmployeeID = 2, 
	@RoomID = 4, 
	@AdmissionReason = 'Kind of Smelly'
--*/
 



SELECT * FROM Patient.Appointment


EXEC SP_BookAppointment 
    @PatientID = 1, 
    @EmployeeID = 1, 
    @AppointmentDate = '2025-01-12 09:00:00', 
    @AppointmentReason = 'Pediatric Consultation';

EXEC SP_BookAppointment 
    @PatientID = 2, 
    @EmployeeID = 1, 
    @AppointmentDate = '2025-01-12 09:00:00', 
    @AppointmentReason = 'Persistent Rash';

EXEC SP_BookAppointment 
    @PatientID = 2, 
    @EmployeeID = 2, 
    @AppointmentDate = '2025-01-12 09:00:00', 
    @AppointmentReason = 'Allergies';

EXEC SP_BookAppointment 
    @PatientID = 2, 
    @EmployeeID = 2, 
    @AppointmentDate = '2025-01-12 09:00:00', 
    @AppointmentReason = 'Headache';
--*/


--------------------Query--------------------Query--------------------Query--------------------Query--------------------




-- Vilka patienter träffat vilka läkare?
SELECT 
	A.AdmissionID, 
	P.FirstName + ' ' + P.LastName AS PatientName,
    E.FirstName + ' ' + E.LastName AS DoctorName, 
    R.RoomNumber, 
	A.AdmissionDate, 
	A.AdmissionReason
FROM 
	Patient.Admission A
JOIN Patient.Patient P		ON A.PatientID = P.PatientID
JOIN Employee.Employee E	ON A.EmployeeID = E.EmployeeID
JOIN Room.Room R			ON A.RoomID = R.RoomID
WHERE A.DischargeDate IS NULL;
 
 
-- Visa en läkares alla bokningar?
SELECT 
	A.AppointmentID, 
	P.FirstName + ' ' + P.LastName AS PatientName, 
    A.AppointmentDate, 
	A.AppointmentReason, 
	A.AppointmentStatus
FROM 
	Patient.Appointment A
JOIN Patient.Patient P ON A.PatientID = P.PatientID
WHERE 
	A.EmployeeID = 1
ORDER BY 
	A.AppointmentDate;
 
-- Vilka mediciner har en patient fått utskrivet?
SELECT 
	P.FirstName + ' ' + P.LastName AS PatientName, 
	PR.MedicationName, 
	PR.Dosage, 
	PR.PrescriptionDate
FROM 
	Patient.Prescriptions PR
JOIN Patient.Patient P ON PR.PatientID = P.PatientID
WHERE 
	PR.EmployeeID = 1 
ORDER BY 
	PR.PrescriptionDate DESC;
 
-- Vilka rum är lediga?
SELECT 
	RoomID, 
	RoomNumber, 
	RoomTypeID 
FROM 
	Room.Room 
WHERE 
	IsBooked = 0 AND IsActive = 1;

-- Vilken patient har flest Journal Historik?
SELECT 
	p.PatientID,
	p.FirstName,
	p.LastName,
	COUNT(*) AS RecordEntries
FROM 
	Patient.MedicalRecord mr
JOIN Patient.Patient p ON mr.PatientID = p.PatientID
GROUP BY 
	p.PatientID, FirstName, p.LastName
ORDER BY RecordEntries DESC

-- Kan vi se journalhistorik för enskild patient?
SELECT 
	CONCAT(p.FirstName, ' ', p.LastName) AS PatientName, 
	CONCAT(e.FirstName, ' ', e.LastName) AS DoctorName, 
	mr.RecordDate, 
	mr.Allergies, 
	mr.LabResults, 
	mr.Diagnosis, 
	mr.TreatmentPlan, 
	mr.Comments
FROM 
	Patient.MedicalRecord mr
INNER JOIN Patient.Patient p 	ON mr.PatientID = p.PatientID
INNER JOIN Employee.Employee e 	ON e.EmployeeID = mr.EmployeeID
WHERE p.PatientID = 1

--*/