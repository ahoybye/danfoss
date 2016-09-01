global class UserOpportunitiesIterable implements Iterable<AggregateResult>{ 
    global Iterator<AggregateResult> iterator(){ 
        return new UserOpportunitiesIterator(); 
    } 
}