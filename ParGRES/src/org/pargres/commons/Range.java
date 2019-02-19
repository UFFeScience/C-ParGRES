/*
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 * Pargres Project <http://pargres.nacad.ufrj.br>
 */
package org.pargres.commons;

import java.io.Serializable;

public class Range implements Serializable {

	private static final long serialVersionUID = 3256446910515655737L;
	private String field;
	private String tableName;
	private long rangeInit;
	private long rangeEnd;
	private long cardinality;
    private String rangeMin;
    private String rangeMax;
    
	
	public Range(String field, String tableName, long rangeInit, long rangeEnd, long cardinality) {
		this.field = field;
		this.tableName = tableName;
		this.rangeInit = rangeInit;
		this.rangeEnd = rangeEnd;
		this.cardinality = cardinality;
	}
	
	public String getField() {
		return field;
	}
	public long getRangeEnd() {
		return rangeEnd;
	}
	public long getRangeInit() {
		return rangeInit;
	}
	public String getTableName() {
		return tableName;
	}

	public long getCardinality() {
		return cardinality;
	}

	public void setRangeEnd(long rangeEnd) {
		this.rangeEnd = rangeEnd;
	}

	public void setRangeInit(long rangeInit) {
		this.rangeInit = rangeInit;
	}

    public String getRangeMax() {
        return rangeMax;
    }

    public void setRangeMax(String rangeMax) {
        this.rangeMax = rangeMax;
    }

    public String getRangeMin() {
        return rangeMin;
    }

    public void setRangeMin(String rangeMin) {
        this.rangeMin = rangeMin;
    }

}
