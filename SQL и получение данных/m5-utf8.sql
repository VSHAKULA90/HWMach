--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
--так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

SELECT customer_id, payment_id, payment_date, 
  ROW_NUMBER () OVER (order by payment_date) AS culumn_1,
  ROW_NUMBER () OVER (PARTITION BY customer_id ORDER BY payment_date) AS culumn_2,
  sum(amount) OVER (PARTITION BY customer_id ORDER BY payment_date, amount desc) AS culumn_3,
  DENSE_RANK() over (partition by customer_id order by amount desc) AS culumn_4
FROM payment
order by customer_id;

--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.

SELECT p.customer_id, p.payment_id, p.payment_date, p.amount,
  LAG(amount, 1, 0.00) OVER (PARTITION BY customer_id ORDER BY payment_date ) AS last_amount
FROM payment p;

--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.

SELECT p.customer_id, p.payment_id, p.payment_date, p.amount,
  p.amount - LEAD (amount, 1, 0.00) OVER (PARTITION BY customer_id ORDER BY payment_date ) AS differebce
FROM payment p;

--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

SELECT DISTINCT c.customer_id, 
  FIRST_VALUE(p.payment_id) OVER (PARTITION BY c.customer_id ORDER BY p.payment_id DESC),
  max(p.payment_date) OVER (PARTITION BY c.customer_id ORDER BY p.payment_id DESC), 
  FIRST_VALUE(p.amount) OVER (PARTITION BY c.customer_id ORDER BY p.payment_id DESC) 
FROM customer c JOIN payment p ON c.customer_id = p.customer_id
ORDER BY c.customer_id;

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.

SELECT staff_id, (payment_date)::date, sum(amount) AS sum_amount,
  sum(sum(amount)) OVER (PARTITION BY staff_id ORDER BY payment_date::date) AS sum
FROM payment p
WHERE payment_date::date BETWEEN '2005-08-01' AND '2005-08-31'
GROUP BY staff_id, payment_date::date;

--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку

SELECT customer_id, payment_date, payment_number
FROM (
  SELECT customer_id, payment_date, 
    ROW_NUMBER () OVER (ORDER BY payment_id) AS payment_number
  FROM payment
  WHERE payment_date::date = '2005-08-20' ) payn
WHERE payment_number % 100 = 0;

--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм






