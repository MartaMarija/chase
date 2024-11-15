CREATE OR REPLACE FUNCTION public.chasealgO(TEXT[], TEXT[][], TEXT[][], TEXT[][], TEXT[], TEXT) RETURNS INT 
AS $$
DECLARE 
	broj_atributa int := array_length($1, 1);
	dekompozicije text[];
begin
	perform napravi_pocetnu_tablicu($1);
	case 
		when $6 = 'FZ' then
			dekompozicije[1] := $5[1]; --X
			dekompozicije[2] := $1;    --R
		when $6 = 'VZ' then
			dekompozicije[1] := concat($5[1], ' ', $5[2]);									 --XY
			dekompozicije[2] := vrati_drugu_dekompoziciju_viseznacne_zavisnosti($1, $5[2]);  --X U (R-XY)
		when $6 = 'ZS' then
			dekompozicije := $5;
	end case;
	perform popuni_pocetnu_tablicu($1, dekompozicije);
	perform provjeri_funkcijske_zavisnosti($2);
	--provjera VZ
	/*--broj_VZ := array_length($3, 1);
	for i in 1..broj_VZ loop
		a := concat($3[i][1],' ', $3[i][2]);
		b := '';
		desna_strana := string_to_array($3[i][2], ' ');
		duljina_ds := array_length(desna_strana, 1);
		ne_sadrzi := true;
		for j in 1..brojAtributa loop
			ne_sadrzi := true;
			for k in 1..duljina_ds loop
				if $1[j] = desna_strana[k] then
					ne_sadrzi := false;
				end if;
			end loop;
			if ne_sadrzi = true then
				b := concat(b, ' ', $1[j]);
			end if;
		end loop;
		
	end loop;
	raise notice 'b: % --- a: %', b, a;*/
	return broj_atributa;
END $$
LANGUAGE plpgsql;
select chasealgO(ARRAY ['a','b','c','d','e'], array[['b','c'],['a b c','d e']], array[['a c','b']], array[['a b', 'c', 'b d']], array['a b','a b','c','e'], 'ZS');


select chasealgO(ARRAY ['a','b','c','d','e'], array[['a b','c'],['c','d']], array[['a c','b']], array[['a b', 'c', 'b d']], array['a b','a b','c'], 'ZS');
select chasealgO(ARRAY ['a','b','c','d','e'], array[['a b','c']], array[['a c','b']], array[['a b', 'c', 'b d']], array['a b','c'], 'VZ');
select chasealgO(ARRAY ['a','b','c','d','e'], array[['a b','c']], array[['a c','b']], array[['a b', 'c', 'b d']], array['b','c'], 'FZ');

    				--raise notice 'cnt: %', cnt;