public class SetAsMainAccountExtension {
    
    private ID aaid; 
    
    public SetAsMainAccountExtension(ApexPages.StandardController controller) {
        aaid = controller.getId();
    }
    
    public PageReference gotoOpp() {
        // Associated_Account__c assoc_acc = (Associated_Account__c)controller.getRecord();
        //get the associated account fields - aa is the account you want to make the account on the opp
        Associated_Account__c aa = [select Associated_Account__c, SubAccount__c, Contact__c, Project_Opportunity__c, Name, Id from Associated_Account__c where Id = :aaid];
        //the parent opp is the parent opportunity
        Opportunity parentopp = [select Id, name, Sub_Account__c, Contact__c, AccountId from Opportunity where Id = :aa.Project_Opportunity__c];
        
        
        List<Associated_Account__c> preExistingAA = [
            select Associated_Account__c, SubAccount__c, Contact__c, Type_of_Association__c
            from Associated_Account__c
            where Associated_Account__c = :parentopp.AccountId and Project_Opportunity__c = :aa.Project_Opportunity__c
        ];       
        if (preExistingAA.isEmpty()) {
            Associated_Account__c newAA = new Associated_Account__c();
            newAA.Project_Opportunity__c = aa.Project_Opportunity__c;
            newAA.Associated_Account__c = parentopp.AccountId;
            newAA.Contact__c = parentopp.Contact__c;
            newAA.SubAccount__c = parentopp.Sub_Account__c;
            newAA.Type_of_Association__c = 'Previous Main Account';
            insert newAA;
        } else {
            preExistingAA[0].Type_of_Association__c = 'Previous Main Account';
            preExistingAA[0].Contact__c = parentopp.Contact__c;
            preExistingAA[0].SubAccount__c = parentopp.Sub_Account__c;
            update preExistingAA[0];
        }
        
        parentopp.AccountId = aa.Associated_Account__c;
        parentopp.Sub_Account__c = aa.SubAccount__c;
        parentopp.Contact__c = aa.Contact__c;
       
        //Added Feb 11th - auto set the Sales Area if available from Associated Account
        if (aa.SubAccount__c != null)
        {
            List<Sales_Area__c> listSA =[select id from Sales_Area__c where Sub_Account__c =:aa.SubAccount__c limit 1];
            if(listSA.size() == 1){parentopp.Sales_Area__c = listSA[0].id;}
            else
            {parentopp.Sales_Area__c = null;}
        }
        else{parentopp.Sales_Area__c = null;}
                
        update parentopp;
        
        aa.Type_of_Association__c = 'Main Account';
        update aa;
        
        return new PageReference('/' + parentopp.id);
    }
    
}