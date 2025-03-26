USE master;
GO

IF EXISTS(SELECT * FROM sys.databases WHERE name = 'BankDB')
BEGIN
    ALTER DATABASE BankDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BankDB;
END
GO

CREATE DATABASE BankDB;
GO

USE BankDB;
GO

CREATE TABLE Branch (
    BranchID INT IDENTITY (1,1) PRIMARY KEY,
    OfficeName NVARCHAR(50),
    OfficeAddress NVARCHAR(40) NOT NULL,
	City NVARCHAR(40) NOT NULL,
	ZipCode NVARCHAR(10) NOT NULL,
	BranchCountry NVARCHAR(30) NOT NULL,
	CONSTRAINT Branch_OfficeName CHECK(OfficeName LIKE '%[0-9A-za-zÅÄÖåäö -]%'),
	CONSTRAINT Branch_OfficeAddress CHECK(OfficeName LIKE '%[0-9A-za-zÅÄÖåäö -]%'),
	CONSTRAINT Branch_City CHECK(City LIKE '%[A-Za-zÅÄÖåäö -]%'),
	CONSTRAINT Branch_ZipCode CHECK(ZipCode LIKE '%[0-9]%'),
	CONSTRAINT Branch_Country CHECK(BranchCountry LIKE '%[A-Za-zÅÄÖåäö -]%')


); 
GO

CREATE TABLE Department (
    DepartmentID INT IDENTITY (1,1) PRIMARY KEY,
    BranchID INT NOT NULL,
    DepartmentName NVARCHAR(20) NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
	CONSTRAINT Department_BranchID CHECK(BranchID LIKE '%[0-9]%'),
	CONSTRAINT Department_DepartmentName CHECK(DepartmentName LIKE '%[A-Za-zÅÄÖåäö -]%')

);
GO

CREATE TABLE Employee (
    EmployeeID INT IDENTITY (1,1) PRIMARY KEY,
    DepartmentID INT NOT NULL,
    EmployeeName NVARCHAR(50) NOT NULL,
	EmployeePhone NVARCHAR(20) NOT NULL,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
	CONSTRAINT Employee_EmployeeName CHECK(EmployeeName LIKE '%[A-Za-zÅÄÖåäö -]%'),
	CONSTRAINT Employee_EmployeePhone CHECK(EmployeePhone LIKE '%[0-9+ ]%') 

);
GO

CREATE TABLE CardType (
    CardTypeID INT IDENTITY (1,1) PRIMARY KEY,
    CardTypeName NVARCHAR(20) NOT NULL UNIQUE,
	CONSTRAINT CardType_CardTypeName CHECK(CardTypeName LIKE '%[A-Za-zÅÄÖåäö -]%')

);
GO


CREATE TABLE Card (
    CardID INT IDENTITY (1,1) PRIMARY KEY, 
	CardTypeID INT NOT NULL,
	CardNumber NVARCHAR(16) UNIQUE,
    CardIssueDate DATE NOT NULL DEFAULT GETDATE(),
    CardValidTo DATE NOT NULL DEFAULT DATEADD(YEAR, 3, GETDATE()),
    CVV INT, 
    IsActive BIT,
    FOREIGN KEY (CardTypeID) REFERENCES CardType(CardTypeID),
	CONSTRAINT Card_CardNumber CHECK(CardNumber LIKE '%[0-9]%'),
	CONSTRAINT Card_CVV CHECK(CVV LIKE '%[0-9]%'),
	CONSTRAINT Card_CardTypeID CHECK(CardTypeID LIKE '%[0-9]%'),

);

GO

CREATE TABLE InterestType (
    InterestTypeID INT IDENTITY (1,1) PRIMARY KEY,
    InterestAmount DECIMAL(10, 3) CHECK (InterestAmount BETWEEN 1 AND 10)

);
GO

CREATE TABLE AccountType (
    AccountTypeID INT IDENTITY (1,1) PRIMARY KEY,
    InterestTypeID INT NOT NULL,
    AccountTypeName NVARCHAR(50) NOT NULL UNIQUE,
    AllowNegativeBalance BIT NOT NULL DEFAULT 0,
    NegativeBalanceLimit DECIMAL(18, 2) NOT NULL DEFAULT 0,
    FOREIGN KEY (InterestTypeID) REFERENCES InterestType(InterestTypeID),
	CONSTRAINT AccountType_AccountTypeName CHECK(AccountTypeName LIKE '%[A-Za-zÅÄÖåäö -]%')

);
GO

CREATE TABLE Customer (
    CustomerID INT IDENTITY (1,1) PRIMARY KEY, 
    BranchID INT NOT NULL,
    CustomerName NVARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    Gender NVARCHAR(10) NOT NULL,
    IsMarried BIT,
    IsPensioner BIT NOT NULL,
    PhoneNumber NVARCHAR(30) NOT NULL UNIQUE,
    EmailAddress NVARCHAR(50) NOT NULL UNIQUE,
    Address NVARCHAR(50) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    Country NVARCHAR(50) NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT Customer_CustomerName CHECK(CustomerName LIKE '%[A-Za-zÅÄÖåäö -]%'),
    CONSTRAINT Customer_PhoneNumber CHECK(PhoneNumber LIKE '%[0-9+ ]%'),
    CONSTRAINT Customer_EmailAddress CHECK (EmailAddress LIKE '_%@_%._%'),
    CONSTRAINT Customer_City CHECK(City LIKE '%[A-Za-zÅÄÖåäö -]%'),
    CONSTRAINT Customer_Country CHECK(Country LIKE '%[A-Za-zÅÄÖåäö -]%'),
    CONSTRAINT Customer_Age CHECK (DATEDIFF(YEAR, BirthDate, GETDATE()) >= 18),
	CONSTRAINT Customer_Gender CHECK (Gender IN ('Male', 'Female', 'M', 'F', 'O', 'Other'))
);
GO


CREATE TABLE Account (
    AccountID INT IDENTITY (1,1) PRIMARY KEY,
    AccountTypeID INT NOT NULL,
    Balance DECIMAL(18, 2) NOT NULL,
    AccountOpened DATE NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL,
    FOREIGN KEY (AccountTypeID) REFERENCES AccountType(AccountTypeID)

);
GO


CREATE TABLE LoanType (
    LoanTypeID INT IDENTITY (1,1) PRIMARY KEY,
    LoanTypeName VARCHAR(30) NOT NULL UNIQUE,
	CONSTRAINT LoanType_LoanTypeName CHECK(LoanTypeName LIKE '%[A-Za-zÅÄÖåäö -]%')

);
GO



