/*
 * QueryResultQueue.java
 *
 * Created on 17 novembre 2003, 16:59
 */

package org.pargres.grouper;

/**
 * 
 * @author lima
 */

import java.sql.ResultSet;
import java.util.LinkedList;
import java.util.NoSuchElementException;

public class ResultSetQueueImpl extends ResultSetQueue{

    LinkedList<ResultSet> list;

    public ResultSetQueueImpl() {
        list = new LinkedList<ResultSet>();
    }

    public synchronized ResultSet pop() throws NoSuchElementException {
        ResultSet result = list.removeFirst();
        notifyAll();
        return result;
    }

    public synchronized void push(int key, ResultSet o) {
        list.addLast(o);
        notifyAll();
    }

    public synchronized void clear() {
        list.clear();
        notifyAll();
    }

    public synchronized boolean isEmpty() {
        boolean empty = list.isEmpty();
        notifyAll();
        return empty;
    }

}