/*
BANKING & HFC SQL PRACTICE PROJECT
Dialect: Microsoft SQL Server (T-SQL)
Contains: 10 tables, sample data, and 75 practice questions with solutions.

Run this script in a practice database. It drops/recreates only the 10 tables
listed below. Do not run in a production database.
*/

-- Optional: CREATE DATABASE BankingHFCPractice;
-- GO
-- USE BankingHFCPractice;
-- GO

SET NOCOUNT ON;

-- Drop in dependency order
DROP TABLE IF EXISTS dbo.CreditScores;
DROP TABLE IF EXISTS dbo.Collateral;
DROP TABLE IF EXISTS dbo.LoanPayments;
DROP TABLE IF EXISTS dbo.Loans;
DROP TABLE IF EXISTS dbo.LoanProducts;
DROP TABLE IF EXISTS dbo.Transactions;
DROP TABLE IF EXISTS dbo.Accounts;
DROP TABLE IF EXISTS dbo.Customers;
DROP TABLE IF EXISTS dbo.Employees;
DROP TABLE IF EXISTS dbo.Branches;

CREATE TABLE dbo.Branches (
    BranchID INT PRIMARY KEY,
    BranchName VARCHAR(80) NOT NULL,
    City VARCHAR(60) NOT NULL,
    StateName VARCHAR(60) NOT NULL,
    Region VARCHAR(20) NOT NULL
);

CREATE TABLE dbo.Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(80) NOT NULL,
    BranchID INT NOT NULL REFERENCES dbo.Branches(BranchID),
    ManagerID INT NULL REFERENCES dbo.Employees(EmployeeID),
    JobTitle VARCHAR(50) NOT NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(12,2) NOT NULL
);

CREATE TABLE dbo.Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    City VARCHAR(60) NOT NULL,
    CustomerSegment VARCHAR(20) NOT NULL,
    JoinDate DATE NOT NULL,
    DateOfBirth DATE NOT NULL,
    RiskCategory VARCHAR(20) NOT NULL
);

CREATE TABLE dbo.Accounts (
    AccountID INT PRIMARY KEY,
    CustomerID INT NOT NULL REFERENCES dbo.Customers(CustomerID),
    BranchID INT NOT NULL REFERENCES dbo.Branches(BranchID),
    AccountType VARCHAR(20) NOT NULL,
    OpenDate DATE NOT NULL,
    Balance DECIMAL(14,2) NOT NULL,
    AccountStatus VARCHAR(20) NOT NULL
);

CREATE TABLE dbo.Transactions (
    TransactionID INT PRIMARY KEY,
    AccountID INT NOT NULL REFERENCES dbo.Accounts(AccountID),
    TransactionDate DATE NOT NULL,
    TransactionType VARCHAR(20) NOT NULL,
    Amount DECIMAL(14,2) NOT NULL,
    Channel VARCHAR(20) NOT NULL,
    TransactionStatus VARCHAR(20) NOT NULL
);

CREATE TABLE dbo.LoanProducts (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(80) NOT NULL,
    ProductType VARCHAR(30) NOT NULL,
    BaseInterestRate DECIMAL(5,2) NOT NULL,
    MaxTenureMonths INT NOT NULL
);

CREATE TABLE dbo.Loans (
    LoanID INT PRIMARY KEY,
    CustomerID INT NOT NULL REFERENCES dbo.Customers(CustomerID),
    ProductID INT NOT NULL REFERENCES dbo.LoanProducts(ProductID),
    BranchID INT NOT NULL REFERENCES dbo.Branches(BranchID),
    LoanOfficerID INT NOT NULL REFERENCES dbo.Employees(EmployeeID),
    ApplicationDate DATE NOT NULL,
    ApprovalDate DATE NULL,
    DisbursementDate DATE NULL,
    PrincipalAmount DECIMAL(14,2) NOT NULL,
    InterestRate DECIMAL(5,2) NOT NULL,
    TenureMonths INT NOT NULL,
    LoanStatus VARCHAR(20) NOT NULL
);

CREATE TABLE dbo.LoanPayments (
    PaymentID INT PRIMARY KEY,
    LoanID INT NOT NULL REFERENCES dbo.Loans(LoanID),
    DueDate DATE NOT NULL,
    PaymentDate DATE NULL,
    PrincipalPaid DECIMAL(12,2) NOT NULL,
    InterestPaid DECIMAL(12,2) NOT NULL,
    LateFee DECIMAL(10,2) NOT NULL,
    PaymentStatus VARCHAR(20) NOT NULL
);

CREATE TABLE dbo.Collateral (
    CollateralID INT PRIMARY KEY,
    LoanID INT NOT NULL REFERENCES dbo.Loans(LoanID),
    CollateralType VARCHAR(30) NOT NULL,
    PropertyCity VARCHAR(60) NULL,
    EstimatedValue DECIMAL(14,2) NOT NULL,
    ValuationDate DATE NOT NULL
);

CREATE TABLE dbo.CreditScores (
    CreditScoreID INT PRIMARY KEY,
    CustomerID INT NOT NULL REFERENCES dbo.Customers(CustomerID),
    ScoreDate DATE NOT NULL,
    CreditScore INT NOT NULL,
    Bureau VARCHAR(30) NOT NULL
);