CREATE TABLE Loan (
    LoanID INT IDENTITY (1,1) PRIMARY KEY,
    LoanTypeID INT NOT NULL,
    InterestTypeID INT NOT NULL,
    CustomerID INT NOT NULL,
    LoanAmount DECIMAL(18, 2) NOT NULL CHECK (LoanAmount > 1000),
    LoanStartDate DATE NOT NULL,
    LoanEndDate DATE NOT NULL,
    FOREIGN KEY (InterestTypeID) REFERENCES InterestType(InterestTypeID),
    FOREIGN KEY (LoanTypeID) REFERENCES LoanType(LoanTypeID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
	CONSTRAINT Loan_LoanEndDate CHECK (LoanEndDate > LoanStartDate)
);
GO

CREATE TABLE Disposition (
    DispositionID INT IDENTITY(1, 1) PRIMARY KEY,
    CustomerID INT NOT NULL, 
    CardID INT, 
    AccountID INT NOT NULL,
	AccountRole NVARCHAR(10) NOT NULL DEFAULT 'Primary',
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (CardID) REFERENCES Card(CardID),
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
	CONSTRAINT Disposition_AccountRole CHECK(AccountRole IN ('Primary', 'Joint'))
);
GO

CREATE TABLE TransactionType (
	TransactionTypeID INT IDENTITY (1,1) PRIMARY KEY,
	TransactionTypeName NVARCHAR(25) NOT NULL UNIQUE,
	CONSTRAINT TransactionType_TransactionTypeName CHECK(TransactionTypeName LIKE '%[A-Za-zÅÄÖåäö -]%')

);
GO

CREATE TABLE Transactions (
    TransactionID INT IDENTITY (1,1) PRIMARY KEY,
	TransactionTypeID INT NOT NULL,
	CardID INT, 
	BalanceBefore INT,
	BalanceAfter INT,
    TransactionAmount DECIMAL(18, 2) NOT NULL, 
    AccountID INT NOT NULL, 
	TransactionDate DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
    FOREIGN KEY (CardID) REFERENCES Card(CardID),
	FOREIGN KEY (TransactionTypeID) REFERENCES TransactionType(TransactionTypeID)
);
GO

CREATE TABLE LoanRepayment (
    LoanRepaymentID INT IDENTITY (1,1) PRIMARY KEY,
    AccountID INT NOT NULL,
    LoanID INT NOT NULL,
    RepaymentAmount DECIMAL(10, 2) NOT NULL,
	InterestAmount DECIMAL (10, 2) NOT NULL DEFAULT 0,
    RemainingAmount DECIMAL(10, 2) NOT NULL,
    DueDate DATE DEFAULT NULL,  -- default som NULL, uppdateras via SP
    PaymentDate DATETIME DEFAULT NULL, -- default som NULL så vi kan uppdatera den med ett paymentdate i SP:n
    PaymentStatus NVARCHAR(12) DEFAULT 'Due' NOT NULL CHECK (PaymentStatus IN ('Due', 'Paid', 'Fully Paid')),
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
    FOREIGN KEY (LoanID) REFERENCES Loan(LoanID),
	CONSTRAINT Loan_RepaymentAmount CHECK (RepaymentAmount > 0),
	CONSTRAINT Loan_InterestAmount CHECK (InterestAmount > 0),
	CONSTRAINT Loan_RemainingAmount CHECK (RemainingAmount >= 0),
);
GO

CREATE TABLE InsuranceType (
    InsuranceTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE,
	CONSTRAINT InsuranceType_InsuranceTypeName CHECK(TypeName LIKE '%[A-Za-zÅÄÖåäö -]%'),
);
GO


CREATE TABLE Insurance (
    PolicyID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    InsuranceTypeID INT NOT NULL,
    StartDate DATE NOT NULL DEFAULT GETDATE(),
    PremiumAmount DECIMAL(18,2) NOT NULL,
    CoverageAmount DECIMAL(18,2) NOT NULL,
    Status NVARCHAR(15) NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active', 'Expired', 'Cancelled')),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (InsuranceTypeID) REFERENCES InsuranceType(InsuranceTypeID),
	CONSTRAINT Insurance_PremiumAmount CHECK (PremiumAmount > 0),
	CONSTRAINT Insurance_CoverageAmount CHECK (CoverageAmount > 0),
);
GO

CREATE TABLE InsuranceClaim (
    ClaimID INT IDENTITY(1,1) PRIMARY KEY,
    PolicyID INT NOT NULL,
    ClaimDate DATE NOT NULL DEFAULT GETDATE(),
    ClaimAmount DECIMAL(18,2) NOT NULL CHECK (ClaimAmount > 0),
    ClaimStatus NVARCHAR(15) DEFAULT 'Pending' CHECK (ClaimStatus IN ('Pending', 'Approved', 'Rejected', 'Paid')),
    Comment NVARCHAR(255),
    FOREIGN KEY (PolicyID) REFERENCES Insurance(PolicyID)
);
GO

CREATE TABLE ClaimApproval (
    ApprovalID INT IDENTITY(1,1) PRIMARY KEY,
    ClaimID INT UNIQUE,
    ApprovedByEmployeeID INT NOT NULL,
    ApprovalDate DATE NOT NULL DEFAULT GETDATE(),
    Decision NVARCHAR(10) NOT NULL DEFAULT 'Pending' CHECK (Decision IN ('Approved', 'Rejected', 'Pending')),
    Comments NVARCHAR(255), -- kommentarer om beslutet. här får Richard skriva bajskorv om han vill.
    FOREIGN KEY (ClaimID) REFERENCES InsuranceClaim(ClaimID),
    FOREIGN KEY (ApprovedByEmployeeID) REFERENCES Employee(EmployeeID)
);
GO

CREATE TABLE SupportTicket (
    TicketID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    ResolvedAt DATETIME NULL,
    TicketStatus NVARCHAR(20) NOT NULL DEFAULT 'Open' CHECK (TicketStatus IN ('Open', 'In Progress', 'Resolved', 'Closed')),
    Priority NVARCHAR(10) NOT NULL CHECK (Priority IN ('Low', 'Medium', 'High', 'Urgent')),
    AssignedToEmployeeID INT DEFAULT NULL, -- default null, uppdateras via SP
    IssueDescription NVARCHAR(500) NOT NULL,
    ResolutionDescription NVARCHAR(500) NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (AssignedToEmployeeID) REFERENCES Employee(EmployeeID),
	CONSTRAINT SupportTicker_ResolvedAt CHECK (ResolvedAt > CreatedAt)

);

CREATE TABLE SupportResponse (
    ResponseID INT IDENTITY(1,1) PRIMARY KEY,
    TicketID INT NOT NULL,
    RespondedByEmployeeID INT NOT NULL,
    ResponseText NVARCHAR(1000) NOT NULL,
    ResponseDate DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (TicketID) REFERENCES SupportTicket(TicketID),
    FOREIGN KEY (RespondedByEmployeeID) REFERENCES Employee(EmployeeID)
);

CREATE TABLE SupportCategory (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL UNIQUE
	CONSTRAINT SupportCategory_CategoryName CHECK(CategoryName LIKE '%[A-Za-zÅÄÖåäö -]%'),
);



CREATE TABLE TicketCategoryMapping (
    TicketID INT NOT NULL,
    CategoryID INT NOT NULL,
    PRIMARY KEY (TicketID, CategoryID),
    FOREIGN KEY (TicketID) REFERENCES SupportTicket(TicketID),
    FOREIGN KEY (CategoryID) REFERENCES SupportCategory(CategoryID)
);

CREATE TABLE CustomerFeedback (
    FeedbackID INT IDENTITY(1,1) PRIMARY KEY,
    TicketID INT NOT NULL,
    CustomerID INT NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    FeedbackText NVARCHAR(500),
    SubmittedAt DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (TicketID) REFERENCES SupportTicket(TicketID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

GO

CREATE TABLE KnowledgeBase (
    KBID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    Title NVARCHAR(100) NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    LastUpdatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (CategoryID) REFERENCES SupportCategory(CategoryID)
);

GO



------------------------------FUNCTIONLAND--------------------------------------------------------------------------------------------


-- Man måste jobba på försäkringsavdelningen för att få godkänna en försäkringsutbetalning.

CREATE TRIGGER CheckInsuranceApproval
ON ClaimApproval
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Employee e ON i.ApprovedByEmployeeID = e.EmployeeID
        INNER JOIN Department d ON e.DepartmentID = d.DepartmentID
        WHERE d.DepartmentID <> 2
    )
    BEGIN

        RAISERROR ('Only employees from the Insurance Department can approve claims.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger för att kolla att ett konto inte överskrider sin kreditgräns. 

CREATE TRIGGER CheckNegativeBalance
ON Account
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN AccountType at ON i.AccountTypeID = at.AccountTypeID
        WHERE at.AllowNegativeBalance = 0 AND i.Balance < 0
    )
    BEGIN
        RAISERROR ('Negative balances are not allowed for this account type.', 16, 1);
        ROLLBACK;
    END
    ELSE IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN AccountType at ON i.AccountTypeID = at.AccountTypeID
        WHERE at.AllowNegativeBalance = 1 AND i.Balance < -at.NegativeBalanceLimit)
    BEGIN
        RAISERROR ('Balance exceeds the allowed negative limit for this account type.', 16, 1);
        ROLLBACK;
    END
END;
GO

-- Trigger för att kolla att ett konto inte får skapas med en negativ balance

CREATE TRIGGER CheckNegativeBalanceOnCreation
ON Account
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN AccountType at ON i.AccountTypeID = at.AccountTypeID
        WHERE at.AllowNegativeBalance = 0 AND i.Balance < 0 OR at.AllowNegativeBalance = 0 AND i.Balance < 0
    )

    BEGIN
        RAISERROR ('New accounts cannot be created with a negative balance.', 16, 1);
        ROLLBACK;
        RETURN;
    END
END;
GO


-- Stored Procedure för att ta ut pengar

CREATE PROCEDURE WithdrawMoney
    @AccountID INT,
    @CardID INT,
    @Amount DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentBalance DECIMAL(18,2), 
            @AllowNegative BIT, 
            @NegativeLimit DECIMAL(18,2), 
            @NewBalance DECIMAL(18,2), 
            @TransactionTypeID INT,
            @IsActive BIT, 
            @ExpiryDate DATE;

 SELECT @AccountID = d.AccountID,
           @IsActive = c.IsActive, 
           @ExpiryDate = c.CardValidTo
    FROM Disposition d
    INNER JOIN Card c ON d.CardID = c.CardID
    WHERE c.CardID = @CardID;
  

    IF @IsActive IS NULL
    BEGIN
        PRINT 'Error: Card not found!';
        RETURN;
    END

    IF @IsActive = 0 OR @ExpiryDate < GETDATE()
    BEGIN
        PRINT 'Error: Card is inactive or expired!';
        RETURN;
    END

    SELECT @CurrentBalance = Balance, 
           @AllowNegative = at.AllowNegativeBalance, 
           @NegativeLimit = at.NegativeBalanceLimit
    FROM Account a
    INNER JOIN AccountType at ON a.AccountTypeID = at.AccountTypeID
    WHERE a.AccountID = @AccountID;

    IF @CurrentBalance IS NULL
    BEGIN
        PRINT 'Error: Account not found!';
        RETURN;
    END

    IF (@CurrentBalance - @Amount < 0 AND @AllowNegative = 0) OR 
       (@AllowNegative = 1 AND @CurrentBalance - @Amount < -@NegativeLimit)
    BEGIN
        PRINT 'Error: Insufficient funds!';
        RETURN;
    END

    SET @NewBalance = @CurrentBalance - @Amount;

    SELECT @TransactionTypeID = TransactionTypeID 
    FROM TransactionType 
    WHERE TransactionTypeName = 'Withdrawal';

    UPDATE Account
    SET Balance = @NewBalance
    WHERE AccountID = @AccountID;

    INSERT INTO Transactions (AccountID, CardID, TransactionTypeID, TransactionAmount, TransactionDate, BalanceBefore, BalanceAfter)
    VALUES (@AccountID, @CardID, @TransactionTypeID, -@Amount, GETDATE(), @CurrentBalance, @NewBalance);

    PRINT 'Withdrawal successful!';
END;
GO



-- SP för att sätta in pengar på ett konto

CREATE PROCEDURE DepositMoney
    @AccountID INT,
    @Amount DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentBalance DECIMAL(18,2), 
            @NewBalance DECIMAL(18,2), 
            @TransactionTypeID INT;

    IF @Amount <= 0
    BEGIN
        PRINT 'Error: Deposit amount must be greater than zero!';
        RETURN;
    END

    SELECT @CurrentBalance = Balance 
    FROM Account 
    WHERE AccountID = @AccountID;

    IF @CurrentBalance IS NULL
    BEGIN
        PRINT 'Error: Account not found!';
        RETURN;
    END

    SET @NewBalance = @CurrentBalance + @Amount;

    SELECT @TransactionTypeID = TransactionTypeID 
    FROM TransactionType 
    WHERE TransactionTypeName = 'Deposit';

    UPDATE Account
    SET Balance = @NewBalance
    WHERE AccountID = @AccountID;

    INSERT INTO Transactions (AccountID, TransactionTypeID, TransactionAmount, TransactionDate, BalanceBefore, BalanceAfter)
    VALUES (@AccountID, @TransactionTypeID, @Amount, GETDATE(), @CurrentBalance, @NewBalance);

    PRINT 'Deposit successful!';
