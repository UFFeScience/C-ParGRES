/**
 * 
 */
package org.pargres.util;

/**
 * @author kinder
 * 
 */
public class Hash {
    public static Integer code(String s, int a) {
        return (s.hashCode() & 0x7FFFFFFF) % a;
    }
}
