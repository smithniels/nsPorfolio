-- del.sql
-- I'd never thought of writting loops in SQL. I don't think I ever will need to, but here we are.

declare @int float
set @int = 0

While @int < 15
	begin
    set @int += 1.3
    print concat('Integer is currently at ', @int)
end
print('done')