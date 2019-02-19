/*
 * IntervalTree.java
 *
 * Created on 31 mai 2004, 00:15
 */

package org.pargres.util;

/**
 *
 * @author  Alex
 */

import java.io.PrintStream;

public class IntervalTree {

    private IntervalTreeNode root;

    /** Creates a new instance of IntervalTree */
    public IntervalTree(int beginning, int end) {
        root = new IntervalTreeNode(beginning, end);
    }

    public synchronized void removeInterval(int beginning, int end) {
        if (root.removeInterval(beginning, end) == 0)
            root = null;
        notifyAll();
    }

    public boolean isEmpty() {
        return root == null ? true : false;
    }

    public void print(PrintStream p) {
        if (root != null)
            root.print(p, "");
    }
}
