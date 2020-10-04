use classicmodels;

#Single entity
#1
select * 
from offices
order by country, state, city;

#2
select count(employeeNumber)
from employees;

#3
select sum(amount) 
from payments;

#4
select * 
from productlines
where productline like '%Cars%';

#5
select sum(amount)
from payments
where date_format(paymentDate, '%Y%m%d') = '20041028';

#6
select *
from payments
where amount > 100000;

#7
select *
from products
order by productLine;

#8
select productLine, count(productCode) as count
from products
group by productLine;

#9
select amount
from payments
order by amount
limit 1;

#10
select amount
from payments
where amount > 2 * (select avg(amount) from payments);

#11
select avg((MSRP - buyPrice) / buyPrice) as avg_perc_markup
from products; 

#12
select count(distinct productCode) as count
from products;

#13
select customerName, city
from customers
where salesRepEmployeeNumber is null;

#14
select concat(lastname, ' ', firstname) as VP_man_name
from employees
where jobTitle like '%VP%'
	or jobTitle like '%manager%';
    
#15
select orderNumber, sum(quantityOrdered * priceEach) as sum
from orderdetails
group by orderNumber
having sum(quantityOrdered * priceEach) > 5000;

#One to many relationship
#1
select customerName, salesRepEmployeeNumber
from customers;

#2
select sum(amount) as sum
from customers c
inner join payments p
on c.customerNumber = p.customerNumber
where c.customerName = 'Atelier graphique';

#3
select paymentDate, sum(amount) as total
from payments
group by paymentDate
order by paymentDate;

#4
select productCode
from products
where productCode not in (select distinct productCode from orderdetails);

#5
select customerNumber, sum(amount) as total
from payments
group by customerNumber;

#6
select count(o.orderNumber) as count
from customers c
inner join orders o
on c.customerNumber = o.customerNumber
where c.customerName = 'Herkku Gifts';

#7
select e.employeeNumber
from employees e
inner join offices off
on e.officeCode = off.officeCode
where off.city = 'Boston';

#8
select customerNumber, amount
from payments
where amount > 100000
order by amount desc;

#9
select o.orderNumber, sum(od.quantityOrdered * priceEach) as value
from orders o
inner join orderdetails od
on o.orderNumber = od.orderNumber
where o.status = 'On Hold'
group by o.orderNumber;

#10
select customerNumber, sum(isOnHold) as onHoldNumber
from
(select customerNumber, 
case 
	when `status` = 'On Hold' then 1
    else 0
end as isOnHold
from orders) as temp
group by customerNumber;

#Many to many relationship
#1
select o.orderDate, od.productCode
from orders o
inner join orderdetails od
on o.orderNumber = od.orderNumber
order by o.orderDate;

#2
select o.orderDate, o.orderNumber
from orders o
inner join orderdetails od
on o.orderNumber = od.orderNumber
inner join products p
on p.productCode = od.productCode
where p.productName = '1940 Ford Pickup Truck'
order by o.orderDate desc;

#3
select c.customerName, o.orderNumber
from customers c
inner join orders o
on c.customerNumber = o.customerNumber
inner join (select orderNumber, sum(quantityOrdered * priceEach) as total from orderdetails group by orderNumber) as temp
on o.orderNumber = temp.orderNumber
where temp.total > 25000;

#4
select productCode, count(*) as count
from orderdetails
group by productCode
having count(*) = (select count(distinct orderNumber) from orderdetails)
order by count desc;


#5
select distinct od.productCode
from orderdetails od
inner join products p
on od.productCode = p.productCode
where od.priceEach < 0.8 * p.MSRP;

#6
select distinct od.productCode
from orderdetails od
inner join products p
on od.productCode = p.productCode
where od.priceEach > 2 * p.buyPrice;

#7
select od.productCode
from orderdetails od
inner join orders o
on od.orderNumber = o.orderNumber
where date_format(o.orderDate, '%W') = 'Monday';

#8
select p.productCode, p.quantityInStock - temp.shipped_total as on_hand
from products p
right join
(select od.productCode, sum(od.quantityOrdered) as shipped_total
from orderdetails od
inner join orders o
on o.orderNumber = od.orderNumber
where o.shippedDate is not null
and od.productCode in
(select distinct od.productCode
from orders o
inner join orderdetails od
on o.orderNumber = od.orderNumber
where o.`status` = 'On Hold')
group by od.productCode) as temp
on p.productCode = temp.productCode;

#Regular expressions
#1
select *
from products
where productName like '%Ford%';

#2
select *
from products
where productName like '%ship';

#3
select country, count(*) as count
from customers
where country in ('Denmark', 'Norway', 'Sweden')
group by country;

#4
select *
from products
where productCode regexp 'S700_1[0-4][0-9][0-9]';

#5
select *
from customers
where customerName regexp '[0-9]';

#6
select *
from employees
where lastName regexp 'Dianne|Diane'
	or firstName regexp 'Dianne|Diane';
    
