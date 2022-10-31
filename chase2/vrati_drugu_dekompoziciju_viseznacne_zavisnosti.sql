create or replace function vrati_drugu_dekompoziciju_viseznacne_zavisnosti(text[], text) returns text 
as $$
declare
	brojAtributa int := array_length($1, 1);
	dekompozicija_polje text[];
	dekompozicija text := '';
	duljina_dekompozicija_polje int;
	sadrzi boolean := false;
	i int;
	j int;
begin 
	dekompozicija_polje := string_to_array($2, ' ');
	duljina_dekompozicija_polje := array_length(dekompozicija_polje, 1);
	for i in 1..brojAtributa loop
		sadrzi := false;
		for j in 1..duljina_dekompozicija_polje loop
			if $1[i] = dekompozicija_polje[j] then
				sadrzi := true;
			end if;
		end loop;
		if sadrzi = false and length(dekompozicija) = 0  then
		  	dekompozicija := $1[i];
		elsif sadrzi = false then
		  	dekompozicija := concat(dekompozicija, ' ', $1[i]);
		end if;
	end loop;
	return dekompozicija;
end $$
language 'plpgsql';

select druga_dekompozicija_viseznacne_zavisnosti(array['a','b','c'], 'a');

