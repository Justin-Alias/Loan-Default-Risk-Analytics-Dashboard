
CREATE LOGIN data_user 
WITH PASSWORD = '0326';

USE Loan;

CREATE USER data_user FOR LOGIN data_user;

ALTER ROLE db_datareader ADD MEMBER data_user;


create database Loan
use Loan

select * from [dbo].[Loan_default]