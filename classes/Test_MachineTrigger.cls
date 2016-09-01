@isTest //(SeeAllData=true)
private class Test_MachineTrigger {

    static testMethod void myUnitTest() {
        Test_Utility.initTestData();   //create C&E pricebook
        Account acct = Test_Utility.createAccount(1);
        insert acct;
        Machine_Model__c model = new Machine_Model__c(Name = 'machine', Account__c = acct.Id, Annual_Production_Volume__c = 10, Annual_Production_Volume_Plus1__c=10, Annual_Production_Volume_Plus2__c=10, Annual_Production_Volume_Plus3__c=10,Total_Machine_Potential__c = 10.00);
        insert model;
		model.Name = 'machine2';
		update model;
        Product2 prod1 = new Product2(Name = 'prod1', Business_Org__c = 'Danfoss', SAP_Material_Code__c = '123456');
        Product2 prod2 = new Product2(Name='prod2', Business_Org__c = 'Parker', SAP_Material_Code__c = '654321');
		List<Product2> products = new List<Product2>();
		products.add(prod1);
        products.add(prod2);
		insert products;
        Machine_Model_Product__c mmprod1 = new Machine_Model_Product__c(Name = 'mmprod1', Machine_Model__c = model.Id, Machine_Model_Product__c = prod1.Id, Price__c = 2.00, Number_Per_Machine__c = 1, Adoption_Rate__c = 100, Subsystem__c = 'Steering Function', Competitiveness__c = 'High');
        Machine_Model_Product__c mmprod2 = new Machine_Model_Product__c(Name = 'mmprod2', Machine_Model__c = model.Id, Machine_Model_Product__c = prod2.Id, Price__c = 0.00, Number_Per_Machine__c = 1, Adoption_Rate__c = 100);
        Machine_Model_Product__c mmprod3 = new Machine_Model_Product__c(Name = 'mmprod3', Machine_Model__c = model.Id, Machine_Model_Product__c = prod1.Id, Price__c = 2.00, Number_Per_Machine__c = 1);
        List<Machine_Model_Product__c> lstMMProds = new List<Machine_Model_Product__c>();
        lstMMProds.add(mmprod1);
        lstMMProds.add(mmprod2);
        lstMMProds.add(mmprod3);
		System.debug('lstMMProds: ' + lstMMProds);
        insert lstMMProds;
//Start Test		
		Test.startTest();
		double avgContent = 0;
        for (Machine_Model_Product__c p : lstMMProds) {
             if (p.Adoption_Rate__c != null && p.Price__c != null && p.Number_Per_Machine__c != null) 
                avgContent += (mmprod1.Number_Per_Machine__c * mmprod1.Price__c *(mmprod1.Adoption_Rate__c/100));
        }
        system.assertEquals(4, avgContent);
        double potential = avgContent * model.Annual_Production_Volume_Plus3__c;
        model.Total_Machine_Potential__c = potential;
        update model;
		Customer_Part_Number__c cpn = new Customer_Part_Number__c(SAP_Customer_Material_Id__c = '23456', Material_Number__c = '12345', Account__c = acct.Id, Product__c = prod1.Id);
		insert cpn;
		System.debug('lstMMProds after 2nd model update: ' + lstMMProds);
        system.assertEquals(40, model.Total_Machine_Potential__c);
	//test clone
		MIDClonePageControllerExtension contClone = new MIDClonePageControllerExtension();
        Apexpages.Standardcontroller stdcont = new Apexpages.Standardcontroller(model);       
        MIDCloneUtils xclone = new MIDCloneUtils();
        contClone = new MIDClonePageControllerExtension(stdcont);
		string fieldsNames = '';
        string recId = model.Id; 
        String objAPIName= 'Machine_Model_Product__c';          
        String queryString = 'select count(id) total from Machine_Model_Product__c where Machine_Model__c=\'' + String.escapeSingleQuotes(recId) + '\'';
        SObject result = Database.query(queryString);
        if((Integer)result.get('total')>0)
            fieldsNames = fieldsNames + objAPIName + ','; 
        list<String> selectedChildObjAPINames=New list<String>();
        if(fieldsNames.length()>0) {
            for(String childObjAPIName:fieldsNames.split(',')) {
                selectedChildObjAPINames.add(childObjAPIName);
            }
        }
        MIDCloneUtils cclone = new MIDCloneUtils(model.Id, selectedChildObjAPINames);
        xclone.startsClone(model.Id, selectedChildObjAPINames);
        PageReference prClone = contClone.chainClone();
	//test VF page	
        MIDProductListingControllerExtension contPage = new MIDProductListingControllerExtension();
        contPage = new MIDProductListingControllerExtension(stdcont);
        Pagereference prPage = contPage.NewMachineProduct();
        List<Machine_Model_Product__c> lstprods= contPage.getSteeringProducts();
        lstprods = contPage.getPropelProducts();
        lstprods = contPage.getFanDriveProducts();
        lstprods = contPage.getWorkFunctionProducts();
        lstprods = contPage.getElectronicsProducts();
		contPage.prodToDel = mmprod1.Id;
		contPage.deleteProduct();
		//model.Annual_Production_Volume_Plus3__c = null;
		//update model;
/*		Machine_Model_Product__c mmprod2 = new Machine_Model_Product__c(Machine_Model__c = model.Id, Machine_Model_Product__c = prod1.Id, Name = 'machine prod2', Price__c = 10, 
        		Number_Per_Machine__c = 10, Adoption_Rate__c = 100, Subsystem__c = 'Steering Function', Competitiveness__c = 'High');
        insert mmprod2;*/
		
		delete model;
		Test.stopTest();
        }
}