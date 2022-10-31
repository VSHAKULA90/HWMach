--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

SELECT CONCAT(customer.last_name,' ', customer.first_name) AS "Customer name", address.address, city.city, country.country 
FROM customer JOIN address ON customer.address_id = address.address_id 
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id;



--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

SELECT store.store_id AS "ID магазина", count(DISTINCT customer.customer_id) AS "Количество магазинов"
FROM store JOIN customer ON store.store_id = customer.store_id 
GROUP BY store.store_id;



--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

SELECT store.store_id AS "ID магазина", count(DISTINCT customer.customer_id) AS "Количество магазинов"
FROM store JOIN customer ON store.store_id = customer.store_id 
GROUP BY store.store_id
HAVING count(DISTINCT customer.customer_id) > '300'; 



-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

SELECT store.store_id AS "ID магазина", count( customer.customer_id) AS "Количество магазинов", city.city AS "Город", concat(staff.last_name,' ',staff.first_name) AS "Имя сотрудника" 
FROM customer JOIN store ON customer.store_id  = store.store_id
JOIN address ON address.address_id = store.address_id  
JOIN city ON city.city_id =address.city_id 
JOIN staff ON staff.staff_id  = store.manager_staff_id  
GROUP BY store.store_id, city.city_id, staff.staff_id  
HAVING count( customer.customer_id) > '300'; 



--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

SELECT DISTINCT(concat(c.last_name, ' ', c.first_name)) AS "Фамилия и имя покупателя", count(r.inventory_id) AS "Количество фильмов"
FROM customer c JOIN rental r  ON r.customer_id = c.customer_id 
GROUP BY c.customer_id  
ORDER BY count(r.inventory_id) DESC
LIMIT 5;



--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

SELECT DISTINCT (concat(c.last_name,' ', c.first_name)) AS "Фамилия и имя покупателя",
   count(r.inventory_id) AS "Количество фильмов", 
   round(sum(p.amount)) AS "Обшая стоимость платежей", 
   min(p.amount) AS "Минимальная стоимость платежа", 
   max(p.amount) AS "Максимальная стоимость платежа"  --перенес, а то очень длинная выборка
FROM customer c JOIN rental r ON r.customer_id = c.customer_id
JOIN payment p ON p.rental_id  = r.rental_id
GROUP BY c.customer_id;



--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.

--если есть ссылка на доп материал, скиньте при проверке.

SELECT c.city AS "Город 1", c2.city AS "Город 2"
FROM city c CROSS JOIN city c2
WHERE c != c2;



--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 

SELECT DISTINCT (customer_id) AS "ID покупателя", 
  round(avg(date_part('day', return_date-rental_date) + date_part('hour', return_date-rental_date)/24 + date_part('minute', return_date-rental_date)/1440)::NUMERIC, 2) AS "Среднее количество дней на возврат" 
FROM rental r 
GROUP BY customer_id 
ORDER BY customer_id;


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.


SELECT f.title AS "Название", f.rating AS "Рейтинг", c.name AS "Жанр", f.release_year AS "Год выпуска", 
l.name AS "Язык", COUNT(r.rental_id) AS "Количество аренд", SUM(p.amount) AS "Общая стоимость аренды"
FROM rental r 
JOIN inventory i ON r.inventory_id = i.inventory_id 
JOIN payment p ON r.rental_id = p.rental_id 
JOIN film f ON i.film_id = f.film_id 
JOIN language l ON f.language_id = l.language_id 
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id 
GROUP BY f.film_id, c.category_id, l.language_id;


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.

SELECT f.title AS "Название", f.rating AS "Рейтинг", c.name AS "Жанр", f.release_year AS "Год выпуска", 
l.name AS "Язык", COUNT(r.rental_id) AS "Количество аренд", SUM(p.amount) AS "Общая стоимость аренды"
FROM rental r 
JOIN inventory i ON r.inventory_id = i.inventory_id 
JOIN payment p ON r.rental_id = p.rental_id 
RIGHT JOIN film f ON i.film_id = f.film_id 
JOIN language l ON f.language_id = l.language_id 
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id 
GROUP BY f.film_id, c.category_id, l.language_id, r.rental_id 
HAVING count(r.rental_id) = 0



--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".



SELECT DISTINCT (s.staff_id), count(p.payment_id) AS "Количсетво продаж", 
  CASE 
    WHEN count(p.payment_id) > 7300 
    THEN 
      'Да'
  ELSE 
      'Нет'
  END AS "Премия"
FROM staff s JOIN payment p  ON s.staff_id = p.staff_id 
GROUP BY s.staff_id;


