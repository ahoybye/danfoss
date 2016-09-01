public with sharing class MIDProductListingControllerExtension {

    private Machine_Model__c mach;
    private Machine_Model_Product__c prod;
    public String subsystem { get; set; }
    public String mmprodName { get; set; }
    public String curr { get; set; }
	public string prodToDel{get;set;}
    private ApexPages.standardController controller {get;set;}
    public List<Machine_Model_Product__c> steeringlist;
    public List<Machine_Model_Product__c> propellist;
    public List<Machine_Model_Product__c> fanDrivelist;
    public List<Machine_Model_Product__c> workFunctionlist;
    public List<Machine_Model_Product__c> electronicslist;
    public string mmprodURL = '';
    public string mmprodescaped;
    
    public MIDProductListingControllerExtension(ApexPages.StandardController stdcontroller) {
            controller = stdController;
            this.mach = (Machine_Model__c)stdcontroller.getRecord();
    } 
    
    //Constructor
    public MIDProductListingControllerExtension(){ 
    }
      
    public PageReference NewMachineProduct(){
        /* if (!Test.isRunningTest())
         	mmprodName = mmprodName.replace('&','%26');
         mmprodURL = '/a0P/e?CF00NC0000005Mmuy=' + mmprodName + '&Name=(populated on save)&00NC0000005MmvE=' + subsystem + '&retURL=%2F'+mach.id;
         PageReference np = new PageReference(mmprodURL);*/ 
        PageReference np = new PageReference('/apex/AddMachineProduct?id=' + mach.Id + '&subsystem=' + subsystem + '&retURL=%2F'+mach.id); //00NC0000005MmvE
		np.setRedirect(true);
        return np;  
    }
	
	public pagereference deleteProduct()
    {     
        if(prodToDel!=null)
        {
			delete new Machine_Model_Product__c(Id=prodToDel);
        }
        
        return null;
    }
    
    public List<Machine_Model_Product__c> getSteeringProducts() {
            steeringlist = [SELECT Machine_Model__c, Machine_Model__r.Name, Name, Price__c, Machine_Model_Product__c, Product_Type__c, Total_Product_units__c, Total_Product_value__c, Competitiveness__c, Machine_Model_Product__r.Name, Subsystem__c, Supplier__c, Number_Per_Machine__c, Adoption_Rate__c FROM Machine_Model_Product__c Where Subsystem__c LIKE 'Steering%' AND Machine_Model__c=:mach.id];
            return steeringlist;
    }
    public List<Machine_Model_Product__c> getPropelProducts() {
            propellist = [SELECT Machine_Model__c, Machine_Model__r.Name, Name, Price__c, Machine_Model_Product__c, Product_Type__c, Total_Product_units__c, Total_Product_value__c, Competitiveness__c, Machine_Model_Product__r.Name, Subsystem__c, Supplier__c, Number_Per_Machine__c, Adoption_Rate__c FROM Machine_Model_Product__c Where Subsystem__c LIKE 'Transmission%' AND Machine_Model__c=:mach.id];
            return propellist;
    }
    public List<Machine_Model_Product__c> getFanDriveProducts() {
            fanDrivelist = [SELECT Machine_Model__c, Machine_Model__r.Name, Name, Price__c, Machine_Model_Product__c, Product_Type__c, Total_Product_units__c, Total_Product_value__c, Competitiveness__c, Machine_Model_Product__r.Name, Subsystem__c, Supplier__c, Number_Per_Machine__c, Adoption_Rate__c FROM Machine_Model_Product__c Where Subsystem__c = 'Fan Drive' AND Machine_Model__c=:mach.id];
            return fanDrivelist;
    }
    public List<Machine_Model_Product__c> getWorkFunctionProducts() {
            workFunctionlist = [SELECT Machine_Model__c, Machine_Model__r.Name, Name, Price__c, Machine_Model_Product__c, Product_Type__c, Total_Product_units__c, Total_Product_value__c, Competitiveness__c, Machine_Model_Product__r.Name, Subsystem__c, Supplier__c, Number_Per_Machine__c, Adoption_Rate__c FROM Machine_Model_Product__c Where Subsystem__c = 'Working Function' AND Machine_Model__c=:mach.id];
            return workFunctionlist;
    }
    public List<Machine_Model_Product__c> getElectronicsProducts() {
            electronicslist = [SELECT Machine_Model__c, Machine_Model__r.Name, Name, Price__c, Machine_Model_Product__c, Product_Type__c, Total_Product_units__c, Total_Product_value__c, Competitiveness__c, Machine_Model_Product__r.Name, Subsystem__c, Supplier__c, Number_Per_Machine__c, Adoption_Rate__c FROM Machine_Model_Product__c Where Subsystem__c = 'HMI and Electronics' AND Machine_Model__c=:mach.id];
            return electronicslist;
    }
}