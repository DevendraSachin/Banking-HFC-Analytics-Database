/*
BANKING & HFC SQL PRACTICE PROJECT
Dialect: Microsoft SQL Server (T-SQL)
Contains: 10 tables, sample data, and 75 practice questions with solutions.

Run this script in a practice database. It drops/recreates only the 10 tables
listed below. Do not run in a production database.
*/

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




/* ================================================================
   105 PRACTICE QUESTIONS WITH SOLUTIONS
   Run each query separately, or select one block at a time.
   ================================================================ */

-- Q01 [Basic | SELECT, WHERE]
-- List all active accounts with balances above 100,000.
SELECT AccountID, CustomerID, AccountType, Balance
FROM dbo.Accounts
WHERE AccountStatus = 'Active' AND Balance > 100000;

-- Q02 [Basic | ORDER BY]
-- Show the 5 largest account balances.
SELECT TOP (5) AccountID, CustomerID, Balance
FROM dbo.Accounts
ORDER BY Balance DESC;

-- Q03 [Basic | INNER JOIN]
-- List each account with its customer's name and branch.
SELECT a.AccountID, c.CustomerName, b.BranchName, a.AccountType, a.Balance
FROM dbo.Accounts a
INNER JOIN dbo.Customers c ON c.CustomerID = a.CustomerID
INNER JOIN dbo.Branches b ON b.BranchID = a.BranchID;

-- Q04 [Basic | LEFT JOIN]
-- List all customers, including those with no loan.
SELECT c.CustomerID, c.CustomerName, l.LoanID, l.LoanStatus
FROM dbo.Customers c
LEFT JOIN dbo.Loans l ON l.CustomerID = c.CustomerID
ORDER BY c.CustomerID, l.LoanID;

-- Q05 [Basic | RIGHT JOIN]
-- Return all branches and any loans assigned to them, including branches with no loans.
SELECT b.BranchName, l.LoanID, l.PrincipalAmount
FROM dbo.Loans l
RIGHT JOIN dbo.Branches b ON b.BranchID = l.BranchID
ORDER BY b.BranchID, l.LoanID;

-- Q06 [Basic | SELF JOIN]
-- Show each employee and their manager, if any.
SELECT e.EmployeeName AS Employee, m.EmployeeName AS Manager
FROM dbo.Employees e
LEFT JOIN dbo.Employees m ON m.EmployeeID = e.ManagerID
ORDER BY e.EmployeeID;

-- Q07 [Basic | CROSS JOIN]
-- Generate all combinations of loan products and branch locations.
SELECT p.ProductName, b.BranchName
FROM dbo.LoanProducts p
CROSS JOIN dbo.Branches b;

-- Q08 [Basic | GROUP BY]
-- Count customers in each customer segment.
SELECT CustomerSegment, COUNT(*) AS CustomerCount
FROM dbo.Customers
GROUP BY CustomerSegment;

-- Q09 [Basic | HAVING]
-- Find branches with at least two loans.
SELECT b.BranchName, COUNT(*) AS LoanCount
FROM dbo.Branches b
JOIN dbo.Loans l ON l.BranchID = b.BranchID
GROUP BY b.BranchName
HAVING COUNT(*) >= 2;

-- Q10 [Basic | Aggregate]
-- Find average principal amount by loan status.
SELECT LoanStatus, AVG(PrincipalAmount) AS AveragePrincipal
FROM dbo.Loans
GROUP BY LoanStatus;

-- Q11 [Basic | Single-row subquery]
-- Find loans larger than the average loan principal.
SELECT LoanID, CustomerID, PrincipalAmount
FROM dbo.Loans
WHERE PrincipalAmount > (SELECT AVG(PrincipalAmount) FROM dbo.Loans);

-- Q12 [Basic | Multi-row subquery]
-- Find customers who have at least one loan.
SELECT CustomerID, CustomerName
FROM dbo.Customers
WHERE CustomerID IN (SELECT CustomerID FROM dbo.Loans);

-- Q13 [Basic | NOT EXISTS]
-- Find customers who have never taken a loan.
SELECT c.CustomerID, c.CustomerName
FROM dbo.Customers c
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Loans l WHERE l.CustomerID = c.CustomerID
);

-- Q14 [Basic | Derived table / inline view]
-- Find branches whose total loan principal exceeds 5,000,000.
SELECT x.BranchID, x.TotalPrincipal
FROM (
    SELECT BranchID, SUM(PrincipalAmount) AS TotalPrincipal
    FROM dbo.Loans
    GROUP BY BranchID
) x
WHERE x.TotalPrincipal > 5000000;

-- Q15 [Basic | UNION]
-- Combine cities appearing in customers and branches, removing duplicates.
SELECT City FROM dbo.Customers
UNION
SELECT City FROM dbo.Branches;

-- Q16 [Basic | UNION ALL]
-- Combine customer cities and branch cities while preserving duplicates.
SELECT City FROM dbo.Customers
UNION ALL
SELECT City FROM dbo.Branches;

-- Q17 [Basic | EXCEPT]
-- Customer IDs that do not appear in the loans table.
SELECT CustomerID FROM dbo.Customers
EXCEPT
SELECT CustomerID FROM dbo.Loans;

-- Q18 [Basic | INTERSECT]
-- Customer IDs that have both an account and a loan.
SELECT CustomerID FROM dbo.Accounts
INTERSECT
SELECT CustomerID FROM dbo.Loans;

-- Q19 [Basic | View]
-- Create a view of active loans with customer and product details.
CREATE OR ALTER VIEW dbo.vw_ActiveLoans AS
SELECT l.LoanID, c.CustomerName, p.ProductName, l.PrincipalAmount,
       l.InterestRate, l.TenureMonths, b.BranchName
FROM dbo.Loans l
JOIN dbo.Customers c ON c.CustomerID = l.CustomerID
JOIN dbo.LoanProducts p ON p.ProductID = l.ProductID
JOIN dbo.Branches b ON b.BranchID = l.BranchID
WHERE l.LoanStatus = 'Active';
GO
SELECT * FROM dbo.vw_ActiveLoans;

-- Q20 [Basic | CTE]
-- Calculate total successful transaction amount per account.
WITH SuccessfulTransactions AS (
    SELECT AccountID, SUM(Amount) AS SuccessfulAmount
    FROM dbo.Transactions
    WHERE TransactionStatus = 'Success'
    GROUP BY AccountID
)
SELECT a.AccountID, COALESCE(st.SuccessfulAmount, 0) AS SuccessfulAmount
FROM dbo.Accounts a
LEFT JOIN SuccessfulTransactions st ON st.AccountID = a.AccountID;

-- Q21 [Basic | Multiple CTEs]
-- Find customers with total account balance above 300,000 and show their loan total.
WITH AccountTotals AS (
    SELECT CustomerID, SUM(Balance) AS TotalBalance
    FROM dbo.Accounts
    GROUP BY CustomerID
),
LoanTotals AS (
    SELECT CustomerID, SUM(PrincipalAmount) AS TotalLoanPrincipal
    FROM dbo.Loans
    GROUP BY CustomerID
)
SELECT c.CustomerName, a.TotalBalance, COALESCE(l.TotalLoanPrincipal, 0) AS TotalLoanPrincipal
FROM AccountTotals a
JOIN dbo.Customers c ON c.CustomerID = a.CustomerID
LEFT JOIN LoanTotals l ON l.CustomerID = a.CustomerID
WHERE a.TotalBalance > 300000;

