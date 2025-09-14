--1. Track New Hires
--Create a trigger that inserts a record into a EmployeeAudit table whenever a new employee is added.
--Goal: Practice AFTER INSERT.




CREATE TRIGGER trg_AfterInsert_Employees
ON Employees
AFTER INSERT
AS
BEGIN
    INSERT INTO EmployeeAudit (EmployeeID, FullName, Department, Salary, HireDate)
    SELECT EmployeeID, FullName, Department, Salary, HireDate
    FROM inserted;
END;







--2. Prevent Negative Salary
--Create a trigger that prevents inserting or updating salary to a negative value.
--Goal: Practice ROLLBACK inside INSTEAD OF INSERT/UPDATE.




CREATE TRIGGER trg_PreventNegativeSalary
ON Employees
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted
        WHERE Salary < 0
    )
    BEGIN
        RAISERROR('Salary cannot be negative.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;






--3. Log Deleted Employees
--When an employee is deleted, insert their data into a DeletedEmployees table for history.
--Goal: Practice AFTER DELETE.


CREATE TABLE DeletedEmployees (
    EmployeeID INT,
    FullName NVARCHAR(100),
    Department NVARCHAR(50),
    Salary DECIMAL(10,2),
    HireDate DATE,
    DeletedDate DATETIME DEFAULT GETDATE()
);


CREATE TRIGGER trg_afterdelete_Employees
ON Employees
AFTER DELETE
AS
BEGIN
     INSERT INTO DeletedEmployees (EmployeeID,FullName,Department, Salary, HireDate)
	 SELECT EmployeeID,FullName,Department, Salary, HireDate
	   FROM deleted
END;












--4. Update LastModified Date
--Add a LastModified column to Employees. Create a trigger that updates it whenever employee details are updated.
--Goal: Practice AFTER UPDATE.

alter table employees add LastModified datetime


ALTER TRIGGER trg_afterupdate_employees
ON Employees
AFTER UPDATE
AS
BEGIN
UPDATE Employees set LastModified=GETDATE()
  from employees t1
  JOIN inserted t2 on t1.EmployeeID=t2.EmployeeID
END;









--5. Prevent Salary Decrease
--Create a trigger that blocks any salary decrease for existing employees.
--Goal: Compare Inserted and Deleted pseudo-tables.



CREATE TRIGGER trg_preventsalarydecrease
ON Employees
AFTER UPDATE 
AS
BEGIN
     IF EXISTS (
	            select 1
				  from inserted t1
				  join deleted t2 on t1.EmployeeID=t2.EmployeeID
	            where t1.Salary<t2.Salary
	    )
	 BEGiN
		RAISERROR('Salary decrease is not allowed!', 16,1)
		ROLLBACK TRANSACTION
	 END;
END;






--6. Limit Max Salary
--If someone tries to insert or update salary more than 100000, automatically set it to 100000.
--Goal: Use INSTEAD OF INSERT/UPDATE and modify data.




CREATE TRIGGER trg_maxsalarylmit
ON Employees
INSTEAD OF INSERT
AS
BEGIN
  INSERT INTO Employees (EmployeeID,FullName, Department,Salary,HireDate)
       SELECT EmployeeID,
	          FullName,
			  Department,
			  CASE WHEN Salary>100000 THEN 100000 ELSE Salary END,
			  HireDate
	     FROM inserted
END;









--7. Cascade Department Change
--If a department name is changed in a Departments table, automatically update all related employees.
--Goal: Trigger on another table affecting Employees.



alter table employees add departmentid int  --step 1

create table Department (
Departmentid int primary key,             -- step 2
Department_name nvarchar(100)
)


insert into Department ( Department_name)
select distinct Department                      --step 3
  from Employees


ALTER trigger trg_upddepartment 
on Department
afTER update
as                                                --step 4
begin
      update t2 set t2.Department=t1.Department_name, t2.departmentid=t1.Departmentid
	    from inserted t1
		join Employees t2 on t1.Departmentid=t2.departmentid
end;









--8. Track Who Changed Data
--Add a ChangedBy column. Trigger should capture SYSTEM_USER every time an employee row is updated.
--Goal: Use SYSTEM_USER inside trigger.



alter table employees add changedby nvarchar(50)


ALTER DATABASE CURRENT SET RECURSIVE_TRIGGERS OFF;
GO

alter trigger trg_changedby
on employees
after update
as 
begin 
    SET NOCOUNT ON;
 update t1 set t1.changedby=SYSTEM_USER
   from Employees t1
   join inserted t2 on t1.EmployeeID=t2.EmployeeID
   WHERE t1.ChangedBy IS NULL;
end;









--9. Count Employees per Department
--Whenever an employee is inserted or deleted, update a DepartmentStats table that stores the number of employees per department.
--Goal: Use AFTER INSERT and AFTER DELETE triggers.



update DepartmentStats set empcount=t2.cnt
  from DepartmentStats t1
  join (select departmentid, count(employeeid) as cnt 
     from  Employees
   group by departmentid) t2  on t1.depid=t2.departmentid



Alter TRIGGER trg_EmployeeInsert
ON Employees
AFTER INSERT
AS
BEGIN

    MERGE DepartmentStats AS ds
    USING (SELECT departmentid,department FROM inserted) AS i 
    ON ds.Depid = i.DepartmentID
    WHEN MATCHED THEN 
        UPDATE SET Empcount = Empcount + 1, depname=i.department
    WHEN NOT MATCHED THEN
        INSERT (Depid, Empcount, depname)
        VALUES (i.DepartmentID, 1, i.Department);
END;



create trigger trg_departmentcountdelete
on Employees
after delete
as
begin

update t1 set t1.empcount=t1.empcount-1
  from DepartmentStats t1
  join deleted t2 on t1.depid=t2.departmentid
end;







--10. Prevent Weekend Hiring
--Prevent inserting a new employee with a HireDate on Saturday or Sunday.
--Goal: Use DATEPART(WEEKDAY, HireDate) inside trigger.


create trigger trg_preventhiring
on employees
for insert
as
begin
     if exists (
	          select 1
			    from inserted
				where DATEPART(WEEKDAY,HireDate) in (1,7)
	 ) 
	 begin
	    RAISERROR('Today  Saturday or Sunday', 16,1)
		ROLLBACK TRANSACTION
		END;
END;



