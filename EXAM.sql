use classicmodels;

#1
select city, count(officeCode) as employee_count
from (select o.city, e.officeCode
from employees e inner join offices o
on e.officeCode = o.officeCode) a
group by city
order by employee_count desc
limit 3;

#2
select productLine, (sum(MSRP * quantityInStock)- sum(buyPrice * quantityInStock)) / sum(MSRP * quantityInStock) as profitMargin
from products
group by productLine;

#3.a
select c.salesRepEmployeeNumber, sum(od.priceEach * od.quantityOrdered) as sales
from orderdetails od 
inner join orders o
on od.orderNumber = o.orderNumber
inner join customers c
on c.customerNumber = o.customerNumber
group by c.salesRepEmployeeNumber
order by sales desc
limit 3;

#3.b
#employees, customers

#3.c
alter table employees add column emp_status varchar(30);

delimiter //
create procedure EmpLeave(in emp_id char(4))
begin
	declare manager_id char(4);
	
	update employees set emp_status = 'inactive' where employee_id = emp_id;
    
    select reportsTo
    into manager_id
    from employees
    where employeeNumber = emp_id;
    
	update customers set salesRepEmployeeNumber = manager_id where salesRepEmployeeNumber = emp_id;
end //

delimiter ;

#4
select employee_id, max(flag)-1 as changeTimes
from (select s.employee_id, row_number() over(partition by s.employee_id) as flag
from Employee_salary s inner join Employee e
on s.employee_id = e.employee_id
inner join Department d
on d.department_id = e.department_id
where d.department_name = '___') a
group by employee_id;

#5
select department_id, employee_name, term_date, row_number() over(partition by department_id order by salary desc) as flag
from Employee
where term_date is null
having flag <= 3;
