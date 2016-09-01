public without sharing class LDIUploadController
{
    public string nameFile{get;set;}
    public transient Blob contentFile{get;set;}
    String[] filelines = new String[]{};
    List<Distributor_Inventory__c> invtouploadORIG = new List<Distributor_Inventory__c>();
    List<Distributor_Inventory__c> invtoupload = new List<Distributor_Inventory__c>();
    private string uId = Userinfo.getUserId();
    private Contact cont;
    private Account acct;
    private User u = [select ContactId, Name, IsPortalEnabled, Business_Org__c From User Where Id = :uId];
    private Product2 prod;
    private Distributor_Inventory__c di;
    private List<Contact> lstContact;
    private List<Product2> lstProducts;
    private List<string> lstNoProdMatch = new List<string>();
    private Set<String> setDI = new Set<String>();    
    public Boolean IsPortalUser {
        get { return u.IsPortalEnabled; }
        set;
    }
    
    public Boolean getshowResults() {
          Boolean bar;
           if (invtoupload.size() == 0 && lstNoProdMatch.size() == 0)
                bar = false;
            else
                bar = true;
            return bar;
    }
   
    public Pagereference ReadFile()
    {
            invtoupload.clear();
            lstNoProdMatch.clear();
            
            if (!u.IsPortalEnabled) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Files can only be uploaded through the portal.'));
              return null;
            }
            lstContact = [Select Name, AccountId, OwnerId from Contact where Id = :u.ContactId];
            if (lstContact.size() == 0)
                cont = [Select Name, AccountId, OwnerId from Contact where Id = '003c0000006C6E5']; 
            else
                cont = [Select Name, AccountId, OwnerId from Contact where Id = :u.ContactId];
            acct = [Select Name, SAP_Account_ID__c, Business_Org__c From Account where Id = :cont.AccountId];
            try {
                nameFile=contentFile.toString();
                contentFile = null;
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a file.'));
                return null;
            }
            filelines = nameFile.split('\n');
            system.debug('filelines: ' + filelines);
            system.debug('filelines.size: ' + filelines.size());
            transient Set<string> setPartNumbers = new Set<string>();
            transient Map<string, string> mapMaterialCodeAndId = new Map<string, string>();
            for (Integer i=0;i<filelines.size();i++) {
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                setPartNumbers.add(inputvalues[0]);
            }
            lstProducts = [Select Name, SAP_Material_Code__c, Model_Code__c From Product2 where SAP_Material_Code__c IN :setPartNumbers];
            system.debug('******************************* lstProducts: ' + lstProducts.size());
            for (Product2 prod : lstProducts)
                mapMaterialCodeAndId.put(prod.SAP_Material_Code__c, prod.Id); 
            try {
                for (Integer i=0;i<filelines.size();i++) {
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
	                    if (mapMaterialCodeAndId.get(inputvalues[0]) != null) {
	                        Distributor_Inventory__c inv = new Distributor_Inventory__c();
	                        inv.Account__c = acct.Id;
	                        inv.Name = inputvalues[0];
	                        inv.Product__c = mapMaterialCodeAndId.get(inputvalues[0]);                              
	                        inv.SAP_id__c = acct.SAP_Account_ID__c + inputvalues[0];    
	                        inv.Quantity__c = Integer.valueOf(inputvalues[1].Trim());
		                        if (setDI.add(inputvalues[0]))
		                        {
		                        	invtoupload.add(inv);
		                        } else {
		                        	system.debug('******************************* duplicate: ' + inputvalues[0]);
		                        }
	                        } else {
	                        lstNoProdMatch.add(inputvalues[0]);
                         }
                }  
                system.debug('******************************* setDI: ' + setDI.size());
            	system.debug('******************************* invtoupload: ' + invtoupload.size());
              	system.debug('******************************* lstNoProdMatch: ' + lstNoProdMatch.size());
	        	} catch (Exception e){
            	  invtoupload.clear();
                  lstNoProdMatch.clear();
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the file or try again later'));
                  return null;
            }
        return null; 
    }
    
    public PageReference ProceedWithUpload()
    {
        try{
            if(LDIpurgeDistributorInventoryWebService.purgeInventoryNotSAP(acct.SAP_Account_ID__c, invtoupload)) {
            //if(LDIpurgeDistributorInventoryWebService.purgeInventory(acct.SAP_Account_ID__c)) {
            //insert invtoupload;
            system.debug('******************************* right after calling webservice');
             invtoupload.clear();
            lstNoProdMatch.clear();
            ApexPages.Message successmsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'Records successfully uploaded! The uploaded inventory will be available within 15 minutes.');
            ApexPages.addMessage(successmsg);
            }
        }
        catch (Exception e){
            system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% duplicate SAP_Id__c: ' + acct.SAP_Account_ID__c );
            invtoupload.clear();
            lstNoProdMatch.clear();
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the file or try again later');
            ApexPages.addMessage(errormsg);
        }
        return null;
    }
    
    public PageReference Cancel()
    {
        invtoupload.clear();
        lstNoProdMatch.clear();
        return null;
    }
    
    public List<string> getNoMatches()
    {
        if (lstNoProdMatch!= NULL)
            if (lstNoProdMatch.size() > 0)
                return lstNoProdMatch;
            else
                return null;
        else
            return null;
    }
    
    public List<Distributor_Inventory__c> getuploadedInventory()
    {
        if (invtoupload!= NULL)
            if (invtoupload.size() > 0)
                return invtoupload;
            else
                return null;                    
        else
            return null;
    }            
 //redirect to Search page
    public PageReference gotoSearch() {
        return new PageReference('/apex/LDI_Search');
    }   

}