-- 1. Branches
INSERT INTO dbo.Branches VALUES
(1,'Mumbai Central','Mumbai','Maharashtra','West'),
(2,'Pune Camp','Pune','Maharashtra','West'),
(3,'Bengaluru Tech Park','Bengaluru','Karnataka','South'),
(4,'Delhi Connaught','New Delhi','Delhi','North'),
(5,'Hyderabad Hitech','Hyderabad','Telangana','South'),
(6,'Ahmedabad West','Ahmedabad','Gujarat','West'),
(7,'Chennai T Nagar','Chennai','Tamil Nadu','South'),
(8,'Kolkata Salt Lake','Kolkata','West Bengal','East'),
(9,'Jaipur Civil Lines','Jaipur','Rajasthan','North'),
(10,'Lucknow Gomti Nagar','Lucknow','Uttar Pradesh','North'),
(11,'Kochi Marine Drive','Kochi','Kerala','South'),
(12,'Indore Vijay Nagar','Indore','Madhya Pradesh','Central');

-- 2. Employees. Top-level managers are inserted first.
INSERT INTO dbo.Employees VALUES
(1,'Aarav Mehta',1,NULL,'Regional Manager','2016-04-11',145000),
(2,'Diya Shah',2,1,'Branch Manager','2018-06-18',105000),
(3,'Kabir Rao',3,1,'Branch Manager','2017-02-20',112000),
(4,'Isha Verma',4,1,'Branch Manager','2019-09-02',98000),
(5,'Rohan Iyer',5,3,'Branch Manager','2020-01-13',96000),
(6,'Anaya Patel',6,2,'Loan Officer','2021-03-08',72000),
(7,'Vivaan Nair',1,1,'Loan Officer','2022-07-14',68000),
(8,'Sara Khan',2,2,'Loan Officer','2020-11-09',75000),
(9,'Arjun Das',3,3,'Loan Officer','2023-01-16',64000),
(10,'Mira Joshi',4,4,'Loan Officer','2022-05-23',66000),
(11,'Neil Thomas',5,5,'Loan Officer','2021-08-30',70000),
(12,'Tara Singh',6,2,'Customer Service','2024-02-05',48000),
(13,'Vikram Krishnan',7,3,'Branch Manager','2020-05-11',99000),
(14,'Pooja Banerjee',8,1,'Branch Manager','2021-07-19',97000),
(15,'Samar Rathore',9,4,'Branch Manager','2019-03-25',94000),
(16,'Ayesha Khan',10,4,'Branch Manager','2022-10-03',92000),
(17,'Kiran Subramanian',7,13,'Loan Officer','2022-06-06',69000),
(18,'Ritu Ghosh',8,14,'Loan Officer','2023-02-13',65000),
(19,'Harsh Vardhan',9,15,'Loan Officer','2021-12-01',71000),
(20,'Fatima Rizvi',10,16,'Loan Officer','2024-01-08',62000),
(21,'Om Prakash',1,1,'Credit Analyst','2020-08-17',81000),
(22,'Leena Dsouza',3,3,'Risk Analyst','2022-04-04',79000),
(23,'Joseph Mathew',11,3,'Branch Manager','2020-08-10',101000),
(24,'Shreya Kulkarni',12,1,'Branch Manager','2021-04-12',99000),
(25,'Akash Menon',11,23,'Loan Officer','2022-09-19',70000),
(26,'Nandini Rao',12,24,'Loan Officer','2023-03-06',67500),
(27,'Rahul Chawla',1,1,'Senior Credit Analyst','2019-11-04',88000),
(28,'Madhuri Sen',4,4,'Collections Officer','2022-02-14',63000);

