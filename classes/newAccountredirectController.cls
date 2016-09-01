/**********************************************************************************
Created By    :    Sumit Mishra
Date          :    10/18/2011
Reason        :    Redirect account new creation with preset recordtype and business org

Last Modification 
Comments      : (Raj-Danfoss IT) To fix the VF and extension class to make this work in SF1
Date          :  04/04/2016

**********************************************************************************/
public class newAccountredirectController
{
    public string accountURL = '';
    string businessOrg='';
    Private Id accRecTypeId;
    public newAccountredirectController(ApexPages.StandardController controller)
    {
        string recType='';
        string recTypeDeveloperName='';
        
        string businessOrgField=FieldID__c.getOrgDefaults().Business_Org__c;
        
        User usr = [select Business_Org__c from User where Id = :UserInfo.getUserId()];
        businessOrg = usr.Business_Org__c;
        
        for(Account_Record_Type_Mapping__c artm:[Select id,Name,Business_Org__c,Record_Type_Developer_Name__c from Account_Record_Type_Mapping__c where Business_Org__c=:businessOrg])
            recTypeDeveloperName = artm.Record_Type_Developer_Name__c;
        
        
        if (recTypeDeveloperName==null)
            recTypeDeveloperName='Prospect';
               
        for(recordType rType:[Select id from recordType where developerName=:recTypeDeveloperName and SobjectType='Account'])
            recType = rType.id;
        
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        //Added branch for setting the URL for Climate & Energy, which uses Division, DB 12th Nov
      
        If (businessOrg == 'Climate and Energy')
            accountURL = '/apex/searchAccount?' + '&retURL='+retURL;
        Else{
            //Added By Raj - SF1 fix
            If(Network.getNetworkId() != null)
              accountURL = 'e?nooverride=1&ent=Account';
            Else{
                
                string searchname = ApexPages.currentPage().getParameters().get('searchname');
                accountURL ='/001/e?nooverride=1&RecordType='+ recType  +'&ent=Account&'+businessOrgField+'='+businessOrg+'&retURL='+retURL;
            }  
        } 
        
      
    }
    public String getGoToAccount(){return accountURL;}
    
    public string getBusOrg() {return businessOrg;}    
    
    
    public String getRecTypeId() {
        Schema.DescribeSObjectResult describeAcc = Schema.SObjectType.Account;    
        List<Schema.RecordTypeInfo> rtInfos = describeAcc.getRecordTypeInfos();
          for(Schema.RecordTypeInfo rtInfo : rtInfos) {
        if(rtInfo.isDefaultRecordTypeMapping()) {               
            accRecTypeId = rtInfo.getRecordTypeId();
            break;
         }
       }

        return accRecTypeId;
    }
    
    //testmethod of above class
    public static testmethod void testAbove()
    {
        Test.startTest();
        ApexPages.StandardController stc = new ApexPages.StandardController(new Account());
        newAccountredirectController c = new newAccountredirectController(stc);
        c.getGoToAccount();
        C.getBusOrg();
        C.getRecTypeId();
        
        Test.stopTest();

    }

}