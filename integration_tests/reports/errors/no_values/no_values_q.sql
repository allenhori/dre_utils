select {{ dre_utils.pivot('region', relation='orders', where='1 = 0') }} from orders
