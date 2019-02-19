package org.pargres.cqp.loadbalancer;

public class RoundRobinLoadBalancer {
	//TODO: (4)Fazer LPRF
	// 1 Intra = 3 Inter 
	//Usar um NQP_Allocator*
		
	private int clusterSize;
	private int next = 0;
	
	public RoundRobinLoadBalancer(int clusterSize) {
		this.clusterSize = clusterSize;
	}
	
	public synchronized int next() {
		int r = next;
		next = (next+1)%clusterSize;
		return r;
	}

}
