trigger EmailMessageTrigger on EmailMessage (before insert) {
    
    if(Trigger.isInsert && Trigger.isBefore){
        DuplicateCaseCheck.processIncomingEmail(trigger.New);
    }
    
}