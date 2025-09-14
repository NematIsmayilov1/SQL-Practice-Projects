--Return Full Name in Uppercase
--Create a function that takes EmployeeID and returns the employee’s full name in uppercase.

CREATE FUNCTION dbo.GetEmployeeNameUpper (@EmpID INT)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @FullName NVARCHAR(100);

    SELECT @FullName = UPPER(FullName)
    FROM Employees
    WHERE EmployeeID = @EmpID;

    RETURN @FullName;
END;

SELECT dbo.GetEmployeeNameUpper(26) AS AliasName;








--Calculate Years of Service
--Create a function that takes EmployeeID and returns how many years the employee has worked (based on HireDate).


--create function dbo.workedyear(@empid int)
--returns int
--as
--BEGIN
--  declare @year int;

--select @year= DATEDIFF(year,HireDate,GETDATE())
--  from Employees
-- where EmployeeID=26
-- return @year;
-- end;


-- SELECT dbo.workedyear(26) AS AliasName;






--Get Employee Department
--Create a function that accepts an EmployeeID and returns the Department of that employee.

create function dbo.etdepartment(@empid int)
returns nvarchar(100)
as
begin
   declare @department nvarchar(100);

select @department=Department
  from Employees
 where EmployeeID=@empid
 return @department;
 end;


 select dbo.etdepartment(26) as department






--Annual Bonus Calculation
--Create a function that accepts an EmployeeID and returns 10% of their salary as a bonus.


create function dbo.getsalarybonus(@empid int)
returns decimal(18,2)
as
begin
  declare @bonus decimal(18,2);

  select @bonus=Salary*0.1
    from Employees
   where EmployeeID=@empid
   return @bonus;
   end;

   select dbo.getsalarybonus(26)




--Check if Employee is Senior
--Create a function that accepts EmployeeID and returns 'Senior' if the employee has more than 5 years of service, otherwise 'Junior'.

create function dbo.getsenior(@empid int)
returns nvarchar(50)
as
begin
 declare @level nvarchar(50);

 select @level=(case when DATEDIFF(year,HireDate,GETDATE())>5then 'Senior' else 'Junior' end)
   from Employees
  where @empid=EmployeeID
  return @level;
  end;

  select dbo.getsenior(1)






--Monthly Salary
--Create a function that takes EmployeeID and returns their salary divided by 12.

ALter FUNCTION dbo.getsalary12(@empid int)
RETURNS DECIMAL(18,4)
AS
BEGIN
 DECLARE @salary DECIMAL(18,4);

 SELECT @salary=(Salary/12)+0.0
   FROM Employees
  WHERE EmployeeID=@empid
  RETURN @salary;
END;

select dbo.getsalary12(26)





--Get First Name
--Create a function that extracts and returns the first name from the FullName column.


create function dbo.getfirstname(@empid int)
returns nvarchar(50)
as
begin
   declare @firstname  nvarchar(50);

select @firstname= left(fullname, charindex(' ', FullName)-1)
  from Employees
 where @empid=EmployeeID
 return @firstname;
 end;


 select dbo.getfirstname(26)



--Get Last Name
--Create a function that extracts and returns the last name from the FullName column.

create function dbo.getlastname(@empid int)
returns nvarchar(50)
as
begin
 declare @lastname nvarchar(50);

 SELECT  @lastname=RIGHT(fullname, CHARINDEX(' ', REVERSE(fullname)) - 1) 
FROM Employees
  where @empid=EmployeeID
 return @lastname;
end;

select dbo.getlastname(26)










--Check if High Earner
--Create a function that accepts EmployeeID and returns 'High Earner' if salary > 5000, otherwise 'Normal Earner'.

ALTER function dbo.gethighersalary(@empid int)
returns nvarchar(50)
as
begin 
  declare @earner nvarchar(50);

select @earner= (case when Salary>70000 then 'High Earner' else 'Normal Earner' end)
  from Employees
 where @empid=EmployeeID
 return @earner;
end;



select dbo.gethighersalary(26) as earner





--Get Formatted Employee Info
--Create a function that takes EmployeeID and returns a formatted string like:

create function dbo.getinfo(@empid int)
returns nvarchar(Max)
as
begin
  declare @info nvarchar(max);
select @info=CONCAT('Employee: ',fullname,
              '-Department: ', Department,
			  '-HireDate: ', HireDate,
			  '-Salary: ', Salary)
  from employees 
  where @empid=EmployeeID
  return @info
end;


select dbo.getinfo(26)