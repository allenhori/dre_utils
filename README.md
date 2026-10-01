# dre_utils

Reusable macros for [DRE](https://github.com/get-dre/dre) reports: select all but a few columns,
and pivot values into columns, in SQL that works on any database DRE reads from.

Dates and periods (`run.date.prev_month`, `period('mtd')`, timezones) are built into DRE itself;
see [DRE's template docs](https://github.com/get-dre/dre/blob/master/docs/templates.md).

## Install

Add the package to your project's `packages.yml` (or `dependencies.yml`) and run `dre deps`:

```yaml
packages:
  - git: https://github.com/get-dre/dre_utils.git
    revision: v0.1.0    # a tag, branch or commit
```

Call its macros through the package's name: `{{ dre_utils.star(...) }}`.

## `star`

```sql
select {{ dre_utils.star('crm.customers', except=['ssn', '_etl_ts']) }}
from crm.customers
-- select "id", "name", "email", "created_at" from crm.customers
```

An explicit list of the relation's columns, without the ones in `except`. It works the same on
every database, instead of relying on `* except (...)` / `* exclude (...)`.

| Argument | |
|---|---|
| `relation` | A table, a fully qualified name, a temp table made by an earlier query, or `ref('file')`. |
| `except` | Column names to leave out (a list, or one name), matched case-insensitively. A name that isn't a column is an error, so a renamed column doesn't slip back in. |
| `alias` | Qualify each column: `alias='c'` gives `c."id"`. |
| `prefix`, `suffix` | Rename each column: `prefix='c_'` gives `"id" as "c_id"`. |
| `quote` | Quote column names (default `true`), with `quote_identifier`. |

The columns come from DRE's `columns()`, which asks the database once per relation in each query file.

## `pivot`

```sql
select account,
  {{ dre_utils.pivot('month', relation='ledger', agg='sum', then_value='amount') }}
from ledger group by account
-- sum(case when month = '2026-07' then amount else 0 end) as "2026-07",
-- sum(case when month = '2026-08' then amount else 0 end) as "2026-08"
```

One aggregated column per value, using portable `case when`.

| Argument | |
|---|---|
| `column` | The column whose values become columns. |
| `values` | The values, as a list. Or leave it out and give `relation`: |
| `relation`, `where`, `order_by`, `max` | Read the distinct values of `column` from `relation` (optionally filtered by `where`), ordered by `order_by` (default: the column). More than `max` (default 100) values is an error. |
| `agg` | The aggregate: `sum` (default), `count`, `avg`, `min`, `max`, ... |
| `then_value` | What's aggregated for matching rows (default `1`). |
| `else_value` | What's aggregated for other rows. Default: `0` for `sum`, `null` for everything else, so `count` and `avg` only see matching rows. |
| `prefix`, `suffix` | Around each value to make the column name. |
| `quote` | Quote column names (default `true`). The name is the value as it is: `"2026-07"`. |
| `quote_values` | Quote string values as SQL literals (default `true`); `false` puts them in as written. |
| `null_name` | The column name for a null value (default `null`); it matches with `is null`. |

## `column_values`

```sql
where region in ({{ dre_utils.column_values('sales', 'region', where='active') }})
-- where region in ('apac', 'emea')
```

The distinct values of a column as SQL literals, with the same `where`, `order_by`, `max` and
`quote_values` as `pivot`.

## `string_literal`

`dre_utils.string_literal("O'Brien")` gives `'O''Brien'`, or `'O\'Brien'` on Databricks, which
doesn't read `''` as an escaped quote (`'O''Brien'` is two literals there, joined into
`OBrien`) and reads backslashes as escapes. `pivot` and `column_values` quote string values with
it. Dispatched like `quote_identifier`.

## `quote_identifier`

`dre_utils.quote_identifier('Order Date')` gives `"Order Date"`, or `` `Order Date` `` on
Databricks. It picks the variant for the report's database through `dispatch()`: define
`<source type>__quote_identifier` in your project's `macros/` to change it.

## Tests

`integration_tests/` is a DRE project that uses this package from `..`. `integration_tests/run.sh`
runs its reports against an in-memory DuckDB and checks each output against `expected/`, and each
error case against `errors.txt`. It needs `dre` on the `PATH` (or `DRE=...`) and the DuckDB and
csv plugins (`dre deps` in `integration_tests/` installs them).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[Apache-2.0](LICENSE).
