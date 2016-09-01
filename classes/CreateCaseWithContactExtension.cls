/**
 * Screen popped by the CTI system when no contact is found in the system. Allows the user to create a new contact (and optionally a new account), and then redirects the user to the case creation screen.
 * @author Jesper Kristensen, Capgemini Sogeti
 * @date april 2014
 */
public class CreateCaseWithContactExtension {
    
    // For input fields
    public Case theCase {get;set;}
    public Contact contact {get;set;}
    public Account account {get;set;}
    public ID selectedCaseRecordType {get;set;}
    public List<SelectOption> caseRecordTypes {get;set;}
    
    // Search results
    public Boolean completeAcc {get;set;}
    public Boolean didSearch {get;set;}
    public ApexPages.StandardSetController casesCon {get;set;}
    public ApexPages.StandardSetController contactsCon {get;set;}
    public ApexPages.StandardSetController accountsCon {get;set;}
    public boolean accountNameSearched {get;set;}
    // Override phone number prompt
    public Contact oldContact {get;set;}
    
    // Selected action
    public ID selectedCaseId {get;set;}
    public ID selectedContactId {get;set;}
    public ID selectedAccountId {get;set;}
    public String createCaseUrl {get;set;}
    public String accountCaseUrl {get;set;}
    
    public CreateCaseWithContactExtension() {
        accountNameSearched = false;
        completeAcc = false;
        didSearch = false;
        theCase = new Case();
        contact = new Contact();
        account = new Account();
        // parameter from https://newvoicemedia.atlassian.net/wiki/display/DP/Creating+a+Visualforce+page+to+pop
        String phone = ApexPages.currentPage().getParameters().get('ANI');
        if (phone != null && phone.trim() != '') {
            for (PicklistEntry pe : Schema.sObjectType.Contact.fields.Phone_Country__c.getPicklistValues()) {
                if (pe.isActive()) {
                    String countryCode = pe.getValue().substringAfter('(').substringBefore(')');
                    if (phone.startsWith(countryCode)) {
                        contact.Phone_Country__c = pe.getValue();
                        contact.Phone_Local__c = phone.removeStart(countryCode);
                        if (countryCode != '+') {
                            break;
                        }
                    }
                }
            }
        }
        
        caseRecordTypes = new List<SelectOption>();
        for (RecordTypeInfo rti : Case.sObjectType.getDescribe().getRecordTypeInfos()) {
            if (rti.isDefaultRecordTypeMapping()) {
                selectedCaseRecordType = rti.getRecordTypeId();
            }
            // The Master record type has isAvailable = true even if it is not actually available, therefore we filter it out expelictly by its ID.
            if (rti.isAvailable() && rti.getRecordTypeId() != '012000000000000AAA') {
                caseRecordTypes.add(new SelectOption(rti.getRecordTypeId(), rti.getName()));
            }
        }
    }
    