-- 3. Customers
INSERT INTO dbo.Customers VALUES
(101,'Aditi Sharma','Mumbai','Retail','2020-01-15','1988-05-12','Low'),
(102,'Rahul Gupta','Pune','Retail','2021-03-22','1992-11-03','Medium'),
(103,'Priya Nair','Bengaluru','Premium','2019-07-10','1985-02-19','Low'),
(104,'Karan Malhotra','New Delhi','Retail','2022-02-01','1990-08-25','High'),
(105,'Sneha Reddy','Hyderabad','Premium','2018-12-12','1982-04-07','Low'),
(106,'Aditya Patel','Ahmedabad','SME','2020-09-09','1979-12-16','Medium'),
(107,'Meera Iyer','Mumbai','Premium','2023-04-18','1995-06-29','Low'),
(108,'Ishaan Kapoor','Pune','SME','2017-05-27','1976-10-10','High'),
(109,'Kavya Rao','Bengaluru','Retail','2024-01-04','1998-03-14','Medium'),
(110,'Dev Khanna','New Delhi','Premium','2021-11-20','1987-07-22','Medium'),
(111,'Nisha Menon','Hyderabad','Retail','2022-08-08','1991-09-01','Low'),
(112,'Yash Desai','Ahmedabad','SME','2019-10-30','1980-01-30','High'),
(113,'Zoya Ali','Mumbai','Retail','2024-06-05','2000-12-11','Medium'),
(114,'Manav Sethi','Pune','Retail','2020-04-25','1989-03-03','Low'),
(115,'Riya Bose','Bengaluru','Premium','2023-09-14','1993-08-08','Low'),
(116,'Ankit Verma','Chennai','Retail','2022-04-12','1990-02-15','Medium'),
(117,'Sonal Mukherjee','Kolkata','Premium','2019-08-21','1986-07-09','Low'),
(118,'Pranav Joshi','Jaipur','SME','2020-12-03','1981-11-22','High'),
(119,'Simran Kaur','Lucknow','Retail','2023-05-16','1996-01-17','Medium'),
(120,'Nitin Kumar','Chennai','Premium','2018-09-07','1984-06-26','Low'),
(121,'Pallavi Roy','Kolkata','Retail','2024-02-14','1999-10-02','Low'),
(122,'Rakesh Jain','Jaipur','SME','2017-11-29','1978-04-19','High'),
(123,'Tanya Mishra','Lucknow','Retail','2021-06-08','1992-12-30','Medium'),
(124,'Mohit Bansal','Mumbai','SME','2020-03-19','1983-05-05','High'),
(125,'Esha Fernandes','Bengaluru','Premium','2024-04-02','1997-09-13','Low'),
(126,'Gaurav Sinha','New Delhi','Retail','2022-12-10','1989-08-08','Medium'),
(127,'Ira Chatterjee','Kolkata','Premium','2023-01-27','1994-03-21','Low'),
(128,'Deepak Yadav','Lucknow','SME','2019-05-05','1977-02-02','High'),
(129,'Neha Pillai','Hyderabad','Retail','2024-05-20','2001-07-18','Medium'),
(130,'Arnav Kapoor','Pune','Premium','2022-07-15','1991-11-11','Low'),
(131,'Sanjay Pillai','Kochi','Retail','2021-02-18','1988-09-12','Low'),
(132,'Lavanya Nair','Indore','Premium','2019-06-23','1985-01-20','Low'),
(133,'Chirag Shah','Mumbai','SME','2020-10-05','1980-06-17','High'),
(134,'Anjali Sood','New Delhi','Retail','2022-07-11','1994-04-28','Medium'),
(135,'Farhan Sheikh','Kochi','SME','2018-03-09','1979-12-02','Medium'),
(136,'Bhavna Tiwari','Indore','Retail','2023-10-16','1997-08-14','Low'),
(137,'Kunal Arora','Pune','Premium','2020-01-29','1986-05-31','Medium'),
(138,'Divya Krishnan','Bengaluru','Retail','2024-02-08','1999-11-07','Low'),
(139,'Sameer Qureshi','Hyderabad','SME','2017-12-19','1976-03-25','High'),
(140,'Priti Agarwal','Kolkata','Premium','2021-09-03','1990-07-16','Low'),
(141,'Naveen Reddy','Chennai','Retail','2022-11-22','1993-02-10','Medium'),
(142,'Mansi Jain','Jaipur','SME','2019-04-17','1982-10-04','High'),
(143,'Aman Gill','Lucknow','Retail','2024-01-19','2000-06-06','Medium'),
(144,'Rekha Thomas','Kochi','Premium','2018-07-30','1984-12-24','Low'),
(145,'Siddharth Bose','Indore','SME','2020-05-14','1978-08-19','High');


-- 4. Accounts: some customers have multiple accounts; some have none.
INSERT INTO dbo.Accounts VALUES
(1001,101,1,'Savings','2020-01-15',125000,'Active'),
(1002,101,1,'Current','2021-06-01',350000,'Active'),
(1003,102,2,'Savings','2021-03-22',78000,'Active'),
(1004,103,3,'Savings','2019-07-10',510000,'Active'),
(1005,103,3,'Current','2020-02-02',240000,'Active'),
(1006,104,4,'Savings','2022-02-01',22000,'Active'),
(1007,105,5,'Savings','2018-12-12',670000,'Active'),
(1008,106,6,'Current','2020-09-09',430000,'Active'),
(1009,107,1,'Savings','2023-04-18',94000,'Active'),
(1010,108,2,'Current','2017-05-27',1250000,'Active'),
(1011,109,3,'Savings','2024-01-04',15000,'Active'),
(1012,110,4,'Savings','2021-11-20',305000,'Active'),
(1013,111,5,'Savings','2022-08-08',56000,'Active'),
(1014,112,6,'Current','2019-10-30',720000,'Active'),
(1015,114,2,'Savings','2020-04-25',112000,'Dormant'),
(1016,101,1,'Savings','2024-01-10',25000,'Active'),
(1017,115,3,'Savings','2023-09-14',180000,'Active'),
(1018,116,7,'Savings','2022-04-12',86000,'Active'),
(1019,117,8,'Savings','2019-08-21',420000,'Active'),
(1020,118,9,'Current','2020-12-03',680000,'Active'),
(1021,119,10,'Savings','2023-05-16',35000,'Active'),
(1022,120,7,'Current','2018-09-07',890000,'Active'),
(1023,121,8,'Savings','2024-02-14',12000,'Active'),
(1024,122,9,'Current','2017-11-29',1150000,'Active'),
(1025,123,10,'Savings','2021-06-08',97000,'Dormant'),
(1026,124,1,'Current','2020-03-19',510000,'Active'),
(1027,125,3,'Savings','2024-04-02',64000,'Active'),
(1028,126,4,'Savings','2022-12-10',143000,'Active'),
(1029,127,8,'Current','2023-01-27',275000,'Active'),
(1030,128,10,'Current','2019-05-05',735000,'Active'),
(1031,129,5,'Savings','2024-05-20',18000,'Active'),
(1032,130,2,'Savings','2022-07-15',205000,'Active'),
(1033,116,7,'Current','2023-08-01',125000,'Active'),
(1034,117,8,'Savings','2021-02-10',95000,'Closed'),
(1035,124,1,'Savings','2022-11-11',42000,'Active'),
(1036,131,11,'Savings','2021-02-18',132000,'Active'),
(1037,132,12,'Current','2019-06-23',560000,'Active'),
(1038,133,1,'Current','2020-10-05',840000,'Active'),
(1039,134,4,'Savings','2022-07-11',67000,'Active'),
(1040,135,11,'Current','2018-03-09',920000,'Active'),
(1041,136,12,'Savings','2023-10-16',28500,'Active'),
(1042,137,2,'Savings','2020-01-29',315000,'Active'),
(1043,138,3,'Savings','2024-02-08',19000,'Active'),
(1044,139,5,'Current','2017-12-19',1380000,'Active'),
(1045,140,8,'Savings','2021-09-03',475000,'Active'),
(1046,141,7,'Savings','2022-11-22',82000,'Active'),
(1047,142,9,'Current','2019-04-17',990000,'Active'),
(1048,143,10,'Savings','2024-01-19',14000,'Active'),
(1049,144,11,'Savings','2018-07-30',610000,'Active'),
(1050,145,12,'Current','2020-05-14',760000,'Active'),
(1051,131,11,'Current','2023-06-01',210000,'Active'),
(1052,133,1,'Savings','2022-08-08',65000,'Active'),
(1053,140,8,'Savings','2024-02-01',125000,'Dormant');

