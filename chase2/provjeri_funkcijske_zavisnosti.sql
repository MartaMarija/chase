CREATE OR REPLACE FUNCTION public.provjeri_funkcijske_zavisnosti(text[])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare 
	broj_funkcijskih_zavisnosti int := array_length($1, 1);
	i int;
	j int;
	lijeva_strana text;
	desna_strana text;
	simbol text;
	simboli text[];
begin 
	for i in 1..broj_funkcijskih_zavisnosti loop
		lijeva_strana := $1[i][1];
		desna_strana := $1[i][2];
		if (select broj_podudaranja from dohvati_broj_podudaranja(lijeva_strana, desna_strana)) <> 0 then
			simboli := '{}';
			if length(lijeva_strana) = 1 then
				FOR simbol in (select lijeva_strana2 from dohvati_lijevu_stranu_char(lijeva_strana, desna_strana)) LOOP
			    	simboli := array_append(simboli, simbol);
			    	raise notice '%', simboli;
			    END LOOP;
			else
				FOR simbol in (select lijeva_strana2 from dohvati_lijevu_stranu_text(lijeva_strana, desna_strana)) LOOP
			    	simboli := array_append(simboli, simbol);
			    	raise notice '%', simboli;
			    END LOOP;
			end if;
			for j in 1..array_length(simboli,1) loop
				PERFORM izvrsi_modifikacije_temeljem_funkcijske_zavisnosti(lijeva_strana, desna_strana, simboli[j]);
			end loop;
		end if;
	end loop;
end $function$
;


select chasealgO(ARRAY ['a','b','c','d','e'], array[['d','c']], array[['a c','b']], array[['a b', 'c', 'b d']], array['a b','a b','c'], 'ZS');
select provjeri_funkcijske_zavisnosti(array[['b', 'd']]);
select provjeri_funkcijske_zavisnosti(array[['a b', 'd']]);
select provjeri_funkcijske_zavisnosti(array[['b', 'd'],['a b','d']]);

