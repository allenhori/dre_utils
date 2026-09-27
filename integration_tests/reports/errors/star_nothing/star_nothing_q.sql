select {{ dre_utils.star('orders', except=['id','region','month','amount','Note','_etl_ts']) }} from orders