END;
GO

-- SP för att föra över pengar mellan konton


CREATE PROCEDURE TransferMoney
    @FromAccountID INT,
    @ToAccountID INT,
    @Amount DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SenderBalance DECIMAL(18,2), 
            @RecipientBalance DECIMAL(18,2), 
            @AllowNegative BIT, 
            @NegativeLimit DECIMAL(18,2), 
            @NewSenderBalance DECIMAL(18,2), 
            @NewRecipientBalance DECIMAL(18,2), 
            @TransactionTypeID INT;

    SELECT @SenderBalance = Balance, 
           @AllowNegative = at.AllowNegativeBalance, 
           @NegativeLimit = at.NegativeBalanceLimit
    FROM Account a
    INNER JOIN AccountType at ON a.AccountTypeID = at.AccountTypeID
    WHERE a.AccountID = @FromAccountID;

    IF @SenderBalance IS NULL
    BEGIN
        PRINT 'Error: Sender account not found!';
        RETURN;
    END

    SELECT @RecipientBalance = Balance 
    FROM Account 
    WHERE AccountID = @ToAccountID;

    IF @RecipientBalance IS NULL
    BEGIN
        PRINT 'Error: Recipient account not found!';
        RETURN;
    END

    IF (@SenderBalance - @Amount < 0 AND @AllowNegative = 0) OR 
       (@AllowNegative = 1 AND @SenderBalance - @Amount < -@NegativeLimit)
    BEGIN
        PRINT 'Error: Insufficient funds!';
        RETURN;
    END

    SET @NewSenderBalance = @SenderBalance - @Amount;
    SET @NewRecipientBalance = @RecipientBalance + @Amount;


    SELECT @TransactionTypeID = TransactionTypeID 
    FROM TransactionType 
    WHERE TransactionTypeName = 'Transfer';

    UPDATE Account
    SET Balance = @NewSenderBalance
    WHERE AccountID = @FromAccountID;

    UPDATE Account
    SET Balance = @NewRecipientBalance
    WHERE AccountID = @ToAccountID;

    INSERT INTO Transactions (AccountID, TransactionTypeID, TransactionAmount, TransactionDate, BalanceBefore, BalanceAfter)
    VALUES (@FromAccountID, @TransactionTypeID, -@Amount, GETDATE(), @SenderBalance, @NewSenderBalance);

    INSERT INTO Transactions (AccountID, TransactionTypeID, TransactionAmount, TransactionDate, BalanceBefore, BalanceAfter)
    VALUES (@ToAccountID, @TransactionTypeID, @Amount, GETDATE(), @RecipientBalance, @NewRecipientBalance);

    PRINT 'Transfer successful!';
END;


GO
-- SP för att skapa ett konto & uppdatera dispositions-tabellen

CREATE PROCEDURE CreateBankAccount
    @CustomerID INT,
    @AccountTypeID INT,
    @InitialDeposit DECIMAL(18,2),
    @ExistingAccountID INT = NULL,
    @AccountRole NVARCHAR(10) = 'Primary'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewAccountID INT;
    DECLARE @HolderCount INT;

    IF @ExistingAccountID IS NOT NULL
    BEGIN
        SELECT @HolderCount = COUNT(*)
        FROM Disposition
        WHERE AccountID = @ExistingAccountID;

        IF @HolderCount >= 2
        BEGIN
            PRINT 'Error: Cannot add more than 2 holders to a joint account.';
            RETURN;
        END;

        SET @NewAccountID = @ExistingAccountID;
    END
    ELSE
    BEGIN

        INSERT INTO Account (AccountTypeID, Balance, AccountOpened, IsActive)
        VALUES (@AccountTypeID, @InitialDeposit, GETDATE(), 1);

        SET @NewAccountID = SCOPE_IDENTITY();
    END

    INSERT INTO Disposition (CustomerID, AccountID, AccountRole)
    VALUES (@CustomerID, @NewAccountID, @AccountRole);

	PRINT 'Account successfully created.'
END;
GO


-- SP för att skapa ett kort och lägga in det i dispositions-tabellen länkat till rätt konto
CREATE PROCEDURE CreateCard
    @CustomerID INT,
    @AccountID INT,
    @CardTypeID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExistingAccount INT, @ExistingCustomer INT, @NewCardID INT;
    DECLARE @GeneratedCardNumber NVARCHAR(16);
    DECLARE @GeneratedCVV INT;
    DECLARE @IsLinked INT, @ExistingCardID INT;

    SELECT @ExistingAccount = AccountID 
    FROM Account 
    WHERE AccountID = @AccountID;

    IF @ExistingAccount IS NULL
    BEGIN
        PRINT 'Error: The specified account does not exist.';
        RETURN;
    END;

    SELECT @ExistingCustomer = CustomerID 
    FROM Customer 
    WHERE CustomerID = @CustomerID;

    IF @ExistingCustomer IS NULL
    BEGIN
        PRINT 'Error: The specified customer does not exist.';
        RETURN;
    END;

    SELECT @IsLinked = COUNT(*) 
    FROM Disposition 
    WHERE CustomerID = @CustomerID AND AccountID = @AccountID;

    IF @IsLinked = 0
    BEGIN
        PRINT 'Error: The customer is not linked to this account.';
        RETURN;
    END;

    SET @GeneratedCardNumber = 
        CAST(ABS(CHECKSUM(NEWID())) % 9000000000000000 + 1000000000000000 AS NVARCHAR(16));

    SET @GeneratedCVV = ABS(CHECKSUM(NEWID())) % 900 + 100;

    INSERT INTO Card (CardNumber, CardIssueDate, CardValidTo, CVV, CardTypeID, IsActive)
    VALUES (@GeneratedCardNumber, GETDATE(), DATEADD(YEAR, 3, GETDATE()), @GeneratedCVV, @CardTypeID, 1);

    SET @NewCardID = SCOPE_IDENTITY();

    SELECT @ExistingCardID = CardID
    FROM Disposition 
    WHERE CustomerID = @CustomerID AND AccountID = @AccountID;

    IF @ExistingCardID IS NULL
    BEGIN
        UPDATE Disposition
        SET CardID = @NewCardID
        WHERE CustomerID = @CustomerID AND AccountID = @AccountID;
        PRINT 'Card successfully created and linked to customer account (updated disposition).';
    END
    ELSE
    BEGIN

        INSERT INTO Disposition (CustomerID, AccountID, CardID)
        VALUES (@CustomerID, @AccountID, @NewCardID);
        PRINT 'Card successfully created and linked to customer account (new disposition).';
    END

    PRINT 'Generated Card Number: ' + @GeneratedCardNumber;
    PRINT 'Generated CVV: ' + CAST(@GeneratedCVV AS NVARCHAR(3));
END;
GO

-- SP för att ta ett lån


CREATE PROCEDURE TakeLoan
    @CustomerID INT,
    @LoanTypeID INT,
    @InterestTypeID INT,
    @LoanAmount DECIMAL(18,2),
    @LoanStartDate DATE,
    @LoanEndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @LoanID INT, 
            @InterestRate DECIMAL(10,3), 
            @MonthlyInterestRate DECIMAL(10,6), 
            @TotalMonths INT, 
            @MonthlyPayment DECIMAL(18,2),
            @AccountID INT,
            @CurrentMonth INT,
            @DueDate DATE,
            @RemainingAmount DECIMAL(18,2),
            @BalanceBefore DECIMAL(18,2),
            @BalanceAfter DECIMAL(18,2),
            @TransactionTypeID INT;

    SELECT TOP 1 @AccountID = a.AccountID, @BalanceBefore = a.Balance
    FROM Disposition d
    INNER JOIN Account a ON d.AccountID = a.AccountID
    WHERE d.CustomerID = @CustomerID
    ORDER BY d.AccountID ASC;

    IF @AccountID IS NULL
    BEGIN
        PRINT 'Error: Customer does not have a bank account!';
        RETURN;
    END

    SELECT @InterestRate = InterestAmount FROM InterestType WHERE InterestTypeID = @InterestTypeID;
    
    IF @InterestRate IS NULL
    BEGIN
        PRINT 'Error: Invalid Interest Type!';
        RETURN;
    END

    INSERT INTO Loan (LoanTypeID, InterestTypeID, CustomerID, LoanAmount, LoanStartDate, LoanEndDate)
    VALUES (@LoanTypeID, @InterestTypeID, @CustomerID, @LoanAmount, @LoanStartDate, @LoanEndDate);

    SET @LoanID = SCOPE_IDENTITY();

    SET @MonthlyInterestRate = @InterestRate / 100 / 12;
    SET @TotalMonths = DATEDIFF(MONTH, @LoanStartDate, @LoanEndDate);
    SET @RemainingAmount = @LoanAmount;
    SET @CurrentMonth = 1;

    IF @TotalMonths > 0 AND @MonthlyInterestRate > 0
    BEGIN
       IF @TotalMonths > 0 
BEGIN
    IF @MonthlyInterestRate > 0
    BEGIN
        SET @MonthlyPayment = (@LoanAmount * @MonthlyInterestRate) / 
                              (1 - POWER(1 + @MonthlyInterestRate, -@TotalMonths));
    END
    ELSE
    BEGIN
        SET @MonthlyPayment = @LoanAmount / @TotalMonths;
    END
END
ELSE
BEGIN
    PRINT 'Error: Loan duration must be greater than zero!';
    RETURN;
END

    END
    ELSE
    BEGIN
        SET @MonthlyPayment = @LoanAmount / NULLIF(@TotalMonths, 0);
    END

