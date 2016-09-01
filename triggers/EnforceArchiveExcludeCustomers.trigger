trigger EnforceArchiveExcludeCustomers on CollaborationGroup (before insert, before update) {
    Boolean IsAdmin = false;
    String profileId = UserInfo.getProfileId(); 
    List<Profile> profileList = [Select Id from Profile where Name like 'System Administrator%'];
    for (Profile profile : profileList)
    {
        if (profileId == profile.Id)
        {
            IsAdmin = true;
        }
    }    
    
    if (IsAdmin == false)
    {
        for (CollaborationGroup cg : Trigger.new)
        {
            if (cg.IsAutoArchiveDisabled && cg.CanHaveGuests)
            {
                cg.addError('You cannot disable auto archiving. You do not have sufficient permission to create a Chatter group that includes external customers, please contact an Administrator');
            }
        
     //       if (cg.IsAutoArchiveDisabled && cg.CanHaveGuests == false)
     //       {
     //           cg.addError('You cannot disable auto archiving');
     //       }
             
            if (cg.CanHaveGuests && cg.IsAutoArchiveDisabled == false)
            {
                cg.addError('You do not have sufficient permission to create a Chatter group that includes external customers, please contact an Administrator');
            }
        }
    }
}