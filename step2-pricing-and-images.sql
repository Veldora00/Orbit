-- Talaks — pricing update from Milan's revenue sheets (Apple + Samsung), Sept 2026
-- STEP 2 of 2. Run step1-add-care-terms.sql FIRST, then run this whole file.
-- Safe to re-run; it only touches the 7 existing device rows.

-- 1. Damage Cover is now priced PER TERM (a 36-month plan has a cheaper monthly
--    cover price than a 12-month one), so it needs its own column.
--    The old care_monthly column is left in place as a fallback and is not dropped.
alter table devices add column if not exists care_terms jsonb;

-- 2. Subscription pricing + per-term Damage Cover, per device.
--    'terms' stays a % of RRP so the higher storage tiers price themselves;
--    each % below is the exact monthly $ from the sheet, divided back out.

-- iPhone 17 — $57/$41/$37 per month (12/24/36mo), cover $14/$11/$9.50
update devices set
  terms      = '{"12": 0.4889206576, "24": 0.7033595425, "36": 0.952108649}'::jsonb,
  care_terms = '{"12": 14, "24": 11, "36": 9.5}'::jsonb
where id = 'iphone-17';

-- iPhone 18 Pro — $105/$67/$58 per month, cover $17/$13/$10.50
update devices set
  terms      = '{"12": 0.6002858504, "24": 0.7660790853, "36": 0.9947594092}'::jsonb,
  care_terms = '{"12": 17, "24": 13, "36": 10.5}'::jsonb
where id = 'iphone-18-pro';

-- iPhone 18 Pro Max — $115/$75/$63 per month, cover $18/$14/$11
update devices set
  terms      = '{"12": 0.600260983, "24": 0.7829491083, "36": 0.9865158765}'::jsonb,
  care_terms = '{"12": 18, "24": 14, "36": 11}'::jsonb
where id = 'iphone-18-pro-max';

-- iPhone Duo — $204/$131/$92 per month, cover $20/$18/$16
update devices set
  terms      = '{"12": 0.6996284653, "24": 0.8985424407, "36": 0.9465561589}'::jsonb,
  care_terms = '{"12": 20, "24": 18, "36": 16}'::jsonb
where id = 'iphone-duo';

-- Galaxy S26 — $116/$59 per month (12/24mo only), cover $14/$12
update devices set
  terms      = '{"12": 0.8986442866, "24": 0.9141381536}'::jsonb,
  care_terms = '{"12": 14, "24": 12}'::jsonb
where id = 'galaxy-s26';

-- Galaxy S26 Plus — $139/$72 per month (12/24mo only), cover $14/$12
update devices set
  terms      = '{"12": 0.9021092482, "24": 0.9345592212}'::jsonb,
  care_terms = '{"12": 14, "24": 12}'::jsonb
where id = 'galaxy-s26-plus';

-- Galaxy S26 Ultra — $165/$85 per month (12/24mo only), cover $14/$12
update devices set
  terms      = '{"12": 0.9004092769, "24": 0.9276944065}'::jsonb,
  care_terms = '{"12": 14, "24": 12}'::jsonb
where id = 'galaxy-s26-ultra';

-- 3. Real Samsung photos (these files are now in the repo's images/ folder).
--    NOTE: the Ultra violet file is spelled 'Coblat Violet' in the zip you sent —
--    the path below matches the actual filename so the image loads. Rename both
--    the file and this path if you want the typo gone.

update devices set colours = '[{"name": "Black", "img": "images/Samsung Galaxy S26 Black.webp"}, {"name": "White", "img": "images/Samsung Galaxy S26 White.webp"}, {"name": "Sky Blue", "img": "images/Samsung Galaxy S26 Sky Blue.webp"}, {"name": "Cobalt Violet", "img": "images/Samsung Galaxy S26 Cobalt Violet.webp"}]'::jsonb where id = 'galaxy-s26';

update devices set colours = '[{"name": "Black", "img": "images/Samsung Galaxy S26 + Black.webp"}, {"name": "White", "img": "images/Samsung Galaxy S26 + White.webp"}, {"name": "Blue", "img": "images/Samsung Galaxy S26 + Blue.webp"}, {"name": "Cobalt Violet", "img": "images/Samsung Galaxy S26 + Cobalt Violet.webp"}]'::jsonb where id = 'galaxy-s26-plus';

update devices set colours = '[{"name": "Black", "img": "images/Samsung Galaxy S26 Ultra Black.webp"}, {"name": "White", "img": "images/Samsung Galaxy S26 Ultra White.webp"}, {"name": "Sky Blue", "img": "images/Samsung Galaxy S26 Ultra Sky Blue.webp"}, {"name": "Cobalt Violet", "img": "images/Samsung Galaxy S26 Ultra Coblat Violet.webp"}]'::jsonb where id = 'galaxy-s26-ultra';

-- 4. Check it worked — every row should show its monthly prices.
select id, name,
       (select jsonb_object_agg(k, round(((storages->0->>'rrp')::numeric * v::numeric) / k::numeric, 2))
          from jsonb_each_text(terms) as t(k,v)) as monthly_price,
       care_terms
from devices order by brand, name;
