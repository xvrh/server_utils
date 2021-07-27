

--# !findUser
select * from app_user where id = :id::int;

--# !findUserByEmail
select * from app_user where email = :email::text;

--# *queryBy
select * from app_user where email = :email::text;

--# ?findUserByEmail
select * from app_user where email = :email::text;