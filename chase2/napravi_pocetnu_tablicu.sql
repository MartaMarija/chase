create or replace function napravi_pocetnu_tablicu(text[]) returns void
as $$
declare 
	brojAtributa int := array_length($1, 1);
	stringZaDodavanjeStupaca text;
	i int;
begin 
	raise notice '%',  $1[1]; 
	drop table if exists pocetna_tablica;
	create table pocetna_tablica();
	for i in 1..brojAtributa loop
		stringZaDodavanjeStupaca := concat('ALTER TABLE pocetna_tablica ADD COLUMN ', $1[i], ' varchar(3);');	
		execute stringZaDodavanjeStupaca;
	end loop;
end $$
language plpgsql;

select napravi_pocetnu_tablicu(array['a','b','c']);