WHILE @CurrentMonth <= @TotalMonths AND @RemainingAmount > 0
BEGIN
    SET @DueDate = DATEADD(MONTH, @CurrentMonth, @LoanStartDate);

    DECLARE @InterestThisMonth DECIMAL(18,2);
    SET @InterestThisMonth = ROUND(@RemainingAmount * @MonthlyInterestRate, 2);

    DECLARE @PrincipalPortion DECIMAL(18,2);
    SET @PrincipalPortion = @MonthlyPayment - @InterestThisMonth;

    IF @CurrentMonth = @TotalMonths OR @RemainingAmount <= @PrincipalPortion
    BEGIN

        SET @PrincipalPortion = @RemainingAmount;
        SET @InterestThisMonth = ROUND(@MonthlyPayment - @PrincipalPortion, 2);
        SET @MonthlyPayment = @PrincipalPortion;
    END

    SET @RemainingAmount = @RemainingAmount - @PrincipalPortion;

    INSERT INTO LoanRepayment (AccountID, LoanID, RepaymentAmount, InterestAmount, RemainingAmount, DueDate, PaymentStatus)
    VALUES (@AccountID, @LoanID, @MonthlyPayment, @InterestThisMonth, 
            CASE WHEN @RemainingAmount < 0 THEN 0 ELSE @RemainingAmount END, 
            @DueDate, 'Due');

    SET @CurrentMonth = @CurrentMonth + 1;
END


    SET @BalanceAfter = @BalanceBefore + @LoanAmount;

    UPDATE Account
    SET Balance = @BalanceAfter
    WHERE AccountID = @AccountID;

    SELECT @TransactionTypeID = TransactionTypeID 
    FROM TransactionType 
    WHERE TransactionTypeName = 'Loan Deposit';

    INSERT INTO Transactions (AccountID, TransactionTypeID, TransactionAmount, TransactionDate, BalanceBefore, BalanceAfter)
    VALUES (@AccountID, @TransactionTypeID, @LoanAmount, GETDATE(), @BalanceBefore, @BalanceAfter);

    PRINT 'Loan successfully issued!';
END;
GO


-- SP för att betala av ett lån enligt betalningsplanen gjort i SPn "Take Loan"
CREATE PROCEDURE ProcessLoanRepayment
    @LoanID INT,
    @AccountID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE 
        @RepaymentAmount DECIMAL(18,2), 
        @RemainingBalance DECIMAL(18,2), 
        @LoanRepaymentID INT,
        @TransactionDate DATETIME,
        @LoanAccountID INT,
        @BalanceBefore DECIMAL(18,2),
        @BalanceAfter DECIMAL(18,2),
        @TransactionTypeID INT;

    SELECT @LoanAccountID = d.AccountID
    FROM Loan l
    INNER JOIN Customer c ON l.CustomerID = c.CustomerID
    INNER JOIN Disposition d ON c.CustomerID = d.CustomerID
    WHERE l.LoanID = @LoanID;

    IF @LoanAccountID <> @AccountID
    BEGIN
        PRINT 'Error: This account is not authorized to pay this loan!';
        RETURN;
    END

    SELECT @RemainingBalance = Balance 
    FROM Account
    WHERE AccountID = @AccountID;

    SELECT TOP 1 
        @LoanRepaymentID = LoanRepaymentID, 
        @RepaymentAmount = RepaymentAmount, 
        @TransactionDate = DueDate
    FROM LoanRepayment
    WHERE LoanID = @LoanID AND PaymentStatus = 'Due'
    ORDER BY DueDate ASC; 

    IF @LoanRepaymentID IS NOT NULL AND @RemainingBalance >= @RepaymentAmount
    BEGIN

        SET @BalanceBefore = @RemainingBalance;
        SET @BalanceAfter = @BalanceBefore - @RepaymentAmount;


        UPDATE Account
        SET Balance = @BalanceAfter
        WHERE AccountID = @AccountID;

        SELECT @TransactionTypeID = TransactionTypeID 
        FROM TransactionType 
        WHERE TransactionTypeName = 'Loan Repayment';

        INSERT INTO Transactions (AccountID, TransactionTypeID, TransactionAmount, TransactionDate, BalanceBefore, BalanceAfter)
        VALUES (@AccountID, @TransactionTypeID, -@RepaymentAmount, GETDATE(), @BalanceBefore, @BalanceAfter);


        UPDATE LoanRepayment
        SET PaymentStatus = 'Paid', PaymentDate = GETDATE()
        WHERE LoanRepaymentID = @LoanRepaymentID;

        IF NOT EXISTS (
            SELECT 1 FROM LoanRepayment 
            WHERE LoanID = @LoanID AND PaymentStatus = 'Due'
        )
        BEGIN
            UPDATE LoanRepayment
            SET PaymentStatus = 'Fully Paid'
            WHERE LoanID = @LoanID;
        END

        PRINT 'Loan installment paid successfully!';
    END
    ELSE IF @LoanRepaymentID IS NULL
    BEGIN
        PRINT 'Error: No due installment found!';
    END
    ELSE
    BEGIN
        PRINT 'Error: Insufficient funds!';
    END
END;
GO

-- SP för att betala ut försäkring
CREATE PROCEDURE ProcessInsurancePayout
    @ClaimID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PolicyID INT, @CustomerID INT, @ClaimAmount DECIMAL(18,2),
            @AccountID INT, @ClaimStatus NVARCHAR(15), @Approved NVARCHAR(30);

    SELECT @PolicyID = PolicyID, @ClaimAmount = ClaimAmount, @ClaimStatus = ClaimStatus
    FROM InsuranceClaim
    WHERE ClaimID = @ClaimID;



	SELECT @Approved = Decision
	FROM ClaimApproval
	WHERE @ClaimID = ClaimID

 IF @Approved = 'Rejected' 
    BEGIN
        UPDATE InsuranceClaim
        SET ClaimStatus = 'Rejected'
        WHERE ClaimID = @ClaimID;

        PRINT 'Error: Claim has been rejected!';
        RETURN;
    END

    IF @Approved <> ('Approved')
    BEGIN
        PRINT 'Error: Claim has not been approved!';
        RETURN;
    END

 IF @ClaimStatus = 'Paid'
    BEGIN
        PRINT 'Error: This claim has already been paid!';
        RETURN;
    END

    SELECT @CustomerID = CustomerID FROM Insurance WHERE PolicyID = @PolicyID;

    SELECT TOP 1 @AccountID = AccountID 
    FROM Disposition 
    WHERE CustomerID = @CustomerID 
    ORDER BY AccountID ASC; 

    IF @AccountID IS NULL
    BEGIN
        PRINT 'Error: No bank account found for this customer!';
        RETURN;
    END

    UPDATE Account
    SET Balance = Balance + @ClaimAmount
    WHERE AccountID = @AccountID;

    INSERT INTO Transactions (AccountID, TransactionTypeID, TransactionAmount, TransactionDate)
    VALUES (@AccountID, 5, @ClaimAmount, GETDATE());

    UPDATE InsuranceClaim
    SET ClaimStatus = 'Paid'
    WHERE ClaimID = @ClaimID;

    PRINT 'Insurance claim payout processed successfully!';
END;
GO


-- Stored Procedure för att skapa en support ticket
CREATE PROCEDURE OpenAndAssignTicket
    @CustomerID INT,
	@CategoryID INT,
    @IssueDescription NVARCHAR(500),
    @Priority NVARCHAR(10) = 'Medium'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TicketID INT;
    DECLARE @EmployeeID INT;
    DECLARE @RecentTicketID INT;


    SELECT TOP 1 @RecentTicketID = TicketID
    FROM SupportTicket
    WHERE CustomerID = @CustomerID
        AND IssueDescription = @IssueDescription
        AND CreatedAt >= DATEADD(MINUTE, -10, GETDATE())
    ORDER BY CreatedAt DESC;

    IF @RecentTicketID IS NOT NULL
    BEGIN
        PRINT 'Error: Duplicate ticket detected. Submission denied. Try again in 10 minutes.';
        RETURN;
    END;

    INSERT INTO SupportTicket (CustomerID, CreatedAt, TicketStatus, Priority, IssueDescription)
    VALUES (@CustomerID, GETDATE(), 'Open', @Priority, @IssueDescription);

    SET @TicketID = SCOPE_IDENTITY();

    SELECT TOP 1 @EmployeeID = Employee.EmployeeID
    FROM Employee
    INNER JOIN Department ON Employee.DepartmentID = Department.DepartmentID
    LEFT JOIN SupportTicket ON Employee.EmployeeID = SupportTicket.AssignedToEmployeeID 
        AND SupportTicket.TicketStatus IN ('Open', 'In Progress')
    WHERE Department.DepartmentID = 4 
    GROUP BY Employee.EmployeeID
    ORDER BY COUNT(SupportTicket.TicketID) ASC;

    UPDATE SupportTicket
    SET AssignedToEmployeeID = @EmployeeID
    WHERE TicketID = @TicketID;

	    IF @CategoryID IS NOT NULL
    BEGIN
        INSERT INTO TicketCategoryMapping (TicketID, CategoryID)
        VALUES (@TicketID, @CategoryID);
    END;


    PRINT 'Ticket successfully logged.'
END;
GO

-- Stored Procedure för att svara på och stänga en support ticket

CREATE PROCEDURE CloseAndResolveTicket
    @TicketID INT,
	@ResolutionDescription NVARCHAR(1000),
    @RespondedByEmployeeID INT, 
    @ResponseText NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TicketStatus NVARCHAR(50), @AssignedEmployeeID INT;

    SELECT @TicketStatus = TicketStatus, @AssignedEmployeeID = AssignedToEmployeeID
    FROM SupportTicket
    WHERE TicketID = @TicketID;

    IF @TicketStatus IS NULL
    BEGIN
        PRINT 'Error: The specified ticket does not exist.';
        RETURN;
    END;

    IF @TicketStatus NOT IN ('Open', 'In Progress')
    BEGIN
        PRINT 'Error: The ticket cannot be closed because it is not open or in progress.';
        RETURN;
    END;

    UPDATE SupportTicket
    SET TicketStatus = 'Resolved', ResolvedAt = GETDATE(), ResolutionDescription = @ResolutionDescription
    WHERE TicketID = @TicketID;

    INSERT INTO SupportResponse (TicketID, RespondedByEmployeeID, ResponseText)
    VALUES (@TicketID, @RespondedByEmployeeID, @ResponseText);


    PRINT 'Ticket successfully closed and resolved, and response logged!';
