select {{ dre_utils.star('orders', except='_etl_ts', alias='o', prefix='o_', suffix='_x') }} from orders o order by id
