select
	100.00 * sum(l_extendedprice * (1 - l_discount))
		 / sum(l_extendedprice * (1 - l_discount)) as promo_revenue
from
	lineitem,
	part
where
    p_type like 'PROMO%' escape 'a'
	and l_partkey = p_partkey
	and l_shipdate >= date '1997-07-01'
	and l_shipdate < date '1997-07-01' + interval '1 month';