END;
GO


--------------------------INSERTLAND------------------------------------------------------------------------------------

PRINT 'Welcome to the Wilfrid Laurier Memorial Bank database system!'
PRINT 'Please use our Stored Procedures to interact with the system, and have a jolly good day, eh?'

INSERT INTO TransactionType (TransactionTypeName)
VALUES
('Withdrawal'),
('Deposit'),
('Loan Repayment'),
('Insurance Payment'),
('Insurance Payout'),
('Loan Deposit'),
('Transfer'),
('ATM Withdrawal'),
('ATM Deposit')


INSERT INTO CardType (CardTypeName) VALUES
('Credit'),
('Debit'),
('Secured'),
('Money Access');
GO

INSERT INTO Card (CardNumber, CardIssueDate, CardValidTo, CVV, CardTypeID, IsActive) VALUES
(12345678901234, '2023-01-03', '2026-01-03', 123, 2, 1),
(23456789012345, '2024-05-11', '2027-05-11', 456, 1, 0),
(34567890123456,'2022-04-16', '2025-04-16', 789, 3, 1);
GO


INSERT INTO InterestType (InterestAmount) VALUES
(2),
(2.5),
(3),
(4),
(4.45),
(5),
(7)

GO

INSERT INTO AccountType (InterestTypeID, AccountTypeName, AllowNegativeBalance, NegativeBalanceLimit)
VALUES 
    (1, 'Checking Account', 1, 500.00),
    (2, 'Savings Account', 0, 0),
    (3, 'Business Account', 1, 1000.00);
GO


INSERT INTO Branch (OfficeName, OfficeAddress, City, ZipCode, BranchCountry) VALUES
('Downtown Toronto', '123 Bay St', 'Toronto', 'M5J 2N8', 'Canada'),
('Vancouver Central', '456 Granville St', 'Vancouver', 'V6C 1T2', 'Canada'),
('Montreal East', '789 Rue Sainte-Catherine', 'Montreal', 'H3B 1B5', 'Canada'),
('Calgary South', '101 8 Ave SW', 'Calgary', 'T2P 1B4', 'Canada');


GO

INSERT INTO Department (BranchID, DepartmentName) VALUES
(1, 'Finance'),
(2, 'Insurance'),
(3, 'IT'),
(4, 'Customer Support');
GO

INSERT INTO Employee (DepartmentID, EmployeeName, EmployeePhone) VALUES
(1, 'Wilford Lark', '+1-202-555-0123'),
(2, 'Björn Svensson', '+46-8-555-1234'),
(3, 'Carina Eriksson', '+46-31-555-5678'),
(4, 'David Miller', '+44-20-7946-0958'),
(4, 'Emma Wilson', '+44-121-555-7890'),
(4, 'Franklin Carter', '+1-415-555-2468'),
(2, 'Cortman DeWott', '+1-411-122-9518');
GO


INSERT INTO Customer (BranchID, CustomerName, BirthDate, Gender, IsMarried, IsPensioner, PhoneNumber, EmailAddress, Address, City, Country) VALUES
(1,'John Holden', '1991-08-11', 'M', 1, 0, '+46701-567897', 'JohnHolden@HoldenEnterprises.com', 'Apoteksgatan 12', 'Knivsta', 'Sweden'),
(1,'Lisa Embosso','1995-01-17', 'F', 0, 0, '+4673-567844', 'LisaEmb@email.com', 'Stockmansvägen 45', 'Tierp', 'Sweden'),
(1,'Hugo Marsvinsson', '2001-08-12', 'M', 0, 0, '+4673-1312774', 'Hugo@Hugoshay.com', 'Söderovägen 11', 'Fullerö', 'Sweden'),
(1,'Alice Johnson', '1985-03-10', 'Female', 1, 0, '123456789', 'alice@email.com', '21 Beaver Street', 'Sault-St-Marie', 'Canada'),
(2,'Bob Smith', '1990-07-15', 'Male', 0, 0, '987654321', 'bob@email.com', '49 Moose Avenue', 'Tuppewa', 'Canada'),
(3,'Charlie Davis', '1978-12-01', 'Male', 1, 1, '555666777', 'charlie@email.com', '12 Washawa Street', 'Edmonton', 'Canada'),
(1, 'Ethan Tremblay', '1988-04-22', 'Male', 1, 0, '+1 604-555-1234', 'ethan.tremblay@email.ca', '342 Pine St', 'Vancouver', 'Canada'),
(2, 'Olivia MacKenzie', '1992-09-30', 'Female', 0, 0, '+1 416-555-9876', 'olivia.mackenzie@email.ca', '1200 Maple Ave', 'Toronto', 'Canada'),
(3, 'Noah Leblanc', '1975-06-18', 'Male', 1, 1, '+1 418-555-3322', 'noah.leblanc@email.ca', '89 Rue Saint-Paul', 'Quebec City', 'Canada'),
(1, 'Sophia O’Reilly', '1998-11-25', 'Female', 0, 0, '+1 780-555-4567', 'sophia.oreilly@email.ca', '78 Jasper Ave', 'Edmonton', 'Canada'),
(4, 'Liam Fortin', '1983-02-14', 'Male', 1, 0, '+1 514-555-8899', 'liam.fortin@email.ca', '212 Boul René-Lévesque', 'Montreal', 'Canada'),
(1, 'Emma Sinclair', '1996-07-04', 'Female', 0, 0, '+1 306-555-7766', 'emma.sinclair@email.ca', '67 Broadway St', 'Regina', 'Canada'),
(1, 'Benjamin Carter', '1972-12-09', 'Male', 1, 1, '+1 204-555-2211', 'ben.carter@email.ca', '54 Portage Ave', 'Winnipeg', 'Canada'),
(1, 'Charlotte Dubois', '1990-05-21', 'Female', 1, 0, '+1 613-555-4433', 'charlotte.dubois@email.ca', '33 Rideau St', 'Ottawa', 'Canada'),
(1, 'Jack Thompson', '1981-03-03', 'Male', 1, 0, '+1 867-555-9988', 'jack.thompson@email.ca', '8 Franklin Ave', 'Yellowknife', 'Canada'),
(1, 'Emily Walker', '1985-08-25', 'Female', 1, 0, '+1 867-555-2233', 'emily.walker@email.ca', '123 Maple St', 'Yellowknife', 'Canada'),
(1, 'James Walker', '1983-11-14', 'Male', 1, 0, '+1 867-555-8877', 'james.walker@email.ca', '123 Maple St', 'Yellowknife', 'Canada'),
(2, 'Ethan Brooks', '1994-06-22', 'Male', 0, 0, '+1 403-555-1234', 'ethan.brooks@email.ca', '56 River St', 'Calgary', 'Canada'),
(3, 'Ava Martin', '1989-09-14', 'Female', 1, 0, '+1 780-555-6789', 'ava.martin@email.ca', '120 Bayview Ave', 'Edmonton', 'Canada'),
(4, 'Mason Taylor', '1975-11-30', 'Male', 1, 1, '+1 604-555-4321', 'mason.taylor@email.ca', '342 Spruce St', 'Vancouver', 'Canada'),
(1, 'Isabella Reynolds', '1993-04-18', 'Female', 0, 0, '+1 416-555-8765', 'isabella.reynolds@email.ca', '789 Queen St', 'Toronto', 'Canada'),
(2, 'Logan Bennett', '1987-12-25', 'Male', 1, 0, '+1 514-555-3456', 'logan.bennett@email.ca', '145 Bloor St', 'Montreal', 'Canada'),
(3, 'Mia Foster', '1990-10-10', 'Female', 1, 0, '+1 647-555-2345', 'mia.foster@email.ca', '34 King St', 'Toronto', 'Canada'),
(4, 'Lucas Henderson', '1972-02-05', 'Male', 1, 1, '+1 204-555-6789', 'lucas.henderson@email.ca', '88 Wellington Ave', 'Winnipeg', 'Canada'),
(2, 'Amelia Thompson', '1998-07-22', 'Female', 0, 0, '+1 705-555-7890', 'amelia.thompson@email.ca', '12 Lakeshore Dr', 'Sudbury', 'Canada'),
(3, 'Henry Carter', '1984-08-19', 'Male', 1, 0, '+1 905-555-3210', 'henry.carter@email.ca', '210 Dundas St', 'Mississauga', 'Canada'),
(4, 'Charlotte Evans', '1991-01-27', 'Female', 1, 0, '+1 709-555-8765', 'charlotte.evans@email.ca', '500 Main Rd', 'St. Johns', 'Canada'),
(1, 'William Parker', '1977-06-13', 'Male', 1, 1, '+1 306-555-4321', 'william.parker@email.ca', '76 Prairie St', 'Regina', 'Canada'),
(2, 'Sophia White', '1995-11-11', 'Female', 0, 0, '+1 403-555-5678', 'sophia.white@email.ca', '98 Bow River Rd', 'Calgary', 'Canada'),
(3, 'Jacob Russell', '1982-03-09', 'Male', 1, 0, '+1 204-555-1098', 'jacob.russell@email.ca', '56 Broadway Ave', 'Winnipeg', 'Canada'),
(4, 'Emily Harris', '1999-12-29', 'Female', 0, 0, '+1 819-555-7777', 'emily.harris@email.ca', '67 Laurier St', 'Gatineau', 'Canada'),
(1, 'Liam Scott', '1979-05-07', 'Male', 1, 1, '+1 867-555-3344', 'liam.scott@email.ca', '400 Aurora Rd', 'Whitehorse', 'Canada'),
(2, 'Ella Robinson', '1986-09-02', 'Female', 1, 0, '+1 705-555-8901', 'ella.robinson@email.ca', '87 Georgian Bay Rd', 'Barrie', 'Canada'),
(3, 'Noah Green', '1994-02-16', 'Male', 0, 0, '+1 506-555-5674', 'noah.green@email.ca', '19 Water St', 'Fredericton', 'Canada'),
(4, 'Lily Adams', '1981-07-21', 'Female', 1, 0, '+1 867-555-7654', 'lily.adams@email.ca', '233 Polar Bear Rd', 'Yellowknife', 'Canada'),
(1, 'James Hall', '1974-08-03', 'Male', 1, 1, '+1 709-555-9981', 'james.hall@email.ca', '90 Signal Hill Rd', 'St. Johns', 'Canada'),
(2, 'Olivia Wright', '2000-10-12', 'Female', 0, 0, '+1 418-555-8763', 'olivia.wright@email.ca', '76 Old Quebec St', 'Quebec City', 'Canada');

