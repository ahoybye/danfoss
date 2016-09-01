/**********************************************************************************
Created By    :    Sumit Mishra
Date          :    10/20/2011
Reason        :    Test method for trigger ValidateDistributer 
**********************************************************************************/
@isTest
private class Test_ValidateDistributer   
{
    static testMethod void unitTest1()
    {
        List<Product_Line__c> lstPL = new List<Product_Line__c>();
        Product_Line__c PL1 = new Product_Line__c(Name='PL1');lstPL.add(PL1);
        Product_Line__c PL2 = new Product_Line__c(Name='PL1');lstPL.add(PL2);
        Product_Line__c PL3 = new Product_Line__c(Name='PL1');lstPL.add(PL3);
        insert lstPL;
		
        Account actP = Test_Utility.createAccount(1);        
        actP.Channel__c ='Distributor';
        actP.Channel_Attributes__c='Partial Line';
        insert actP;
        Account actC = Test_Utility.createAccount(2);        
        actC.Channel__c ='Distributor';
        actC.Channel_Attributes__c='Partial Line';
        actC.ParentId=actP.id;
        insert actC;
        Authorized_Product__c aProd = new Authorized_Product__c(Account__c = actC.Id,Product_Line__c= PL1.id);
        dataBase.Saveresult DBRes = database.insert(aprod,false);
        system.AssertEquals(DBRes.isSuccess(),false);
        
        aProd = new Authorized_Product__c(Account__c = actP.Id,Product_Line__c= PL1.id);
        insert aProd;
        
        aProd = new Authorized_Product__c(Account__c = actC.Id,Product_Line__c= PL1.id);
        DBRes = database.insert(aprod);
        system.AssertEquals(DBRes.isSuccess(),true);
    } 
}