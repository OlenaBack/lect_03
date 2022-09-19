/*
 Завдання на SQL до лекції 02.
 */


/*
1.
Вивести кількість фільмів в кожній категорії.
Результат відсортувати за спаданням.
*/
with filmCountByFilmCategory(category_id, film_count) as
         (select category_id,
                 count(*) as film_count
          from film_category
          group by category_id)

select c.name, s.film_count
from filmCountByFilmCategory as s
         left join category as c on s.category_id = c.category_id
order by s.film_count desc




/*
2.
Вивести 10 акторів, чиї фільми брали на прокат найбільше.
Результат відсортувати за спаданням.
*/
with filmRentCount (film_id, rent_count) as
         (select i.film_id, count(*) as rent_count
          from rental r
                   join inventory i on i.inventory_id = r.inventory_id
          group by i.film_id),
     actorsFilmRentCount (actor_id, films_rent_count) as
         (select actor_id, sum(frc.rent_count) as film_rent_count
          from film_actor fa
                   join filmRentCount frc on fa.film_id = frc.film_id
          group by actor_id)

select a.first_name, a.last_name, ar.films_rent_count
from actorsFilmRentCount as ar
         join actor as a on ar.actor_id = a.actor_id
order by films_rent_count desc
limit 10



/*
3.
Вивести категорія фільмів, на яку було витрачено найбільше грошей
в прокаті
*/
with amountPerInventory(inventory_id, inventory_rent_amount) as
         (select r.inventory_id, sum(p.amount)
          from payment p
                   join rental r on p.rental_id = r.rental_id
          group by r.inventory_id),
     amountPerFilm(film_id, film_rent_amount) as
         (select film_id, sum(a.inventory_rent_amount)
          from amountPerInventory a
                   join inventory i on a.inventory_id = i.inventory_id
          group by i.film_id),
     amountPerCategory(category_id, category_rent_amount) as
         (select fc.category_id, sum(a.film_rent_amount)
          from amountPerFilm a
                   join film_category fc on a.film_id = fc.film_id
          group by fc.category_id),
     categoryWithBiggestAmount(category_id, category_rent_amount) as
         (select * from amountPerCategory order by category_rent_amount desc limit 1)

select c.name
from categoryWithBiggestAmount a
         join category c on a.category_id = c.category_id


/*
4.
Вивести назви фільмів, яких не має в inventory.
Запит має бути без оператора IN
*/
select f.title
from film f
         left join inventory i on f.film_id = i.film_id
where i.film_id is NULL




/*
5.
Вивести топ 3 актори, які найбільше зʼявлялись в категорії фільмів “Children”.
*/
with childrenFilm(film_id) as
         (select film_id
          from film_category f
                   join category c on f.category_id = c.category_id
          where c.name = 'Children'),
     actorsInChildrenFilm (actor_id, film_count) as
         (select fa.actor_id, count(*) as film_count
          from film_actor fa
                   join childrenFilm cf on fa.film_id = cf.film_id
          group by fa.actor_id)

select first_name || ' ' || last_name as actor_name
from actorsInChildrenFilm af
         join actor a on af.actor_id = a.actor_id
order by af.film_count desc
limit 3


/*
6.
Вивести міста з кількістю активних та неактивних клієнтів
(в активних customer.active = 1).
Результат відсортувати за кількістю неактивних клієнтів за спаданням.
*/
with customerCityWithActivity (customer_id, active, city_id) as
         (select c.customer_id, c.active, a.city_id
          from customer c
                   inner join address a on c.address_id = a.address_id),
     cityActivity(city_id, active, inactive) as
         (select city_id,
                 COUNT(CASE WHEN active = 1 THEN 1 END) as active,
                 COUNT(CASE WHEN active = 0 THEN 1 END) as inactive
          from customerCityWithActivity
          group by city_id)
select c.city, active, inactive
from cityActivity cA
         join city c on ca.city_id = c.city_id
order by inactive desc, city