-- 5. Transactions
INSERT INTO dbo.Transactions VALUES
(1,1001,'2024-01-05','Deposit',25000,'Branch','Success'),
(2,1001,'2024-01-12','Withdrawal',5000,'ATM','Success'),
(3,1001,'2024-02-03','Transfer',12000,'Mobile','Success'),
(4,1002,'2024-02-15','Deposit',80000,'Branch','Success'),
(5,1002,'2024-03-01','Payment',22000,'Online','Success'),
(6,1003,'2024-01-20','Deposit',15000,'Mobile','Success'),
(7,1003,'2024-02-20','Withdrawal',3000,'ATM','Success'),
(8,1004,'2024-01-07','Deposit',100000,'Online','Success'),
(9,1004,'2024-02-17','Transfer',45000,'Mobile','Success'),
(10,1005,'2024-03-05','Deposit',60000,'Branch','Success'),
(11,1006,'2024-01-22','Withdrawal',2000,'ATM','Success'),
(12,1007,'2024-02-09','Deposit',120000,'Branch','Success'),
(13,1007,'2024-03-11','Payment',35000,'Online','Failed'),
(14,1008,'2024-01-19','Deposit',90000,'Branch','Success'),
(15,1008,'2024-03-21','Transfer',25000,'Mobile','Success'),
(16,1009,'2024-02-14','Deposit',18000,'Mobile','Success'),
(17,1010,'2024-01-31','Deposit',200000,'Branch','Success'),
(18,1010,'2024-02-28','Payment',75000,'Online','Success'),
(19,1011,'2024-03-12','Deposit',5000,'Mobile','Success'),
(20,1012,'2024-01-16','Transfer',30000,'Online','Pending'),
(21,1013,'2024-02-22','Deposit',12000,'Branch','Success'),
(22,1014,'2024-03-04','Deposit',150000,'Branch','Success'),
(23,1015,'2024-01-08','Withdrawal',4000,'ATM','Success'),
(24,1016,'2024-03-15','Deposit',10000,'Mobile','Success'),
(25,1017,'2024-03-20','Transfer',22000,'Online','Success'),
(26,1001,'2024-03-25','Deposit',25000,'Branch','Success'),
(27,1003,'2024-03-28','Payment',8000,'Online','Failed'),
(28,1004,'2024-03-29','Withdrawal',10000,'ATM','Success'),
(29,1007,'2024-03-30','Transfer',45000,'Mobile','Success'),
(30,1010,'2024-03-31','Deposit',30000,'Branch','Success'),
(31,1018,'2024-01-05','Deposit',22000,'Mobile','Success'),
(32,1018,'2024-02-05','Withdrawal',4000,'ATM','Success'),
(33,1018,'2024-03-05','Payment',6500,'Online','Success'),
(34,1019,'2024-01-10','Deposit',95000,'Branch','Success'),
(35,1019,'2024-02-10','Transfer',25000,'Mobile','Success'),
(36,1020,'2024-01-12','Deposit',120000,'Branch','Success'),
(37,1020,'2024-02-12','Payment',45000,'Online','Failed'),
(38,1021,'2024-01-15','Deposit',9000,'Mobile','Success'),
(39,1021,'2024-02-15','Withdrawal',2000,'ATM','Success'),
(40,1022,'2024-01-18','Deposit',150000,'Branch','Success'),
(41,1022,'2024-02-18','Transfer',50000,'Online','Success'),
(42,1023,'2024-01-21','Deposit',6000,'Mobile','Success'),
(43,1024,'2024-01-24','Deposit',200000,'Branch','Success'),
(44,1024,'2024-02-24','Payment',65000,'Online','Success'),
(45,1025,'2024-01-27','Withdrawal',5000,'ATM','Success'),
(46,1026,'2024-02-02','Deposit',110000,'Branch','Success'),
(47,1026,'2024-03-02','Transfer',30000,'Mobile','Pending'),
(48,1027,'2024-02-06','Deposit',17000,'Mobile','Success'),
(49,1028,'2024-02-09','Deposit',45000,'Branch','Success'),
(50,1029,'2024-02-12','Transfer',35000,'Online','Success'),
(51,1030,'2024-02-15','Deposit',175000,'Branch','Success'),
(52,1030,'2024-03-15','Payment',55000,'Online','Success'),
(53,1031,'2024-02-18','Deposit',8000,'Mobile','Success'),
(54,1032,'2024-02-21','Deposit',50000,'Branch','Success'),
(55,1033,'2024-03-01','Deposit',30000,'Branch','Success'),
(56,1033,'2024-03-01','Deposit',30000,'Branch','Success'),
(57,1034,'2024-03-04','Withdrawal',12000,'ATM','Success'),
(58,1035,'2024-03-07','Payment',7000,'Online','Failed'),
(59,1019,'2024-03-10','Deposit',25000,'Mobile','Success'),
(60,1024,'2024-03-13','Transfer',40000,'Online','Success'),
(61,1036,'2024-01-03','Deposit',30000,'Mobile','Success'),
(62,1036,'2024-02-03','Withdrawal',7000,'ATM','Success'),
(63,1036,'2024-03-03','Payment',9000,'Online','Success'),
(64,1037,'2024-01-06','Deposit',80000,'Branch','Success'),
(65,1037,'2024-02-06','Transfer',35000,'Mobile','Success'),
(66,1038,'2024-01-09','Deposit',140000,'Branch','Success'),
(67,1038,'2024-02-09','Payment',48000,'Online','Failed'),
(68,1039,'2024-01-12','Deposit',15000,'Mobile','Success'),
(69,1040,'2024-01-15','Deposit',160000,'Branch','Success'),
(70,1040,'2024-02-15','Transfer',45000,'Online','Success'),
(71,1041,'2024-01-18','Deposit',8000,'Mobile','Success'),
(72,1042,'2024-01-21','Deposit',55000,'Branch','Success'),
(73,1042,'2024-02-21','Payment',12000,'Online','Success'),
(74,1043,'2024-01-24','Deposit',10000,'Mobile','Success'),
(75,1044,'2024-01-27','Deposit',220000,'Branch','Success'),
(76,1044,'2024-02-27','Transfer',60000,'Mobile','Pending'),
(77,1045,'2024-02-02','Deposit',75000,'Branch','Success'),
(78,1046,'2024-02-05','Deposit',18000,'Mobile','Success'),
(79,1047,'2024-02-08','Deposit',175000,'Branch','Success'),
(80,1047,'2024-03-08','Payment',42000,'Online','Success'),
(81,1048,'2024-02-11','Deposit',6000,'Mobile','Success'),
(82,1049,'2024-02-14','Deposit',95000,'Branch','Success'),
(83,1050,'2024-02-17','Transfer',40000,'Online','Success'),
(84,1050,'2024-03-17','Payment',40000,'Online','Success'),
(85,1051,'2024-03-01','Deposit',25000,'Branch','Success'),
(86,1051,'2024-03-01','Deposit',25000,'Branch','Success'),
(87,1052,'2024-03-04','Withdrawal',8000,'ATM','Success'),
(88,1053,'2024-03-07','Payment',11000,'Online','Failed'),
(89,1037,'2024-03-10','Deposit',35000,'Mobile','Success'),
(90,1044,'2024-03-13','Transfer',60000,'Online','Success');

