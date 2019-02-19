/*
 * JobStatistics.java
 *
 * Created on 28 novembre 2003, 12:36
 */

package org.pargres.util;

/**
 *
 * @author  lima
 */

import java.io.Serializable;
import java.io.PrintStream;



public class LocalQueryTaskStatistics implements Serializable {

  /**
	 * 
	 */
	private static final long serialVersionUID = 3256999952029857077L;
private int a_intervalBeginning; // Limits of the interval the LQT is responsible for.
  private int a_intervalEnd;
  private long a_beginingTime; // Holds the time the job began
  private long a_qryProcFinishTime; // holds the time when query processing was finished
  private long a_finishTime; // Holds the time the job finished all its tasks
  private long a_numberOfQueries; // Number of queries executed
  private long a_totalQueryTime; // Total time spent waiting for query responses
  private long a_maxQueryTime; // Maximum time spent waiting for query responses
  private long a_minQueryTime; // Maximum time spent waiting for query responses

  // To measure IDLE time
  private boolean a_idle; // indicates if LQT is IDLE
  private long a_initIdleInterval; // used when in IDLE state to store the time when entering IDLE state
  private long a_totalIdleTime;

  // To have information related to partition size tuning
  private PartitionTuner a_partitionTuner;

  // Statistics about dynamic load balancing
  private boolean a_dynamicLoadBalancing;
  private long a_numDifferentBroadcasts; // number of different help offers broadcasts initiated by this node
  private long a_numRestartedBroadcasts; // number of broadcasts reinitiated because grid extremities were reached and nobody accepted the offer
  private long a_numHelpOffersMsgsReceived; // number of help offer messages received from other nodes
  private long a_numForwardedHelpOffersMsgs; // number of help messages offers received and forwarded
  private long a_numHelpOffersAcceptancesSent; // number of help offers accepted by this node
  private long a_numHelpOffersReceived; // number of help offers accepted by this node and effectively received
  private long a_numHelpOffersEffectivelyGiven; // number of help offers accepted by other nodes and effectively taken by them
  private long a_numDespisedHelpOfferAcceptanceMsgs; // number of help acceptance msgs received by this node but despised because it was already helping other one
  private long a_numOwnedRangesProcessed; // number of ranges owned by this node and processed by him
  private long a_numNotOwnedRangesProcessed; // number of ranges NOT owned by this node and processed by him

  /** Creates a new instance of JobStatistics
   *  dymanicLoadBalancing - indicates if dynamic load balancing statistics should be used
   * */

  public LocalQueryTaskStatistics(boolean dynamicLoadBalancing) {
    a_beginingTime = 0;
    a_qryProcFinishTime = 0;
    a_finishTime = 0;
    a_numberOfQueries = 0;
    a_totalQueryTime = 0;
    a_maxQueryTime = -1;
    a_minQueryTime = -1;
    a_partitionTuner = null;
    a_idle = false;
    a_totalIdleTime = 0;
    a_dynamicLoadBalancing = dynamicLoadBalancing;
    if (a_dynamicLoadBalancing) {
      a_numDifferentBroadcasts = 0;
      a_numRestartedBroadcasts = 0;
      a_numHelpOffersMsgsReceived = 0;
      a_numForwardedHelpOffersMsgs = 0;
      a_numHelpOffersAcceptancesSent = 0;
      a_numHelpOffersReceived = 0;
      a_numHelpOffersEffectivelyGiven = 0;
      a_numDespisedHelpOfferAcceptanceMsgs = 0;
      a_numOwnedRangesProcessed = 0;
      a_numNotOwnedRangesProcessed = 0;
    }
  }

  public void setIntervalLimits(int begin, int end) {
    a_intervalBeginning = begin;
    a_intervalEnd = end;
  }

  /* begin()
   * When called save the moment when the job has begun
   */
  synchronized public void begin() {
    a_beginingTime = System.currentTimeMillis();
    a_idle = false;
    notifyAll();
  }

