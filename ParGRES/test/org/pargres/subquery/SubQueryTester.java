package org.pargres.subquery;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

public class SubQueryTester {
	private Connection con;
	private static int REPEAT = 3;
	private static int lineitemRangeInit = 0;
	private static int linteitemRangeEnd  = 30000000/16;
	private static int partsuppRangeInit = 0;
	private static int partsuppRangeEnd = 1000000/16;
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		SubQueryTester sqt = new SubQueryTester();
		sqt.run();
	}
	
	public SubQueryTester() {
		try {
			Class.forName("org.postgresql.Driver");
			con = DriverManager.getConnection("jdbc:postgresql://node3/tpch_sf5","tpch","");			
		} catch (Exception e) {
			e.printStackTrace();
		}				
	}	
	
	public void run() {
		echo("Q#0 Original");
		exec("SELECT COUNT(*) FROM REGION");
		
		echo("Q#2 Original");
		exec("select s_acctbal,	s_name,	n_name,	p_partkey, p_mfgr, s_adress, s_phone, s_comment " +
				     "from part, supplier, partsupp, nation, region "+
				     "where p_partkey = ps_partkey and s_suppkey = ps_suppkey and p_size = 33 "+
					 "and s_nationkey = n_nationkey "+
					 "and n_regionkey = r_regionkey "+
					 "and r_name = 'AFRICA' "+				
					 "order by s_acctbal desc, n_name, s_name, p_partkey");
		
		echo("Q#2 Particionada");
		exec("select s_acctbal,	s_name,	n_name,	p_partkey, p_mfgr, s_adress, s_phone, s_comment " +
				     "from part, supplier, partsupp, nation, region "+				     
				     "where "+
				     "ps_partkey > "+partsuppRangeInit+" and ps_partkey < "+partsuppRangeEnd+" "+
				     "and p_partkey = ps_partkey and s_suppkey = ps_suppkey and p_size = 33 "+
					 "and s_nationkey = n_nationkey "+
					 "and n_regionkey = r_regionkey "+
					 "and r_name = 'AFRICA' "+				
					 "order by s_acctbal desc, n_name, s_name, p_partkey");
		
		echo("Q#2 Particionada completa");
		exec("select s_acctbal,	s_name,	n_name,	p_partkey, p_mfgr, s_adress, s_phone, s_comment " +
				     "from part, supplier, partsupp, nation, region "+				     
				     "where "+
				     "p_partkey > "+partsuppRangeInit+" and p_partkey < "+partsuppRangeEnd+" "+
				     "and ps_partkey > "+partsuppRangeInit+" and ps_partkey < "+partsuppRangeEnd+" "+
				     "and p_partkey = ps_partkey and s_suppkey = ps_suppkey and p_size = 33 "+
					 "and s_nationkey = n_nationkey "+
					 "and n_regionkey = r_regionkey "+
					 "and r_name = 'AFRICA' "+				
					 "order by s_acctbal desc, n_name, s_name, p_partkey");
		
		echo("Q#7 Completa");
		exec("select supp_nation, cust_nation, l_year, sum(volume) as revenue from "+
			 "(select n1.n_name as supp_nation, "+
			  "n2.n_name as cust_nation, "+
			  "extract(year from l_shipdate) as l_year, "+
			  "l_extendedprice * (1 - l_discount) as volume "+
			  "from supplier, lineitem, orders,customer,nation n1,nation n2 "+
			  "where "+
			  "s_suppkey = l_suppkey "+
			  "and o_orderkey = l_orderkey "+
			  "and c_custkey = o_custkey "+
			  "and s_nationkey = n1.n_nationkey "+
			  "and c_nationkey = n2.n_nationkey "+
			  "and (  "+
			  "	(n1.n_name = 'RUSSIA' and n2.n_name = 'FRANCE') "+
			  "		or (n1.n_name = 'FRANCE' and n2.n_name = 'RUSSIA') "+
			  "	) "+
			  "	and l_shipdate between date '1995-01-01' and date '1996-12-31' "+
			  "		) as shipping "+
			  "	group by "+
			  "		supp_nation,cust_nation,l_year "+	
			  " order by supp_nation, cust_nation,	l_year ");		
		
		echo("Q#7 Particionada");
		exec("select supp_nation, cust_nation, l_year, sum(volume) as revenue from "+
			 "(select n1.n_name as supp_nation, "+
			  "n2.n_name as cust_nation, "+
			  "extract(year from l_shipdate) as l_year, "+
			  "l_extendedprice * (1 - l_discount) as volume "+
			  "from supplier, lineitem, orders,customer,nation n1,nation n2 "+
			  "where "+
			  "l_orderkey > "+lineitemRangeInit+" and l_orderkey < "+linteitemRangeEnd+" "+
			  "and s_suppkey = l_suppkey "+
			  "and o_orderkey = l_orderkey "+
			  "and c_custkey = o_custkey "+
			  "and s_nationkey = n1.n_nationkey "+
			  "and c_nationkey = n2.n_nationkey "+
			  "and (  "+
			  "	(n1.n_name = 'RUSSIA' and n2.n_name = 'FRANCE') "+
			  "		or (n1.n_name = 'FRANCE' and n2.n_name = 'RUSSIA') "+
			  "	) "+
			  "	and l_shipdate between date '1995-01-01' and date '1996-12-31' "+
			  "		) as shipping "+
			  "	group by "+
			  "		supp_nation,cust_nation,l_year "+	
			  " order by supp_nation, cust_nation,	l_year ");			
		
		echo("Q#7 Particionada completa");
		exec("select supp_nation, cust_nation, l_year, sum(volume) as revenue from "+
			 "(select n1.n_name as supp_nation, "+
			  "n2.n_name as cust_nation, "+
			  "extract(year from l_shipdate) as l_year, "+
			  "l_extendedprice * (1 - l_discount) as volume "+
			  "from supplier, lineitem, orders,customer,nation n1,nation n2 "+
			  "where "+
			  "l_orderkey > "+lineitemRangeInit+" and l_orderkey < "+linteitemRangeEnd+" "+
			  "and o_orderkey > "+lineitemRangeInit+" and o_orderkey < "+linteitemRangeEnd+" "+
			  "and s_suppkey = l_suppkey "+
			  "and o_orderkey = l_orderkey "+
			  "and c_custkey = o_custkey "+
			  "and s_nationkey = n1.n_nationkey "+
			  "and c_nationkey = n2.n_nationkey "+
			  "and (  "+
			  "	(n1.n_name = 'RUSSIA' and n2.n_name = 'FRANCE') "+
			  "		or (n1.n_name = 'FRANCE' and n2.n_name = 'RUSSIA') "+
			  "	) "+
			  "	and l_shipdate between date '1995-01-01' and date '1996-12-31' "+
			  "		) as shipping "+
			  "	group by "+
			  "		supp_nation,cust_nation,l_year "+	
			  " order by supp_nation, cust_nation,	l_year ");			
		
		
		echo("Q#9 Completa");
		exec("select nation,o_year,sum(amount) as sum_profit "+
			 "from	( select "+
			 "	n_name as nation, "+
			 "	extract(year from o_orderdate) as o_year, "+
			 "	l_extendedprice * (1 - l_discount) - ps_supplycost * l_quantity as amount "+
			 "from "+
			 "	part, "+
			 "	supplier, "+
			 "	lineitem, "+
			 "	partsupp, "+
			 "	orders, "+
			 "	nation "+
			 "where "+
			 "	s_suppkey = l_suppkey "+
			 "	and ps_suppkey = l_suppkey "+
			 "	and ps_partkey = l_partkey "+
			 "	and p_partkey = l_partkey "+
			 "	and o_orderkey = l_orderkey "+
			 "	and s_nationkey = n_nationkey "+
			 "	and p_name like '%violet%' "+
		     ") as profit "+
			 "	group by "+
			 "		nation, "+
			 "		o_year "+
			 "	order by "+
			 "		nation, "+
			 "		o_year desc");
		
		echo("Q#9 Particionada");
		exec("select nation,o_year,sum(amount) as sum_profit "+
			 "from	( select "+
			 "	n_name as nation, "+
			 "	extract(year from o_orderdate) as o_year, "+
			 "	l_extendedprice * (1 - l_discount) - ps_supplycost * l_quantity as amount "+
			 "from "+
			 "	part, "+
			 "	supplier, "+
			 "	lineitem, "+
			 "	partsupp, "+
			 "	orders, "+
			 "	nation "+
			 "where "+
			 " l_orderkey > "+lineitemRangeInit+" and l_orderkey < "+linteitemRangeEnd+" "+			 
			 "  and s_suppkey = l_suppkey "+
			 "	and ps_suppkey = l_suppkey "+
			 "	and ps_partkey = l_partkey "+
			 "	and p_partkey = l_partkey "+
			 "	and o_orderkey = l_orderkey "+
			 "	and s_nationkey = n_nationkey "+
			 "	and p_name like '%violet%' "+
		     ") as profit "+
			 "	group by "+
			 "		nation, "+
			 "		o_year "+
			 "	order by "+
			 "		nation, "+
			 "		o_year desc");
		
		echo("Q#9 Particionada completa");
		exec("select nation,o_year,sum(amount) as sum_profit "+
			 "from	( select "+
			 "	n_name as nation, "+
			 "	extract(year from o_orderdate) as o_year, "+
			 "	l_extendedprice * (1 - l_discount) - ps_supplycost * l_quantity as amount "+
			 "from "+
			 "	part, "+
			 "	supplier, "+
			 "	lineitem, "+
			 "	partsupp, "+
			 "	orders, "+
			 "	nation "+
			 "where "+
			 " l_orderkey > "+lineitemRangeInit+" and l_orderkey < "+linteitemRangeEnd+" "+
			 "  and o_orderkey > "+lineitemRangeInit+" and o_orderkey < "+linteitemRangeEnd+" "+
			 "  and s_suppkey = l_suppkey "+
			 "	and ps_suppkey = l_suppkey "+
			 "	and ps_partkey = l_partkey "+
			 "	and p_partkey = l_partkey "+
			 "	and o_orderkey = l_orderkey "+
			 "	and s_nationkey = n_nationkey "+
			 "	and p_name like '%violet%' "+
		     ") as profit "+
			 "	group by "+
			 "		nation, "+
			 "		o_year "+
			 "	order by "+
			 "		nation, "+
			 "		o_year desc");			
		
		echo("Q#11 Completa");
		exec("select "+
			"ps_partkey, "+
			"sum(ps_supplycost * ps_availqty) as value "+
			"from "+
			"partsupp, "+
			"	supplier, "+
			"nation "+
			"where "+
			"ps_suppkey = s_suppkey "+
			"	and s_nationkey = n_nationkey "+
			"	and n_name = 'JORDAN' "+
			"group by "+
			"	ps_partkey having "+
			"		sum(ps_supplycost * ps_availqty) > ( "+
			"			select "+
			"				sum(ps_supplycost * ps_availqty) * 0.0001000000 "+
			"			from "+
			"				partsupp, "+
			"				supplier, "+
			"				nation "+
			"			where "+
			"				ps_suppkey = s_suppkey "+
			"				and s_nationkey = n_nationkey "+
			"				and n_name = 'JORDAN' "+
			"		) "+
			"order by "+
			"	value desc");
		
		echo("Q#11 Particionada");
		exec("select "+
				"ps_partkey, "+
				"sum(ps_supplycost * ps_availqty) as value "+
				"from "+
				"partsupp, "+
				"	supplier, "+
				"nation "+
				"where "+
				"ps_partkey > "+partsuppRangeInit+" and ps_partkey < "+partsuppRangeEnd+" "+
				"and ps_suppkey = s_suppkey "+
				"	and s_nationkey = n_nationkey "+
				"	and n_name = 'JORDAN' "+
				"group by "+
				"	ps_partkey having "+
				"		sum(ps_supplycost * ps_availqty) > ( "+
				"			select "+
				"				sum(ps_supplycost * ps_availqty) * 0.0001000000 "+
				"			from "+
				"				partsupp, "+
				"				supplier, "+
				"				nation "+
				"			where "+
				"				ps_suppkey = s_suppkey "+
				"				and s_nationkey = n_nationkey "+
				"				and n_name = 'JORDAN' "+
				"		) "+
				"order by "+
				"	value desc");		
		
		echo("Q#13 Completa");
		exec("select "+
			"		c_count, "+
			"count(*) as custdist "+
			"from "+
			"( "+
			"select "+
			"c_custkey, "+
			"count(o_orderkey) "+
			"from "+
			"		customer left outer join orders on "+
			"			c_custkey = o_custkey "+
			"			and o_comment not like '%express%packages%' "+
			"	group by "+
			"		c_custkey "+
			") as c_orders (c_custkey, c_count) "+
			"group by "+
			"c_count "+
			"order by "+
			"custdist desc, "+
			"c_count desc");
		
		
		echo("Q#13 Particionada");
		exec("select "+
			"		c_count, "+
			"count(*) as custdist "+
			"from "+
			"( "+
			"select "+
			"c_custkey, "+
			"count(o_orderkey) "+
			"from "+
			"		customer left outer join orders on "+
			"			c_custkey = o_custkey "+
			"           and o_orderkey > "+lineitemRangeInit+" and o_orderkey < "+linteitemRangeEnd+" "+
			"			and o_comment not like '%express%packages%' "+
			"	group by "+
			"		c_custkey "+
			") as c_orders (c_custkey, c_count) "+
			"group by "+
			"c_count "+
			"order by "+
			"custdist desc, "+
			"c_count desc");		
		
		echo("Q#17 Completa");
		exec("select "+
				"sum(l_extendedprice) / 7.0 as avg_yearly "+
				"from "+
				"lineitem, "+
				"part "+
				"where "+
				"p_partkey = l_partkey "+
				"and p_brand = 'Brand#25' "+
				"and p_container = 'WRAP DRUM' "+
				"and l_quantity < ( "+
				"select "+
				"0.2 * avg(l_quantity) "+
				"from "+
				"lineitem "+
				"where "+
				"l_partkey = p_partkey )");
		
		echo("Q#17 Particionada");
		exec("select "+
				"sum(l_extendedprice) / 7.0 as avg_yearly "+
				"from "+
				"lineitem, "+
				"part "+
				"where "+
				"l_orderkey > "+lineitemRangeInit+" and l_orderkey < "+linteitemRangeEnd+" "+
				"and p_partkey = l_partkey "+
				"and p_brand = 'Brand#25' "+
				"and p_container = 'WRAP DRUM' "+
				"and l_quantity < ( "+
				"select "+
				"0.2 * avg(l_quantity) "+
				"from "+
				"lineitem "+
				"where "+
				"l_partkey = p_partkey )");		
		
		
		echo("Q#20 Completa");
		exec("select "+
		"s_name, "+
		"s_adress "+
		"from "+
		"supplier, "+
		"nation "+
		"where "+
		"s_suppkey in ( "+
		"select "+
		"				ps_suppkey "+
		"	from "+
		"		partsupp "+
		"	where "+
		"		ps_partkey in ( "+
		"			select "+
		"				p_partkey "+
		"			from "+
		"				part "+
		"			where "+
		"				p_name like 'pale%' "+
		"		) "+
		"		and ps_availqty > ( "+
		"			select "+
		"				0.5 * sum(l_quantity) "+
		"			from "+
		"				lineitem "+
		"			where "+
		"				l_partkey = ps_partkey "+
		"				and l_suppkey = ps_suppkey "+
		"				and l_shipdate >= date '1995-01-01' "+
		"				and l_shipdate < date '1995-01-01' + interval '1 year' "+
		"		) "+
		")			 "+	
		"and s_nationkey = n_nationkey "+
		"and n_name = 'INDIA' "+
		"order by "+
		"s_name");
		
		echo("Q#20 Particionada");
		exec("select "+
		"s_name, "+
		"s_adress "+
		"from "+
		"supplier, "+
		"nation "+
		"where "+
		"s_suppkey in ( "+
		"select "+
		"				ps_suppkey "+
		"	from "+
		"		partsupp "+
		"	where "+
		"		ps_partkey in ( "+
		"			select "+
		"				p_partkey "+
		"			from "+
		"				part "+
		"			where "+
		"				p_name like 'pale%' "+
		"		) "+
		"		and ps_availqty > ( "+
		"			select "+
		"				0.5 * sum(l_quantity) "+
		"			from "+
		"				lineitem "+
		"			where "+
		"				l_orderkey > "+lineitemRangeInit+" and l_orderkey < "+linteitemRangeEnd+" "+
		"				and l_partkey = ps_partkey "+
		"				and l_suppkey = ps_suppkey "+
		"				and l_shipdate >= date '1995-01-01' "+
		"				and l_shipdate < date '1995-01-01' + interval '1 year' "+
		"		) "+
		")			 "+	
		"and s_nationkey = n_nationkey "+
		"and n_name = 'INDIA' "+
		"order by "+
		"s_name");		
		
	}
	
	public void exec(String sql) {
		for(int i = 0; i < REPEAT; i++)
			executeQuery(sql);
	}
	
	public void echo(String value) {
		System.out.println(value);
	}
	public void executeQuery(String sql) {
		try {
			long init = System.currentTimeMillis();
			ResultSet rs = con.createStatement().executeQuery(sql);
			while(rs.next()) { 
				//do nothing
			}
			long total = System.currentTimeMillis() - init;
			System.out.println("Tempo total da consulta: "+total);
		} catch (Exception e) {
			System.err.println("Erro na consulta:\n"+sql+"\n"+e+"\n");
			e.printStackTrace();
		}
	}

}
