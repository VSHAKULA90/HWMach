--=============== МОДУЛЬ 2. РАБОТА С БАЗАМИ ДАННЫХ =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия городов из таблицы городов.

SELECT DISTINCT city
FROM city



--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
--названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.

SELECT DISTINCT city
FROM city
WHERE city LIKE 'L%' AND city LIKE '%a' AND city NOT LIKE '% %'



--ЗАДАНИЕ №3 
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.

--ПОПРАВИЛ
--МОЖНО так
SELECT payment_id, payment_date, amount
FROM payment
WHERE date(payment_date) BETWEEN '17-06-2005' AND '19-06-2005' AND amount > '1'
ORDER BY payment_date

--и так
SELECT payment_id, payment_date, amount
FROM payment
WHERE payment_date BETWEEN '17-06-2005' AND '19-06-2005'::date + INTERVAL '1 day' AND amount > '1'
ORDER BY payment_date


--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.

SELECT payment_id, payment_date, amount
FROM payment
ORDER BY payment_date DESC 
LIMIT 10



--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.

SELECT CONCAT (last_name,' ',first_name) AS "Фамилия и имя", email AS "Электронная почта", LENGTH(email) AS "Длина Email", DATE_TRUNC('DAY',last_update::DATE) AS "Дата"
FROM customer



--ЗАДАНИЕ №6
--Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
--Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.

--ПОПРАВИЛ
SELECT  LOWER(last_name), LOWER(first_name), active 
FROM customer
WHERE active = 1 AND (first_name = 'KELLY' OR first_name  = 'WILLIE')


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.

--ПОПРАВИЛ
SELECT film_id, title, description, rating, rental_rate 
FROM film
WHERE (rating = 'R' AND rental_rate BETWEEN 0 AND 3) OR (rating ='PG-13'AND rental_rate >=4)


--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.


SELECT film_id, title, description
FROM film
ORDER BY LENGTH(description) DESC
LIMIT 3


--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.


SELECT customer_id, email, split_part(email, '@', 1) AS "Email before @", split_part(email, '@', 2) AS "Email after @"
FROM customer


--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.

--ПОПРАВИЛ

SELECT customer_id, email, concat(upper(substring(split_part(email, '@', 1) FROM 1 FOR 1)), lower(substring(split_part(email, '@', 1) FROM 2))) AS "Email before @", concat(upper(substring(split_part(email, '@', 2) FROM 1 FOR 1)), lower(substring(split_part(email, '@', 2) FROM 2))) AS "Email after @"
FROM customer


