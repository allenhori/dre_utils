select '{{ dre_utils.column_values('orders', 'region', where="region in ('apac', 'emea')", order_by='-amount', quote_values=false) }}' as by_amount,
  {{ dre_utils.pivot('region', relation='orders', where="region in ('apac', 'emea')", order_by='-amount', agg='max', then_value='id', quote=false, prefix='r_', suffix='_id') }}
from orders
