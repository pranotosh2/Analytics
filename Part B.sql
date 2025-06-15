-- PART B 

-- QUESTION-1


with deposit_oct as (
    select `user id`, sum(amount) as total_deposit, count(*) as deposit_count 
    from deposit
    where str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-01 00:00:00' and '2022-10-31 23:59:59'
    group by `user id`
),
withdrawal_oct as (
    select `user id`, sum(amount) as total_withdrawal, count(*) as withdrawal_count
    from withdrawal 
    where str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-01 00:00:00' and '2022-10-31 23:59:59'
    group by `user id`
),
games_oct as (
    select `user id`, sum(`games played`) as total_games
    from user 
    where str_to_date(datetime, '%e/%m/%Y %H:%i') between '2022-10-01 00:00:00' and '2022-10-31 23:59:59'
    group by `user id`
),
loyalty_ranked as (
    select 
        u.`user id`,
        d.total_deposit,
        w.total_withdrawal,
        g.total_games,
        round(
            0.01 * d.total_deposit + 
            0.005 * w.total_withdrawal +
            0.001 * greatest(d.deposit_count - w.withdrawal_count, 0) +
            0.2 * g.total_games, 
        3) as loyalty_points,
        rank() over (
            order by 
                round(
                    0.01 * d.total_deposit + 
                    0.005 * w.total_withdrawal +
                    0.001 * greatest(d.deposit_count - w.withdrawal_count, 0) +
                    0.2 * g.total_games, 
                3) desc
        ) as rank_no
    from (select distinct `user id` from user) u
    left join deposit_oct d on u.`user id` = d.`user id`
    left join withdrawal_oct w on u.`user id` = w.`user id`
    left join games_oct g on u.`user id` = g.`user id`
)
select 
    `user id`, 
    loyalty_points, 
    total_games,
    1000 as bonus_amount
from loyalty_ranked
order by rank_no limit 50;