-- 6. Loan products
INSERT INTO dbo.LoanProducts VALUES
(1,'Home Loan Standard','Home Loan',8.40,360),
(2,'Affordable Housing Loan','Home Loan',7.90,300),
(3,'Personal Loan Flexi','Personal Loan',13.50,60),
(4,'Loan Against Property','Property Loan',10.25,180),
(5,'SME Business Loan','Business Loan',11.75,120),
(6,'Senior Citizen Home Loan','Home Loan',8.10,300),
(7,'Education Loan Plus','Education Loan',9.25,120),
(8,'Gold Loan Quick','Gold Loan',10.75,36),
(9,'Home Loan Balance Transfer','Home Loan',8.15,300),
(10,'Rental Property Loan','Property Loan',10.50,240);


-- 7. Loans
INSERT INTO dbo.Loans VALUES
(2001,101,1,1,7,'2022-01-10','2022-01-18','2022-01-25',4500000,8.25,240,'Active'),
(2002,102,2,2,8,'2022-05-14','2022-05-20','2022-06-01',2200000,7.75,240,'Active'),
(2003,103,1,3,9,'2021-02-01','2021-02-10','2021-02-20',6800000,8.10,300,'Active'),
(2004,104,3,4,10,'2023-03-05','2023-03-15','2023-03-20',450000,14.00,48,'Active'),
(2005,105,1,5,11,'2020-08-17','2020-08-25','2020-09-01',5200000,8.00,240,'Active'),
(2006,106,5,6,6,'2021-06-11','2021-06-25','2021-07-05',1800000,11.50,84,'Active'),
(2007,107,2,1,7,'2023-06-01','2023-06-10','2023-06-15',2600000,7.85,240,'Active'),
(2008,108,4,2,8,'2020-04-03','2020-04-15','2020-04-25',3200000,10.00,120,'Closed'),
(2009,110,1,4,10,'2022-09-12','2022-09-25','2022-10-01',7500000,8.20,300,'Active'),
(2010,112,5,6,6,'2023-01-08','2023-01-20','2023-02-01',2400000,11.25,96,'Active'),
(2011,114,3,2,8,'2021-11-11','2021-11-20','2021-12-01',600000,13.25,48,'Closed'),
(2012,101,3,1,7,'2024-02-02',NULL,NULL,350000,13.75,36,'Pending'),
(2013,109,2,3,9,'2024-03-10','2024-03-18',NULL,1900000,7.80,240,'Approved'),
(2014,111,1,5,11,'2023-07-07','2023-07-17','2023-07-25',3100000,8.30,240,'Active'),
(2015,106,4,6,6,'2024-01-15',NULL,NULL,900000,10.50,120,'Rejected'),
(2016,116,1,7,17,'2022-05-01','2022-05-12','2022-05-20',2800000,8.35,240,'Active'),
(2017,117,2,8,18,'2021-09-05','2021-09-15','2021-09-25',3500000,7.80,240,'Active'),
(2018,118,5,9,19,'2021-01-10','2021-01-20','2021-02-01',2100000,11.60,96,'Active'),
(2019,119,3,10,20,'2023-06-01','2023-06-10','2023-06-18',500000,13.90,48,'Active'),
(2020,120,6,7,17,'2020-02-14','2020-02-22','2020-03-01',6200000,8.05,240,'Active'),
(2021,122,5,9,19,'2019-02-10','2019-02-22','2019-03-01',2600000,11.40,120,'Closed'),
(2022,123,3,10,20,'2022-07-10','2022-07-18','2022-07-25',500000,13.90,48,'Closed'),
(2023,124,4,1,7,'2021-04-01','2021-04-12','2021-04-20',4100000,10.10,180,'Active'),
(2024,125,1,3,9,'2024-04-10','2024-04-20','2024-05-01',3900000,8.20,240,'Active'),
(2025,126,2,4,10,'2023-01-15','2023-01-25','2023-02-01',2400000,7.85,240,'Active'),
(2026,127,7,8,18,'2023-02-05','2023-02-15','2023-02-25',850000,9.10,96,'Active'),
(2027,128,5,10,20,'2020-06-01','2020-06-15','2020-06-25',3100000,11.80,120,'Active'),
(2028,129,8,5,11,'2024-06-01',NULL,NULL,180000,10.90,24,'Pending'),
(2029,130,3,2,8,'2023-08-01','2023-08-12',NULL,700000,13.50,48,'Approved'),
(2030,121,1,8,18,'2024-03-01',NULL,NULL,2700000,9.50,240,'Rejected'),
(2031,131,1,11,25,'2021-04-01','2021-04-12','2021-04-20',3100000,8.30,240,'Active'),
(2032,132,2,12,26,'2020-07-05','2020-07-15','2020-07-25',4200000,7.85,240,'Active'),
(2033,133,5,1,7,'2021-01-11','2021-01-22','2021-02-01',2800000,11.70,120,'Active'),
(2034,134,3,4,10,'2023-08-01','2023-08-10','2023-08-20',450000,13.90,48,'Active'),
(2035,135,4,11,25,'2019-03-15','2019-03-25','2019-04-05',3600000,10.20,180,'Closed'),
(2036,137,1,2,8,'2021-03-10','2021-03-20','2021-04-01',4200000,8.30,240,'Active'),
(2037,139,5,5,11,'2018-01-10','2018-01-20','2018-02-01',3300000,11.60,120,'Active'),
(2038,140,9,8,18,'2022-01-14','2022-01-25','2022-02-05',4200000,8.15,300,'Active'),
(2039,142,5,9,19,'2020-05-01','2020-05-12','2020-05-20',2800000,11.70,120,'Active'),
(2040,144,6,11,25,'2019-08-08','2019-08-18','2019-08-28',5100000,8.05,240,'Active'),
(2041,145,10,12,26,'2021-06-03','2021-06-15','2021-06-25',2900000,10.60,180,'Active'),
(2042,131,3,11,25,'2024-03-01',NULL,NULL,550000,13.75,36,'Pending'),
(2043,133,4,1,7,'2024-01-15','2024-01-28','2024-02-05',2400000,10.30,180,'Active'),
(2044,138,2,3,9,'2024-02-10','2024-02-20',NULL,2100000,7.95,240,'Approved'),
(2045,143,1,10,20,'2024-02-18',NULL,NULL,2600000,11.00,240,'Rejected');

