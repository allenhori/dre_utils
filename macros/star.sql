{#- star(relation, except=[], prefix='', suffix='', alias=none, quote=true)

    An explicit, comma-separated list of `relation`'s columns, without the ones named in
    `except` (matched case-insensitively). Every name in `except` must be a column: a typo is an
    error, not a column that quietly stays in. `alias` qualifies each column (`o.id`), and
    `prefix`/`suffix` rename them (`id as o_id`). Columns come from core's `columns()`, so
    `relation` can be a table, a fully qualified name, a temp table or `ref('file')`. -#}
{% macro star(relation, except=[], prefix='', suffix='', alias=none, quote=true) -%}
{%- if except is string -%}{%- set except = [except] -%}{%- endif -%}
{%- set cols = columns(relation) -%}
{%- set known = cols | map(attribute='name') | map('lower') | list -%}
{%- set skip = except | map('lower') | list -%}
{%- for e in except if (e | lower) not in known -%}
{{ raise_error("dre_utils.star: `" ~ e ~ "` in `except` isn't a column of " ~ relation ~ "; its columns are " ~ (cols | map(attribute='name') | join(', '))) }}
{%- endfor -%}
{%- set ns = namespace(out=[]) -%}
{%- for c in cols if (c.name | lower) not in skip -%}
{%- set name = quote_identifier(c.name) if quote else c.name -%}
{%- set col = (alias ~ '.' ~ name) if alias else name -%}
{%- if prefix or suffix -%}
{%- set new = prefix ~ c.name ~ suffix -%}
{%- set col = col ~ ' as ' ~ (quote_identifier(new) if quote else new) -%}
{%- endif -%}
{%- set ns.out = ns.out + [col] -%}
{%- endfor -%}
{%- if not ns.out -%}
{{ raise_error("dre_utils.star: `except` leaves no columns of " ~ relation) }}
{%- endif -%}
{{ ns.out | join(', ') }}
{%- endmacro %}
