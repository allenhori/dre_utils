{#- A value as a SQL literal: strings quoted (with `'` doubled), numbers and booleans bare,
    none as `null`. With `quote_values=false`, the value goes in as it is. -#}
{% macro _literal(v, quote_values=true) -%}
{%- if v is none -%}null
{%- elif v is sameas true -%}true
{%- elif v is sameas false -%}false
{%- elif not quote_values or v is number -%}{{ v }}
{%- else -%}'{{ v | string | replace("'", "''") }}'
{%- endif -%}
{%- endmacro %}

{#- The query behind `column_values` and `pivot(relation=...)`: one row more than `max`, so
    too many values can be told apart from exactly `max`. -#}
{% macro _distinct_sql(relation, column, where=none, order_by=none, max=100) -%}
{#- `group by` rather than `distinct`, so `order_by` can name another column: each value is
    placed by the smallest `order_by` among its rows. -#}
select {{ column }} from {{ relation }}{% if where %} where {{ where }}{% endif %} group by {{ column }} order by {% if order_by %}min({{ order_by }}){% else %}{{ column }}{% endif %} limit {{ max + 1 }}
{%- endmacro %}

{% macro _no_values(macro, column, relation) -%}
{{ raise_error("dre_utils." ~ macro ~ ": `" ~ column ~ "` has no values" ~ ((" in " ~ relation) if relation else "") ~ ", so there's nothing to " ~ ("list" if macro == 'column_values' else "pivot")) }}
{%- endmacro %}

{% macro _too_many(macro, column, relation, max) -%}
{{ raise_error("dre_utils." ~ macro ~ ": `" ~ column ~ "` has more than " ~ max ~ " distinct values in " ~ relation ~ "; narrow it with `where=`, or raise `max=` if you really want that many") }}
{%- endmacro %}

{#- column_values(relation, column, where=none, order_by=none, max=100, quote_values=true)

    The distinct values of `column` as a comma-separated list of SQL literals, e.g. for
    `where region in ({{ dre_utils.column_values('sales', 'region') }})`. Ordered by `order_by`,
    else by the column. More than `max` values is an error. -#}
{% macro column_values(relation, column, where=none, order_by=none, max=100, quote_values=true) -%}
{%- set rows = run_query(_distinct_sql(relation, column, where, order_by, max), max_rows=max + 1) -%}
{%- if rows | length > max -%}{{ _too_many('column_values', column, relation, max) }}{%- endif -%}
{%- if not rows -%}{{ _no_values('column_values', column, relation) }}{%- endif -%}
{%- set ns = namespace(out=[]) -%}
{%- for r in rows -%}{%- set ns.out = ns.out + [_literal(r[0], quote_values)] -%}{%- endfor -%}
{{ ns.out | join(', ') }}
{%- endmacro %}

{#- pivot(column, values=none, relation=none, where=none, order_by=none, max=100, agg='sum',
          then_value=1, else_value=none, prefix='', suffix='', quote=true, quote_values=true,
          null_name='null')

    One aggregated column per value of `column`, in portable SQL:
    `sum(case when month = '2026-07' then amount else 0 end) as "2026-07"`, ...

    Values come from `values` (a list), or, when that's not given, from the distinct values of
    `column` in `relation` (with `where`, `order_by` and `max` as in `column_values`). The
    `else` is 0 for `sum` and null for anything else, so `count`, `avg`, `min` and `max`
    ignore the other rows (`count` of a 0 would count them); `else_value` overrides it. A none value matches with `is null` and its
    column is named `null_name`. Column names are the values themselves, plus `prefix` and
    `suffix`, quoted with `quote_identifier` (turn off with `quote=false`). -#}
{% macro pivot(column, values=none, relation=none, where=none, order_by=none, max=100, agg='sum', then_value=1, else_value=none, prefix='', suffix='', quote=true, quote_values=true, null_name='null') -%}
{%- if values is none -%}
{%- if relation is none -%}
{{ raise_error("dre_utils.pivot: give the `values` to pivot on, or a `relation` to read them from") }}
{%- endif -%}
{%- set fetched = namespace(values=[]) -%}
{%- set rows = run_query(_distinct_sql(relation, column, where, order_by, max), max_rows=max + 1) -%}
{%- if rows | length > max -%}{{ _too_many('pivot', column, relation, max) }}{%- endif -%}
{%- for r in rows -%}
{%- set fetched.values = fetched.values + [r[0]] -%}
{%- endfor -%}
{%- set values = fetched.values -%}
{%- endif -%}
{%- if not values -%}{{ _no_values('pivot', column, relation) }}{%- endif -%}
{%- if else_value is none -%}
{%- set else_value = 0 if (agg | lower) == 'sum' else 'null' -%}
{%- endif -%}
{%- set ns = namespace(out=[]) -%}
{%- for v in values -%}
{%- set cond = (column ~ ' is null') if v is none else (column ~ ' = ' ~ _literal(v, quote_values)) -%}
{%- set name = prefix ~ (null_name if v is none else v) ~ suffix -%}
{%- set alias = quote_identifier(name) if quote else name -%}
{%- set ns.out = ns.out + [agg ~ '(case when ' ~ cond ~ ' then ' ~ then_value ~ ' else ' ~ else_value ~ ' end) as ' ~ alias] -%}
{%- endfor -%}
{{ ns.out | join(',\n  ') }}
{%- endmacro %}
