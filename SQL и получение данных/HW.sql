--Приложение №2
--Вопрос 1. В каких городах больше одного аэропорта? 
--В решении обязательно должно быть использовано __

--выбираем города и считаем количество аэропортов.
--группируем данные по городам.
--выбираем города в которых больше 1 аэропорта.
SELECT a.city AS "Город", count(a.airport_code) AS "Кол-во аэропортов" 
FROM airports a 
GROUP BY a.city 
HAVING count(a.airport_code) > 1;

--Вопрос 2. В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета? 
--В решении обязательно должно быть использовано - Подзапрос

--джоиним таблицу аэропорт к рейсам
--выбираем название аэропорта из т.аэропорты и номер рейса из т.рейсы
--фильтруем по условию в подзапросе
--подзапрос - выбираем код самолета из таблицы самолеты с сортировкой по макс дальности, вывести 1 запись.
SELECT DISTINCT a.airport_name AS "Аэропорт", f.flight_no AS "Рейс" 
FROM flights f RIGHT JOIN airports a ON f.departure_airport = a.airport_code 
WHERE f.aircraft_code = (
  SELECT ai.aircraft_code
  FROM aircrafts ai 
  ORDER BY ai."range" desc
  LIMIT 1
);
  
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

--Вопрос 5. Найдите количество свободных мест для каждого рейса, их % отношение к общему количеству мест в самолете.
--Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта 
--на каждый день. Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного 
--аэропорта на этом или более ранних рейсах в течении дня.
--В решении обязательно должно быть использовано - Оконная функция, Подзапросы или/и cte

--СТЕ max_seat считаем общее количество мест в самелете
--СТЕ boarding  считаем занятые места в самелета на каждом рейсе, с условием только вылетевшие рейсы
--джоиним два СТЕ
--в основном запросе считаем :
--дату приводим к формату гггг-мм-дд
--количество свободных мест математически
--долю свободных мест
--для подсчета количества пассажиров вылетивших в день считаем через оконную фонкцию
-- фильтруем данные по 2, 3 и 1 полю

WITH max_seat AS (
 SELECT aircraft_code, count(seat_no) AS max_seat
 FROM seats s 
 GROUP BY aircraft_code
),
boarding AS (
 SELECT f.flight_no, f.departure_airport, f.arrival_airport, count(bp.boarding_no) AS "boarding_seat", f.aircraft_code, f.actual_departure 
 FROM flights f JOIN boarding_passes bp ON f.flight_id = bp.flight_id
 WHERE f.actual_departure IS NOT NULL
 GROUP BY f.flight_id
)
SELECT bo.flight_no AS "Номер рейса", 
 bo.departure_airport AS "Аэропорт вылета", 
 bo.actual_departure::date AS "Дата вылета",
 bo.arrival_airport AS "Аэропорт прилета", 
 bo.aircraft_code AS "Код самолета", 
 bo.boarding_seat AS "Кол-во занятых мест на рейсе", 
 ms.max_seat AS "Кол-во мест в самелете всего",
 ms.max_seat - bo.boarding_seat AS "Кол-во свободных мест", 
 round((ms.max_seat - bo.boarding_seat) / ms.max_seat :: dec * 100, 2) AS "Доля свободных мест, %",
 sum(bo.boarding_seat) OVER (PARTITION BY (bo.departure_airport, bo.actual_departure::date) ORDER BY bo.actual_departure) AS "Кол-во пасажиров вылет. за день"
FROM boarding bo JOIN max_seat ms ON bo.aircraft_code = ms.aircraft_code
ORDER BY bo.departure_airport, bo.actual_departure, bo.flight_no; 

--Вопрос 6. Найдите процентное соотношение перелетов по типам самолетов от общего количества.
--В решении обязательно должно быть использовано -  Подзапрос или окно, Оператор ROUND

--Подзапросом считаем общее количество перелетов
--считаем доля от перелетов по моделям, условие только выполненые рейсы
--группируем по моделям. 
SELECT a.model, 
 count(f.flight_id) AS "общее количество рейсов", 
 round(count(f.flight_id) / 
  (SELECT count(f2.flight_id) 
   FROM flights f2 
   WHERE f2.actual_departure IS NOT NULL
   )::dec * 100, 4) AS "Доля от тотала"
FROM aircrafts a JOIN flights f ON a.aircraft_code = f.aircraft_code 
WHERE f.actual_departure IS NOT NULL 
GROUP BY a.model;

--Вопрос 7. Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
--В решении обязательно должно быть использовано - CTE

--СТЕ формируем по данным перелета, аэропорта вылета и прилета, с условем если перелет не эконом сумма полета становится отрицательной
--основной запрос, группировка с условием если сумма перелета более 0
WITH price AS (
 SELECT DISTINCT tf.flight_id, f.departure_airport, f.arrival_airport, tf.fare_conditions,
  CASE WHEN tf.fare_conditions ='Economy'
   THEN tf.amount 
   ELSE -tf.amount 
   END amount 
 FROM ticket_flights tf JOIN flights f ON tf.flight_id = f.flight_id
)
SELECT p.flight_id AS "id рейса", p.departure_airport AS "Аэропорт вылета", p.arrival_airport AS "Аэропорт прилета", sum(p.amount) AS "Бизнес меньше на"
FROM price p
GROUP BY p.flight_id, p.departure_airport, p.arrival_airport
HAVING sum(p.amount) > 0;

--Вопрос 8. Между какими городами нет прямых рейсов?
--В решении обязательно должно быть использовано - Декартово произведение в предложении FROM
--Самостоятельно созданные представления (если облачное подключение, то без представления)
--Оператор EXCEPT

--Вопрос 9. Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов 
-- в самолетах, обслуживающих эти рейсы *
--В решении обязательно должно быть использовано - - Оператор RADIANS или использование sind/cosd, CASE 

--собираем данные с рейсы и аэропорт.
--подтягиваем данные по координатам отправления и прилета.
--расчитываем дальность полета по формуле из итогового задания
--условием проставляем данные по дальности полета
SELECT DISTINCT f.departure_airport AS "Аэропорт вылета", f.arrival_airport AS "Аэропорт прилета", a."range" AS "Дальность полета самолета", 
 round((acos(sind(a2.latitude) * sind(a3.latitude) + cosd(a2.latitude) * cosd(a3.latitude) * cosd(a2.longitude - a3.longitude)) * 6371)::dec, 2) AS "Дальность рейса",
  CASE WHEN a."range" < round((acos(sind(a2.latitude) * sind(a3.latitude) + cosd(a2.latitude) * cosd(a3.latitude) * cosd(a2.longitude - a3.longitude)) * 6371)::dec, 2)
   THEN 'Дальность меньше'
   ELSE 'Дальность больше'
   END "Дальность полета"
FROM flights f JOIN airports a2 ON f.departure_airport = a2.airport_code 
JOIN airports a3 ON f.arrival_airport  = a3.airport_code 
JOIN aircrafts a ON f.aircraft_code = a.aircraft_code;

