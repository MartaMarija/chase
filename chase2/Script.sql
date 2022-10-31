
CREATE OR REPLACE FUNCTION public.test() RETURNS varchar 
AS $$
DECLARE 
	slovo varchar;
	aba varchar;
	s varchar;
begin
	slovo := 'a b';
	--foreach s in array slovo loop
	--	aba := concat(aba, s);
	--end loop;
	
   	return slovo[1];
END $$
LANGUAGE plpgsql;
SELECT * from pocetna_tablica r1, pocetna_tablica r2 where concat(r1.A, r1.B)=concat(r2.A, r2.B) and concat(r1.C, r1.d) <> concat(r2.C, r2.d);
select test();

drop function test();

SELECT column_name
  FROM information_schema.columns
 WHERE table_schema = 'public'
   AND table_name   = 'pocetna_tablica'
     limit 1 offset 2;
   
insert into pocetna_tablica values ('1','2','C','D');

SELECT id FROM TAG_TABLE WHERE 'aaaaaaaa' LIKE '%' || tag_name || '%';

