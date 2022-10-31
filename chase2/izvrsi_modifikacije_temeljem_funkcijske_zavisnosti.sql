create or replace function izvrsi_modifikacije_temeljem_funkcijske_zavisnosti(text, text, text) returns void
as $$
declare 
	lijeva_strana varchar[] := string_to_array($1, ' ');
	duljina_lijeve_strane int := array_length(lijeva_strana, 1);
	desna_strana varchar[] := string_to_array($2, ' ');
	duljina_desne_strane int := array_length(desna_strana, 1);
	string_za_where_uvjet text := 'WHERE ';
	string_za_update_redova text := 'UPDATE pocetna_tablica SET ';
	y int;
	simboli text[];
	--{"0 0"}{"0 0","31 32"}
	--{32}{32,0}
begin
	--update pocetna_tablica set c=(select c from pocetna_tablica where a='0' and b='0' order by c limit 1), d=(select d from pocetna_tablica where a='0' and b='0' order by d limit 1) where a='0' and b='0';
	if $3 like '% %' then
		simboli := string_to_array($3, ' ');
		for j in 1..duljina_lijeve_strane-1 loop
			string_za_where_uvjet := concat(string_za_where_uvjet, lijeva_strana[j], '=''', simboli[j], ''' and ');
		end loop;
		string_za_where_uvjet := concat(string_za_where_uvjet, lijeva_strana[duljina_lijeve_strane], '=''', simboli[duljina_lijeve_strane], '''');
	else
		for j in 1..duljina_lijeve_strane-1 loop
			string_za_where_uvjet := concat(string_za_where_uvjet, lijeva_strana[j], '=''', $3, ''' and ');
		end loop;
		string_za_where_uvjet := concat(string_za_where_uvjet, lijeva_strana[duljina_lijeve_strane], '=''', $3, '''');
	end if;
	for j in 1..duljina_desne_strane-1 loop
		string_za_update_redova := concat(string_za_update_redova, desna_strana[j], '=(SELECT ', desna_strana[j], ' FROM pocetna_tablica ', string_za_where_uvjet, ' ORDER BY ', desna_strana[j], '::int limit 1), ');
	end loop;
	string_za_update_redova := concat(string_za_update_redova, desna_strana[duljina_desne_strane], ' =(SELECT ', desna_strana[duljina_desne_strane], ' FROM pocetna_tablica ', string_za_where_uvjet, ' ORDER BY ', desna_strana[duljina_desne_strane], '::int limit 1) ', string_za_where_uvjet, ';');
	raise notice '%', string_za_update_redova;	
	execute string_za_update_redova;
end $$
language plpgsql;
