global class OTAggregateResultIterable implements Iterable<AggregateResult>{ 
    global Iterator<AggregateResult> iterator(){ 
        return new OTAggregateResultIterator(); 
    } 
}