-- Q22 [Basic | ROW_NUMBER]
-- Number loans from largest to smallest within each branch.
SELECT LoanID, BranchID, PrincipalAmount,
       ROW_NUMBER() OVER (PARTITION BY BranchID ORDER BY PrincipalAmount DESC) AS RowNum
FROM dbo.Loans;

-- Q23 [Basic | RANK]
-- Rank loans by principal amount; tied amounts share rank and leave gaps.
SELECT LoanID, PrincipalAmount,
       RANK() OVER (ORDER BY PrincipalAmount DESC) AS PrincipalRank
FROM dbo.Loans;

-- Q24 [Basic | DENSE_RANK]
-- Rank distinct interest rates without gaps.
SELECT LoanID, InterestRate,
       DENSE_RANK() OVER (ORDER BY InterestRate DESC) AS RateRank
FROM dbo.Loans;

-- Q25 [Basic | NTILE]
-- Divide customers into four groups based on current account balances.
WITH CustomerBalances AS (
    SELECT c.CustomerID, c.CustomerName, COALESCE(SUM(a.Balance), 0) AS TotalBalance
    FROM dbo.Customers c LEFT JOIN dbo.Accounts a ON a.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.CustomerName
)
SELECT *, NTILE(4) OVER (ORDER BY TotalBalance DESC) AS BalanceQuartile
FROM CustomerBalances;

-- Q26 [Intermediate | GROUP BY]
-- Calculate transaction count and total amount by transaction type.
SELECT TransactionType, COUNT(*) AS TransactionCount, SUM(Amount) AS TotalAmount
FROM dbo.Transactions
GROUP BY TransactionType;

-- Q27 [Intermediate | HAVING]
-- Find customers with more than one account and a combined balance over 100,000.
SELECT c.CustomerID, c.CustomerName, COUNT(a.AccountID) AS AccountCount,
       SUM(a.Balance) AS TotalBalance
FROM dbo.Customers c
JOIN dbo.Accounts a ON a.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CustomerName
HAVING COUNT(a.AccountID) > 1 AND SUM(a.Balance) > 100000;

-- Q28 [Intermediate | ROLLUP]
-- Show loan principal totals by region and city, plus subtotals and grand total.
SELECT b.Region, b.City, SUM(l.PrincipalAmount) AS TotalPrincipal
FROM dbo.Loans l
JOIN dbo.Branches b ON b.BranchID = l.BranchID
GROUP BY ROLLUP (b.Region, b.City)
ORDER BY b.Region, b.City;

-- Q29 [Intermediate | CUBE]
-- Calculate loan principal for every combination of region and loan status.
SELECT b.Region, l.LoanStatus, SUM(l.PrincipalAmount) AS TotalPrincipal
FROM dbo.Loans l
JOIN dbo.Branches b ON b.BranchID = l.BranchID
GROUP BY CUBE (b.Region, l.LoanStatus)
ORDER BY b.Region, l.LoanStatus;

-- Q30 [Intermediate | GROUPING SETS]
-- Return totals by branch, by loan status, and overall.
SELECT b.BranchName, l.LoanStatus, SUM(l.PrincipalAmount) AS TotalPrincipal
FROM dbo.Loans l
JOIN dbo.Branches b ON b.BranchID = l.BranchID
GROUP BY GROUPING SETS ((b.BranchName), (l.LoanStatus), ());

-- Q31 [Intermediate | GROUPING]
-- Label rows produced by ROLLUP as detail, subtotal, or grand total.
SELECT
    b.Region, b.City, SUM(l.PrincipalAmount) AS TotalPrincipal,
    CASE
      WHEN GROUPING(b.Region) = 1 THEN 'Grand Total'
      WHEN GROUPING(b.City) = 1 THEN 'Region Subtotal'
      ELSE 'City Detail'
    END AS RowLevel
FROM dbo.Loans l
JOIN dbo.Branches b ON b.BranchID = l.BranchID
GROUP BY ROLLUP (b.Region, b.City);

-- Q32 [Intermediate | GROUPING_ID]
-- Identify grouping level for region, status and loan totals.
SELECT b.Region, l.LoanStatus, SUM(l.PrincipalAmount) AS TotalPrincipal,
       GROUPING_ID(b.Region, l.LoanStatus) AS GroupingLevel
FROM dbo.Loans l
JOIN dbo.Branches b ON b.BranchID = l.BranchID
GROUP BY ROLLUP (b.Region, l.LoanStatus);

-- Q33 [Intermediate | INNER JOIN]
-- Show loan payments with customer, loan, and branch details.
SELECT lp.PaymentID, c.CustomerName, l.LoanID, b.BranchName,
       lp.DueDate, lp.PaymentStatus, lp.PrincipalPaid + lp.InterestPaid AS AmountPaid
FROM dbo.LoanPayments lp
JOIN dbo.Loans l ON l.LoanID = lp.LoanID
JOIN dbo.Customers c ON c.CustomerID = l.CustomerID
JOIN dbo.Branches b ON b.BranchID = l.BranchID;

-- Q34 [Intermediate | LEFT JOIN]
-- Find accounts with no successful transaction.
SELECT a.AccountID, a.CustomerID
FROM dbo.Accounts a
LEFT JOIN dbo.Transactions t
  ON t.AccountID = a.AccountID AND t.TransactionStatus = 'Success'
WHERE t.TransactionID IS NULL;

-- Q35 [Intermediate | RIGHT JOIN]
-- List every loan product, including products that have never been used.
SELECT p.ProductName, l.LoanID, l.PrincipalAmount
FROM dbo.Loans l
RIGHT JOIN dbo.LoanProducts p ON p.ProductID = l.ProductID
ORDER BY p.ProductID, l.LoanID;

-- Q36 [Intermediate | SELF JOIN]
-- Find pairs of employees who report to the same manager.
SELECT e1.EmployeeName AS Employee1, e2.EmployeeName AS Employee2,
       m.EmployeeName AS SharedManager
FROM dbo.Employees e1
JOIN dbo.Employees e2
  ON e1.ManagerID = e2.ManagerID AND e1.EmployeeID < e2.EmployeeID
JOIN dbo.Employees m ON m.EmployeeID = e1.ManagerID;

-- Q37 [Intermediate | CROSS JOIN]
-- Generate every combination of customer segment and loan product type.
SELECT s.CustomerSegment, p.ProductType
FROM (SELECT DISTINCT CustomerSegment FROM dbo.Customers) s
CROSS JOIN (SELECT DISTINCT ProductType FROM dbo.LoanProducts) p;

-- Q38 [Intermediate | Correlated subquery]
-- Find loans whose principal is greater than the average loan principal for their branch.
SELECT l.LoanID, l.BranchID, l.PrincipalAmount
FROM dbo.Loans l
WHERE l.PrincipalAmount > (
    SELECT AVG(l2.PrincipalAmount)
    FROM dbo.Loans l2
    WHERE l2.BranchID = l.BranchID
);

-- Q39 [Intermediate | Scalar subquery]
-- Show each loan and the difference between its principal and the overall average.
SELECT LoanID, PrincipalAmount,
       PrincipalAmount - (SELECT AVG(PrincipalAmount) FROM dbo.Loans) AS DifferenceFromAverage
