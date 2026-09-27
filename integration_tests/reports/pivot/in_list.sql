select count(*) as n, '{{ dre_utils.column_values('orders', 'region', where='region is not null') | replace("'", "") }}' as regions
from orders where region in ({{ dre_utils.column_values('orders', 'region', where='region is not null') }})
