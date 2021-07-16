

--# -findUser
select * from app_user where id = :id;

--# -findUserByEmail
select * from app_user where email = :email;

--# *query
select * from app_user where email = :email;

--# findUserByEmail
select * from app_user where email = :email;