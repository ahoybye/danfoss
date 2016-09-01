public without sharing class LDISearchController {
  public String soql {get;set;}
  //public transient List<Distributor_Inventory__c> invList {get;set;}
  private Set<string> setregions = new Set<string>();
  private List<string> regions = new List<string>();
  private transient string busorg;
  public String product {get; set;}
  String model = '';
    String descr = '';
    String distributor = '';
    
      public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
      }
     
      public String sortField {
        get  { if (sortField == null) {sortField = 'Product__c'; } return sortField;  }
        set;
      }
     
      public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        runQuery();
      }
     
      public String debugSoql {
        get { return soql + ' order by ' + sortField + ' ' + sortDir; }
        set;
      }
     
      public LDISearchController () {
        refreshInventoryList();
      }
 
     public void refreshInventoryList() {
        setCont = new ApexPages.Standardsetcontroller([select Name, Product__c From Distributor_Inventory__c Where Name = '4410075xxxx']);
     }
     
     public PageReference runSearch() {
        product = Apexpages.currentPage().getParameters().get('product');
        model = Apexpages.currentPage().getParameters().get('model');
        descr = Apexpages.currentPage().getParameters().get('descr');
        distributor = Apexpages.currentPage().getParameters().get('distributor');
        sortField = 'Product__c';
        sortDir = 'desc';
        runQuery();
        setregions.clear();
        regions.clear();
        return null;
      }
          
      public void runQuery() {
       try {
                    getLDIRegions();
                    User u;
                    u = [select ContactId, Name, IsPortalEnabled, Business_Org__c From User Where Id = :Userinfo.getUserId()];
                    if (u.IsPortalEnabled) 
                        soql = 'select Count() from Distributor_Inventory__c Where Account__r.Business_Org__c = \'' + busorg + '\' and Account__r.LDI_Region__c IN ' + regions;
                    else
                        soql = 'select Count() from Distributor_Inventory__c Where Account__r.Business_Org__c = \'' + busorg + '\' and Account__r.Name != null';
                    if (!product.equals(''))
                      soql += ' and Name LIKE \'%'+String.escapeSingleQuotes(product)+'%\'';
                    if (!model.equals(''))
                      soql += ' and Product__r.Model_Code__c LIKE \'%'+String.escapeSingleQuotes(model)+'%\'';
                    if (!descr.equals(''))
                      soql += ' and Product__r.Name LIKE \'%'+String.escapeSingleQuotes(descr)+'%\''; 
                    if (!distributor.equals(''))
                    soql += ' and Account__r.Name = \''+String.escapeSingleQuotes(distributor)+'\'';
                    system.debug('******************************* soql: ' + soql + ' order by ' + sortField + ' ' + sortDir);
                    if (Database.countQuery(soql) > 10000) {
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'More than 10,000 records found. Please change your search criteria to return fewer records.'));
                    }
                    else {
                        if (u.IsPortalEnabled)
                            soql = 'select Name, Product__c, Product__r.Name, Product__r.Model_Code__c, Quantity__c, Price__c, LastModifiedDate, Account__c, Account__r.Name, Account__r.LDI_Region__c, Account__r.Phone, Account__r.LDI_Email__c from Distributor_Inventory__c Where Account__r.Business_Org__c = \'' + busorg + '\' and Account__r.LDI_Region__c IN ' + regions;
                        else
                            soql = 'select Name, Product__c, Product__r.Name, Product__r.Model_Code__c, Quantity__c, Price__c, LastModifiedDate, Account__c, Account__r.Name, Account__r.LDI_Region__c, Account__r.Phone, Account__r.LDI_Email__c from Distributor_Inventory__c Where Account__r.Business_Org__c = \'' + busorg + '\' and Account__r.Name != null';
                    if (!product.equals(''))
                      soql += ' and Name LIKE \'%'+String.escapeSingleQuotes(product)+'%\'';
                    if (!model.equals(''))
                      soql += ' and Product__r.Model_Code__c LIKE \'%'+String.escapeSingleQuotes(model)+'%\'';
                    if (!descr.equals(''))
                      soql += ' and Product__r.Name LIKE \'%'+String.escapeSingleQuotes(descr)+'%\''; 
                    if (!distributor.equals(''))
                    soql += ' and Account__r.Name = \''+String.escapeSingleQuotes(distributor)+'\'';
                    setCont = new ApexPages.Standardsetcontroller(Database.getQueryLocator(soql + ' order by ' + sortField + ' ' + sortDir));
                        setCont.setPageSize(30);
                    }
                } catch (Exception e) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Oops!'));
            }
      }  
  
        public ApexPages.StandardSetController setCont { get; set; }
            
        public Boolean hasNext {
            get {
                return setCont.getHasNext();
            }
        }
        
        public Boolean hasPrevious {
            get {
                return setCont.getHasPrevious();
            }
            set;
        }

        public Integer resultSize {
            get {
                return setCont.getResultSize();
            }
            set;
        }

        public Integer PageSize {
            get {
                return setCont.getPageSize();
            }
            set;
        }
            
        public Integer pageNumber {
            get {
                return setCont.getPageNumber();
            }
            set;
        }
        
        public Integer totalPages {
            get {
                totalPages = setCont.getResultSize() / setCont.getPageSize();
                return totalPages;
            }
            set;
        }
        
        public void first() {
            setCont.first();
        }
    
        public void last() {
            setCont.last();
        }
    
        public void previous() {
            setCont.previous();
        }
    
        public void next() {
            setCont.next();
        }
        public List<Distributor_Inventory__c> inventList {
            get {
                if (setCont != null)
                    return (List<Distributor_Inventory__c>)setCont.getRecords();
                else
                    return null;
            }
            set;
        }

      public void getLDIRegions() {
        setregions.clear();
        regions.clear();    
        string uId;
        User u;
        Contact cont;
        List<Contact> lstContact;
        Account acct;
        uId = Userinfo.getUserId();
        u = [select ContactId, Name, IsPortalEnabled, Business_Org__c From User Where Id = :uId];
        if (u.IsPortalEnabled) {
          lstContact = [Select Name, AccountId, OwnerId from Contact where Id = :u.ContactId];
          if (lstContact.size() == 0)
              cont = [Select Name, AccountId, LDI_Region__c from Contact where Id = '003c0000006C6E5'];
          else
            cont = [Select Name, AccountId, LDI_Region__c from Contact where Id = :u.ContactId];
          acct = [Select Name, SAP_Account_ID__c, LDI_Region__c, Business_Org__c From Account where Id =:cont.AccountId];
          busorg = acct.Business_Org__c;  
          setregions.add('\'' + acct.LDI_Region__c + '\'');
          if (cont.LDI_Region__c != null && cont.LDI_Region__c != '')
              for(string r : cont.LDI_Region__c.split(';'))
                  setregions.add('\'' + r + '\'');
                  regions.addAll(setregions);
        } else {
          busorg = u.Business_Org__c;
          schema.Describefieldresult f = Schema.getGlobalDescribe().get('account').getDescribe().fields.getMap().get('LDI_Region__c').getDescribe();
          List<Schema.PicklistEntry> P = f.getPicklistValues();
          for (Schema.PicklistEntry v:P) {
            regions.add('\'' + v.getValue() + '\'');
          }
        }
      }  
          
    public PageReference Cancel()
    {
        setCont = new ApexPages.Standardsetcontroller([select Name, Product__c From Distributor_Inventory__c Where Name = 'noproduct__c']);
        setregions.clear();
        regions.clear();
        return null;        
    }
 
  public List<String> distributors {
    get {
      string tmpDist;
      if (distributors == null) {
        distributors = new List<String>();
        getLDIRegions();
        User u;
        u = [select ContactId, Name, IsPortalEnabled, Business_Org__c From User Where Id = :Userinfo.getUserId()];
        if (u.IsPortalEnabled) 
            soql = 'Select Account__r.Name, Count(Id) From Distributor_Inventory__c Where Account__r.Business_Org__c = \'' + busorg + '\' and Account__r.LDI_Region__c IN ' + regions + ' Group by Account__r.Name Having Count(Id) > 0';
        else
            soql = 'Select Account__r.Name, Count(Id) From Distributor_Inventory__c Where Account__r.Business_Org__c = \'' + busorg + '\' Group by Account__r.Name Having Count(Id) > 0';
        List<AggregateResult> results = Database.query(soql);
        for (AggregateResult ar :results) {
            tmpDist = String.valueof(ar.get('Name'));
            distributors.add(tmpDist);
        }
      }
      
      return distributors;          
   }
    set;
    
  }  
    public PageReference gotoUpload() {
        return new PageReference('/apex/LDI_Upload');
    } 
}