GO

GO

INSERT INTO Account (AccountTypeID, Balance, AccountOpened, IsActive)
VALUES 
(1, 1000.00, '2025-02-19', 1),
(2, 2000.00, '2025-02-19', 1),
(3, 1500.00, '2025-02-19', 1),
(1, 500.00, '2025-02-19', 1);

GO
INSERT INTO Disposition(CustomerID, CardID, AccountID) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3);

GO

INSERT INTO LoanType (LoanTypeName) VALUES
('Personal Loan'),
('Mortgage'),
('Auto Loan'),
('Student Loan');
GO

INSERT INTO InsuranceType (TypeName) VALUES
('Personal Injury Insurance'),
('Car Insurance'),
('Home Insurance'),
('Personal Belongings Insurance')

GO

INSERT INTO Insurance (CustomerID, InsuranceTypeID, PremiumAmount, CoverageAmount) VALUES
(1, 1, 140, 15000),
(2, 1, 360, 15000),
(14, 1, 150, 18000),
(7, 2, 250, 155000),
(5, 1, 150, 10000),
(8, 2, 315, 5000),
(9, 1, 150, 55000),
(10, 3, 18, 35000),
(6, 1, 190, 15000);

GO

INSERT INTO InsuranceClaim (PolicyID, ClaimDate, ClaimAmount, Comment) VALUES
(1, '2025-02-19', 7500, 'Broken Arm'),
(2, '2025-02-19', 1500, 'Ligma'),
(3, '2025-02-19', 2500, 'Stubbed Toe'),
(4, '2025-03-05', 10000, 'Car Accident - Minor Damage'),
(5, '2025-03-10', 7500, 'House Fire - Partial Damage'),
(6, '2025-03-15', 5000, 'Flood Damage - Basement'),
(7, '2025-03-20', 30000, 'Car Stolen'),
(8, '2025-03-22', 1200, 'Bicycle Theft'),
(9, '2025-03-25', 15000, 'Medical Surgery')
GO


INSERT INTO ClaimApproval (ClaimID, ApprovedByEmployeeID, ApprovalDate, Decision, Comments) VALUES
(1, 2, GETDATE(), 'Approved', 'Verified Medical Documents'),
(2, 2, GETDATE(), 'Rejected', 'Who the hell is Steve Jobs?'),
(3, 2, GETDATE(), 'Pending', 'Oopsie'),
(4, 7, GETDATE(), 'Approved', 'Repair estimates confirmed by garage'),
(5, 7, GETDATE(), 'Approved', 'Fire damage assessment completed'),
(6, 7, GETDATE(), 'Rejected', 'Damage below deductible amount'),
(7, 2, GETDATE(), 'Approved', 'Police report verified'),
(8, 7, GETDATE(), 'Pending', 'Waiting for proof of ownership'),
(9, 2, GETDATE(), 'Approved', 'Surgery invoices verified')

GO


INSERT INTO SupportCategory (CategoryName) VALUES 
('Card Issues'),
('Loan Queries'),
('Account Access'),
('Fraud and Security'),
('Transaction Disputes');

GO


INSERT INTO SupportTicket (CustomerID, CreatedAt, TicketStatus, Priority, AssignedToEmployeeID, IssueDescription) VALUES 
(1, GETDATE(), 'Open', 'High', 1, 'My card has been blocked without any notification.'),
(2, GETDATE(), 'In Progress', 'Medium', 2, 'I applied for a loan, but it is still pending approval.'),
(3, GETDATE(), 'Open', 'Urgent', 3, 'I noticed an unauthorized transaction on my account.');

GO


INSERT INTO SupportResponse (TicketID, RespondedByEmployeeID, ResponseText, ResponseDate) VALUES 
(1, 1, 'We are looking into your card issue and will update you shortly.', GETDATE()),
(2, 2, 'Your loan application is under review. Please allow 2-3 business days.', GETDATE()),
(3, 3, 'We have flagged the transaction for investigation. Please monitor your account.', GETDATE());

GO

INSERT INTO CustomerFeedback (TicketID, CustomerID, Rating, FeedbackText, SubmittedAt) VALUES 
(1, 1, 4, 'The response was quick, but I need a resolution soon.', GETDATE()),
(2, 2, 3, 'Still waiting for my loan approval.', GETDATE()),
(3, 3, 5, 'Very satisfied with the fraud detection process.', GETDATE());

GO


INSERT INTO KnowledgeBase (CategoryID, Title, Content, CreatedAt, LastUpdatedAt) VALUES 
(1, 'How to unblock your card', 'If your card is blocked, contact support at 1-800-XXX-XXXX or visit a branch.', GETDATE(), GETDATE()),
(2, 'Loan application process', 'Loan applications typically take 2-5 business days to process. Ensure all documents are submitted.', GETDATE(), GETDATE()),
(4, 'What to do if you suspect fraud', 'If you notice unauthorized transactions, freeze your card immediately and contact support.', GETDATE(), GETDATE());

GO

INSERT INTO TicketCategoryMapping (TicketID, CategoryID) VALUES 
(1, 1),
(2, 2),
(3, 4); 


-- EXECLAND



EXEC CreateBankAccount @CustomerID = 4, @AccountTypeID = 1, @InitialDeposit = 500
EXEC CreateBankAccount @CustomerID = 5, @AccountTypeID = 1, @InitialDeposit = 1500
EXEC CreateBankAccount @CustomerID = 6, @AccountTypeID = 1, @InitialDeposit = 2000
EXEC CreateBankAccount @CustomerID = 7, @AccountTypeID = 2, @InitialDeposit = 12000
EXEC CreateBankAccount @CustomerID = 8, @AccountTypeID = 3, @InitialDeposit = 21000
EXEC CreateBankAccount @CustomerID = 9, @AccountTypeID = 2, @InitialDeposit = 31650
EXEC CreateBankAccount @CustomerID = 10, @AccountTypeID = 1, @InitialDeposit = 19.52
EXEC CreateBankAccount @CustomerID = 11, @AccountTypeID = 1, @InitialDeposit = 41.50
EXEC CreateBankAccount @CustomerID = 12, @AccountTypeID = 3, @InitialDeposit = 3210000
EXEC CreateBankAccount @CustomerID = 16, @AccountTypeID = 1, @InitialDeposit = 16500
EXEC CreateBankAccount @CustomerID = 17, @AccountTypeID = 1, @InitialDeposit = 0, @ExistingAccountID = 14, @AccountRole = 'Joint'
EXEC CreateBankAccount @CustomerID = 14, @AccountTypeID = 1, @InitialDeposit = 0
EXEC CreateBankAccount @CustomerID = 18, @AccountTypeID = 1, @InitialDeposit = 800
EXEC CreateBankAccount @CustomerID = 19, @AccountTypeID = 1, @InitialDeposit = 2500
EXEC CreateBankAccount @CustomerID = 20, @AccountTypeID = 2, @InitialDeposit = 10500
EXEC CreateBankAccount @CustomerID = 21, @AccountTypeID = 3, @InitialDeposit = 45000
EXEC CreateBankAccount @CustomerID = 22, @AccountTypeID = 1, @InitialDeposit = 300
EXEC CreateBankAccount @CustomerID = 23, @AccountTypeID = 2, @InitialDeposit = 15700
EXEC CreateBankAccount @CustomerID = 24, @AccountTypeID = 1, @InitialDeposit = 1200
EXEC CreateBankAccount @CustomerID = 25, @AccountTypeID = 3, @InitialDeposit = 250000
EXEC CreateBankAccount @CustomerID = 26, @AccountTypeID = 1, @InitialDeposit = 600
EXEC CreateBankAccount @CustomerID = 27, @AccountTypeID = 2, @InitialDeposit = 9000
EXEC CreateBankAccount @CustomerID = 28, @AccountTypeID = 1, @InitialDeposit = 50
EXEC CreateBankAccount @CustomerID = 29, @AccountTypeID = 2, @InitialDeposit = 18500
EXEC CreateBankAccount @CustomerID = 30, @AccountTypeID = 3, @InitialDeposit = 475000
EXEC CreateBankAccount @CustomerID = 31, @AccountTypeID = 1, @InitialDeposit = 2100
EXEC CreateBankAccount @CustomerID = 32, @AccountTypeID = 2, @InitialDeposit = 32000
EXEC CreateBankAccount @CustomerID = 33, @AccountTypeID = 1, @InitialDeposit = 75.25
EXEC CreateBankAccount @CustomerID = 34, @AccountTypeID = 1, @InitialDeposit = 925
EXEC CreateBankAccount @CustomerID = 35, @AccountTypeID = 2, @InitialDeposit = 14700
EXEC CreateBankAccount @CustomerID = 36, @AccountTypeID = 1, @InitialDeposit = 3500
EXEC CreateBankAccount @CustomerID = 37, @AccountTypeID = 3, @InitialDeposit = 680000


