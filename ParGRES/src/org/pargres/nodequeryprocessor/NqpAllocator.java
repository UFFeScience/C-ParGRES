/*
 * NQP_Allocator.java
 *
 * Created on 3 juin 2004, 00:57
 */

package org.pargres.nodequeryprocessor;

/**
 *
 * @author  Alex
 */

import java.util.TreeSet;
import java.util.Arrays;

public class NqpAllocator {

	private final int LOAD_CQP = 1;

	private final int LOAD_GQT = 2; // GQT + GRC

	private final int LOAD_LQT = 4; // LQT(3) + LRC(1)

	private TreeSet<NqpLoadInfo> a_loadOrderedSet;

	private NodeQueryProcessor[] a_nqp;

	private NqpLoadInfo[] a_loadInfo;

	public NqpAllocator() {
		this(new NodeQueryProcessor[]{},0);
	}
	
	/** Creates a new instance of NQP_Allocator */
	public NqpAllocator(NodeQueryProcessor[] nqp, int idxCQP) {
		// idxCQP - index of the NQP that will share a node with CQP
		a_loadOrderedSet = new TreeSet<NqpLoadInfo>();
		a_nqp = nqp;
		a_loadInfo = new NqpLoadInfo[nqp.length];
		for (int i = 0; i < a_loadInfo.length; i++) {
			int load;
			if (i == idxCQP)
				load = LOAD_CQP;
			else
				load = 0;
			a_loadInfo[i] = new NqpLoadInfo(i, a_nqp[i], load);
			a_loadOrderedSet.add(a_loadInfo[i]);
		}
	}
	
	public void addNode(NodeQueryProcessor nqp) {
		
	}
	
	public void dropNode(NodeQueryProcessor nqp) {
		
	}

	/* alocateNQPsForQueryProcessing() - method called to alocate NQPs for query processing.
	 * allocatedNQP_id - array to store ids of the allocated nqps.
	 *                   The array must be allocated by the caller.
	 *                   Array size indicates the number of nqps needed.
	 *                   The goal is to facilitate deallocation.
	 * Returns: the id of the NQP that must be used to run GQT
	 */
	public synchronized int allocateNQPsForQueryProcessing(int[] allocatedNQP_id) {
		int idGQT;

		if (allocatedNQP_id.length > a_nqp.length)
			throw new IllegalArgumentException("NQP_Allocator Exception: "
					+ allocatedNQP_id.length + " were demanded but only "
					+ a_nqp.length + " are available!");
		NqpLoadInfo[] loadInfo = new NqpLoadInfo[allocatedNQP_id.length];

		// Allocating NQP to run GQT. A LQT always runs with a GQT.
		loadInfo[0] = getLessLoadedNQP();
		loadInfo[0].increaseLoad(LOAD_GQT + LOAD_LQT);
		allocatedNQP_id[0] = loadInfo[0].getNQP_Id();
		idGQT = loadInfo[0].getNQP_Id();

		// Allocating NQPs for LQTs.
		for (int i = 1; i < allocatedNQP_id.length; i++) {
			loadInfo[i] = getLessLoadedNQP();
			loadInfo[i].increaseLoad(LOAD_LQT);
			allocatedNQP_id[i] = loadInfo[i].getNQP_Id();
		}

		// Reinsert LoadInfo in the ordered set to consider the new loads in future allocations
		for (int i = 0; i < loadInfo.length; i++) {
			a_loadOrderedSet.add(loadInfo[i]);
		}

		// order NQP ids
		Arrays.sort(allocatedNQP_id);

		//System.out.println("Load apos alocacao para query " + queryId + " : " + a_loadOrderedSet );
		notifyAll();
		return idGQT;
	}

	private NqpLoadInfo getLessLoadedNQP() {
		NqpLoadInfo loadInfo;

		loadInfo = (NqpLoadInfo) a_loadOrderedSet.first();
		a_loadOrderedSet.remove(loadInfo);
		return loadInfo;
	}

	/* disposeNQPs() - update load information of nqps that have been used for query processing;
	 *
	 * idGQT - The first id must be of the nqp who run gqt.
	 * allocatedNQP_id - ids of nqps being disposed.
	 */
	public synchronized void disposeNQPs(int idGQT, int[] allocatedNQP_id) {
		NqpLoadInfo loadInfo;

		// disposing gqt nqp
		loadInfo = a_loadInfo[idGQT];
		if (!a_loadOrderedSet.remove(loadInfo))
			throw new IllegalStateException(
					"NQP_Allocator.disposeNQPs(): loadInfo not found in the ordered set - "
							+ loadInfo);
		loadInfo.decreaseLoad(LOAD_GQT);
		a_loadOrderedSet.add(loadInfo);

		// disposing other nqps
		for (int i = 0; i < allocatedNQP_id.length; i++) {
			loadInfo = a_loadInfo[allocatedNQP_id[i]];
			if (!a_loadOrderedSet.remove(loadInfo))
				throw new IllegalStateException(
						"NQP_Allocator.disposeNQPs(): loadInfo not found in the ordered set - "
								+ loadInfo);
			loadInfo.decreaseLoad(LOAD_LQT);
			a_loadOrderedSet.add(loadInfo);
		}

		//System.out.println("Load apos desalocacao para query " + queryId + " : " + a_loadOrderedSet );

		notifyAll();
	}
}