-- 8. Loan payments: deliberately includes paid, late, missed, and unpaid dues.
INSERT INTO dbo.LoanPayments VALUES
(3001,2001,'2024-01-05','2024-01-05',12000,28000,0,'Paid'),
(3002,2001,'2024-02-05','2024-02-07',12100,27900,500,'Late'),
(3003,2001,'2024-03-05','2024-03-05',12200,27800,0,'Paid'),
(3004,2002,'2024-01-10','2024-01-10',7000,15000,0,'Paid'),
(3005,2002,'2024-02-10',NULL,0,0,0,'Missed'),
(3006,2003,'2024-01-15','2024-01-16',18000,42000,500,'Late'),
(3007,2003,'2024-02-15','2024-02-15',18100,41900,0,'Paid'),
(3008,2004,'2024-01-20','2024-01-20',6500,5200,0,'Paid'),
(3009,2004,'2024-02-20',NULL,0,0,0,'Missed'),
(3010,2005,'2024-01-12','2024-01-12',15000,35000,0,'Paid'),
(3011,2005,'2024-02-12','2024-02-18',15100,34900,750,'Late'),
(3012,2006,'2024-01-25','2024-01-25',10000,17000,0,'Paid'),
(3013,2007,'2024-02-02','2024-02-02',8000,16000,0,'Paid'),
(3014,2008,'2024-01-08','2024-01-08',25000,27000,0,'Paid'),
(3015,2009,'2024-03-01',NULL,0,0,0,'Missed'),
(3016,2010,'2024-02-16','2024-02-18',9000,23000,500,'Late'),
(3017,2011,'2024-01-05','2024-01-05',11000,9000,0,'Paid'),
(3018,2014,'2024-03-12','2024-03-12',9000,25000,0,'Paid'),
(3019,2001,'2024-04-05',NULL,0,0,0,'Upcoming'),
(3020,2003,'2024-04-15',NULL,0,0,0,'Upcoming'),
(3021,2016,'2024-01-05','2024-01-05',8500,19500,0,'Paid'),
(3022,2016,'2024-02-05','2024-02-09',8600,19400,500,'Late'),
(3023,2016,'2024-03-05','2024-03-05',8700,19300,0,'Paid'),
(3024,2017,'2024-01-08','2024-01-08',10000,23000,0,'Paid'),
(3025,2017,'2024-02-08',NULL,0,0,0,'Missed'),
(3026,2018,'2024-01-12','2024-01-15',9000,22000,500,'Late'),
(3027,2018,'2024-02-12','2024-02-12',9100,21900,0,'Paid'),
(3028,2019,'2024-01-16','2024-01-16',7000,6000,0,'Paid'),
(3029,2019,'2024-02-16',NULL,0,0,0,'Missed'),
(3030,2020,'2024-01-20','2024-01-20',17000,39000,0,'Paid'),
(3031,2020,'2024-02-20','2024-02-25',17100,38900,750,'Late'),
(3032,2021,'2024-01-24','2024-01-24',18000,25000,0,'Paid'),
(3033,2023,'2024-02-01','2024-02-01',15000,31000,0,'Paid'),
(3034,2024,'2024-02-04','2024-02-04',11000,27000,0,'Paid'),
(3035,2025,'2024-02-08',NULL,0,0,0,'Missed'),
(3036,2026,'2024-02-12','2024-02-12',5000,8500,0,'Paid'),
(3037,2027,'2024-02-16','2024-02-19',12000,26000,500,'Late'),
(3038,2028,'2024-03-01',NULL,0,0,0,'Upcoming'),
(3039,2016,'2024-04-05',NULL,0,0,0,'Upcoming'),
(3040,2020,'2024-03-20','2024-03-20',17200,38800,0,'Paid'),
(3041,2031,'2024-01-05','2024-01-05',9500,24000,0,'Paid'),
(3042,2031,'2024-02-05','2024-02-08',9600,23900,500,'Late'),
(3043,2031,'2024-03-05','2024-03-05',9700,23800,0,'Paid'),
(3044,2032,'2024-01-08','2024-01-08',13000,28000,0,'Paid'),
(3045,2032,'2024-02-08',NULL,0,0,0,'Missed'),
(3046,2033,'2024-01-12','2024-01-15',11000,26000,500,'Late'),
(3047,2033,'2024-02-12','2024-02-12',11100,25900,0,'Paid'),
(3048,2034,'2024-01-16','2024-01-16',6500,5800,0,'Paid'),
(3049,2034,'2024-02-16',NULL,0,0,0,'Missed'),
(3050,2035,'2024-01-20','2024-01-20',20000,31000,0,'Paid'),
(3051,2036,'2024-01-24','2024-01-24',14000,32000,0,'Paid'),
(3052,2036,'2024-02-24','2024-03-02',14100,31900,750,'Late'),
(3053,2037,'2024-02-01','2024-02-01',16000,29000,0,'Paid'),
(3054,2038,'2024-02-04',NULL,0,0,0,'Missed'),
(3055,2039,'2024-02-08','2024-02-08',15000,28000,0,'Paid'),
(3056,2040,'2024-02-12','2024-02-12',18000,37000,0,'Paid'),
(3057,2041,'2024-02-16','2024-02-19',12000,27000,500,'Late'),
(3058,2042,'2024-03-01',NULL,0,0,0,'Upcoming'),
(3059,2031,'2024-04-05',NULL,0,0,0,'Upcoming'),
(3060,2036,'2024-03-24','2024-03-24',14200,31800,0,'Paid');


