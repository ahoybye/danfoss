/******************************************************
* Author        :  Shailendra Singh (Appirio Offshore)
* Name          :  OpportunityManagement
* Date          :  09/08/2012
* Related Task  :  T-68281
* Description   :  Util Methods for functionality around opportunity
*******************************************************/
public without sharing class OpportunityManagement {
    
    public static User u = [select Id, Sales_Org__c, IsPortalEnabled from User where Id = :UserInfo.getUserId()]; 
       
    public static void getSalesOrg(List<Opportunity> lstOpptys)  //BEFORE INSERT
    {
        Set<String> setAcctIds = new Set<String>();
        for(Opportunity oppty :lstOpptys){ 
            setAcctIds.add(oppty.AccountId);
        }
        List<Account> lstAccts = [select SAP_Account_ID__c From Account where Id IN :setAcctIds];  
		Map<Id, String> mapAcctIdandSAPId = new Map<Id, String>();
        for(Account acct :lstAccts)
        { 
			if(!mapAcctIdandSAPId.containsKey(acct.Id)){
                mapAcctIdandSAPId.put(acct.Id, acct.SAP_Account_ID__c);		//it's a text field
            }         
        }
        List<Sales_Org__c> lstSO = [select Id, SAP_Account_Id__c, Name From Sales_Org__c where SAP_Account_Id__c IN :mapAcctIdandSAPId.values() and SAP_Account_Id__c != '' and SAP_Account_Id__c != null and Inactive__c = false];
		Map<String, Sales_Org__c> mapSO = new Map<String, Sales_Org__c>();
		for(Sales_Org__c so :lstSO){
			if(!mapSO.containsKey(so.SAP_Account_Id__c + u.Sales_Org__c)){
                mapSO.put(so.SAP_Account_Id__c + u.Sales_Org__c, so);
            }         
		}			
        for(Opportunity oppty : lstOpptys){
            if (!lstSO.isEmpty() && lstSO.size() == 1)  {
                for (Sales_Org__c s :lstSO)
                    oppty.Sales_Org__c = s.Id;
            }
            else if (!lstSO.isEmpty() && lstSO.size() > 1 && u.Sales_Org__c != '' && u.Sales_Org__c != null) {
				oppty.Sales_Org__c = mapSO.get(mapAcctIdandSAPId.get(oppty.AccountId)+u.Sales_Org__c).Id;
            }
            else if (!lstSO.isEmpty() && oppty.Sales_Org__c == null)
                oppty.addError('You must select a Sales Org.');
        }
    }
    
    public static void checkForCompetitorPrice(List<Opportunity> lstOpptys)  //BEFORE INSERT, BEFORE UPDATE
    {
        List <OpportunityLineItem> lstOLIs = new List <OpportunityLineItem>();
        Set<Id> setOpptyIds = new set<Id>();
        for (Opportunity oppty :lstOpptys){
            if ((oppty.StageName == 'Closed Won' || oppty.StageName == 'Closed Lost') && oppty.Reason_Won_Lost__c == 'Price'){
                setOpptyIds.add(oppty.Id); 
            }
        }
        lstOLIs = [Select OpportunityId, Competitor__c, Approx_Competitor_Price__c From OpportunityLineItem Where OpportunityId IN :setOpptyIds and (Approx_Competitor_Price__c = null or Competitor__c = null)];
        setOpptyIds.clear();
        if (!lstOLIs.isEmpty()) {
            for (OpportunityLineItem oli :lstOLIs){
                setOpptyIds.add(oli.OpportunityId);
            }
        }
        if (!setOpptyIds.isEmpty()){
            List<Opportunity> lstOpps = [select Id From Opportunity where Id IN :setOpptyIds];
            for (Opportunity oppty :lstOpptys) {
            	oppty.addError('All products for this opportunity must have an approximate competitor price and competitor entered before the opportunity can be saved in a closed stage with a reason of "Price"');
            }   
        }
    }
    
    public static void CompilePartNumbersFromOLI(List<Opportunity> lstOpptys)  //BEFORE UPDATE
    {
        List <OpportunityLineItem> lstOLIs = new List <OpportunityLineItem>();
        Map<Id, List <string>> mapOLIs = new Map<Id, List <string>>(); 
        for (Opportunity oppty :lstOpptys){
            if(!mapOLIs.containsKey(oppty.Id)){
                mapOLIs.put(oppty.Id, new List<string>());
            }         
        }
        lstOLIs = [select OpportunityId, PricebookEntry.ProductCode, Customer_Material_Number__c From OpportunityLineItem where OpportunityId IN :mapOLIs.keySet()];
		if (!lstOLIs.isEmpty()){
	    	for (OpportunityLineItem oli :lstOLIs){
				mapOLIs.get(oli.OpportunityId).add(oli.PricebookEntry.ProductCode);
				if(oli.Customer_Material_Number__c != '' && oli.Customer_Material_Number__c != null)
					mapOLIs.get(oli.OpportunityId).add(oli.Customer_Material_Number__c);
			}
			if (!mapOLIs.values().isEmpty()){
				for(Opportunity oppty :lstOpptys){
					oppty.OLInumbers__c = '';
					List<String> lstStrMaterials = mapOLIs.get(oppty.Id);
	                for (string s :lstStrMaterials){
						if(s != null){
		                    if (oppty.OLInumbers__c == '' || oppty.OLInumbers__c == null)
								oppty.OLInumbers__c = s + ', ';
		                    else if(!oppty.OLInumbers__c.contains(s))
								oppty.OLInumbers__c += s + ', ';
						}
					}
				}	
			}
		}		
		else
			for (Opportunity oppty :lstOpptys)
				if(mapOLIs.get(oppty.Id).isEmpty())
					oppty.OLInumbers__c = '';
    }
    
    public static void notifyOpportunityAccountTeam(Set<ID> opptyIds)  //AFTER INSERT (only if a portal user)
    {
        Map<ID,Contact> userContactMap = new Map<ID,Contact>();
        if(!u.isPortalEnabled){ // Opportunity is not created By an portal User
            return;
        }
		Id templateId = ApprovalEmailTemplateMapping__c.getInstance('New Opportunity from PartnerLink').Email_Template_ID__c;
        List<Opportunity> oppList = [Select ID,AccountID,Account.OwnerID,Account.Owner.Name,Account.Owner.FirstName,Account.Owner.LastName,Account.Owner.Email From Opportunity Where ID IN :opptyIds];
        for(Opportunity opp : oppList){
            if(opp.AccountId != null){ 
                Contact contact = new Contact(FirstName = opp.Account.Owner.FirstName,LastName = opp.Account.Owner.LastName,Email = opp.Account.Owner.Email);
                userContactMap.put(opp.Account.OwnerID,contact);                        
            }
            
            if(!userContactMap.isempty()){
                insert userContactMap.values();
            }
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Opportunity opp : oppList){
            if(opp.AccountId != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(userContactMap.get(opp.Account.OwnerId).Id);
				mail.setSaveAsActivity(false);
                mail.setWhatId(opp.Id);
                mail.setTemplateId(templateId);    
                emails.add(mail);
            }
        }
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails,false);
        }
        // After sending Email delete Contact records;
        if(!userContactMap.isempty()){
            delete userContactMap.values();
        }           
    }
    
    public static void handleReplacementBusiness(List<Opportunity> lstOpptys, map<Id, Opportunity> mapOpptys)  //AFTER UPDATE
    {
        Set<Id> setOpptyIds = new Set<Id>();
        for (Opportunity oppty : lstOpptys){
            Opportunity opptyOld = mapOpptys.get(oppty.Id);
            if (opptyOld.Type == 'Replacement Business' && oppty.Type == 'Existing Business'){
                setOpptyIds.add(oppty.Id);
            }
        }
        List<OpportunityLineItem> OLIs = [select UnitPrice, Proposed_Price__c from OpportunityLineItem where OpportunityId IN :setOpptyIds];        
        for(OpportunityLineItem oli :OLIs){           
            oli.Proposed_Price__c = oli.UnitPrice;
            oli.UnitPrice = 0.00;
        }
        update OLIs;
    }
    
    @future
    public static void updateOpptyOwner(Set<Id> setOpptyIDs)  //AFTER INSERT
    {
        if (u.isPortalEnabled) {
            List<Opportunity> oppList = [Select ID, AccountId, Account.OwnerID From Opportunity Where ID IN :setOpptyIDs];
            for(Opportunity oppty :oppList){                
                oppty.ownerId = oppty.Account.OwnerId;
                //Create Account Team Member for Partner Portal User
                List<AccountTeamMember> members = new List<AccountTeamMember>();
                AccountTeamMember member = new AccountTeamMember();
                member.AccountId = oppty.AccountId;
                member.TeamMemberRole = 'Partner';
                member.UserId = Userinfo.getUserId();
                members.add(member);
                
                if (!members.isEmpty()) {
                    insert members;
                }
                List<AccountShare> shares = [select Id, OpportunityAccessLevel, RowCause, UserOrGroupId from AccountShare 
                                            where AccountId = :oppty.AccountId and UserOrGroupId = :Userinfo.getUserId()];
                // set Partner team members access as follows: ACCOUNT: Read (default), CONTACT: Read (preferrably Read/Write for Prospect Accounts - if only one option is available default to Read/Write),                           OPPORTUNITY Read/Write, CASE: Private (default)
                for (AccountShare share : shares)  {
                    share.OpportunityAccessLevel = 'Edit';
                    share.ContactAccessLevel = 'Edit';
                }
                update shares;  
            }
            if(!oppList.isEmpty())
                update oppList; 
        }   
    }   
}