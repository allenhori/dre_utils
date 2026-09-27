select {{ dre_utils.star('orders', except=['_ETL_TS', 'note']) }} from orders order by id