-- 9. Collateral
INSERT INTO dbo.Collateral VALUES
(4001,2001,'Residential Property','Mumbai',6500000,'2023-10-01'),
(4002,2002,'Residential Property','Pune',3200000,'2023-08-12'),
(4003,2003,'Residential Property','Bengaluru',9000000,'2023-11-20'),
(4004,2005,'Residential Property','Hyderabad',7200000,'2023-06-05'),
(4005,2006,'Commercial Property','Ahmedabad',2600000,'2023-12-15'),
(4006,2007,'Residential Property','Mumbai',3900000,'2024-01-10'),
(4007,2008,'Commercial Property','Pune',4700000,'2022-09-19'),
(4008,2009,'Residential Property','New Delhi',10500000,'2023-09-01'),
(4009,2010,'Commercial Property','Ahmedabad',3600000,'2024-01-04'),
(4010,2014,'Residential Property','Hyderabad',4600000,'2023-07-25'),
(4011,2016,'Residential Property','Chennai',3900000,'2023-08-01'),
(4012,2017,'Residential Property','Kolkata',4900000,'2023-09-10'),
(4013,2018,'Commercial Property','Jaipur',3200000,'2023-10-12'),
(4014,2020,'Residential Property','Chennai',8100000,'2023-07-21'),
(4015,2020,'Additional Property','Coimbatore',1500000,'2024-01-15'),
(4016,2021,'Commercial Property','Jaipur',3500000,'2022-05-17'),
(4017,2023,'Commercial Property','Mumbai',5600000,'2023-11-05'),
(4018,2024,'Residential Property','Bengaluru',5300000,'2024-04-25'),
(4019,2025,'Residential Property','New Delhi',3400000,'2023-12-01'),
(4020,2027,'Commercial Property','Lucknow',4200000,'2023-08-18'),
(4021,2031,'Residential Property','Kochi',4200000,'2023-08-01'),
(4022,2032,'Residential Property','Indore',5700000,'2023-09-10'),
(4023,2033,'Commercial Property','Mumbai',3900000,'2023-10-12'),
(4024,2035,'Commercial Property','Kochi',4800000,'2022-05-17'),
(4025,2036,'Residential Property','Pune',5900000,'2023-07-21'),
(4026,2036,'Additional Property','Satara',900000,'2024-01-15'),
(4027,2037,'Commercial Property','Hyderabad',4500000,'2023-11-05'),
(4028,2038,'Residential Property','Kolkata',6100000,'2024-01-25'),
(4029,2039,'Commercial Property','Jaipur',3700000,'2023-12-01'),
(4030,2040,'Residential Property','Kochi',6900000,'2023-08-18'),
(4031,2041,'Commercial Property','Indore',3900000,'2024-02-10');

