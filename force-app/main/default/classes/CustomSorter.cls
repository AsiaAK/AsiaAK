/*
 * Created by Admin on 4/25/2018.
 */
global class CustomSorter implements Comparable{
	//public String ID;
	public Object obj;
	public Integer orderMultiplyer = 1;
	public Object comparableValue;
    public Decimal secondComparableValue;
	private Integer BIGGER = 1;
	private Integer SMALLER = -1;
	private Integer EQUALS = 0;
    

	public CustomSorter(Object obj, Integer orderMultiplyer, Object comparableValue, Decimal secondComparableValue){
		 this.obj = obj;
		 this.orderMultiplyer = orderMultiplyer;
		 this.comparableValue = comparableValue;
         this.secondComparableValue = secondComparableValue;
	}

	global Integer compareTo(Object compareTo) {
		Integer result = EQUALS;
        CustomSorter compareToEntity = (CustomSorter)compareTo;
        result =  compareByFirstParametr(compareToEntity);
		return result * this.orderMultiplyer;
	}

	private Integer compareByFirstParametr(CustomSorter compareToEntity){
        
        if(this.comparableValue instanceof Date) {
            Date comparableDate = (Date)this.comparableValue;
			Date compareToDate = (Date)compareToEntity.comparableValue;
            if(comparableDate == compareToDate) return compareBySecondParametr(compareToEntity);		
			return (comparableDate > compareToDate) ? BIGGER : SMALLER;
        }
        
        if(this.comparableValue instanceof Decimal) {
            if ((Decimal)this.comparableValue == (Decimal)compareToEntity.comparableValue) return compareBySecondParametr(compareToEntity);
        	return ((Decimal)this.comparableValue > (Decimal)compareToEntity.comparableValue) ? BIGGER : SMALLER;
        }
        
        if(this.comparableValue instanceof String) {
            if ((String)this.comparableValue == (String)compareToEntity.comparableValue) return compareBySecondParametr(compareToEntity);
            return ((String)this.comparableValue > (String)compareToEntity.comparableValue) ? BIGGER : SMALLER;
        }
		
        return SMALLER;
	}
    
    private Integer compareBySecondParametr(CustomSorter compareToEntity) {
        if(this.secondComparableValue > compareToEntity.secondComparableValue) {        
        	return this.orderMultiplyer == 1 ? BIGGER : SMALLER;                
        } else if(this.secondComparableValue < compareToEntity.secondComparableValue) {
        	return this.orderMultiplyer == 1 ? SMALLER : BIGGER;
        } else {
        	return EQUALS;
        }
    }
}