FROM dbo.Loans;

-- Q40 [Intermediate | Multi-row subquery / ANY]
-- Find loans whose principal is greater than at least one home loan principal.
SELECT LoanID, PrincipalAmount
FROM dbo.Loans
WHERE PrincipalAmount > ANY (
    SELECT PrincipalAmount
    FROM dbo.Loans
    WHERE ProductID IN (1,2)
);

-- Q41 [Intermediate | EXISTS]
-- Find customers who have at least one late or missed payment.
SELECT c.CustomerID, c.CustomerName
FROM dbo.Customers c
WHERE EXISTS (
    SELECT 1
    FROM dbo.Loans l
    JOIN dbo.LoanPayments lp ON lp.LoanID = l.LoanID
    WHERE l.CustomerID = c.CustomerID
      AND lp.PaymentStatus IN ('Late','Missed')
);

-- Q42 [Intermediate | Derived table]
-- Find the top 3 customers by total loan principal.
SELECT TOP (3) x.CustomerID, c.CustomerName, x.TotalPrincipal
FROM (
    SELECT CustomerID, SUM(PrincipalAmount) AS TotalPrincipal
    FROM dbo.Loans
    GROUP BY CustomerID
) x
JOIN dbo.Customers c ON c.CustomerID = x.CustomerID
ORDER BY x.TotalPrincipal DESC;

-- Q43 [Intermediate | UNION]
-- Build a unique list of customer IDs that appear in accounts or loans.
SELECT CustomerID FROM dbo.Accounts
UNION
SELECT CustomerID FROM dbo.Loans;

-- Q44 [Intermediate | UNION ALL]
-- Show a combined event feed of transactions and loan payments, retaining duplicates.
SELECT 'Transaction' AS EventType, TransactionDate AS EventDate, Amount AS EventAmount
FROM dbo.Transactions
UNION ALL
SELECT 'Loan Payment', PaymentDate, PrincipalPaid + InterestPaid
FROM dbo.LoanPayments
WHERE PaymentDate IS NOT NULL;

-- Q45 [Intermediate | EXCEPT]
-- Find customers with accounts but no loan.
SELECT CustomerID FROM dbo.Accounts
EXCEPT
SELECT CustomerID FROM dbo.Loans;

-- Q46 [Intermediate | INTERSECT]
-- Find cities that have both customers and branches.
SELECT City FROM dbo.Customers
INTERSECT
SELECT City FROM dbo.Branches;

-- Q47 [Intermediate | CTE]
-- Calculate a loan-to-collateral ratio for each secured loan.
WITH CollateralTotals AS (
    SELECT LoanID, SUM(EstimatedValue) AS CollateralValue
    FROM dbo.Collateral
    GROUP BY LoanID
)
SELECT l.LoanID, l.PrincipalAmount, c.CollateralValue,
       CAST(l.PrincipalAmount / NULLIF(c.CollateralValue, 0) AS DECIMAL(10,4)) AS LoanToValueRatio
FROM dbo.Loans l
JOIN CollateralTotals c ON c.LoanID = l.LoanID;

-- Q48 [Intermediate | Multiple CTEs]
-- Compare each customer's total balance, loan principal and current/latest credit score.
WITH Balances AS (
    SELECT CustomerID, SUM(Balance) AS TotalBalance
    FROM dbo.Accounts GROUP BY CustomerID
),
LoanSums AS (
    SELECT CustomerID, SUM(PrincipalAmount) AS TotalPrincipal
    FROM dbo.Loans GROUP BY CustomerID
),
LatestScores AS (
    SELECT CustomerID, CreditScore,
           ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY ScoreDate DESC, CreditScoreID DESC) AS rn
    FROM dbo.CreditScores
)
SELECT c.CustomerName, COALESCE(b.TotalBalance,0) AS TotalBalance,
       COALESCE(l.TotalPrincipal,0) AS TotalPrincipal, s.CreditScore AS LatestCreditScore
FROM dbo.Customers c
LEFT JOIN Balances b ON b.CustomerID = c.CustomerID
LEFT JOIN LoanSums l ON l.CustomerID = c.CustomerID
LEFT JOIN LatestScores s ON s.CustomerID = c.CustomerID AND s.rn = 1;

-- Q49 [Intermediate | Recursive CTE]
-- Show the reporting hierarchy below each top-level employee.
WITH EmployeeHierarchy AS (
    SELECT EmployeeID, EmployeeName, ManagerID, 0 AS HierarchyLevel,
           CAST(EmployeeName AS VARCHAR(400)) AS HierarchyPath
    FROM dbo.Employees
    WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.EmployeeID, e.EmployeeName, e.ManagerID, eh.HierarchyLevel + 1,
           CAST(eh.HierarchyPath + ' > ' + e.EmployeeName AS VARCHAR(400))
    FROM dbo.Employees e
    JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT EmployeeID, EmployeeName, ManagerID, HierarchyLevel, HierarchyPath
FROM EmployeeHierarchy
ORDER BY HierarchyPath
OPTION (MAXRECURSION 100);

-- Q50 [Intermediate | ROW_NUMBER]
-- Return the most recent credit-score record per customer.
WITH RankedScores AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY CustomerID ORDER BY ScoreDate DESC, CreditScoreID DESC
    ) AS rn
    FROM dbo.CreditScores
)
SELECT CustomerID, ScoreDate, CreditScore, Bureau
FROM RankedScores
WHERE rn = 1;

-- Q51 [Intermediate | RANK and DENSE_RANK]
-- Compare ranking of loan officers by total loan principal handled.
WITH OfficerTotals AS (
    SELECT e.EmployeeID, e.EmployeeName, SUM(l.PrincipalAmount) AS TotalPrincipal
    FROM dbo.Employees e
    JOIN dbo.Loans l ON l.LoanOfficerID = e.EmployeeID
    GROUP BY e.EmployeeID, e.EmployeeName
)
SELECT *, RANK() OVER (ORDER BY TotalPrincipal DESC) AS RankWithGaps,
          DENSE_RANK() OVER (ORDER BY TotalPrincipal DESC) AS DenseRank
FROM OfficerTotals;

-- Q52 [Intermediate | NTILE]
-- Split loans into 4 principal-size buckets.
SELECT LoanID, PrincipalAmount,
       NTILE(4) OVER (ORDER BY PrincipalAmount) AS PrincipalQuartile
FROM dbo.Loans;

-- Q53 [Intermediate | LAG]
-- Compare each customer's credit score with their previous recorded score.
SELECT CustomerID, ScoreDate, CreditScore,
       LAG(CreditScore) OVER (PARTITION BY CustomerID ORDER BY ScoreDate) AS PreviousScore,
       CreditScore - LAG(CreditScore) OVER (PARTITION BY CustomerID ORDER BY ScoreDate) AS ScoreChange
FROM dbo.CreditScores;

-- Q54 [Intermediate | LEAD]
-- Show the next credit-score date and score for each customer.
SELECT CustomerID, ScoreDate, CreditScore,
       LEAD(ScoreDate) OVER (PARTITION BY CustomerID ORDER BY ScoreDate) AS NextScoreDate,
       LEAD(CreditScore) OVER (PARTITION BY CustomerID ORDER BY ScoreDate) AS NextScore
FROM dbo.CreditScores;