-- 10. Credit scores
INSERT INTO dbo.CreditScores VALUES
(5001,101,'2022-01-01',720,'CIBIL'),
(5002,101,'2023-01-01',745,'CIBIL'),
(5003,101,'2024-01-01',758,'CIBIL'),
(5004,102,'2023-01-01',680,'Experian'),
(5005,102,'2024-01-01',695,'Experian'),
(5006,103,'2022-06-01',790,'CIBIL'),
(5007,103,'2024-02-01',805,'CIBIL'),
(5008,104,'2023-03-01',620,'CIBIL'),
(5009,104,'2024-03-01',635,'CIBIL'),
(5010,105,'2022-01-01',775,'Experian'),
(5011,105,'2024-01-01',788,'Experian'),
(5012,106,'2023-06-01',700,'CIBIL'),
(5013,106,'2024-02-01',690,'CIBIL'),
(5014,107,'2024-01-01',735,'CIBIL'),
(5015,108,'2022-01-01',610,'Experian'),
(5016,108,'2024-01-01',640,'Experian'),
(5017,109,'2024-03-01',710,'CIBIL'),
(5018,110,'2023-01-01',760,'CIBIL'),
(5019,110,'2024-01-01',752,'CIBIL'),
(5020,111,'2023-08-01',730,'Experian'),
(5021,112,'2023-01-01',650,'CIBIL'),
(5022,112,'2024-01-01',665,'CIBIL'),
(5023,114,'2022-01-01',705,'Experian'),
(5024,114,'2024-01-01',720,'Experian'),
(5025,115,'2024-02-01',780,'CIBIL'),
(5026,116,'2023-01-01',690,'CIBIL'),
(5027,116,'2024-01-01',710,'CIBIL'),
(5028,117,'2022-01-01',765,'Experian'),
(5029,117,'2024-01-01',780,'Experian'),
(5030,118,'2022-06-01',640,'CIBIL'),
(5031,118,'2024-02-01',655,'CIBIL'),
(5032,119,'2024-01-01',700,'CIBIL'),
(5033,120,'2021-01-01',790,'Experian'),
(5034,120,'2024-01-01',800,'Experian'),
(5035,121,'2024-03-01',725,'CIBIL'),
(5036,122,'2022-01-01',630,'CIBIL'),
(5037,122,'2024-01-01',645,'CIBIL'),
(5038,123,'2022-01-01',700,'Experian'),
(5039,123,'2024-01-01',700,'Experian'),
(5040,124,'2022-01-01',675,'CIBIL'),
(5041,124,'2024-01-01',690,'CIBIL'),
(5042,125,'2024-05-01',785,'CIBIL'),
(5043,126,'2023-01-01',710,'CIBIL'),
(5044,126,'2024-01-01',720,'CIBIL'),
(5045,127,'2023-02-01',760,'Experian'),
(5046,127,'2024-02-01',775,'Experian'),
(5047,128,'2022-01-01',620,'CIBIL'),
(5048,128,'2024-01-01',635,'CIBIL'),
(5049,129,'2024-06-01',705,'CIBIL'),
(5050,130,'2023-08-01',770,'Experian'),
(5051,130,'2024-08-01',790,'Experian'),
(5052,131,'2022-01-01',710,'CIBIL'),
(5053,131,'2024-01-01',730,'CIBIL'),
(5054,132,'2022-01-01',780,'Experian'),
(5055,132,'2024-01-01',795,'Experian'),
(5056,133,'2022-06-01',660,'CIBIL'),
(5057,133,'2024-02-01',675,'CIBIL'),
(5058,134,'2023-01-01',695,'CIBIL'),
(5059,134,'2024-01-01',705,'CIBIL'),
(5060,135,'2021-01-01',700,'Experian'),
(5061,135,'2024-01-01',715,'Experian'),
(5062,136,'2024-01-01',720,'CIBIL'),
(5063,137,'2022-01-01',745,'CIBIL'),
(5064,137,'2024-01-01',745,'CIBIL'),
(5065,138,'2024-03-01',735,'CIBIL'),
(5066,139,'2022-01-01',625,'Experian'),
(5067,139,'2024-01-01',650,'Experian'),
(5068,140,'2022-01-01',770,'CIBIL'),
(5069,140,'2024-01-01',785,'CIBIL'),
(5070,141,'2023-01-01',690,'CIBIL'),
(5071,141,'2024-01-01',710,'CIBIL'),
(5072,142,'2022-01-01',640,'CIBIL'),
(5073,142,'2024-01-01',655,'CIBIL'),
(5074,143,'2024-02-01',700,'Experian'),
(5075,144,'2022-01-01',795,'CIBIL'),
(5076,144,'2024-01-01',810,'CIBIL'),
(5077,145,'2022-01-01',635,'Experian'),
(5078,145,'2024-01-01',650,'Experian');

GO

-- To Check Row count in Table;
select 'Accounts' as Table_name, count(*) as Row_Count from accounts
Union all select 'Branches', count(*) from branches
union all select 'employees', count(*) from employees
union all select 'customers', count(*) from customers
union all select 'transactions', count(*) from transactions
union all select 'loanproducts', count(*) from loanproducts
union all select 'Loans', count(*) from loans
union all select 'LoanPayments', count(*) from LoanPayments
union all select 'collateral', count(*) from Collateral
union all select 'creditscores', count(*) from CreditScores order by Row_Count desc;

