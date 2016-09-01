@isTest (seealldata=true)
private class Test_LDIControllers {
        static Account account;
        static Contact contactPortal;
        static User portalUser;
        static User adminUser;
        
        static testMethod void myUnitTest() {
           
            createUsers();
            system.runAs(adminUser) {
                account = Test_Utility.createAccount(1);
                insert account;
                contactPortal = Test_Utility.createContact(account.Id,2);
                insert contactPortal;
                List<Profile> portalUserProfiles = [Select id from Profile where Name IN ('PartnerLink - Basic','PartnerLink - Full') limit 1];
                system.assertEquals(portalUserProfiles.size(), 1);
                portalUser = Test_Utility.createPortalUser(contactPortal.Id, portalUserProfiles.get(0).Id);
                insert portalUser;
            }
             
            system.runAs(portalUser){
                LDISearchController scont = new LDISearchController();
                LDIUploadController ucont = new LDIUploadController();
                string ds = scont.debugSoql;
                Distributor_Inventory__c di = new Distributor_Inventory__c();
                di.Account__c = account.id;
                di.SAP_id__c = 'x';
                insert di;
                List<Distributor_Inventory__c> invList = new List<Distributor_Inventory__c>();
                invList = [Select Id, SAP_id__c from Distributor_Inventory__c where SAP_id__c = 'x'];
                List<Distributor_Inventory__c> invtoupload = new List<Distributor_Inventory__c>();
                invtoupload = [Select Id, SAP_id__c from Distributor_Inventory__c where SAP_id__c = 'x'];
                contactPortal.LDI_Region__c = 'Americas';
                update contactPortal;
                scont.getLDIRegions();              
                List<string> lstdist = scont.distributors;
                Pagereference pr = scont.gotoUpload();
                Pagereference pg = Page.LDI_Search;
                Test.setCurrentPage(pg);
                pg.getParameters().put('product', '1100');
                pg.getParameters().put('model', '90');
                pg.getParameters().put('descr', 'kit');
                pg.getParameters().put('distributor', 'Comatrol');
                scont.toggleSort();
                scont.runSearch();
                scont.Cancel();
				Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];
                stdPb.IsActive = true;
                update stdPb;   
                Product2 product2i = new Product2(Name = 'product2i', SAP_Material_Code__c='12345',Business_Org__c = 'Integrated');
                insert product2i;
        
                List<Distributor_Inventory__c> inv = ucont.getuploadedInventory();
                List<string> lstNoProdMatch;
                ucont.getNoMatches();
                lstNoProdMatch = new List<string>();
                ucont.getshowResults();
                invtoupload = [Select Id, SAP_id__c from Distributor_Inventory__c where SAP_id__c = 'x'];
                Blob content = Blob.valueOf('12345,1\n123,2'); 
                ucont.contentFile = content;
                ucont.ReadFile();  
                ucont.nameFile = content.toString();
                String[] filelines = new String[]{};
                Set<string> setPartNumbers = new Set<string>();
                Map<string, string> mapMaterialCodeAndId = new Map<string, string>();
                for (Integer i=1;i<filelines.size();i++)
                {
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                    setPartNumbers.add(inputvalues[0]);
                }
                ucont.getshowResults();
                ucont.gotoSearch(); 
                ucont.getNoMatches(); 
                ucont.getuploadedInventory();           
                ucont.ReadFile();              
                ucont.ProceedWithUpload(); 
                ucont.Cancel(); 
                content = Blob.valueOf('123,1\n123,1');
                ucont.contentFile = content;
                ucont.ReadFile();              
                ucont.ProceedWithUpload(); 
                ucont.getuploadedInventory();
                ucont.getNoMatches();
            }
        }
     
         private static void createUsers() {
              Profile profile = [Select id from Profile where Name = 'System Administrator' limit 1];
              UserRole roles = [Select id from UserRole where Name = 'SFDC_Platform Administrator' limit 1];
              adminUser = Test_Utility.createUser(profile.Id,roles.Id, 1);
              insert adminUser; 
        }
}