package org.pargres.cqp.querymanager;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map.Entry;

import org.pargres.commons.util.PargresException;

/*
 * Algorithm:
 * (1) If all results are not exceptions and equals, do nothing; whatelse go (2);
 * (2) If all results are exceptions, do nothing; whatelse go (3);
 * (3) If at least one results are not exception, consider those true;
 * (4) If true results are equals; drop backends related to false results; whatelse go (5);
 * (5) Calculate most frequent true result and drop backend related to other results;
 */
public class ResultDiff {
	private HashMap<Integer,UpdateCountList> resultHistogram = new HashMap<Integer,UpdateCountList>();
	private ArrayList<UpdateResult> exceptionResultList = new ArrayList<UpdateResult>();
	private ArrayList<Integer> nodesToDrop = new ArrayList<Integer>();
	private SQLException exception;
	private int updateCount = -1;

	public void add(int nodeId, int updateCount, SQLException exception) {
		if(exception == null) { 
			UpdateCountList updateCountList = resultHistogram.get(updateCount);		
			if(updateCountList == null) 
				updateCountList = new UpdateCountList();
			updateCountList.add(nodeId);
			resultHistogram.put(updateCount,updateCountList);
		} else {
			exceptionResultList.add(new UpdateResult(nodeId,exception));
		}			
		nodeId++;
	}
	
	public void compare() {
		if(resultHistogram.size() == 1 && exceptionResultList.size() == 0) {
			updateCount = resultHistogram.keySet().iterator().next();
			exception = null;
		} else if (resultHistogram.size() == 0) {
			updateCount = -1;
			String error = "";
			for(UpdateResult ur : exceptionResultList) {
				error += "database "+ur.getNodeId()+": \""+ur.getException().getMessage()+"\"\n";
			}
			exception = new PargresException(error); 
		} else if(resultHistogram.size() == 1 && exceptionResultList.size() > 0) {
			updateCount = resultHistogram.keySet().iterator().next();
			exception = null;
			for(UpdateResult ur : exceptionResultList)
				nodesToDrop.add(ur.getNodeId());			
			
		} else if(resultHistogram.size() > 1) {
			int max = -1;
			UpdateCountList ucl = null;
			for(Entry<Integer,UpdateCountList> entry : resultHistogram.entrySet())  {
				if(max < entry.getValue().count()) {
					max = entry.getValue().count();
					ucl = entry.getValue();
					updateCount = entry.getKey();
				}
			} 
			
			for(Entry<Integer,UpdateCountList> entry : resultHistogram.entrySet())  {
				if(entry.getValue() != ucl) 
					nodesToDrop.addAll(entry.getValue().getList());				
			} 			
			
			exception = null;
			for(UpdateResult ur : exceptionResultList)
				nodesToDrop.add(ur.getNodeId());				
		}					
	}		
	
	public ArrayList<Integer> getNodesToDrop() {
		return nodesToDrop;
	}
	
	public boolean hasError() {
		return exception != null;
	}
	
	public SQLException getException() {
		return exception;
	}
	
	public int getUpdateCount() {
		return updateCount;
	}	
	
	class UpdateCountList {
		private ArrayList<Integer> list = new ArrayList<Integer>(); 
			
		public void add(int nodeId) {
			list.add(nodeId);
		}
		
		public int count() {
			return list.size();
		}
		
		public ArrayList<Integer> getList() {
			return list;
		}
		
	}
	
	class UpdateResult {
		private int count;
		private SQLException exception;
		private int nodeId;
		
		public UpdateResult(int nodeId, int count) {
			this.nodeId = nodeId;
			this.count = count;
		}
		
		public UpdateResult(int nodeId, SQLException exception) {
			this.nodeId = nodeId;
			this.exception = exception;
		}
		
		public boolean isUpdate() {
			return exception == null;
		}
		
		public int getNodeId() {
			return nodeId;
		}		

		public int getCount() {
			return count;
		}

		public SQLException getException() {
			return exception;
		}		
	}

	 

}
