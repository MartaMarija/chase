CREATE OR REPLACE FUNCTION public.dohvati_lijevu_stranu_text(text, text) RETURNS table (lijeva_strana2 text) 
AS $$
DECLARE 
	lijeva_strana varchar[] := string_to_array($1, ' ');
	duljina_lijeve_strane int := array_length(lijeva_strana, 1);
	desna_strana varchar[] := string_to_array($2, ' ');
	duljina_desne_strane int := array_length(desna_strana, 1);
	stringZaSelect varchar;
	stupci_lijeve_strane varchar := 'concat(';
	i int;
	y int;
begin
	--npr. SELECT count(*) FROM pocetna_tablica t1, pocetna_tablica t2 WHERE concat(t1.a, t1.b)=concat(t2.a, t2.b) and concat(t1.c, t1.d)<>concat(t2.c, t2.d);
	for j in 1..duljina_lijeve_strane-1 loop
		stupci_lijeve_strane := concat(stupci_lijeve_strane, 't1.',lijeva_strana[j], ', '' '', ');
	end loop;
	stupci_lijeve_strane := concat(stupci_lijeve_strane, 't1.',lijeva_strana[duljina_lijeve_strane], ') ');

	stringZaSelect := concat('SELECT DISTINCT ', stupci_lijeve_strane,' as stupci FROM pocetna_tablica t1, pocetna_tablica t2 WHERE concat(');

	for j in 1..duljina_lijeve_strane-1 loop
		stringZaSelect := concat(stringZaSelect, 't1.', lijeva_strana[j], ', ');
	end loop;
	stringZaSelect := concat(stringZaSelect, 't1.', lijeva_strana[duljina_lijeve_strane], ')=concat(');
	for j in 1..duljina_lijeve_strane-1 loop
		stringZaSelect := concat(stringZaSelect, 't2.', lijeva_strana[j], ', ');
	end loop;
		stringZaSelect := concat(stringZaSelect, 't2.', lijeva_strana[duljina_lijeve_strane], ') and concat(');
	for j in 1..duljina_desne_strane-1 loop
		stringZaSelect := concat(stringZaSelect, 't1.', desna_strana[j], ', ');
	end loop;
		stringZaSelect := concat(stringZaSelect, 't1.', desna_strana[duljina_desne_strane], ')<>concat(');
	for j in 1..duljina_desne_strane-1 loop
		stringZaSelect := concat(stringZaSelect, 't2.', desna_strana[j], ', ');
	end loop;
	stringZaSelect := concat(stringZaSelect, 't2.', desna_strana[duljina_desne_strane], ');');
	raise notice 'stringZaSelect: %', stringZaSelect;
   	RETURN QUERY execute stringZaSelect;
END $$
LANGUAGE plpgsql;

select dohvati_lijevu_stranu_text('a b', 'c');

CREATE OR REPLACE FUNCTION public.dohvati_lijevu_stranu_char(text, text) RETURNS table (lijeva_strana2 character varying) 
AS $$
DECLARE 
	lijeva_strana text := $1;
	desna_strana varchar[] := string_to_array($2, ' ');
	duljina_desne_strane int := array_length(desna_strana, 1);
	stringZaSelect varchar;
	i int;
	y int;
begin
	--npr. SELECT t1.a FROM pocetna_tablica t1, pocetna_tablica t2 WHERE t1.a=t2.a and concat(t1.c, t1.d)<>concat(t2.c, t2.d);
	stringZaSelect := concat('SELECT DISTINCT t1.', lijeva_strana,' FROM pocetna_tablica t1, pocetna_tablica t2 WHERE t1.', lijeva_strana, '=t2.', lijeva_strana, ' and concat(');
	for j in 1..duljina_desne_strane-1 loop
		stringZaSelect := concat(stringZaSelect, 't1.', desna_strana[j], ', ');
	end loop;
		stringZaSelect := concat(stringZaSelect, 't1.', desna_strana[duljina_desne_strane], ')<>concat(');
	for j in 1..duljina_desne_strane-1 loop
		stringZaSelect := concat(stringZaSelect, 't2.', desna_strana[j], ', ');
	end loop;
	stringZaSelect := concat(stringZaSelect, 't2.', desna_strana[duljina_desne_strane], ');');
	raise notice 'stringZaSelect: %', stringZaSelect;
   	RETURN QUERY execute stringZaSelect;
END $$
LANGUAGE plpgsql;

select dohvati_lijevu_stranu_char('b', 'c');

