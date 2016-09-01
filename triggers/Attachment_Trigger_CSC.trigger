trigger Attachment_Trigger_CSC on Attachment (before insert) {

    If(Trigger.isInsert && Trigger.isBefore)
	{
	
		email2CaseAttachment.chatterAttachment(Trigger.new);
	}
    
}