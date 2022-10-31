create or replace function dohvati_broj_podudaranja(text, text) returns table (broj_podudaranja bigint) 
as $$
declare
	lijeva_strana varchar[] := string_to_array($1, ' ');
	duljina_lijeve_strane int := array_length(lijeva_strana, 1);
	desna_strana varchar[] := string_to_array($2, ' ');
	duljina_desne_strane int := array_length(desna_strana, 1);
	string_za_select text := 'SELECT count(*) FROM pocetna_tablica t1, pocetna_tablica t2 WHERE concat(';
	i int;
	y int;
begin
	--npr. SELECT count(*) FROM pocetna_tablica t1, pocetna_tablica t2 WHERE concat(t1.a, t1.b)=concat(t2.a, t2.b) and concat(t1.c, t1.d)<>concat(t2.c, t2.d);
	for j in 1..duljina_lijeve_strane-1 loop
		string_za_select := concat(string_za_select, 't1.', lijeva_strana[j], ', ');
	end loop;
	string_za_select := concat(string_za_select, 't1.', lijeva_strana[duljina_lijeve_strane], ')=concat(');
	for j in 1..duljina_lijeve_strane-1 loop
		string_za_select := concat(string_za_select, 't2.', lijeva_strana[j], ', ');
	end loop;
		string_za_select := concat(string_za_select, 't2.', lijeva_strana[duljina_lijeve_strane], ') and concat(');
	for j in 1..duljina_desne_strane-1 loop
		string_za_select := concat(string_za_select, 't1.', desna_strana[j], ', ');
	end loop;
		string_za_select := concat(string_za_select, 't1.', desna_strana[duljina_desne_strane], ')<>concat(');
	for j in 1..duljina_desne_strane-1 loop
		string_za_select := concat(string_za_select, 't2.', desna_strana[j], ', ');
	end loop;
		string_za_select := concat(string_za_select, 't2.', desna_strana[duljina_desne_strane], ');');
   	return query execute string_za_select;
end $$
language plpgsql;

select dohvati_broj_podudaranja('b', 'c');

