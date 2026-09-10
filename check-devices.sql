-- Talaks — diagnostic. Reads only, changes nothing. Safe to run any time.
-- Supabase dashboard -> SQL Editor -> New query -> paste -> Run.
-- Send me the two tables it prints and I'll know exactly what's wrong.

-- ============================================================
-- CHECK 1: do the device IDs my pricing SQL targets actually exist?
-- If "matched" is less than 7, that's the problem: my UPDATE statements
-- are looking for rows that aren't there, so they silently do nothing.
-- ============================================================
select
  count(*) as rows_in_table,
  count(*) filter (
    where id in ('iphone-17','iphone-18-pro','iphone-18-pro-max','iphone-duo',
                 'galaxy-s26','galaxy-s26-plus','galaxy-s26-ultra')
  ) as matched_my_sql
from devices;


-- ============================================================
-- CHECK 2: what is actually in each row right now?
-- The "verdict" column says in plain words what's going on.
-- ============================================================
select
  id,
  name,
  colours->0->>'img' as first_image_path,

  case
    when colours::text ilike '%phantom-black%'
      then 'OLD IMAGE PATH -> the pricing SQL has not been applied. Run supabase-pricing-update.sql.'
    when colours::text ilike '%Samsung Galaxy%'
      then 'NEW IMAGE PATH -> database is fine. A missing photo means the FILE is not in the GitHub repo.'
    else 'Apple row (not part of the Samsung image issue)'
  end as image_verdict,

  case
    when care_terms is null
      then 'NO per-term insurance -> pricing SQL has not been applied to this row.'
    else 'Per-term insurance present: ' || care_terms::text
  end as insurance_verdict,

  -- what the customer actually sees as their monthly price, per term
  (select jsonb_object_agg(k, round(((storages->0->>'rrp')::numeric * v::numeric) / k::numeric, 2))
     from jsonb_each_text(terms) as t(k,v)) as monthly_price_shown

from devices
order by brand, name;


-- ============================================================
-- CHECK 3: does the devices table even have the care_terms column yet?
-- Expect one row. No rows = the ALTER TABLE at the top of the
-- pricing SQL never ran.
-- ============================================================
select column_name, data_type
from information_schema.columns
where table_name = 'devices' and column_name = 'care_terms';
