select {{ dre_utils.star('orders', except=['Note', '_etl_ts', 'month'], quote=false) }} from orders order by id
