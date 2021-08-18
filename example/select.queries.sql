--GENERATE: extension SelectQueries

--# findUser -> !
select * from app_user where id = :id::int;

--# findUserByEmail -> !
select * from app_user where email = :email::text;

--# queryByCountry
select * from app_user where country_code = :country::text;

--# allNames
select first_name from app_user;