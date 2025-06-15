-- PART A 
-- QUESTION-1.

with deposit_slots as (
    select `user id`,
        sum(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-02 00:00:00' and '2022-10-02 23:59:59' then amount else 0 end) as deposit_s1,
        count(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-02 00:00:00' and '2022-10-02 23:59:59' then 1 end) as deposit_count_s1,

        sum(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-16 00:00:00' and '2022-10-16 23:59:59' then amount else 0 end) as deposit_s2,
        count(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-16 00:00:00' and '2022-10-16 23:59:59' then 1 end) as deposit_count_s2,

        sum(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-18 00:00:00' and '2022-10-18 23:59:59' then amount else 0 end) as deposit_s3,
        count(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-18 00:00:00' and '2022-10-18 23:59:59' then 1 end) as deposit_count_s3,

        sum(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-26 00:00:00' and '2022-10-26 23:59:59' then amount else 0 end) as deposit_s4,
        count(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-26 00:00:00' and '2022-10-26 23:59:59' then 1 end) as deposit_count_s4
    from deposit
    group by `user id`
),
withdrawal_slots as (
    select `user id`,
        sum(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-02 00:00:00' and '2022-10-02 23:59:59' then amount else 0 end) as withdrawal_s1,
        count(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-02 00:00:00' and '2022-10-02 23:59:59' then 1 end) as withdrawal_count_s1,

        sum(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-16 00:00:00' and '2022-10-16 23:59:59' then amount else 0 end) as withdrawal_s2,
        count(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-16 00:00:00' and '2022-10-16 23:59:59' then 1 end) as withdrawal_count_s2,

        sum(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-24 00:00:00' and '2022-10-24 23:59:59' then amount else 0 end) as withdrawal_s3,
        count(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-24 00:00:00' and '2022-10-24 23:59:59' then 1 end) as withdrawal_count_s3,

        sum(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-26 00:00:00' and '2022-10-26 23:59:59' then amount else 0 end) as withdrawal_s4,
        count(case when str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-26 00:00:00' and '2022-10-26 23:59:59' then 1 end) as withdrawal_count_s4
    from withdrawal
    group by `user id`
),
games_oct as (
    select `user id`, sum(`games played`) as total_games
    from user
    where str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-01 00:00:00' and '2022-10-31 23:59:59'
    group by `user id`
)

select
    u.`user id`,

    round(0.01 * d.deposit_s1 + 0.005 * w.withdrawal_s1 + 
          0.001 * greatest(d.deposit_count_s1 - w.withdrawal_count_s1, 0) +
          0.2 * g.total_games, 3) as loyalty_s1,

    round(0.01 * d.deposit_s2 + 0.005 * w.withdrawal_s2+ 
          0.001 * greatest(d.deposit_count_s2 - w.withdrawal_count_s2, 0) +
          0.2 * g.total_games, 3) AS loyalty_s2,

    round(0.01 * d.deposit_s3 + 0.005 * w.withdrawal_s3 + 
          0.001 * greatest(d.deposit_count_s3 - w.withdrawal_count_s3, 0) +
          0.2 * g.total_games, 3) AS loyalty_s3,

    round(0.01 * d.deposit_s4 + 0.005 * w.withdrawal_s4 + 
          0.001 * greatest(d.deposit_count_s4 - w.withdrawal_count_s4, 0) +
          0.2 * g.total_games, 3) AS loyalty_s4

from (select distinct `user id` from user) u
left join deposit_slots d on u.`user id` = d.`user id`
left join  withdrawal_slots w on u.`user id` = w.`user id`
left join  games_oct g on u.`user id` = g.`user id`
order by loyalty_s1 desc;



-- QUESTION-2.

with deposit_oct as(
	select `user id`,sum(amount) as total_deposit, count(*) as deposit_count 
    from deposit
    where str_to_date(datetime,'%e/%m/%Y %H:%i') between '2022-10-01 00:00:00' and '2022-10-31 23:59:59'
    group by `user id`

),
withdrawal_oct as(
	select `user id`, sum(amount) as total_withdrawal,count(*) as withdrawal_count
    from withdrawal 
    where str_to_date(datetime,'%e/%m/%Y %H:%i') between '2022-10-01 00:00:00' and '2022-10-31 23:59:59'
    group by `user id`

),
games_oct as(
	select `user id`,sum(`games played`) as total_games
    from user 
    where str_to_date(datetime,'%e/%m/%Y %H:%i') between '2022-10-01 00:00:00' and '2022-10-31 23:59:59'
    group by `user id`

)
select u.`user id`,d.total_deposit,w.total_withdrawal,g.total_games,
round(
	0.001*d.total_deposit+ 0.005*w.total_withdrawal
    + 0.001* greatest(d.deposit_count-w.withdrawal_count,0)
    + 0.2*g.total_games
    ,3 ) as loyalty_points ,
    rank() over (order by round(
	0.001*d.total_deposit+ 0.005*w.total_withdrawal
  + 0.001* greatest(d.deposit_count-w.withdrawal_count,0)
  + 0.2*g.total_games, 3) desc) as rank_no

from (select distinct `user id` from user) u
left join deposit_oct d on u.`user id` = d.`user id`
left join withdrawal_oct w on u.`user id`=w.`user id`
left join games_oct g on u.`user id`=g.`user id`;


-- QUESTION-3

select  round(avg(amount), 2) as avg_deposit_amount
from deposit;

-- QUESTION-4

with played_games as (
    select `user id`, sum(`games played`) as games
    from user
    group by `user id`
)
select avg(games) as avg_games_played_per_user from played_games;

-- QUESTION-5

with oct_month as(
    select `user id`, sum(amount) as user_total
    from deposit
    where str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-01 00:00:00' and '2022-10-31 23:59:59'
    group by `user id`)
select avg(user_total) as avg_deposit_per_user from oct_month;
