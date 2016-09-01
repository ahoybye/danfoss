public class Test_DataFactory {
        
    /* Price Book */
    public static Pricebook2 create_CE_PriceBook () {        
        Pricebook2 pb = new Pricebook2();
        pb.Name='Climate and Energy';
        pb.IsActive=true;
        return pb;
    }
    
    public static Product2 create_CE_Product(string name, string SapID) {
        Product2 p = new Product2();
        p.Name = name;
        p.SAP_Material_Code_CE__c = SapID;        
        return p;
    }
    
    public static Account create_CE_Customer (String name, String currencyIsoCode, String country, String region) {
        /* Create CE Customer */
        Account account = new Account();
        account.Name = name;
        account.Business_Org__c  = 'Climate and Energy';
        account.RecordTypeId = [SELECT Id FROM recordtype WHERE sObjectType='Account' and DeveloperName = 'Customer_CE' and IsActive=true LIMIT 1].Id;
        account.ShippingCountry=country;
        account.Country_MainAddress__c=country;
        account.CurrencyIsoCode='DKK';
        account.Danfoss_Region__c = region;        
        return account;
    }
    
    public static Sales_Area_Master__c create_SalesAreaMaster(string salesOrg, string distChannel, string division) {
        Sales_Area_Master__c sam = new Sales_Area_Master__c();        
        sam.Sales_Area_ID__c= salesOrg + '-' + distChannel + '-' + division;
        sam.Sales_Org__c = SalesOrg;
        sam.Channel__c = distChannel;        
        sam.Division__c = division;
        sam.Sales_Org_Description__c = sam.Sales_Area_ID__c;
        return sam;
    }
    
    public static Sub_Account__c create_SubAccount(string name, string SapID, Account a) {
        Sub_Account__c sa = new Sub_Account__c();
        sa.Name  = name;
        sa.SAP_Account_ID__c = SapID;
        sa.Country_Code__c = a.ShippingCountry;
        sa.City__c = a.ShippingCity;
        sa.Postal_Code__c = a.Postal_Code__c;
        sa.Street__c = a.ShippingStreet;
        sa.Account__c = a.id;
        sa.Currency__c = 'DKK: Danish krone';
        return sa;        
    }
    
    public static Sales_Area__c create_salesArea (Sub_Account__c sa, Sales_Area_Master__c sam) {
        Sales_Area__c sao = new Sales_Area__c();
        sao.Sub_Account__c = sa.Id;
        sao.Sales_Area_Master__c = sam.Id;
        sao.Sales_Area_SAP_ID__c = sa.SAP_Account_ID__c + sam.Sales_Area__c;
        return sao;
    }
    
    public static void setMaster (Account a, Sub_Account__c sa) {
        a.Master_Sub_Account__c=sa.id;
        a.CE_SAP_Account_ID__c=sa.SAP_Account_ID__c;        
    }
}