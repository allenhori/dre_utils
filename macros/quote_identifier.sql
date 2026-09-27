{#- quote_identifier(name): `name` quoted for the report's database, with any quote inside it
    doubled. Dispatched: define `<source type>__quote_identifier` in your project to change it. -#}
{% macro quote_identifier(name) -%}
{{ dispatch('quote_identifier', 'dre_utils')(name) }}
{%- endmacro %}

{% macro default__quote_identifier(name) -%}
"{{ name | string | replace('"', '""') }}"
{%- endmacro %}

{% macro databricks__quote_identifier(name) -%}
`{{ name | string | replace('`', '``') }}`
{%- endmacro %}
