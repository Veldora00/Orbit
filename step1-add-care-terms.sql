-- STEP 1 of 2. Run this one first, on its own.
--
-- Supabase dashboard -> SQL Editor -> New query -> paste this -> Run.
-- It adds one column. It does not touch any of your existing data.
--
-- This is the column the admin panel is complaining about
-- ("Could not find the 'care_terms' column of 'devices'").
-- It holds the Damage Cover price for each term, e.g. {"12": 14, "24": 11, "36": 9.5}

alter table devices add column if not exists care_terms jsonb;


-- Confirm it worked. You should get exactly one row back: care_terms | jsonb
select column_name, data_type
from information_schema.columns
where table_name = 'devices' and column_name = 'care_terms';
