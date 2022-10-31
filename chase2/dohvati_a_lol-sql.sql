CREATE OR REPLACE FUNCTION public.dohvati_lijevu_stranu(text, text) RETURNS table (lijeva_strana character varying(8)) 
AS $$
DECLARE 
	i int;
	y int;
	broj_FZ int;
	duljina_l int;
	duljina_d int;
	sadrzaj_l varchar[];
	sadrzaj_d varchar[];
	stringZaSelect varchar;
	lijevaStrana varchar;
begin
	sadrzaj_l := string_to_array($1, ' ');
	duljina_l := array_length(sadrzaj_l, 1);
	sadrzaj_d := string_to_array($2, ' ');
	duljina_d := array_length(sadrzaj_d, 1);
	--npr. SELECT count(*) FROM pocetna_tablica t1, pocetna_tablica t2 WHERE concat(t1.a, t1.b)=concat(t2.a, t2.b) and concat(t1.c, t1.d)<>concat(t2.c, t2.d);
	for j in 1..duljina_l-1 loop
		lijevaStrana := concat(lijevaStrana, 't1.',sadrzaj_l[j], ' || ');
	end loop;
	lijevaStrana := concat(lijevaStrana, 't1.',sadrzaj_l[duljina_l], ' ');

	stringZaSelect := concat('SELECT ', lijevaStrana,' as stupci FROM pocetna_tablica t1, pocetna_tablica t2 WHERE concat(');

	for j in 1..duljina_l-1 loop
		stringZaSelect := concat(stringZaSelect, 't1.', sadrzaj_l[j], ', ');
	end loop;
	stringZaSelect := concat(stringZaSelect, 't1.', sadrzaj_l[duljina_l], ')=concat(');
	for j in 1..duljina_l-1 loop
		stringZaSelect := concat(stringZaSelect, 't2.', sadrzaj_l[j], ', ');
	end loop;
		stringZaSelect := concat(stringZaSelect, 't2.', sadrzaj_l[duljina_l], ') and concat(');
	for j in 1..duljina_d-1 loop
		stringZaSelect := concat(stringZaSelect, 't1.', sadrzaj_d[j], ', ');
	end loop;
		stringZaSelect := concat(stringZaSelect, 't1.', sadrzaj_d[duljina_d], ')<>concat(');
	for j in 1..duljina_d-1 loop
		stringZaSelect := concat(stringZaSelect, 't2.', sadrzaj_d[j], ', ');
	end loop;
		stringZaSelect := concat(stringZaSelect, 't2.', sadrzaj_d[duljina_d], ') limit 1;');
	raise notice 'stringZaSelect: %', stringZaSelect;
   	RETURN QUERY execute stringZaSelect;
END $$
LANGUAGE plpgsql;

select dohvati_lijevu_stranu('b','c');
