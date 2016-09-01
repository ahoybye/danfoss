/**********************************************************************************
Created By    :    Sumit Mishra
Date          :    10/14/2011
Reason        :    Test method for TestonProductAfterInsertCreatePBEntry  
**********************************************************************************/
@isTest (seealldata=true)
private class Test_onProductAfterInsertCreatePBEntry  
{
    static testMethod void unitTest1() 
    {
        List<Product_Line__c> lstPL = new List<Product_Line__c>();
        Product_Line__c PL1 = new Product_Line__c(Name='PL1',PL_Code__c='XPL1',Business_Org__c='Comatrol');
        lstPL.add(PL1);
        Product_Line__c PL2 = new Product_Line__c(Name='PL2',PL_Code__c='XPL2',Business_Org__c='Integrated');
        lstPL.add(PL2);
        Product_Line__c PL3 = new Product_Line__c(Name='PL3',PL_Code__c='XPL3',Business_Org__c='Turolla');
        lstPL.add(PL3);
        Product_Line__c PL4 = new Product_Line__c(Name='PL4',PL_Code__c='XPL4');
        lstPL.add(PL4);
        Product_Line__c PL5 = new Product_Line__c(Name='PL5',PL_Code__c='XPL5',Business_Org__c='Valmova');
        lstPL.add(PL5);
        Insert lstPL;
        List<product2> lstProduct = new List<product2>();
        product2 prod1 = new product2(Name = 'testProduct111', productCode='tp111', SAP_Product_Line_Code__c ='XPL1');
        lstProduct.add(prod1);
        product2 prod2 = new product2(Name = 'testProduct112', productCode='tp112', SAP_Product_Line_Code__c ='XPL2');
        lstProduct.add(prod2);
        product2 prod3 = new product2(Name = 'testProduct113', productCode='tp113', SAP_Product_Line_Code__c ='XPL3');
        lstProduct.add(prod3);
        product2 prod4 = new product2(Name = 'testProduct114', productCode='tp114', SAP_Product_Line_Code__c ='XPL4');
        lstProduct.add(prod4);
        product2 prod5 = new product2(Name = 'testProduct115', productCode='tp115', SAP_Product_Line_Code__c ='XPL5');
        lstProduct.add(prod5);
        product2 prod6 = new product2(Name = 'testProduct116', productCode='tp114');
        lstProduct.add(prod6);
        
        insert lstProduct;        
    }
}