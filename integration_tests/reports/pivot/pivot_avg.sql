select
  {{ dre_utils.pivot('region', relation='orders', where="region <> 'o''hare'", agg='avg', then_value='amount', prefix='avg_') }}
from orders
