/*
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 * Pargres Project <http://pargres.nacad.ufrj.br>
 */
package org.pargres.util;

public class MemoryLeakDetector {
	long minimal;
	long minimal2;
	long diff;
	static int N = 2;
	
	public void begin() {
		for(int i = 0; i < N; i++)
			System.gc();	
			
		minimal = Runtime.getRuntime().totalMemory();		
	}
	
	public void end() throws Exception {
		for(int i = 0; i < N; i++)
			System.gc();	

		minimal2 = Runtime.getRuntime().totalMemory();
		diff = minimal - minimal2;
		if(diff < 0)
			diff *= -1;
		if(diff > 0.0001 * minimal)
			throw new Exception("Memory leak: "+minimal+", "+minimal2);
		
		System.out.println("Memory test ok : "+minimal+", "+minimal2);
	}
}
