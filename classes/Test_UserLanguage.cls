@isTest(SeeAllData=true)
private class Test_UserLanguage {
	static testMethod void testgetUpdateLanguage(){	
		UserRole role = new UserRole();
		Profile profile = new Profile();
		User user = Test_Utility.createUser(profile.Id, role.Id, 1);
		user.LanguageLocaleKey='German';
		
		Quote quote = new Quote(Name = 'Test Quote');
		PageReference pg = Page.UserLanguage;
		Test.setCurrentPage(pg);

		ApexPages.StandardController sc = new ApexPages.standardController(quote);
		
		UserLanguage lang = new UserLanguage(sc);
		lang.newLanguage = user;
		lang.getUpdateLanguage();
		
	}
}