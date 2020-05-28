-- del.sql

declare @int float
set @int = 0

While @int < 15
	begin
    set @int += 1.3
    print concat('Integer is currently at ', @int)
end
print('done')