    public void search() {
        didSearch = true;
        accountNameSearched = false; 
        try {
            //String firstNameLike = contact.FirstName == null ? '%' : '%' + contact.FirstName + '%';
            //String lastNameLike = contact.LastName == null ? '%' : '%' + contact.LastName + '%';
            //contacts = [select Id, Name, AccountId, Email, Phone from Contact where (FirstName like :firstNameLike and LastName like :lastNameLike) or (Email = :contact.Email and Email != null) or (Phone = :contact.Phone and Phone != null) limit 1000];
            List<String> contactSearchNames = new List<String>();
            if (contact.FirstName != null && contact.FirstName.trim() != '') {
                contactSearchNames.add(contact.FirstName + '*');
            }
            if (contact.LastName != null && contact.LastName.trim() != '') {
                contactSearchNames.add(contact.LastName + '*');
            }
            String contactSearchName = String.join(contactSearchNames, ' AND ');
            List<String> contactSearchTerms = new List<String>();
            if (contactSearchName.trim() != '') {
                contactSearchTerms.add(contactSearchName);
            }
            if (contact.Email != null && contact.Email.trim() != '') {
                contactSearchTerms.add(contact.Email);
            }
            String pn = getPhone();
            if (pn != null && pn.trim() != '') {
                contactSearchTerms.add(pn);
            }
            String contactSearchString = String.join(contactSearchTerms, ' OR ');
            // Search for: (FirstName AND LastName) OR Email OR Phone
            
            List<String> casesFields = new List<String> {'Id'};
            for (FieldSetMember field : SObjectType.Case.FieldSets.CreateCaseWithContactResults.getFields()) {
                casesFields.add(field.getFieldPath());
            }
            casesCon = new ApexPages.StandardSetController(Search.query('find :contactSearchString returning Case(' + String.join(casesFields, ', ') + ') limit 1000')[0]);
            casesCon.setPageSize(5);
            
            List<String> contactFields = new List<String> {'Id'};
            for (FieldSetMember field : SObjectType.Contact.FieldSets.CreateCaseWithContactResults.getFields()) {
                contactFields.add(field.getFieldPath());
            }
            contactsCon = new ApexPages.StandardSetController(Search.query('find :contactSearchString returning Contact(' + String.join(contactFields, ', ' ) + ' where account.name like \'%' + account.Name_2__c + '%\') limit 1000')[0]);
            contactsCon.setPageSize(5);
            
            //String accountNameLike = '%' + account.Name + '%';
            //accounts = [select Id, Name from Account where Name like :accountNameLike limit 1000];
            String accountSearchString;
            if (account.Name_2__c != '')
            {
             accountNameSearched = true;  
             accountSearchString = '*' + account.Name_2__c + '*';
            }
            else
            {
             accountSearchString = 'noaccountselected';
            }
            
            List<String> accountFields = new List<String> {'Id'};
            for (FieldSetMember field : SObjectType.Account.FieldSets.CreateCaseWithContactResults.getFields()) {
                accountFields.add(field.getFieldPath());
            }
            accountsCon = new ApexPages.StandardSetController(Search.query('find :accountSearchString in NAME FIELDS returning Account(' + String.join(accountFields, ', ') + ') limit 1000')[0]);
            accountsCon.setPageSize(5);
        } catch (SearchException ex) {
            // for example "search term must be longer than one character"
            ApexPages.addMessages(ex);
            didSearch = false;
        }
    }
    
    public List<Case> getCases() {
        return casesCon.getRecords();
    }
    
    public List<Contact> getContacts() {
        return contactsCon.getRecords();
    }
    
    public List<Account> getAccounts() {
        return accountsCon.getRecords();
    }
    
    public void createCase() {
        // Create case
        
        theCase.RecordTypeId = selectedCaseRecordType;
        theCase.Origin = 'Phone';
        insert theCase;
        ApexPages.StandardController caseController = new ApexPages.StandardController(theCase);
        PageReference pr = caseController.edit();
        pr.getParameters().put('retURL', caseController.view().getUrl());
        /*
        Contact selectedContact = [select Id, Name, Account.Id, Account.Name from Contact where Id = :selectedContactId];
        PageReference pr = new PageReference('/500/e');
        pr.getParameters().put('cas3_lkid', selectedContact.Id);
        pr.getParameters().put('cas3', selectedContact.Name);
        pr.getParameters().put('cas4_lkid', selectedContact.Account.Id);
        pr.getParameters().put('cas4', selectedContact.Account.Name);
        pr.getParameters().put('RecordType', selectedCaseRecordType);
		*/
        createCaseUrl = pr.getUrl();
    }
    
    public void selectCase() {
        createCaseUrl = new ApexPages.StandardController(new Case(Id = selectedCaseId)).view().getUrl();
       	selectedAccountId =[select accountid from case where id=:selectedCaseId].accountID;
        accountCaseUrl = new ApexPages.StandardController(new Account(id=selectedAccountId)).view().getUrl();
    }
    
    public void selectContact() {
        theCase.ContactId = selectedContactId;
        oldContact = [select Name, Phone, MobilePhone from Contact where Id = :selectedContactId];
    }
    
    public String getPhone() {
        String cc = '';
        if (contact.Phone_Country__c != null && contact.Phone_Country__c.trim() != '') {
            cc = contact.Phone_Country__c.substringAfter('(').substringBefore(')');
        }
        if (contact.Phone_Local__c != null && contact.Phone_Local__c.trim() != '') {
            return cc + contact.Phone_Local__c;
        }
        return null;
    }
    