-- Q55 [Intermediate | FIRST_VALUE]
-- Show each customer's first recorded credit score alongside every record.
SELECT CustomerID, ScoreDate, CreditScore,
       FIRST_VALUE(CreditScore) OVER (
           PARTITION BY CustomerID ORDER BY ScoreDate, CreditScoreID
       ) AS FirstRecordedScore
FROM dbo.CreditScores;

-- Q56 [Intermediate | LAST_VALUE + frame]
-- Show each customer's latest score alongside every historical record.
SELECT CustomerID, ScoreDate, CreditScore,
       LAST_VALUE(CreditScore) OVER (
           PARTITION BY CustomerID
           ORDER BY ScoreDate, CreditScoreID
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS LatestRecordedScore
FROM dbo.CreditScores;

-- Q57 [Intermediate | PERCENT_RANK]
-- Calculate relative rank of loans by principal amount.
SELECT LoanID, PrincipalAmount,
       PERCENT_RANK() OVER (ORDER BY PrincipalAmount) AS PercentRank
FROM dbo.Loans;

-- Q58 [Intermediate | CUME_DIST]
-- Calculate cumulative distribution of credit scores.
SELECT CustomerID, CreditScore,
       CUME_DIST() OVER (ORDER BY CreditScore) AS CumulativeDistribution
FROM dbo.CreditScores;

-- Q59 [Intermediate | SUM OVER]
-- Show each loan payment and total paid across all recorded payments for that loan.
SELECT LoanID, PaymentID, PrincipalPaid, InterestPaid,
       SUM(PrincipalPaid + InterestPaid) OVER (PARTITION BY LoanID) AS LoanRecordedPaymentsTotal
FROM dbo.LoanPayments;

-- Q60 [Intermediate | AVG OVER]
-- Compare each loan's interest rate with its branch's average rate.
SELECT LoanID, BranchID, InterestRate,
       AVG(InterestRate) OVER (PARTITION BY BranchID) AS BranchAverageRate
FROM dbo.Loans;

-- Q61 [Intermediate | COUNT OVER]
-- Show each transaction and the number of transactions on its account.
SELECT TransactionID, AccountID, TransactionDate, Amount,
       COUNT(*) OVER (PARTITION BY AccountID) AS AccountTransactionCount
FROM dbo.Transactions;

-- Q62 [Intermediate | MIN OVER]
-- Show each payment and the earliest due date for its loan.
SELECT LoanID, PaymentID, DueDate,
       MIN(DueDate) OVER (PARTITION BY LoanID) AS FirstDueDate
FROM dbo.LoanPayments;

-- Q63 [Intermediate | MAX OVER]
-- Show each customer's highest historical credit score on every score row.
SELECT CustomerID, ScoreDate, CreditScore,
       MAX(CreditScore) OVER (PARTITION BY CustomerID) AS HighestScore
FROM dbo.CreditScores;

-- Q64 [Advanced | Running total]
-- Calculate running transaction amount per account in transaction-date order.
SELECT AccountID, TransactionID, TransactionDate, Amount,
       SUM(Amount) OVER (
           PARTITION BY AccountID
           ORDER BY TransactionDate, TransactionID
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS RunningTransactionAmount
FROM dbo.Transactions;

-- Q65 [Advanced | Moving/window calculation]
-- Calculate a 3-transaction moving average per account.
SELECT AccountID, TransactionID, TransactionDate, Amount,
       AVG(CAST(Amount AS DECIMAL(14,2))) OVER (
           PARTITION BY AccountID
           ORDER BY TransactionDate, TransactionID
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS MovingAverageLast3Transactions
FROM dbo.Transactions;

-- Q66 [Advanced | Window frame]
-- Calculate the current payment plus the previous payment for each loan.
SELECT LoanID, PaymentID, DueDate, PrincipalPaid + InterestPaid AS PaymentAmount,
       SUM(PrincipalPaid + InterestPaid) OVER (
           PARTITION BY LoanID
           ORDER BY DueDate, PaymentID
           ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
       ) AS CurrentAndPreviousPaymentTotal
FROM dbo.LoanPayments;

-- Q67 [Advanced | Offset functions]
-- Compare each transaction with the previous and next transaction on its account.
SELECT AccountID, TransactionID, TransactionDate, Amount,
       LAG(Amount, 1, 0) OVER (
           PARTITION BY AccountID ORDER BY TransactionDate, TransactionID
       ) AS PreviousAmount,
       LEAD(Amount, 1, 0) OVER (
           PARTITION BY AccountID ORDER BY TransactionDate, TransactionID
       ) AS NextAmount
FROM dbo.Transactions;

-- Q68 [Advanced | Partitioned calculations]
-- Rank customers by total balance within each customer segment.
WITH CustomerBalances AS (
    SELECT c.CustomerID, c.CustomerName, c.CustomerSegment,
           COALESCE(SUM(a.Balance),0) AS TotalBalance
    FROM dbo.Customers c
    LEFT JOIN dbo.Accounts a ON a.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.CustomerName, c.CustomerSegment
)
SELECT *, DENSE_RANK() OVER (
    PARTITION BY CustomerSegment ORDER BY TotalBalance DESC
) AS SegmentBalanceRank
FROM CustomerBalances;

-- Q69 [Advanced | Top N per group]
-- Return the two largest loans in each branch.
WITH RankedLoans AS (
    SELECT l.*, ROW_NUMBER() OVER (
        PARTITION BY BranchID ORDER BY PrincipalAmount DESC, LoanID
    ) AS rn
    FROM dbo.Loans l
)
SELECT LoanID, BranchID, PrincipalAmount
FROM RankedLoans
WHERE rn <= 2
ORDER BY BranchID, rn;

-- Q70 [Advanced | Conditional aggregation]
-- Summarize payment counts and amounts by loan.
SELECT LoanID,
       SUM(CASE WHEN PaymentStatus = 'Paid' THEN 1 ELSE 0 END) AS PaidCount,
       SUM(CASE WHEN PaymentStatus = 'Late' THEN 1 ELSE 0 END) AS LateCount,
       SUM(CASE WHEN PaymentStatus = 'Missed' THEN 1 ELSE 0 END) AS MissedCount,
       SUM(PrincipalPaid + InterestPaid) AS TotalRecordedPaid
FROM dbo.LoanPayments
GROUP BY LoanID;

-- Q71 [Advanced | GROUPING SETS + GROUPING_ID]
-- Report loan principal by region/status, region only, status only, and grand total.
SELECT b.Region, l.LoanStatus, SUM(l.PrincipalAmount) AS TotalPrincipal,
       GROUPING_ID(b.Region, l.LoanStatus) AS GroupingID
FROM dbo.Loans l
JOIN dbo.Branches b ON b.BranchID = l.BranchID
GROUP BY GROUPING SETS ((b.Region, l.LoanStatus), (b.Region), (l.LoanStatus), ());

-- Q72 [Advanced | Correlated aggregate]
-- Find customers whose total loan principal exceeds the average customer-level loan total.
WITH CustomerLoanTotals AS (
    SELECT CustomerID, SUM(PrincipalAmount) AS TotalPrincipal
    FROM dbo.Loans
    GROUP BY CustomerID
)
SELECT c.CustomerID, c.CustomerName, t.TotalPrincipal
FROM CustomerLoanTotals t
JOIN dbo.Customers c ON c.CustomerID = t.CustomerID
WHERE t.TotalPrincipal > (
    SELECT AVG(CAST(x.TotalPrincipal AS DECIMAL(14,2)))
    FROM CustomerLoanTotals x
);

-- Q73 [Advanced | Latest row + joins]
-- Show each customer's latest credit score and any active loan exposure.
WITH LatestScore AS (
    SELECT CustomerID, CreditScore, ScoreDate,
           ROW_NUMBER() OVER (
               PARTITION BY CustomerID ORDER BY ScoreDate DESC, CreditScoreID DESC
           ) AS rn
    FROM dbo.CreditScores
),
ActiveExposure AS (
    SELECT CustomerID, SUM(PrincipalAmount) AS ActivePrincipal
    FROM dbo.Loans
    WHERE LoanStatus = 'Active'
    GROUP BY CustomerID
)
SELECT c.CustomerID, c.CustomerName, s.CreditScore, s.ScoreDate,
       COALESCE(a.ActivePrincipal,0) AS ActivePrincipal
FROM dbo.Customers c
LEFT JOIN LatestScore s ON s.CustomerID = c.CustomerID AND s.rn = 1
LEFT JOIN ActiveExposure a ON a.CustomerID = c.CustomerID;

-- Q74 [Advanced | Delinquency analysis]
-- Find branches with at least one missed payment and show missed-payment counts.
SELECT b.BranchName, COUNT(*) AS MissedPaymentCount
FROM dbo.Branches b
JOIN dbo.Loans l ON l.BranchID = b.BranchID
JOIN dbo.LoanPayments lp ON lp.LoanID = l.LoanID
WHERE lp.PaymentStatus = 'Missed'
GROUP BY b.BranchName
HAVING COUNT(*) >= 1
ORDER BY MissedPaymentCount DESC;

-- Q75 [Advanced | Multi-step analytics]
-- Create a branch performance report: loan count, total principal, average rate,
-- successful transaction volume for accounts in the branch, and total collateral.
WITH LoanMetrics AS (
    SELECT BranchID, COUNT(*) AS LoanCount,
           SUM(PrincipalAmount) AS TotalPrincipal,
           AVG(InterestRate) AS AverageInterestRate
    FROM dbo.Loans
    GROUP BY BranchID
),
TransactionMetrics AS (
    SELECT a.BranchID, SUM(t.Amount) AS SuccessfulTransactionVolume
    FROM dbo.Accounts a
    JOIN dbo.Transactions t ON t.AccountID = a.AccountID
    WHERE t.TransactionStatus = 'Success'
    GROUP BY a.BranchID
),
CollateralMetrics AS (
    SELECT l.BranchID, SUM(c.EstimatedValue) AS TotalCollateralValue
    FROM dbo.Loans l
    JOIN dbo.Collateral c ON c.LoanID = l.LoanID
    GROUP BY l.BranchID
)
SELECT b.BranchName,
       COALESCE(lm.LoanCount,0) AS LoanCount,
       COALESCE(lm.TotalPrincipal,0) AS TotalPrincipal,
       lm.AverageInterestRate,
       COALESCE(tm.SuccessfulTransactionVolume,0) AS SuccessfulTransactionVolume,
       COALESCE(cm.TotalCollateralValue,0) AS TotalCollateralValue
FROM dbo.Branches b
LEFT JOIN LoanMetrics lm ON lm.BranchID = b.BranchID
LEFT JOIN TransactionMetrics tm ON tm.BranchID = b.BranchID
LEFT JOIN CollateralMetrics cm ON cm.BranchID = b.BranchID
ORDER BY COALESCE(lm.TotalPrincipal,0) DESC;


-- Q76 [Nested subquery]
-- Find loans whose principal is above the average principal for their product,
-- where that product's average principal is itself above the overall loan average.
SELECT l.LoanID, l.ProductID, l.PrincipalAmount
FROM dbo.Loans l
WHERE l.PrincipalAmount > (
    SELECT AVG(CAST(l2.PrincipalAmount AS DECIMAL(14,2)))
    FROM dbo.Loans l2
    WHERE l2.ProductID = l.ProductID
)
AND (
    SELECT AVG(CAST(l3.PrincipalAmount AS DECIMAL(14,2)))
    FROM dbo.Loans l3
    WHERE l3.ProductID = l.ProductID
) > (
    SELECT AVG(CAST(PrincipalAmount AS DECIMAL(14,2)))
    FROM dbo.Loans
);

-- Q77 [ALL]
-- Find loans whose interest rate is higher than every active home loan rate.
SELECT l.LoanID, l.InterestRate, l.LoanStatus
FROM dbo.Loans l
WHERE l.InterestRate > ALL (
    SELECT l2.InterestRate
    FROM dbo.Loans l2
    JOIN dbo.LoanProducts p ON p.ProductID = l2.ProductID
    WHERE l2.LoanStatus = 'Active'
      AND p.ProductType = 'Home Loan'
);

-- Q78 [NOT EXISTS / relational division]
-- Find customers who have a successful transaction on every account they own.
-- Customers with no accounts are excluded.
SELECT c.CustomerID, c.CustomerName
FROM dbo.Customers c
WHERE EXISTS (
    SELECT 1 FROM dbo.Accounts a WHERE a.CustomerID = c.CustomerID
)
AND NOT EXISTS (
    SELECT 1
    FROM dbo.Accounts a
    WHERE a.CustomerID = c.CustomerID
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.Transactions t
          WHERE t.AccountID = a.AccountID
            AND t.TransactionStatus = 'Success'
      )
);

-- Q79 [Correlated aggregate]
-- Find customers whose total account balance exceeds the total balance
-- of every other customer in their own segment.
SELECT c.CustomerID, c.CustomerName, c.CustomerSegment,
       (SELECT COALESCE(SUM(a.Balance),0)
        FROM dbo.Accounts a WHERE a.CustomerID = c.CustomerID) AS TotalBalance
FROM dbo.Customers c
WHERE (SELECT COALESCE(SUM(a.Balance),0)
       FROM dbo.Accounts a WHERE a.CustomerID = c.CustomerID)
      > ALL (
          SELECT COALESCE(SUM(a2.Balance),0)
          FROM dbo.Customers c2
          LEFT JOIN dbo.Accounts a2 ON a2.CustomerID = c2.CustomerID
          WHERE c2.CustomerSegment = c.CustomerSegment
            AND c2.CustomerID <> c.CustomerID
          GROUP BY c2.CustomerID
      );

-- Q80 [Nested NOT EXISTS]
-- Find customers who have a loan but have never had a missed payment on any loan.
SELECT c.CustomerID, c.CustomerName
FROM dbo.Customers c
WHERE EXISTS (
    SELECT 1 FROM dbo.Loans l WHERE l.CustomerID = c.CustomerID
)
AND NOT EXISTS (
    SELECT 1
    FROM dbo.Loans l
    JOIN dbo.LoanPayments lp ON lp.LoanID = l.LoanID
    WHERE l.CustomerID = c.CustomerID
      AND lp.PaymentStatus = 'Missed'
);

-- Q81 [CROSS APPLY]
-- Return each customer's latest credit-score record.
SELECT c.CustomerID, c.CustomerName, s.ScoreDate, s.CreditScore, s.Bureau
FROM dbo.Customers c
CROSS APPLY (
    SELECT TOP (1) cs.ScoreDate, cs.CreditScore, cs.Bureau
    FROM dbo.CreditScores cs
    WHERE cs.CustomerID = c.CustomerID
    ORDER BY cs.ScoreDate DESC, cs.CreditScoreID DESC
) s;

-- Q82 [OUTER APPLY]
-- Return every customer with their latest loan, including customers with no loans.
SELECT c.CustomerID, c.CustomerName, recent.LoanID,
       recent.ApplicationDate, recent.LoanStatus, recent.PrincipalAmount
FROM dbo.Customers c
OUTER APPLY (
    SELECT TOP (1) l.LoanID, l.ApplicationDate, l.LoanStatus, l.PrincipalAmount
    FROM dbo.Loans l
    WHERE l.CustomerID = c.CustomerID
    ORDER BY l.ApplicationDate DESC, l.LoanID DESC
) recent;

-- Q83 [APPLY + correlated top-N]
-- Find the two most recent transactions for every account, preserving accounts
-- that have no transactions.
SELECT a.AccountID, a.CustomerID, t.TransactionID, t.TransactionDate,
       t.Amount, t.TransactionStatus
FROM dbo.Accounts a
OUTER APPLY (
    SELECT TOP (2) t.TransactionID, t.TransactionDate, t.Amount, t.TransactionStatus
    FROM dbo.Transactions t
    WHERE t.AccountID = a.AccountID
    ORDER BY t.TransactionDate DESC, t.TransactionID DESC
) t
ORDER BY a.AccountID, t.TransactionDate DESC;

-- Q84 [Conditional aggregation + subquery]
-- Classify customers by exposure using total loan principal and total account balance.
WITH CustomerExposure AS (
    SELECT c.CustomerID, c.CustomerName,
           (SELECT COALESCE(SUM(l.PrincipalAmount),0)
            FROM dbo.Loans l WHERE l.CustomerID = c.CustomerID) AS LoanExposure,
           (SELECT COALESCE(SUM(a.Balance),0)
            FROM dbo.Accounts a WHERE a.CustomerID = c.CustomerID) AS DepositBalance
    FROM dbo.Customers c
)
SELECT *,
       CASE
         WHEN LoanExposure >= 5000000 THEN 'High Loan Exposure'
         WHEN LoanExposure >= 2000000 THEN 'Medium Loan Exposure'
         WHEN LoanExposure > 0 THEN 'Low Loan Exposure'
         ELSE 'No Loan Exposure'
       END AS ExposureBand,
       LoanExposure - DepositBalance AS NetExposure
FROM CustomerExposure;

-- Q85 [Anti-join]
-- Find loan products that have never been used by a loan application.
SELECT p.ProductID, p.ProductName, p.ProductType
FROM dbo.LoanProducts p
LEFT JOIN dbo.Loans l ON l.ProductID = p.ProductID
WHERE l.LoanID IS NULL;

-- Q86 [Window function: change detection]
-- Identify each customer's credit-score records where the score changed
-- by at least 20 points from the previous recorded score.
WITH ScoreHistory AS (
    SELECT CustomerID, ScoreDate, CreditScore,
           LAG(CreditScore) OVER (
               PARTITION BY CustomerID ORDER BY ScoreDate, CreditScoreID
           ) AS PreviousScore
    FROM dbo.CreditScores
)
SELECT CustomerID, ScoreDate, PreviousScore, CreditScore,
       CreditScore - PreviousScore AS ScoreChange
FROM ScoreHistory
WHERE PreviousScore IS NOT NULL
  AND ABS(CreditScore - PreviousScore) >= 20;

-- Q87 [Window function: gaps between events]
-- Calculate the number of days between consecutive transactions per account.
WITH TransactionSequence AS (
    SELECT AccountID, TransactionID, TransactionDate, Amount,
           LAG(TransactionDate) OVER (
               PARTITION BY AccountID ORDER BY TransactionDate, TransactionID
           ) AS PreviousTransactionDate
    FROM dbo.Transactions
)
SELECT AccountID, TransactionID, PreviousTransactionDate, TransactionDate,
       DATEDIFF(DAY, PreviousTransactionDate, TransactionDate) AS DaysBetweenTransactions
FROM TransactionSequence
WHERE PreviousTransactionDate IS NOT NULL;

-- Q88 [Window function: consecutive-event groups]
-- Identify consecutive months in which a customer had at least one successful
-- transaction. The query returns each customer's active-month islands.
WITH CustomerMonths AS (
    SELECT DISTINCT a.CustomerID,
           DATEFROMPARTS(YEAR(t.TransactionDate), MONTH(t.TransactionDate), 1) AS ActivityMonth
    FROM dbo.Accounts a
    JOIN dbo.Transactions t ON t.AccountID = a.AccountID
    WHERE t.TransactionStatus = 'Success'
),
MonthNumbers AS (
    SELECT CustomerID, ActivityMonth,
           DATEDIFF(MONTH, '20000101', ActivityMonth) AS MonthNumber
    FROM CustomerMonths
),
Islands AS (
    SELECT CustomerID, ActivityMonth,
           MonthNumber - ROW_NUMBER() OVER (
               PARTITION BY CustomerID ORDER BY ActivityMonth
           ) AS IslandKey
    FROM MonthNumbers
)
SELECT CustomerID, MIN(ActivityMonth) AS StreakStartMonth,
       MAX(ActivityMonth) AS StreakEndMonth, COUNT(*) AS ConsecutiveActiveMonths
FROM Islands
GROUP BY CustomerID, IslandKey
ORDER BY CustomerID, StreakStartMonth;

-- Q89 [Window function: median]
-- Calculate the median principal amount by loan status using PERCENTILE_CONT.
SELECT DISTINCT LoanStatus,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY PrincipalAmount)
         OVER (PARTITION BY LoanStatus) AS MedianPrincipal
FROM dbo.Loans;

-- Q90 [Window function: rolling 3-month totals]
-- Show monthly successful transaction totals and a 3-row rolling total
-- per account. Months without transactions are not generated in this query.
WITH MonthlyTransactions AS (
    SELECT a.AccountID,
           DATEFROMPARTS(YEAR(t.TransactionDate), MONTH(t.TransactionDate), 1) AS TransactionMonth,
           SUM(t.Amount) AS MonthlyAmount
    FROM dbo.Accounts a
    JOIN dbo.Transactions t ON t.AccountID = a.AccountID
    WHERE t.TransactionStatus = 'Success'
    GROUP BY a.AccountID, DATEFROMPARTS(YEAR(t.TransactionDate), MONTH(t.TransactionDate), 1)
)
SELECT AccountID, TransactionMonth, MonthlyAmount,
       SUM(MonthlyAmount) OVER (
           PARTITION BY AccountID ORDER BY TransactionMonth
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS RollingThreeObservedMonths
FROM MonthlyTransactions;

-- Q91 [EMI approximation / financial calculation]
-- Estimate monthly EMI for each loan using the standard amortization formula.
-- InterestRate is assumed to be an annual percentage rate.
SELECT LoanID, PrincipalAmount, InterestRate, TenureMonths,
       CAST(
         CASE WHEN InterestRate = 0
              THEN PrincipalAmount / NULLIF(TenureMonths,0)
              ELSE PrincipalAmount *
                   ((InterestRate / 1200.0) * POWER(1 + InterestRate / 1200.0, TenureMonths)) /
                   NULLIF(POWER(1 + InterestRate / 1200.0, TenureMonths) - 1, 0)
         END AS DECIMAL(14,2)
       ) AS EstimatedMonthlyEMI
FROM dbo.Loans
WHERE TenureMonths > 0;

-- Q92 [Delinquency rate]
-- Calculate missed-payment rate by branch, using recorded payment schedules.
SELECT b.BranchName,
       COUNT(lp.PaymentID) AS ScheduledPaymentRows,
       SUM(CASE WHEN lp.PaymentStatus = 'Missed' THEN 1 ELSE 0 END) AS MissedPayments,
       CAST(100.0 * SUM(CASE WHEN lp.PaymentStatus = 'Missed' THEN 1 ELSE 0 END)
            / NULLIF(COUNT(lp.PaymentID),0) AS DECIMAL(6,2)) AS MissedPaymentPct
FROM dbo.Branches b
JOIN dbo.Loans l ON l.BranchID = b.BranchID
JOIN dbo.LoanPayments lp ON lp.LoanID = l.LoanID
GROUP BY b.BranchName
ORDER BY MissedPaymentPct DESC;

-- Q93 [Credit risk segmentation]
-- Identify customers whose latest credit score is below 650 but who have
-- an active loan. Return their active principal exposure.
WITH LatestScore AS (
    SELECT CustomerID, CreditScore,
           ROW_NUMBER() OVER (
               PARTITION BY CustomerID ORDER BY ScoreDate DESC, CreditScoreID DESC
           ) AS rn
    FROM dbo.CreditScores
),
ActiveLoans AS (
    SELECT CustomerID, SUM(PrincipalAmount) AS ActivePrincipal
    FROM dbo.Loans
    WHERE LoanStatus = 'Active'
    GROUP BY CustomerID
)
SELECT c.CustomerID, c.CustomerName, s.CreditScore, a.ActivePrincipal
FROM dbo.Customers c
JOIN LatestScore s ON s.CustomerID = c.CustomerID AND s.rn = 1
JOIN ActiveLoans a ON a.CustomerID = c.CustomerID
WHERE s.CreditScore < 650;

-- Q94 [Loan-to-value ratio]
-- Flag secured loans with a loan-to-value ratio above 80%.
WITH SecurityValue AS (
    SELECT LoanID, SUM(EstimatedValue) AS TotalCollateralValue
    FROM dbo.Collateral
    GROUP BY LoanID
)
SELECT l.LoanID, l.PrincipalAmount, s.TotalCollateralValue,
       CAST(100.0 * l.PrincipalAmount / NULLIF(s.TotalCollateralValue,0) AS DECIMAL(7,2)) AS LTVPercent,
       CASE WHEN 100.0 * l.PrincipalAmount / NULLIF(s.TotalCollateralValue,0) > 80
            THEN 'Review' ELSE 'Within Threshold' END AS LTVFlag
FROM dbo.Loans l
JOIN SecurityValue s ON s.LoanID = l.LoanID;

-- Q95 [Payment behavior]
-- Find loans where at least two recorded payment rows are late or missed.
SELECT l.LoanID, l.CustomerID,
       SUM(CASE WHEN lp.PaymentStatus IN ('Late','Missed') THEN 1 ELSE 0 END) AS ProblemPaymentCount
FROM dbo.Loans l
JOIN dbo.LoanPayments lp ON lp.LoanID = l.LoanID
GROUP BY l.LoanID, l.CustomerID
HAVING SUM(CASE WHEN lp.PaymentStatus IN ('Late','Missed') THEN 1 ELSE 0 END) >= 2;

-- Q96 [Multiple CTEs + branch comparison]
-- Rank branches by active loan exposure and compare each branch with the
-- average active exposure across all branches, counting branches with zero loans.
WITH BranchExposure AS (
    SELECT b.BranchID, b.BranchName,
           COALESCE(SUM(CASE WHEN l.LoanStatus = 'Active' THEN l.PrincipalAmount ELSE 0 END),0) AS ActiveExposure
    FROM dbo.Branches b
    LEFT JOIN dbo.Loans l ON l.BranchID = b.BranchID
    GROUP BY b.BranchID, b.BranchName
),
Benchmark AS (
    SELECT AVG(CAST(ActiveExposure AS DECIMAL(16,2))) AS AverageBranchExposure
    FROM BranchExposure
)
SELECT e.BranchName, e.ActiveExposure, x.AverageBranchExposure,
       e.ActiveExposure - x.AverageBranchExposure AS DifferenceFromAverage,
       DENSE_RANK() OVER (ORDER BY e.ActiveExposure DESC) AS ExposureRank
FROM BranchExposure e
CROSS JOIN Benchmark x;

-- Q97 [Cohort analysis]
-- For each customer join quarter, count customers and their total loan principal.
WITH CustomerCohort AS (
    SELECT CustomerID,
           DATEADD(QUARTER, DATEDIFF(QUARTER, 0, JoinDate), 0) AS CohortQuarter
    FROM dbo.Customers
),
LoanTotals AS (
    SELECT CustomerID, SUM(PrincipalAmount) AS TotalPrincipal
    FROM dbo.Loans
    GROUP BY CustomerID
)
SELECT cc.CohortQuarter, COUNT(*) AS CustomerCount,
       SUM(COALESCE(lt.TotalPrincipal,0)) AS CohortLoanPrincipal,
       AVG(CAST(COALESCE(lt.TotalPrincipal,0) AS DECIMAL(14,2))) AS AveragePrincipalPerCustomer
FROM CustomerCohort cc
LEFT JOIN LoanTotals lt ON lt.CustomerID = cc.CustomerID
GROUP BY cc.CohortQuarter
ORDER BY cc.CohortQuarter;

-- Q98 [Exception detection]
-- Find accounts where the stored balance is below the net successful
-- transaction flow in this dataset. This is a comparison exercise, not a
-- true reconciliation because opening balances are not stored.
WITH NetFlow AS (
    SELECT AccountID,
           SUM(CASE
                 WHEN TransactionType = 'Deposit' THEN Amount
                 WHEN TransactionType IN ('Withdrawal','Payment') THEN -Amount
                 ELSE 0
               END) AS NetKnownFlow
    FROM dbo.Transactions
    WHERE TransactionStatus = 'Success'
    GROUP BY AccountID
)
SELECT a.AccountID, a.Balance, n.NetKnownFlow
FROM dbo.Accounts a
JOIN NetFlow n ON n.AccountID = a.AccountID
WHERE a.Balance < n.NetKnownFlow;

-- Q99 [Subquery + percentage of total]
-- For each loan, calculate its share of total principal and keep loans that
-- individually account for at least 10% of the portfolio.
SELECT LoanID, PrincipalAmount,
       CAST(100.0 * PrincipalAmount /
            NULLIF((SELECT SUM(PrincipalAmount) FROM dbo.Loans),0) AS DECIMAL(7,2)) AS PortfolioSharePct
FROM dbo.Loans
WHERE 100.0 * PrincipalAmount /
      NULLIF((SELECT SUM(PrincipalAmount) FROM dbo.Loans),0) >= 10
ORDER BY PortfolioSharePct DESC;

-- Q100 [Nested CTE + percentile threshold]
-- Identify customers whose total loan exposure is in the top 25% of borrowers
-- (based on NTILE over customers with loans).
WITH BorrowerTotals AS (
    SELECT CustomerID, SUM(PrincipalAmount) AS TotalPrincipal
    FROM dbo.Loans
    GROUP BY CustomerID
),
BorrowerBuckets AS (
    SELECT CustomerID, TotalPrincipal,
           NTILE(4) OVER (ORDER BY TotalPrincipal DESC) AS ExposureQuartile
    FROM BorrowerTotals
)
SELECT c.CustomerID, c.CustomerName, b.TotalPrincipal, b.ExposureQuartile
FROM BorrowerBuckets b
JOIN dbo.Customers c ON c.CustomerID = b.CustomerID
WHERE b.ExposureQuartile = 1
ORDER BY b.TotalPrincipal DESC;

-- Q101 [Set operators]
-- Find customers with accounts but no successful transaction, then exclude
-- customers who have any active loan.
SELECT CustomerID
FROM dbo.Accounts
EXCEPT
SELECT a.CustomerID
FROM dbo.Accounts a
JOIN dbo.Transactions t ON t.AccountID = a.AccountID
WHERE t.TransactionStatus = 'Success'
EXCEPT
SELECT CustomerID
FROM dbo.Loans
WHERE LoanStatus = 'Active';

-- Q102 [Relational division]
-- Find branches that have at least one loan from every loan product type
-- represented in the loan table. This is intentionally strict.
SELECT b.BranchID, b.BranchName
FROM dbo.Branches b
WHERE NOT EXISTS (
    SELECT DISTINCT p.ProductType
    FROM dbo.LoanProducts p
    WHERE EXISTS (SELECT 1 FROM dbo.Loans l0 WHERE l0.ProductID = p.ProductID)
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.Loans l
          JOIN dbo.LoanProducts p2 ON p2.ProductID = l.ProductID
          WHERE l.BranchID = b.BranchID
            AND p2.ProductType = p.ProductType
      )
);

-- Q103 [Advanced aggregation + grouping]
-- Produce one report with branch-level totals, status-level totals, and
-- branch/status detail; GROUPING_ID identifies the output level.
SELECT b.BranchName, l.LoanStatus,
       COUNT(*) AS LoanCount,
       SUM(l.PrincipalAmount) AS PrincipalTotal,
       GROUPING_ID(b.BranchName, l.LoanStatus) AS AggregationLevel
FROM dbo.Loans l
JOIN dbo.Branches b ON b.BranchID = l.BranchID
GROUP BY GROUPING SETS (
    (b.BranchName, l.LoanStatus),
    (b.BranchName),
    (l.LoanStatus),
    ()
)
ORDER BY AggregationLevel, b.BranchName, l.LoanStatus;

-- Q104 [Temporal comparison]
-- Compare each customer's latest and earliest credit scores, and classify
-- whether the score improved, declined, or remained unchanged.
WITH ScoreBounds AS (
    SELECT CustomerID,
           FIRST_VALUE(CreditScore) OVER (
               PARTITION BY CustomerID ORDER BY ScoreDate, CreditScoreID
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           ) AS FirstScore,
           LAST_VALUE(CreditScore) OVER (
               PARTITION BY CustomerID ORDER BY ScoreDate, CreditScoreID
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           ) AS LatestScore,
           ROW_NUMBER() OVER (
               PARTITION BY CustomerID ORDER BY ScoreDate DESC, CreditScoreID DESC
           ) AS rn
    FROM dbo.CreditScores
)
SELECT c.CustomerID, c.CustomerName, s.FirstScore, s.LatestScore,
       s.LatestScore - s.FirstScore AS ScoreDelta,
       CASE WHEN s.LatestScore > s.FirstScore THEN 'Improved'
            WHEN s.LatestScore < s.FirstScore THEN 'Declined'
            ELSE 'Unchanged' END AS ScoreTrend
FROM ScoreBounds s
JOIN dbo.Customers c ON c.CustomerID = s.CustomerID
WHERE s.rn = 1;

-- Q105 [Capstone: multiple CTEs + correlated subquery + windows]
-- Create a customer risk dashboard combining latest credit score, active
-- loan exposure, missed/late payment count, collateral coverage, and rank.
WITH LatestScore AS (
    SELECT CustomerID, CreditScore,
           ROW_NUMBER() OVER (
               PARTITION BY CustomerID ORDER BY ScoreDate DESC, CreditScoreID DESC
           ) AS rn
    FROM dbo.CreditScores
),
LoanExposure AS (
    SELECT CustomerID, SUM(PrincipalAmount) AS ActivePrincipal
    FROM dbo.Loans
    WHERE LoanStatus = 'Active'
    GROUP BY CustomerID
),
PaymentRisk AS (
    SELECT l.CustomerID,
           SUM(CASE WHEN lp.PaymentStatus IN ('Late','Missed') THEN 1 ELSE 0 END) AS RiskPaymentCount
    FROM dbo.Loans l
    LEFT JOIN dbo.LoanPayments lp ON lp.LoanID = l.LoanID
    GROUP BY l.CustomerID
),
CollateralCoverage AS (
    SELECT l.CustomerID,
           SUM(c.EstimatedValue) AS CollateralValue
    FROM dbo.Loans l
    JOIN dbo.Collateral c ON c.LoanID = l.LoanID
    WHERE l.LoanStatus = 'Active'
    GROUP BY l.CustomerID
),
RiskDashboard AS (
    SELECT c.CustomerID, c.CustomerName, c.RiskCategory,
           s.CreditScore, COALESCE(e.ActivePrincipal,0) AS ActivePrincipal,
           COALESCE(p.RiskPaymentCount,0) AS RiskPaymentCount,
           COALESCE(cv.CollateralValue,0) AS CollateralValue,
           CASE
             WHEN s.CreditScore < 650 OR COALESCE(p.RiskPaymentCount,0) >= 2 THEN 'High Review Priority'
             WHEN s.CreditScore < 700 OR COALESCE(p.RiskPaymentCount,0) = 1 THEN 'Medium Review Priority'
             ELSE 'Standard Review'
           END AS ReviewPriority
    FROM dbo.Customers c
    LEFT JOIN LatestScore s ON s.CustomerID = c.CustomerID AND s.rn = 1
    LEFT JOIN LoanExposure e ON e.CustomerID = c.CustomerID
    LEFT JOIN PaymentRisk p ON p.CustomerID = c.CustomerID
    LEFT JOIN CollateralCoverage cv ON cv.CustomerID = c.CustomerID
)
SELECT *,
       DENSE_RANK() OVER (
           ORDER BY CASE ReviewPriority
                      WHEN 'High Review Priority' THEN 1
                      WHEN 'Medium Review Priority' THEN 2
                      ELSE 3
                    END,
                    RiskPaymentCount DESC,
                    ActivePrincipal DESC
       ) AS ReviewRank,
       CAST(100.0 * ActivePrincipal / NULLIF(CollateralValue,0) AS DECIMAL(7,2)) AS ActiveExposureToCollateralPct,
       (SELECT AVG(CAST(ActivePrincipal AS DECIMAL(16,2))) FROM RiskDashboard) AS AverageCustomerActiveExposure
FROM RiskDashboard
ORDER BY ReviewRank, CustomerID;

