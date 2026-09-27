select {{ dre_utils.star('orders', except=['amout']) }} from orders
