trigger EmailMessageTrigger on EmailMessage (Before insert) {
    
    if(Trigger.isInsert && Trigger.isBefore){
        DuplicateCaseCheck.processIncomingEmail(trigger.New);
    }
    
}