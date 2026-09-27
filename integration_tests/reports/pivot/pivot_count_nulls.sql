select
  {{ dre_utils.pivot('region', relation='orders', where="region is null or region <> 'o''hare'", agg='count', then_value='id', null_name='no_region', quote=false, prefix='n_') }}
from orders