EXEC CreateCard @CustomerID = 4, @AccountID = 5, @CardTypeID = 2
EXEC CreateCard @CustomerID = 5, @AccountID = 6, @CardTypeID = 1
EXEC CreateCard @CustomerID = 6, @AccountID = 7, @CardTypeID = 1
EXEC CreateCard @CustomerID = 7, @AccountID = 8, @CardTypeID = 1
EXEC CreateCard @CustomerID = 8, @AccountID = 9, @CardTypeID = 1
EXEC CreateCard @CustomerID = 9, @AccountID = 10, @CardTypeID = 2
EXEC CreateCard @CustomerID = 10, @AccountID = 11, @CardTypeID = 1
EXEC CreateCard @CustomerID = 11, @AccountID = 12, @CardTypeID = 2
EXEC CreateCard @CustomerID = 12, @AccountID = 13, @CardTypeID = 3
EXEC CreateCard @CustomerID = 12, @AccountID = 13, @CardTypeID = 1
EXEC CreateCard @CustomerID = 16, @AccountID = 14, @CardTypeID = 2
EXEC CreateCard @CustomerID = 17, @AccountID = 14, @CardTypeID = 2
EXEC CreateCard @CustomerID = 14, @AccountID = 15, @CardTypeID = 2
EXEC CreateCard @CustomerID = 18, @AccountID = 16, @CardTypeID = 3
EXEC CreateCard @CustomerID = 19, @AccountID = 17, @CardTypeID = 1
EXEC CreateCard @CustomerID = 20, @AccountID = 18, @CardTypeID = 2
EXEC CreateCard @CustomerID = 21, @AccountID = 19, @CardTypeID = 4
EXEC CreateCard @CustomerID = 22, @AccountID = 20, @CardTypeID = 3
EXEC CreateCard @CustomerID = 23, @AccountID = 21, @CardTypeID = 2
EXEC CreateCard @CustomerID = 24, @AccountID = 22, @CardTypeID = 1
EXEC CreateCard @CustomerID = 25, @AccountID = 23, @CardTypeID = 4
EXEC CreateCard @CustomerID = 26, @AccountID = 24, @CardTypeID = 3
EXEC CreateCard @CustomerID = 27, @AccountID = 25, @CardTypeID = 1
EXEC CreateCard @CustomerID = 28, @AccountID = 26, @CardTypeID = 2
EXEC CreateCard @CustomerID = 29, @AccountID = 27, @CardTypeID = 4
EXEC CreateCard @CustomerID = 30, @AccountID = 28, @CardTypeID = 1
EXEC CreateCard @CustomerID = 31, @AccountID = 29, @CardTypeID = 3
EXEC CreateCard @CustomerID = 32, @AccountID = 30, @CardTypeID = 2
EXEC CreateCard @CustomerID = 33, @AccountID = 31, @CardTypeID = 4
EXEC CreateCard @CustomerID = 34, @AccountID = 32, @CardTypeID = 1
EXEC CreateCard @CustomerID = 35, @AccountID = 33, @CardTypeID = 3
EXEC CreateCard @CustomerID = 36, @AccountID = 34, @CardTypeID = 2
EXEC CreateCard @CustomerID = 37, @AccountID = 35, @CardTypeID = 4



EXEC OpenAndAssignTicket @CustomerID = 2, @CategoryID = 3, @IssueDescription = 'I dropped my bank account down a well', @Priority = 'Urgent'
EXEC OpenAndAssignTicket @CustomerID = 1, @CategoryID = 1, @IssueDescription = 'My cat used my debit card for online shopping', @Priority = 'Medium';
EXEC OpenAndAssignTicket @CustomerID = 3, @CategoryID =  4,@IssueDescription = 'My bank account is being haunted by ghosts', @Priority = 'High';
EXEC OpenAndAssignTicket @CustomerID = 5, @CategoryID =  3, @IssueDescription = 'I accidentally set my savings account to autopilot', @Priority = 'Low';
EXEC OpenAndAssignTicket @CustomerID = 7, @CategoryID =  4, @IssueDescription = 'My account has been hijacked by squirrels', @Priority = 'Urgent';
EXEC OpenAndAssignTicket @CustomerID = 9, @CategoryID =  3, @IssueDescription = 'I need help getting my bank account to sing', @Priority = 'Medium';
EXEC OpenAndAssignTicket @CustomerID = 10, @CategoryID =  2, @IssueDescription = 'My account balance is lower than my coffee budget', @Priority = 'Low';
EXEC OpenAndAssignTicket @CustomerID = 4, @CategoryID = 4, @IssueDescription = 'A ninja stole my card and left a note', @Priority = 'High';
EXEC OpenAndAssignTicket @CustomerID = 6, @CategoryID =  3, @IssueDescription = 'I locked myself out of my account by trying to guess my password too many times', @Priority = 'Urgent';
EXEC OpenAndAssignTicket @CustomerID = 8, @CategoryID =  3, @IssueDescription = 'My bank account was swapped with my dog’s', @Priority = 'Medium';
EXEC OpenAndAssignTicket @CustomerID = 11, @CategoryID = 2, @IssueDescription = 'I tried to buy a house with monopoly money', @Priority = 'High';
EXEC OpenAndAssignTicket @CustomerID = 14, @CategoryID = 3, @IssueDescription = 'Gondor calls for aid.', @Priority = 'Urgent'



EXEC CloseAndResolveTicket 
    @TicketID = 4, 
    @ResolutionDescription = 'Bank account rescued from well using high-tech tools.', 
    @RespondedByEmployeeID = 5, 
    @ResponseText = 'Your bank account is safe and sound after a successful rescue operation!';

EXEC CloseAndResolveTicket 
    @TicketID = 5, 
    @ResolutionDescription = 'Debut card transaction reversed. Cat will be blocked from future purchases.', 
    @RespondedByEmployeeID = 4, 
    @ResponseText = 'Your debit card is now protected from further feline interference!';

EXEC CloseAndResolveTicket 
    @TicketID = 6, 
    @ResolutionDescription = 'Ghosts have been banished from the account using state-of-the-art exorcism techniques.', 
    @RespondedByEmployeeID = 4, 
    @ResponseText = 'Your account is now ghost-free. No more spooky charges!';

EXEC CloseAndResolveTicket 
    @TicketID = 7, 
    @ResolutionDescription = 'Savings account autopilot deactivated and restored to manual control.', 
    @RespondedByEmployeeID = 4, 
    @ResponseText = 'Your savings are now back under your control, no autopilot shenanigans anymore!';

EXEC CloseAndResolveTicket 
    @TicketID = 8, 
    @ResolutionDescription = 'Squirrel invasion thwarted with expert account security measures.', 
    @RespondedByEmployeeID = 5, 
    @ResponseText = 'Your account is now secured from further squirrel hijacks!';

EXEC CloseAndResolveTicket 
    @TicketID = 9, 
    @ResolutionDescription = 'Account singing capabilities enhanced with the latest audio features.', 
    @RespondedByEmployeeID = 5, 
    @ResponseText = 'Your account now has the ability to hum a tune. Enjoy the musical features!';

EXEC CloseAndResolveTicket 
    @TicketID = 10, 
    @ResolutionDescription = 'Balance adjusted to meet your coffee budget after reviewing transactions.', 
    @RespondedByEmployeeID = 4, 
    @ResponseText = 'Your balance has been fixed to ensure you can afford your next coffee!';

EXEC CloseAndResolveTicket 
    @TicketID = 11, 
    @ResolutionDescription= 'Ninja card thief was caught, and account secured with extra encryption.', 
    @RespondedByEmployeeID = 5, 
    @ResponseText = 'Your card is now safe, and the ninja threat has been neutralized!';

EXEC CloseAndResolveTicket 
    @TicketID = 12, 
    @ResolutionDescription = 'Account unlocked with enhanced password recovery protocols.', 
    @RespondedByEmployeeID = 4, 
    @ResponseText = 'Your account is now accessible again. Password attempts will be monitored for security!';

EXEC CloseAndResolveTicket 
    @TicketID = 13, 
    @ResolutionDescription = 'Account swapped back with the dog’s, dog given treats for being a good boy.', 
    @RespondedByEmployeeID = 4, 
    @ResponseText = 'Your bank account is now properly matched to your human identity!';

EXEC CloseAndResolveTicket 
    @TicketID = 14, 
    @ResolutionDescription = 'Monopoly money transaction reversed and real funds allocated.', 
    @RespondedByEmployeeID = 4, 
    @ResponseText = 'The house purchase has been canceled, but your account is now solid with real money!';

EXEC CloseAndResolveTicket
	@TicketID = 15,
	@ResolutionDescription = 'The Rohirrim have been sent out.',
	@RespondedByEmployeeID = 6,
	@ResponseText = 'And Rohan will answer!'


EXEC ProcessInsurancepayout @ClaimID = 6
EXEC ProcessInsurancepayout @ClaimID = 7
EXEC ProcessInsurancepayout @ClaimID = 2
EXEC ProcessInsurancepayout @ClaimID = 1

EXEC TakeLoan @CustomerID = 4, @LoanTypeID = 1, @InterestTypeID = 2, @LoanAmount = 40000, @LoanStartDate = '2025-03-12', @LoanEndDate = '2027-06-18'
EXEC TakeLoan @CustomerID = 11, @LoanTypeID = 4, @InterestTypeID = 3, @LoanAmount = 180000, @LoanStartDate = '2025-03-12', @LoanEndDate = '2028-03-12'
EXEC TakeLoan @CustomerID = 9, @LoanTypeID = 3, @InterestTypeID = 4, @LoanAmount = 55000, @LoanStartDate = '2025-03-12', @LoanEndDate = '2026-03-12'
EXEC TakeLoan @CustomerID = 14, @LoanTypeID = 1, @InterestTypeID = 1, @LoanAmount = 950000, @LoanStartDate = '2025-03-12', @LoanEndDate = '2030-03-12'
EXEC TakeLoan @CustomerID = 6, @LoanTypeID = 3, @InterestTypeID = 2, @LoanAmount = 120000, @LoanStartDate = '2025-03-12', @LoanEndDate = '2027-08-19'
EXEC TakeLoan @CustomerID = 12, @LoanTypeID = 4, @InterestTypeID = 4, @LoanAmount = 15000, @LoanStartDate = '2025-03-12', @LoanEndDate = '2026-01-14'

