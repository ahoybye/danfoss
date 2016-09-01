/**
 * Utility class for getting role-hierarchy data.
 *
 * Created: 2015-09-16, rmohr@salesforce.com
 */
public with sharing class RoleHierarchyHelper {

  /**
   * Returns a list of user ids for all users reporting to userId.
   */
/*
  public static Set<ID> getAllRoleSubordinateUsers(Id userId) {

    // get requested user's role
    Id roleId = [select UserRoleId from User where Id = :userId].UserRoleId;

    // get all of the roles underneath the user
    Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});

    // get all of the ids for the users in those roles
    Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :allSubRoleIds]);

    // return the ids as a set so you can do what you want with them
    return users.keySet();
  }
*/

  /**
   * Returns a list of user ids for users directly reporting to userId.
   */
  public static Set<ID> getRoleSubordinateUsers(Id userId) {

    // get requested user's role
    Id roleId = [select UserRoleId from User where Id = :userId].UserRoleId;

    // get all of the roles underneath the user
    Set<Id> subRoleIds = getSubRoleIds(new Set<ID>{roleId});

    // get all of the ids for the users in those roles
    Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :subRoleIds]);

    // return the ids as a set so you can do what you want with them
    return users.keySet();
  }
  
  private static Set<ID> getSubRoleIds(Set<ID> roleIds) {

    Set<ID> currentRoleIds = new Set<ID>();
    
    // get id of the role underneath the passed role
    for (UserRole userRole : [select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null]) {
        currentRoleIds.add(userRole.Id);
    }

    return currentRoleIds;
  }
/*
  private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

    Set<ID> currentRoleIds = new Set<ID>();

    // get all of the roles underneath the passed roles
    for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null])
    currentRoleIds.add(userRole.Id);

    // go fetch some more rolls!
    if(currentRoleIds.size() > 0)
      currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));

    return currentRoleIds;
  }
*/
}