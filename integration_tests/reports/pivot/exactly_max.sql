select {{ dre_utils.pivot('month', relation='orders', max=2, then_value='amount') }} from orders
