select
  {{ dre_utils.pivot('id', values=[1, 3, 99], then_value='amount', prefix='id_') }}
from orders
