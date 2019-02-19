/*
 * Created on 08/04/2005
 */
package org.pargres.cqp.querymanager;

import java.rmi.RemoteException;
import java.sql.SQLException;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.commons.util.JdbcUtil;
import org.pargres.commons.util.ParserException;
import org.pargres.cqp.ClusterQueryProcessorEngine;

/**
 * @author Bernardo
 */
public class UpdateQueryManager extends AbstractQueryManager {
	
	private Logger logger = Logger.getLogger(UpdateQueryManager.class);

	public UpdateQueryManager(String sql,
			int queryNumber,ClusterQueryProcessorEngine clusterQueryProcessorEngine) throws ParserException {
		super(sql,queryNumber,clusterQueryProcessorEngine);
		int clusterSize = -1;
		try {
			clusterSize = clusterQueryProcessorEngine.getClusterSize();
		} catch (Exception e) {
			logger.error(e);
		}
		if (clusterSize == 0)
			throw new ParserException("No NQP left");
				
		logger.debug(Messages.getString("serverconnection.queryCreate",
				new String[] { getQueryNumber() + "",
						"UPDATE", sql}));
	}
	
	/**
	 * @return
	 */
	public int executeUpdate() throws SQLException, RemoteException {
		schedullerWait();

		int updateCount = -1;
		try {
			if (sql.equals(JdbcUtil.LAZY_UPDATE)) {
				Thread.sleep(1000);
				updateCount = -1;
			} else {
				/*
				 * Send updates in parallel
				 */
				UpdateManager um = new UpdateManager(
						clusterQueryProcessorEngine.getNodeQueryProcessorList(),
						sql);
				updateCount = um.executeUpdate();
				/*
				 * Remove nodes with error
				 */
				for (int nodeId : um.getNodesToDrop())
					clusterQueryProcessorEngine.dropNodeByNodeId(nodeId);
			}
		} catch (InterruptedException e) {
			e.printStackTrace();
			logger.error(Messages.getString("querymanager.error", e));
		}
		return updateCount;
	}
}
