--📘 Exercises on Table-Valued Functions (TVFs)

--Return all employees hired before a given date.
--Input: @HireDate DATE
--Output: EmployeeID, FullName, HireDate


CREATE FUNCTION GetEmployeesBeforeDate(@HireDate DATE)
RETURNS TABLE
AS
RETURN
(
    SELECT EmployeeID,
           FullName,
           HireDate
    FROM Employees
    WHERE HireDate < @HireDate
);


SELECT * 
FROM dbo.GetEmployeesBeforeDate('2018-01-01');







--Return employees from a specific department.
--Input: @Dept NVARCHAR(50)
--Output: FullName, Department, Salary

create function getdepartment(@department nvarchar(50))
returns table
as
return
(
select FullName,
	   Department,
	   Salary
  from Employees
 where Department=@department
);

select *
  from dbo.getdepartment('IT')









--Return employees whose salary is greater than a given amount.
--Input: @MinSalary DECIMAL(10,2)
--Output: FullName, Salary


create function getsalary(@salary decimal(18,2))
returns table
as
return
(
select FullName,
       Salary
  from Employees
 where Salary>@salary
);



select *
  from dbo.getsalary(95200)








--Return top N highest paid employees.
--Input: @TopN INT
--Output: FullName, Salary, Department

alter function getNhghestsalary(@N int)
returns table
as
return
(
select  FullName, 
        Salary, 
        Department
  from(
       select  FullName, 
               Salary, 
       		Department,
       		dense_rank() Over(order by salary desc) dr
         from Employees
		 ) t
 where dr=25
  );


select *
  from getNhghestsalary(25)









--Return employees hired between two dates.
--Input: @StartDate DATE, @EndDate DATE
--Output: FullName, HireDate

create function betweendate(@date1 date, @date2 date)
returns table
as
return
(
select fullname,
       hiredate
  from Employees
 where HireDate between @date1 and @date2
 );


 select * 
   from betweendate('2018-01-31','2018-11-05')






--Return employees along with a rank based on salary (per department).
--Input: @Dept NVARCHAR(50)
--Output: FullName, Salary, Rank


create function getrankemployee(@dept nvarchar(50))
returns table 
as
return
(
select FullName,
       Salary,
	   DENSE_RANK() OVER(partition by department order by salary desc) rank
  from Employees
  where Department=@dept
);


select *
  from getrankemployee('IT')












--Return employees whose salary is between two values.
--Input: @MinSalary DECIMAL(10,2), @MaxSalary DECIMAL(10,2)
--Output: FullName, Salary



create function getminmaxsalary(@MinSalary decimal(18,2), @MaxSalary decimal(18,2))
returns table
as 
return
(
select FullName,Salary
  from Employees
 where Salary between @MinSalary and @MaxSalary
);


select *
  from getminmaxsalary(68000,70000)
  order by Salary desc












--Return employees from multiple departments.
--Input: @Dept1 NVARCHAR(50), @Dept2 NVARCHAR(50)
--Output: FullName, Department

alter function getmultipledep(@Dept1 NVARCHAR(50), @Dept2 NVARCHAR(50))
returns table
as 
return
(
select FullName,
       Department
  from Employees
 where Department=@Dept1 or Department=@Dept2 
 );


 select *
   from getmultipledep('IT','Finance')







--Return employees hired in a given year.
--Input: @Year INT
--Output: FullName, HireDate


create function gethiredyear(@Year int)
returns table
as 
return
(
select FullName,
       HireDate
  from Employees
  where year(hiredate)=@Year
);

select *
  from gethiredyear(2019)









--Return employees whose salary is above the average salary of their department.
--No input parameters.
--Output: FullName, Department, Salary


alter function getaboveaverage()
returns table
as
return
(
select t1.FullName, t1.Department, t1.Salary
  from employees t1 
  left join (
select Department, 
	   avg(salary) sal
  from Employees
group by  Department) t2 on t1.Department=t2.Department

where t1.Salary>t2.sal
);

select *
  from getaboveaverage()