  /* endQueryProcessing()
   * When called, save the moment when the job finished processing queries
   */
  synchronized public void endQueryProcessing() {
    a_qryProcFinishTime = System.currentTimeMillis();
    if (a_idle)
      a_totalIdleTime += (a_qryProcFinishTime - a_initIdleInterval);
    notifyAll();
  }

  /* end()
   * When called save the moment when the job finishes
   */
  synchronized public void end() {
    a_finishTime = System.currentTimeMillis();
    notifyAll();
  }

  /*  queryFinished()
   *  This method must be called when a job query finishes.
   *  It then updates statistics
   */
  public synchronized void queryFinished(long elapsedTime) {
    a_numberOfQueries++;
    a_totalQueryTime += elapsedTime;
    if (elapsedTime > a_maxQueryTime)
      a_maxQueryTime = elapsedTime;
    if ( (a_minQueryTime == -1) || (elapsedTime < a_minQueryTime))
      a_minQueryTime = elapsedTime;
    notifyAll();
  }

  /* elapsedTime()
   * Return the elapsed time from job begining to job end
   */
  public synchronized long elapsedTime() {
    long elapsed = a_finishTime - a_beginingTime;
    notifyAll();
    return elapsed;
  }

  public synchronized long timeWaitingAndProcessingQueries() {
    long elapsed = a_qryProcFinishTime - a_beginingTime;
    notifyAll();
    return elapsed;
  }

  public void setPartitionTuner(PartitionTuner tuner) {
    a_partitionTuner = tuner;
  }

  public long numberOfQueries() {
    return a_numberOfQueries;
  }

  public long totalQueryTime() {
    return a_totalQueryTime;
  }

  public synchronized float meanQueryTime() {
    float meanTime = ( (float) a_totalQueryTime) / (float) a_numberOfQueries;
    notifyAll();
    return meanTime;
  }

  public long maxQueryTime() {
    return a_maxQueryTime;
  }

  public long minQueryTime() {
    return a_minQueryTime;
  }

  public void printTuningStatistics(PrintStream out) {
    if (a_partitionTuner != null)
      a_partitionTuner.printTuningStatistics(out);
  }

  public void idle() {
    a_initIdleInterval = System.currentTimeMillis();
    a_idle = true;
  }

  public void notIdle() {
    a_totalIdleTime += (System.currentTimeMillis() - a_initIdleInterval);
    a_idle = false;
  }

  public long idleTime() {
    return a_totalIdleTime;
  }

  public void print(PrintStream out) {
    out.println(getClass().getName() + ": Responsible for interval: " +
		a_intervalBeginning + " - " + a_intervalEnd + ". Size = " +
		(a_intervalEnd - a_intervalBeginning));
    out.println(getClass().getName() + ": Number of Queries: " +
		numberOfQueries());
    out.println(getClass().getName() + ": Elapsed Time: " + elapsedTime() +
		" ms");
    out.println(getClass().getName() +
		": Time Spent Processing and Waiting for Queries: " +
		timeWaitingAndProcessingQueries() + " ms");
    out.println(getClass().getName() + ": Total Query Time: " + totalQueryTime() +
		" ms");
    out.println(getClass().getName() + ": Mean Query Time: " + meanQueryTime() +
		" ms");
    out.println(getClass().getName() + ": Max Query Time: " + maxQueryTime() +
		" ms");
    out.println(getClass().getName() + ": Min Query Time: " + minQueryTime() +
		" ms");
    out.println(getClass().getName() + ": Idle Time: " + idleTime() + " ms");
    if (a_partitionTuner != null)
      a_partitionTuner.printTuningStatistics(out);
    if( a_dynamicLoadBalancing ) {
      out.println( "----- DYNAMIC LOAD BALANCING STATISTICS -----" );
      out.println( "Different Broadcasts: \t" + a_numDifferentBroadcasts );
      out.println( "Restarted Broadcasts: \t" + a_numRestartedBroadcasts );
      out.println( "HelpOffer Msgs Received: \t" + a_numHelpOffersMsgsReceived );
      out.println( "HelpOffer Msgs Forwarded: \t" + a_numForwardedHelpOffersMsgs );
      out.println( "HelpOfferAcceptances Sent: \t" + a_numHelpOffersAcceptancesSent );
      out.println( "HelpOffers Received:     \t" + a_numHelpOffersReceived );
      out.println( "HelpOffers Effectively Given:\t" + a_numHelpOffersEffectivelyGiven );
      out.println( "Despised Help Accetances: \t" + a_numDespisedHelpOfferAcceptanceMsgs );
      out.println( "Owned ranges processed: \t" + a_numOwnedRangesProcessed );
      out.println( "Not owned ranges processed: \t" + a_numNotOwnedRangesProcessed );
    }
  }

