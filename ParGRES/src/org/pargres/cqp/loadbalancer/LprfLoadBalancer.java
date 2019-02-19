package org.pargres.cqp.loadbalancer;

import java.util.ArrayList;
import java.util.TreeSet;

import org.pargres.commons.logger.Logger;
import org.pargres.cqp.connection.ConnectionManagerImpl;

public class LprfLoadBalancer {
	private Logger logger = Logger.getLogger(ConnectionManagerImpl.class);
	public static final int INTRA_QUERY_LOAD = 3;
	public static final int INTER_QUERY_LOAD = 1;
	//TODO: (4)Fazer LPRF
	// 1 Intra = 3 Inter 
	//Usar um NQP_Allocator*
		
	//private int clusterSize;
	ArrayList<NodeLoad> nodesArray = new ArrayList<NodeLoad>();
	
	public LprfLoadBalancer(int clusterSize) {
		for(int i = 0; i < clusterSize; i++) 
			addNode();
	}
	
	public synchronized int next() {
		TreeSet<NodeLoad> nodes = new TreeSet<NodeLoad>();

		nodes.addAll(nodesArray);
		
		int i = ((NodeLoad)nodes.first()).getIndex();
		return i;
	}
	
	public synchronized void notifyStartIntraQuery(int nodeIndex) { 
		getNodeLoad(nodeIndex).increaseLoad(INTRA_QUERY_LOAD);
	}
	
	public synchronized void notifyFinishIntraQuery(int nodeIndex) { 
		getNodeLoad(nodeIndex).decreaseLoad(INTRA_QUERY_LOAD);
	}
	
	public synchronized void notifyStartInterQuery(int nodeIndex) { 
		getNodeLoad(nodeIndex).increaseLoad(INTER_QUERY_LOAD);
	}
	
	public synchronized void notifyFinishInterQuery(int nodeIndex) { 
		getNodeLoad(nodeIndex).decreaseLoad(INTER_QUERY_LOAD);
	}	
	
	private NodeLoad getNodeLoad(int i) {
		return nodesArray.get(i);
	}
	
	public void dump() {
		System.out.println("LPRF Load Balancer DUMP");
		System.out.println("Next = "+next());
		int i = 0;
		for(NodeLoad nodeLoad : nodesArray) {
			System.out.println("["+i+"] "+nodeLoad.getLoad());
			i++;
		}
		
	}
	
	class NodeLoad implements Comparable {
		private int index = -1;
		private int load = 0;
		public NodeLoad(int index) {
			this.index = index;
		}
		
		public int getLoad() {
			return load;
		}
		
		public int getIndex() {
			return index;
		}
		
		public void increaseLoad(int inc) {
			load += inc;
		}
		
		public void decreaseLoad(int dec) {
			load -= dec;
		}
		
		public int compareTo(Object arg0) {
			if(!arg0.getClass().equals(NodeLoad.class)) {
				logger.error("Load Balancer error!");
				return -1;
			}
			int diff = this.getLoad() - ((NodeLoad)arg0).getLoad();
			if(diff == 0) {
				if(this.getIndex() < ((NodeLoad)arg0).getIndex())
					return -1;
				else
					return 1;
			} else
				return diff;
		}
		
	}

	public void addNode() {
		NodeLoad nodeLoad = new NodeLoad(nodesArray.size());
		nodesArray.add(nodeLoad);
	}

	public void dropNode(int nodeId) {
		nodesArray.remove(nodeId);		
	}

}
