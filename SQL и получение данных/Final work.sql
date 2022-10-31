
--3.Вывести общую сумму продаж по каждому классу билетов

--джойним перелеты к рейсы , к полученной таблице билеты, к полученной таблице бронирования
--выбираем класс перелета и считаем сумму по обороту
--и группируем по классу перелета


SELECT tf.fare_conditions AS "Клас перелета", sum(tf.amount) AS "Оборот", sum(sum(tf.amount)) OVER () AS "тотал оборот" -- тотал оборот 20 766 980 900.00
FROM flights f  RIGHT JOIN ticket_flights tf ON f.flight_id = tf.flight_id 
JOIN tickets t ON tf.ticket_no = t.ticket_no 
JOIN bookings b ON t.book_ref = b.book_ref 
GROUP BY tf.fare_conditions;

--4.Найти маршрут с наибольшим финансовым оборотом

-- джойним  перелеты к рейсы, к полученной таблицу билеты, далее бронирования, для отображения наименования перелета джойним так же информацию по аэропортам
--выбираем рейс, аэропорт вылета, аэропорт прилета и сумму по обороту из таблицы перелеты.
--группируем по рейса, аэропорт вылета и прилета.
--сортируем по сумме оборота по убыварнию
--выбираем только первую строку с максимальным оборотом. 

SELECT f.flight_no AS "Рейс", a.airport_name AS "Аэропорт вылета", a2.airport_name AS "Аэропорт прилета", sum(tf.amount) AS "Оборот"
FROM flights f RIGHT JOIN ticket_flights tf ON f.flight_id = tf.flight_id 
JOIN tickets t ON tf.ticket_no = t.ticket_no 
JOIN bookings b ON t.book_ref = b.book_ref 
JOIN airports a ON f.departure_airport = a.airport_code 
JOIN airports a2 ON f.arrival_airport = a2.airport_code 
GROUP BY f.flight_no, a.airport_name, a2.airport_name 
ORDER BY 4 DESC 
LIMIT 1;

--6.Между какими городами пассажиры не делали пересадки? Пересадкой считается нахождение пассажира в промежуточном аэропорту менее 24 часов.

--создаем cte из таблиц билеты, перелеты и рейсы
--соединяем сте между собой, для того, чтобы можно было расчитать промежуточное время.
--ВЫБИРАЕМ ТОЛЬКО АЭРОПОРТ ОТПРАВЛЕНИЯ И АЭРОПОРТ ПРИЛЕТА
--присоединяем данные по аэропортам
--прописываем условие отбора через И
-- 1.аэропорт прилета должен быть равен аэропорту отправления 
-- 2. аэропорт отправления не равен аэропорту прилета в рамках перелета А-Б-А.
--3. перем перелеты которые удовлетворятю условию находжения в аэропорту менее 24 часов, а именно от 0 часов до 24 часов.
--сортируем по полю один и два, чтобы убедиться что в отбор по пали тольок уникальные значения 

WITH cte_date AS (
 SELECT  t.passenger_name, t.ticket_no, f.departure_airport, f.arrival_airport, f.scheduled_departure, f.scheduled_arrival
 FROM tickets t JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
 JOIN flights f ON tf.flight_id = f.flight_id
)
SELECT DISTINCT a1.city AS "Аэропорт отправления", a2.city AS "Аэропорт прилета"
FROM cte_date cd1 JOIN cte_date cd2 ON cd1.ticket_no = cd2.ticket_no
JOIN airports a1 ON cd1.departure_airport = a1.airport_code 
JOIN airports a2 ON cd2.arrival_airport = a2.airport_code
WHERE cd1.arrival_airport = cd2.departure_airport AND a1.city <> a2.city 
 AND cd2.scheduled_departure - cd1.scheduled_arrival BETWEEN INTERVAL '0' HOUR AND INTERVAL '24' HOUR
ORDER BY 1, 2;