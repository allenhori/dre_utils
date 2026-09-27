select {{ dre_utils.pivot('id', relation='orders', max=3) }} from orders