EXEC WithdrawMoney @AccountID = 3, @CardID = 3, @Amount = 400
EXEC WithdrawMoney @AccountID = 2, @CardID = 2, @Amount = 250;
EXEC WithdrawMoney @AccountID = 7, @CardID = 7, @Amount = 600;
EXEC WithdrawMoney @AccountID = 12, @CardID = 11, @Amount = 150;
EXEC WithdrawMoney @AccountID = 5, @CardID = 5, @Amount = 800;
EXEC WithdrawMoney @AccountID = 9,  @CardID = 9, @Amount = 400;
EXEC WithdrawMoney @AccountID = 3,  @CardID = 3, @Amount = 950;
EXEC WithdrawMoney @AccountID = 14,  @CardID = 15, @Amount = 100;
EXEC WithdrawMoney @AccountID = 14, @CardID = 15, @Amount = 290;
EXEC WithdrawMoney @AccountID = 15, @CardID = 16, @Amount = 680;
EXEC WithdrawMoney @AccountID = 16, @CardID = 17, @Amount = 980;
EXEC WithdrawMoney @AccountID = 17, @CardID = 18, @Amount = 1950;
EXEC WithdrawMoney @AccountID = 18, @CardID = 19, @Amount = 300;
EXEC WithdrawMoney @AccountID = 19, @CardID = 20, @Amount = 745;
EXEC WithdrawMoney @AccountID = 20, @CardID = 21, @Amount = 2000;
EXEC WithdrawMoney @AccountID = 21, @CardID = 22, @Amount = 350;
EXEC WithdrawMoney @AccountID = 22, @CardID = 23, @Amount = 890;
EXEC WithdrawMoney @AccountID = 23, @CardID = 24, @Amount = 1500;
EXEC WithdrawMoney @AccountID = 24, @CardID = 25, @Amount = 260;
EXEC WithdrawMoney @AccountID = 25, @CardID = 26, @Amount = 1150;
EXEC WithdrawMoney @AccountID = 26, @CardID = 27, @Amount = 620;
EXEC WithdrawMoney @AccountID = 27, @CardID = 28, @Amount = 1400;
EXEC WithdrawMoney @AccountID = 28, @CardID = 29, @Amount = 375;
EXEC WithdrawMoney @AccountID = 29, @CardID = 30, @Amount = 2950;
EXEC WithdrawMoney @AccountID = 30, @CardID = 31, @Amount = 910;
EXEC WithdrawMoney @AccountID = 31, @CardID = 32, @Amount = 2700;
EXEC WithdrawMoney @AccountID = 32, @CardID = 33, @Amount = 180;
EXEC WithdrawMoney @AccountID = 33, @CardID = 34, @Amount = 1330;
EXEC WithdrawMoney @AccountID = 34, @CardID = 35, @Amount = 400;
EXEC WithdrawMoney @AccountID = 35, @CardID = 36, @Amount = 2500;

EXEC DepositMoney @AccountID = 4, @Amount = 100
EXEC DepositMoney @AccountID = 1, @Amount = 500;
EXEC DepositMoney @AccountID = 6, @Amount = 300;
EXEC DepositMoney @AccountID = 12, @Amount = 750;
EXEC DepositMoney @AccountID = 8, @Amount = 200;
EXEC DepositMoney @AccountID = 15, @Amount = 900;
EXEC DepositMoney @AccountID = 3, @Amount = 450;
EXEC DepositMoney @AccountID = 10, @Amount = 600;
EXEC DepositMoney @AccountID = 5, @Amount = 1000;
EXEC DepositMoney @AccountID = 14, @Amount = 150;
EXEC DepositMoney @AccountID = 9, @Amount = 800;
EXEC DepositMoney @AccountID = 3, @Amount = 450;
EXEC DepositMoney @AccountID = 8, @Amount = 1200;
EXEC DepositMoney @AccountID = 15, @Amount = 3200;
EXEC DepositMoney @AccountID = 21, @Amount = 980;
EXEC DepositMoney @AccountID = 5, @Amount = 250;
EXEC DepositMoney @AccountID = 18, @Amount = 1900;
EXEC DepositMoney @AccountID = 7, @Amount = 3750;
EXEC DepositMoney @AccountID = 12, @Amount = 410;
EXEC DepositMoney @AccountID = 34, @Amount = 2900;
EXEC DepositMoney @AccountID = 27, @Amount = 1100;
EXEC DepositMoney @AccountID = 11, @Amount = 750;
EXEC DepositMoney @AccountID = 25, @Amount = 500;
EXEC DepositMoney @AccountID = 36, @Amount = 1850;
EXEC DepositMoney @AccountID = 19, @Amount = 2900;
EXEC DepositMoney @AccountID = 9, @Amount = 4500;
EXEC DepositMoney @AccountID = 23, @Amount = 305;
EXEC DepositMoney @AccountID = 31, @Amount = 4950;
EXEC DepositMoney @AccountID = 16, @Amount = 2650;
EXEC DepositMoney @AccountID = 14, @Amount = 740;
EXEC DepositMoney @AccountID = 30, @Amount = 900;
EXEC DepositMoney @AccountID = 6, @Amount = 2150;
EXEC DepositMoney @AccountID = 13, @Amount = 380;
EXEC DepositMoney @AccountID = 22, @Amount = 1600;
EXEC DepositMoney @AccountID = 26, @Amount = 1250;
EXEC DepositMoney @AccountID = 35, @Amount = 490;
EXEC DepositMoney @AccountID = 10, @Amount = 2600;
EXEC DepositMoney @AccountID = 24, @Amount = 800;
EXEC DepositMoney @AccountID = 1, @Amount = 3200;
EXEC DepositMoney @AccountID = 28, @Amount = 950;
EXEC DepositMoney @AccountID = 20, @Amount = 1300;
EXEC DepositMoney @AccountID = 4, @Amount = 370;
EXEC DepositMoney @AccountID = 2, @Amount = 2800;
EXEC DepositMoney @AccountID = 17, @Amount = 4100;
EXEC DepositMoney @AccountID = 32, @Amount = 390;
EXEC DepositMoney @AccountID = 29, @Amount = 4500;
EXEC DepositMoney @AccountID = 33, @Amount = 1025;
EXEC DepositMoney @AccountID = 5, @Amount = 2750;
EXEC DepositMoney @AccountID = 9, @Amount = 300;
EXEC DepositMoney @AccountID = 11, @Amount = 2500;


EXEC TransferMoney @FromAccountID = 4, @ToAccountID = 5, @Amount = 300
EXEC TransferMoney @FromAccountID = 1, @ToAccountID = 6, @Amount = 250;
EXEC TransferMoney @FromAccountID = 12, @ToAccountID = 8, @Amount = 500;
EXEC TransferMoney @FromAccountID = 3, @ToAccountID = 15, @Amount = 700;
EXEC TransferMoney @FromAccountID = 10, @ToAccountID = 2, @Amount = 400;
EXEC TransferMoney @FromAccountID = 7, @ToAccountID = 9, @Amount = 600;
EXEC TransferMoney @FromAccountID = 14, @ToAccountID = 5, @Amount = 350;
EXEC TransferMoney @FromAccountID = 11, @ToAccountID = 10, @Amount = 900;
EXEC TransferMoney @FromAccountID = 13, @ToAccountID = 4, @Amount = 150;
EXEC TransferMoney @FromAccountID = 2, @ToAccountID = 7, @Amount = 800;
EXEC TransferMoney @FromAccountID = 5, @ToAccountID = 3, @Amount = 1000;
EXEC TransferMoney @FromAccountID = 3, @ToAccountID = 8, @Amount = 450;
EXEC TransferMoney @FromAccountID = 15, @ToAccountID = 21, @Amount = 1200;
EXEC TransferMoney @FromAccountID = 5, @ToAccountID = 12, @Amount = 3200;
EXEC TransferMoney @FromAccountID = 18, @ToAccountID = 7, @Amount = 980;
EXEC TransferMoney @FromAccountID = 34, @ToAccountID = 27, @Amount = 250;
EXEC TransferMoney @FromAccountID = 11, @ToAccountID = 25, @Amount = 1900;
EXEC TransferMoney @FromAccountID = 36, @ToAccountID = 19, @Amount = 3750;
EXEC TransferMoney @FromAccountID = 9, @ToAccountID = 23, @Amount = 410;
EXEC TransferMoney @FromAccountID = 31, @ToAccountID = 16, @Amount = 2900;
EXEC TransferMoney @FromAccountID = 14, @ToAccountID = 30, @Amount = 1100;
EXEC TransferMoney @FromAccountID = 6, @ToAccountID = 13, @Amount = 750;
EXEC TransferMoney @FromAccountID = 22, @ToAccountID = 26, @Amount = 500;
EXEC TransferMoney @FromAccountID = 35, @ToAccountID = 10, @Amount = 1850;
EXEC TransferMoney @FromAccountID = 24, @ToAccountID = 1, @Amount = 2900;
EXEC TransferMoney @FromAccountID = 28, @ToAccountID = 20, @Amount = 4500;
EXEC TransferMoney @FromAccountID = 4, @ToAccountID = 2, @Amount = 305;

EXEC ProcessLoanRepayment @LoanID = 1, @AccountID = 5
EXEC ProcessLoanRepayment @LoanID = 2, @AccountID = 12
EXEC ProcessLoanRepayment @LoanID = 4, @AccountID = 15
EXEC ProcessLoanRepayment @LoanID = 5, @AccountID = 7
EXEC ProcessLoanRepayment @LoanID = 1, @AccountID = 5
EXEC ProcessLoanRepayment @LoanID = 2, @AccountID = 12
EXEC ProcessLoanRepayment @LoanID = 4, @AccountID = 15
EXEC ProcessLoanRepayment @LoanID = 5, @AccountID = 7
EXEC ProcessLoanRepayment @LoanID = 1, @AccountID = 5
EXEC ProcessLoanRepayment @LoanID = 1, @AccountID = 5
EXEC ProcessLoanRepayment @LoanID = 1, @AccountID = 5
EXEC ProcessLoanRepayment @LoanID = 1, @AccountID = 5
EXEC ProcessLoanRepayment @LoanID = 1, @AccountID = 5
EXEC ProcessLoanRepayment @LoanID = 1, @AccountID = 5

-------------------------TESTINGLAND--------------------------------------------------------

SELECT * FROM LoanRepayment

SELECT * FROM Loan