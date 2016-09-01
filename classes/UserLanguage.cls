public class UserLanguage
{
    public Quote quote;
    public User newLanguage {get {return newLanguage;} set {newLanguage = value;} }
    public ApexPages.StandardController cont;
   
    public UserLanguage(ApexPages.StandardController controller)
    {
        this.quote = (Quote) controller.getRecord();
        cont = controller;
        newLanguage = new User();

    }
    
    public PageReference getUpdateLanguage()
    {
        if(newLanguage.LanguageLocaleKey!=null && newLanguage.LanguageLocaleKey!='')
        {
            User curuser = [Select Id, LanguageLocaleKey from User where Id = :UserInfo.getUserId()]; 
            
            
            curuser.LanguageLocaleKey = newLanguage.LanguageLocaleKey;
            
            try {
              update curuser;
            }
            catch(DmlException ex) {
              ApexPages.addMessages(ex);
            }
        }
      return null;
} 
}