  /**
   * newBroadcast()
   *  Indicates this node started a broadcast for a new help offer message
   */
  public void newBroadcast() {
    a_numDifferentBroadcasts++;
  }
  public long getNumDifferentBroadcasts() {
    return a_numDifferentBroadcasts;
  }

  /**
   * broadcastRestarted()
   * Indicates the help offer message broadcast by this node has reached grid
   * extremities and it is still idle. The broadcast will be restarted.
   */
  public void broadcastRestarted() {
    a_numRestartedBroadcasts++;
  }
  public long getNumRestartedBroadcasts() {
    return a_numRestartedBroadcasts;
  }

  /**
   * helpOfferReceived()
   *  Indicates this node received a help offer message
   */
  public void helpOfferMsgReceived() {
    a_numHelpOffersMsgsReceived++;
  }
  public long getNumHelpOfferMsgsReceived() {
    return a_numHelpOffersMsgsReceived;
  }


  /**
   * helpOfferForwarded()
   *  Indicates this node received and forwarded a help offer message
   */
  public void helpOfferForwarded() {
    a_numForwardedHelpOffersMsgs++;
  }
  public long getNumHelpOfferMsgsForwarded() {
    return a_numForwardedHelpOffersMsgs;
  }

  /**
   * helpOfferAccepted()
   *  Indicates this node sent a help offer acceptance message
   */
  public void helpOfferAcceptanceSent() {
    a_numHelpOffersAcceptancesSent++;
  }
  public long getNumHelpOfferAcceptanceMsgsSent() {
    return a_numHelpOffersAcceptancesSent;
  }

  /**
   * helpOfferReceived()
   *  Indicates this node accepted and effectively received a help offer
   */
  public void helpOfferReceived() {
    a_numHelpOffersReceived++;
  }
  public long getNumHelpOffersReceived() {
    return a_numHelpOffersReceived;
  }

  /**
   * helpOfferGiven()
   * Indicates another node sent a help acceptance msg and effectively took the
   * offer.
   */
  public void helpOfferGiven() {
    a_numHelpOffersEffectivelyGiven++;
  }
  public long getNumHelpOffersGiven() {
    return a_numHelpOffersEffectivelyGiven;
  }

  /**
   * helpAcceptanceMsgDespised()
   * Indicates another node accepted a help offer too late. This node is busy
   * again.
   */
  public void helpAcceptanceMsgDespised() {
    a_numDespisedHelpOfferAcceptanceMsgs++;
  }
  public long getNumHelpAcceptanceMsgDespised() {
    return a_numDespisedHelpOfferAcceptanceMsgs;
  }

  /**
   * ownedRangeProcessed()
   *  Indicates this node processed a range owned by itself.
   */
  public void ownedRangeProcessed() {
    a_numOwnedRangesProcessed++;
  }
  public long getNumOwnedRangesProcessed() {
    return a_numOwnedRangesProcessed;
  }

  /**
   * notOwnedRangeProcessed()
   *  Indicates this node processed a range owned by another node.
   */
  public void notOwnedRangeProcessed() {
    a_numNotOwnedRangesProcessed++;
  }
  public long getNumNotOwnedRangesProcessed() {
    return a_numNotOwnedRangesProcessed;
  }

}