#7
select *
from products
where productName regexp 'boat|ship';

#8
select *
from products
where productCode regexp '^S700';

#9
select lastName, firstName
from employees
where lastName regexp 'Larry|Barry'
	or firstName regexp 'Larry|Barry';

#10
select lastName, firstName
from employees
where lastName regexp '[^a-zA-Z]'
	or firstName regexp '[^a-zA-Z]';
    
#11
select *
from products
where productVendor regexp 'Diecast$';

#General queries
#1
select *
from employees
where reportsTo is null;

#2
select *
from employees a
inner join employees b
on a.reportsTo = b.employeeNumber
where b.firstName = 'William'
	and b.lastName = 'Patterson';
    
#3
select p.productCode, p.productName
from customers c
inner join orders o
on c.customerNumber = o.customerNumber
inner join orderdetails od
on o.orderNumber = od.orderNumber
inner join products p
on od.productCode = p.productCode
where c.customerName = 'Herkku Gifts';

#4
select e.lastName, e.firstName, sum(temp.total * 0.05) as commission
from orders o
inner join (select orderNumber, sum(quantityOrdered * priceEach) as total from orderdetails group by orderNumber) as temp
using(orderNumber)
inner join customers c
using(customerNumber)
inner join employees e
on e.employeeNumber = c.salesRepEmployeeNumber
group by e.employeeNumber
order by e.lastName, e.firstName;

#5
select datediff(max(orderDate),min(orderDate))
from orders;

#6
select customerNumber, avg(datediff(shippedDate, orderDate)) as dif
from orders
group by customerNumber
order by dif desc;

#7
select sum(quantityOrdered * priceEach) as total
from orders o
inner join orderdetails od
using(orderNumber)
where date_format(orderDate, '%Y%m') = '200408';

#8
select o.customerNumber, sum(temp.total) as order_value, sum(p.amount) as payment
from orders o
inner join (select orderNumber, sum(quantityOrdered * priceEach) as total from orderdetails group by orderNumber) as temp
using(orderNumber)
inner join payments p
using(customerNumber)
where date_format(o.orderDate, '%Y') = '2004'
	and date_format(p.paymentDate, '%Y') = '2004'
group by o.customerNumber;

#9
select concat(a.firstName, ' ', a.lastName) as empName
from employees a
inner join employees b
on a.reportsTo = b.employeeNumber
inner join employees c
on b.reportsTo = c.employeeNumber
where c.firstName = 'Diane'
	and c.lastName = 'Murphy';

#10
select productCode, MSRP * quantityInStock/ (select sum(MSRP * quantityInStock) from products) as percent
from products;

#11
delimiter $$
create function convert_mpg_to_lphkm(mpg float)
returns float
no sql
begin
return (100 * 3.785) / (1.609 * mpg);
end $$
delimiter ;

#12
delimiter $$
create procedure increase_price(pCode varchar(20), percent float)
begin
	update products set MSRP = MSRP * (1 + percent)
    where productCode = pCode;
end $$
delimiter ;

#13
#same as queston No.7

#14
select bymonth, payment_total / order_total as ratio
from
(select date_format(orderDate, '%Y%m') as bymonth, sum(val) as order_total
from orders o
inner join (select orderNumber, sum(quantityOrdered * priceEach) as val from orderdetails group by orderNumber) as temp
using(orderNumber)
where date_format(orderDate, '%Y') = '2004'
group by date_format(orderDate, '%Y%m')
order by bymonth) a
inner join (select date_format(paymentDate, '%Y%m') as bymonth, sum(amount) as payment_total from payments group by date_format(paymentDate, '%Y%m')) b
using(bymonth);

#15
select months, four-three as dif
from
(select date_format(paymentDate, '%m') as months, sum(amount) as four
from payments
where date_format(paymentDate, '%Y') = '2004'
group by date_format(paymentDate, '%m')) a
inner join 
(select date_format(paymentDate, '%m') as months, sum(amount) as three
from payments
where date_format(paymentDate, '%Y') = '2003'
group by date_format(paymentDate, '%m')) b
using(months)
order by months;

#16
delimiter $$
create procedure report_amount(yearMonth char(6), nameStr varchar(30))
begin
	select total
    from orders o
    inner join (select orderNumber, sum(quantityOrdered * priceEach) as total from orderdetails group by orderNumber) as temp
    using(orderNumber)
    inner join customers c
    using(customerNumber)
    where date_format(orderDate, '%Y%m') = yearMonth
		and customerName like '%"+nameStr+"%';
end $$
delimiter ;

#17
delimiter $$
create procedure change_creditLimit(ctry varchar(30), percent float)
begin
	update customers set creditLimit = creditLimit * (1 + percent)
    where country = ctry;
end $$
delimiter ;

###18
select productCode, pcode2
from
(select productCode, orderNumber
from orderdetails) a
inner join
(select orderNumber, productCode as pcode2
from orderdetails) b
using(orderNumber)
where productCode != pcode2
group by productCode, pcode2
having count(*) >= 10;

