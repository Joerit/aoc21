create or replace function run2() returns float
as $$
declare
    pos int := 0;
    depth int := 0;
    aim int := 0;
    cur cursor for 
        select * from input;      
begin
    for instr in cur loop    
        if instr.cmd = 'forward' then
            pos := pos + instr.arg; 
            depth := depth + (instr.arg * aim);
        elsif instr.cmd = 'up' then
            aim := aim - instr.arg;
        elsif instr.cmd = 'down' then
            aim := aim + instr.arg;
        end if;
    end loop;

    return pos * depth;                        
end; $$
language plpgsql;

select run2();

