CREATE OR REPLACE FUNCTION public.chasealgO(TEXT[], TEXT[][], TEXT[][], TEXT[][], TEXT[], TEXT) RETURNS INT 
AS $$
DECLARE 
	--stvaranje tablice
	brojAtributa INT;
	brojac INT;
	--definiranje
	pom INT;
	broj_ZS INT;
	stupac varchar;
begin
	--stvaranje tablice
	drop table if exists pocetna_tablica;
	create table pocetna_tablica();
	brojAtributa := array_length($1, 1);
	brojac := 1;
	LOOP
	    EXIT WHEN brojac = brojAtributa + 1;
	   	EXECUTE 'ALTER TABLE pocetna_tablica ADD COLUMN ' || quote_ident($1[brojac]) || ' varchar(3);';
	    brojac := brojac + 1;
	END LOOP;
	--TEST insert into pocetna_tablica values ('1','2','C','D');
	--definiranje zavisnosti koju provjeravamo/pinjenje tablice
	case 
		when $6 = 'FZ' then
			pom := 1;
		when $6 = 'VZ' then
			pom := 2;
		when $6 = 'ZS' then
			broj_ZS := array_length($5, 1);
			for cnt in 1..broj_ZS loop
				for cnt in 0..brojAtributa-1 loop
    				raise notice 'cnt: %', cnt;
    			end loop;
   			end loop;
			
    --stupac := (SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'pocetna_tablica'
    			--limit 1 offset BROJ);		
	end case;
	--punjenje tablice
	raise notice 'broj_ZS: %', broj_ZS;
	return broj_ZS;
END $$
LANGUAGE plpgsql;

select chasealgO(ARRAY ['A','B','C','D'], array[['A','C']], array[['A','B']], array[['AB', 'C', 'BD']], array['ABC','BD'], 'ZS');

