{% macro seed_orders() -%}
create temp table orders as
select * from (values
  (1, 'apac', '2026-07', 10.0, 'a', timestamp '2026-07-01 10:00:00'),
  (2, 'apac', '2026-08', 20.0, 'b', timestamp '2026-08-01 10:00:00'),
  (3, 'emea', '2026-08', 30.0, 'c', timestamp '2026-08-02 10:00:00'),
  (4, null,   '2026-07', 40.0, 'd', timestamp '2026-07-03 10:00:00'),
  (5, 'o''hare', '2026-08', 5.0, 'e', timestamp '2026-08-04 10:00:00')
) t(id, region, month, amount, "Note", _etl_ts);
{%- endmacro %}
