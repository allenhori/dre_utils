-- Every value, quotes and backslashes included, must match itself as a literal.
select sum(n) as matched,
       {{ dre_utils.pivot('name', relation='places', then_value='n', prefix='p_', quote=true) }}
from places
where name in ({{ dre_utils.column_values('places', 'name') }})