#19
select *, total / (select sum(quantityOrdered * priceEach) from orderdetails) as percent
from
(select customerName, sum(total) as total
from orders o
inner join (select orderNumber, sum(quantityOrdered * priceEach) as total from orderdetails group by orderNumber) as temp
using(orderNumber)
inner join customers c
using(customerNumber)
group by customerName) temp2;

#20
select *, total_profit / (select sum(quantityOrdered * (priceEach - buyPrice))
						from orderdetails od
						inner join products p
						using(productCode)) as percent
from
(select customerName, sum(profit) as total_profit
from orders o
inner join (select orderNumber, sum(quantityOrdered * (priceEach - buyPrice)) as profit
from orderdetails od
inner join products p
using(productCode)
group by orderNumber) profits
using(orderNumber)
inner join customers c
using(customerNumber)
group by customerName) temp
order by total_profit desc;

#21
select salesRepEmployeeNumber, sum(quantityOrdered * priceEach) as revenue
from orderdetails
inner join orders
using(orderNumber)
inner join customers
using(customerNumber)
group by salesRepEmployeeNumber;

#22
select salesRepEmployeeNumber, sum(quantityOrdered * (priceEach - buyPrice)) as profit
from orderdetails
inner join products
using(productCode)
inner join orders
using(orderNumber)
inner join customers
using(customerNumber)
group by salesRepEmployeeNumber
order by profit desc;

#23
select productName, sum(quantityOrdered * priceEach) as revenue
from orderdetails
inner join products
using(productCode)
group by productName;

#24
select productLine, sum(quantityOrdered * (priceEach - buyPrice)) as profit
from products
inner join orderdetails
using(productCode)
group by productLine
order by profit desc;


#25
select productCode, sales2004/sales2003 as ratio
from
(select productCode, sum(quantityOrdered * priceEach) as sales2004
from orderdetails
inner join orders
using(orderNumber)
where year(orderDate) = '2004'
group by productCode) a
inner join (select productCode, sum(quantityOrdered * priceEach) as sales2003
			from orderdetails
			inner join orders
			using(orderNumber)
			where year(orderDate) = '2003'
			group by productCode) b
using(productCode);

#26
select customerNumber, amount2004/amount2003 as ratio
from
(select customerNumber, sum(amount) as amount2003
from payments
where year(paymentDate) = '2003'
group by customerNumber) a
inner join (select customerNumber, sum(amount) as amount2004
			from payments
			where year(paymentDate) = '2004'
			group by customerNumber) b
using(customerNumber);

#27
select distinct productCode
from orderdetails
inner join orders
using(orderNumber)
where year(orderDate) = '2003'
		and	productCode not in (select productCode from orderdetails inner join orders using(orderNumber) where date_format(orderDate, '%Y') = '2004');

#28
select distinct customerNumber
from payments
where customerNumber not in (select customerNumber from payments where date_format(paymentDate, '%Y') = '2003');

#Correlated subqueries
#1
select *
from employees a
inner join employees b
on a.reportsTo = b.employeeNumber
where b.firstName = 'Mary'
	and b.lastName = 'Patterson';

#2
select p.*
from
(select date_format(paymentDate, '%Y%m') as yearMonth, avg(amount) as average
from payments
group by date_format(paymentDate, '%Y%m')) temp
inner join payments p
on temp.yearMonth = date_format(p.paymentDate, '%Y%m')
where amount > 2 * average;

#3
select productCode, productLine, on_hand/total as ratio
from 
(select p.productCode, p.quantityInStock - temp.shipped_total as on_hand
from products p
right join
(select od.productCode, sum(od.quantityOrdered) as shipped_total
from orderdetails od
inner join orders o
on o.orderNumber = od.orderNumber
where o.shippedDate is not null
and od.productCode in
(select distinct od.productCode
from orders o
inner join orderdetails od
on o.orderNumber = od.orderNumber)
group by od.productCode) as temp
on p.productCode = temp.productCode) a
inner join products
using(productCode)
inner join
(select productLine, sum(on_hand) as total
from products
inner join
(select p.productCode, p.quantityInStock - temp.shipped_total as on_hand
from products p
right join
(select od.productCode, sum(od.quantityOrdered) as shipped_total
from orderdetails od
inner join orders o
on o.orderNumber = od.orderNumber
where o.shippedDate is not null
and od.productCode in
(select distinct od.productCode
from orders o
inner join orderdetails od
on o.orderNumber = od.orderNumber)
group by od.productCode) as temp
on p.productCode = temp.productCode) temp2
using(productCode)
group by productLine) b
using(productLine);

#4
select orderNumber, productCode
from orderdetails
inner join (select orderNumber, sum(quantityOrdered * priceEach) as total from orderdetails group by orderNumber) as temp
using(orderNumber)
where orderNumber in (select orderNumber
						from orderdetails
						group by orderNumber
						having count(*) > 2)
	and quantityOrdered * priceEach > 0.5 * total;