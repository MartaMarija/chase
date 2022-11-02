BEGIN;

DROP FUNCTION dohvati_broj_cr(text[]), dohvati_broj_cs(text), izvrsi_modifikacije_temeljem_zavisnosti_spoja(text[]),
dohvati_broj_podudaranja(text, text), vrati_skup_atributa(text[], text), dohvati_lijevu_stranu_char(text, text),
dohvati_lijevu_stranu_text(text, text), izvrsi_modifikacije_temeljem_funkcijske_zavisnosti(text, text, text),
popuni_pocetnu_tablicu(text[], text[]), vrati_drugu_dekompoziciju_viseznacne_zavisnosti(text[], text),
napravi_pocetnu_tablicu(text[]), provjeri_viseznacne_zavisnosti(text[], text[]),
provjeri_funkcijske_zavisnosti(text[]), chase_algoritam(text[], text[], text[], text[], text[], text);

DROP TABLE pocetna_tablica;

COMMIT;
