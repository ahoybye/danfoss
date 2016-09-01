/**
  * Class 			: DisplayAccountTeamController 
  * Developed by 	: Shailendra Singh(Appirio Offshore)
  * Created Date 	: 17/08/2012
  * Related Task	: T-70975
  * Description		: Display Team members of current Portal user
 */
public without sharing class DisplayAccountTeamController {
	public List<TeamMember> teamMembers{get;set;}
	
	final static String ACCOUNT_OWNER = 'Account Owner';
	final static String CUSTOMER_SERVICE_REP= 'Customer Service Rep';
	final static String SALES_SPECIALIST = 'Sales Specialist';
	final static String SYSTEM_APPLICATION_ENGINEER = 'Systems & Applications Engineer';
	final static String PRODUCT_APPLICATION_ENGINEER = 'Products Application Engineer';
	
	public DisplayAccountTeamController(){
		teamMembers = fetchTeamMember();
			
	}
	
	/*
	@return List of Account Team members of current User
	*/
	private List<TeamMember> fetchTeamMember(){
		List<TeamMember> teamMembers = new List<TeamMember>();
		User currentLoginUser =  [Select AccountId, ContactId From User u where ID =: Userinfo.getUserId()];
		for (Account acc : [Select Owner.Phone,Owner.Email,OwnerId,Owner.Name  From Account Where ID =:currentLoginUser.AccountId]) {
			teamMembers.add(new TeamMember(acc.Owner.Name, acc.Owner.Email, ACCOUNT_OWNER, acc.Owner.phone));
		}
		String teamMemberRole;
		for (AccountTeamMember team : [Select User.Phone,User.Email,User.Id,UserId,TeamMemberRole,user.Name From AccountTeamMember Where
									 AccountId = :currentLoginUser.AccountId AND (TeamMemberRole =:CUSTOMER_SERVICE_REP OR
									 TeamMemberRole =:SYSTEM_APPLICATION_ENGINEER OR TeamMemberRole =:SALES_SPECIALIST OR TeamMemberRole =:PRODUCT_APPLICATION_ENGINEER)]) {
			if (team.TeamMemberRole == CUSTOMER_SERVICE_REP) {
				teamMemberRole = CUSTOMER_SERVICE_REP;
			} else if (team.TeamMemberRole == SYSTEM_APPLICATION_ENGINEER) {
				teamMemberRole = SYSTEM_APPLICATION_ENGINEER;
			} else if (team.TeamMemberRole == SALES_SPECIALIST) {
				teamMemberRole = SALES_SPECIALIST;
			} else if (team.TeamMemberRole == PRODUCT_APPLICATION_ENGINEER) {
				teamMemberRole = PRODUCT_APPLICATION_ENGINEER;
			}
			teamMembers.add(new TeamMember(team.User.Name, team.User.Email, teamMemberRole, team.User.phone));		
		}	
		return teamMembers;	
	}
	
	
	/*
	Represent Account Team Member  
	*/
	public class TeamMember{
		public String name{get;set;}
		
		public String email{get;set;}
		
		public String title{get;set;}
		
		public String phone{get;set;}
		
		public TeamMember(String name, String email, String title, String phone){
			this.name = name;
			this.email = email;
			this.title = title;
			this.phone = phone;
		}
	}
}