select coalesce(region, '-') as region,
  {{ dre_utils.pivot('month', relation='orders', agg='sum', then_value='amount') }}
from orders group by region order by region
