public without sharing class SetAsOwner  {
    
    public ID Userid; 
    public ID Caseid;
    public case c;
    public String CaseUrl {get;set;}
    public String CaseNumber{get;set;}
    
    public SetAsOwner(ApexPages.StandardController controller) {
        Caseid = ApexPages.currentPage().getParameters().get('Caseid');
        Userid = ApexPages.currentPage().getParameters().get('Userid');
    }
    
    public void gotoCase() {          
        
      case c = [select subject, casenumber, ownerid, Id from case where Id = :Caseid];
      c.ownerid = Userid;
     
        try
        {
             update c;
        }
        catch (DMLException ex) {
            ApexPages.addMessages(ex);
            }
        catch (Exception ex) {
            ApexPages.addMessages(ex);
            }

        CaseUrl = c.id;
        CaseNumber = c.CaseNumber;
        //return new PageReference('/' + Caseid);
    }
    
}