    public void updateContactPhone() {
        // Update contact and create case
        
        Contact newContact = new Contact(Phone_Local__c = contact.Phone_Local__c, Phone_Country__c = contact.Phone_Country__c, Id = selectedContactId);
        try {
            update newContact;
        } catch(DMLException e) {
            ApexPages.addMessages(e);
            return;
        }
        createCase();
    }
    
    public void updateContactMobile() {
        // Update contact and create case
        
        Contact newContact = new Contact(Mobile_Local__c = contact.Phone_Local__c, Mobile_Country__c = contact.Phone_Country__c, Id = selectedContactId);
        try {
            update newContact;
        } catch(DMLException e) {
            ApexPages.addMessages(e);
            return;
        }
        createCase();
    }
    
    public void selectAccount() {
        // Create contact and case
        
        contact.AccountId = selectedAccountId;
        
        // Begin copy from CreateContactExtension
        Account a = [select Language_CE__c, Country_MainAddress__c, fax_Country__c, Country_Phone__c, Division__c from Account where Id = :selectedAccountId];
        contact.Language__c = a.Language_CE__c;
        contact.Fax_Country__c = a.fax_Country__c;
        //contact.Phone_Country__c = a.Country_Phone__c;
        
        contact.Country_PrivateAddress__c = a.Country_MainAddress__c;
        contact.Division__c = a.Division__c;
        contact.Mobile_Local__c = contact.Phone_Local__c;
        contact.Mobile_Country__c = contact.Phone_Country__c;
        // End copy from CreateContactExtension
        
        insert contact;
        theCase.ContactId = contact.Id;
        createCase();
    }
    
    
    public void selectNothingAdv() {
        completeAcc = true;
    }
    
    public void selectNothing() {
        // Create account, contact and case
        
        // Begin copy from SearchAccountExtension
        
        User u = [select Id, Name, Business_Org__c, Division__c, User_Country__c, Phone_Country_Code__c from User where Id = :UserInfo.getUserId()];
        account.Country_MainAddress__c  = u.User_Country__c;
        //acc.BillingCountry = u.User_Country__c;
        account.ShippingCountry = u.User_Country__c;
      //  account.Division__c = u.Division__c;
        account.Business_Org__c = u.Business_Org__c;
        account.Country_Phone__c = u.Phone_Country_Code__c;
        account.Fax_Country__c = u.Phone_Country_Code__c;
        account.Country_POBox__c = account.Country_MainAddress__c;
        //get the recordtype
        String recTypeDeveloperName;
        List<Account_Record_Type_Mapping__c> artms = [select Record_Type_Developer_Name__c from Account_Record_Type_Mapping__c where Business_Org__c = :u.Business_Org__c];
        if (artms.isEmpty()) {
            recTypeDeveloperName = 'Prospect';
        } else {
            recTypeDeveloperName = artms[0].Record_Type_Developer_Name__c;
        }
        account.RecordTypeId = [select Id from RecordType where DeveloperName = :recTypeDeveloperName and SobjectType = 'Account'].Id;
        account.Country_POBox__c = account.Country_MainAddress__c;        
        account.ShippingCountry= account.Country_MainAddress__c;
     //   account.name = account.Name_2__c;
     //   account.Name_2__c = '';
        // End copy from SearchAccountExtension
        try {
            insert account;
        } catch(DMLException e) {
            ApexPages.addMessages(e);
            return;
        }
       
        selectedAccountId = account.Id;
        selectAccount();
    }
    
    public void selectNoContact() {
        
        //Defect 1st May 2015: Case RecordType must be a Support Case i.e. where Account / Contact not mandatory. 1st May 2015
      //   selectedCaseRecordType = [select Id from RecordType where DeveloperName = 'Support_Case' and SobjectType = 'Case'].Id;
        
        List<String> names = new List<String>();
        if (contact.FirstName != null) {
            names.add(contact.FirstName);
        }
        if (contact.LastName != null) {
            names.add(contact.LastName);
        }
        theCase.SuppliedName = String.join(names, ' ').trim();
        theCase.SuppliedCompany = account.Name;
        theCase.SuppliedEmail = contact.Email;
       //Defect 1st May 2015: WebPhone is not being set to ANI
        // replace theCase.SuppliedPhone =  getPhone();
        theCase.SuppliedPhone= ApexPages.currentPage().getParameters().get('ANI');

        createCase();
    }
    
}