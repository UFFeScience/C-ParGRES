/**
 * 
 */
package org.pargres.grouper;

import java.sql.ResultSet;
import java.util.NoSuchElementException;
import java.util.TreeMap;

/**
 * @author kinder
 *
 */
public class SortedResultSetQueue extends ResultSetQueue {
    
    TreeMap <Integer, ResultSet> list;

    public SortedResultSetQueue() {
        list = new TreeMap<Integer, ResultSet>();
    }

    public synchronized ResultSet pop() throws NoSuchElementException {
        int key = list.firstKey(); 
        ResultSet result = list.get(key);
        list.remove(key);
        notifyAll();
        return result;
    }

    public synchronized void push(int key, ResultSet o) {
        list.put(key, o);
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
