@isTest
private class Test_UpdateOrigBDJWithDefectBDJ {

    static testMethod void TestUpdateOrigBDJWithDefectBDJ() {
        Account acc = Test_Utility.createAccount(1);
    	insert acc;
    	integer i = 1;
    	Bulletin_Delivery_Job__c bdj = Test_Utility.createBulletinDeliveryJob('Test Bulletin Job ' + i, false);
    	insert bdj;
    	Bulletin_Accounts__c ba = Test_Utility.createBulletinAccounts(bdj.Id, acc.Id, false);
    	insert ba;
    	Bulletin_Delivery_Log__c bdl = Test_Utility.createBullDelLog('Test Log 1', ba.Id, false);
    	insert bdl;
    	bdl.Business_Org__c = 'Integrated';
    	update bdl;
    	
    }
}