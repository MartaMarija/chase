create or replace function popuni_pocetnu_tablicu(text[], text[]) returns void
as $$
declare 
	broj_atributa int := array_length($1, 1);
	broj_dekompozicija int := array_length($2, 1);
	stupac text;
	dekompozicija text;
	red text[];
	string_za_dodavanje text;
begin
	for i in 1..broj_dekompozicija loop
		for y in 0..broj_atributa-1 loop
			stupac := (SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'pocetna_tablica'
				limit 1 offset y);
			dekompozicija := $2[i];
			if dekompozicija like '%' || stupac || '%' then
				--red[y] := concat('a', y+1);
				red[y] := '0';
			else
				red[y] := concat(i, y+1);
			end if;
		end loop;
		string_za_dodavanje := 'INSERT INTO pocetna_tablica VALUES (';
		for y in 0..broj_atributa-2 loop	
			string_za_dodavanje := concat(string_za_dodavanje, '''', red[y], ''',');
		end loop;
		string_za_dodavanje := concat(string_za_dodavanje, '''', red[broj_atributa-1], ''');');
		execute string_za_dodavanje;
	end loop;
end $$
language 'plpgsql';