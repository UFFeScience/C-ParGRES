/**
 * 
 */
package org.pargres.grouper;

import java.sql.ResultSet;
import java.util.NoSuchElementException;

/**
 * @author kinder
 * 
 */
public abstract class ResultSetQueue {

    public abstract ResultSet pop() throws NoSuchElementException;

    public abstract void push(int key, ResultSet o);

    public abstract void clear();

    public abstract boolean isEmpty();
}
