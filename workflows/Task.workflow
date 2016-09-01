<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CE_OUTLOOK_SET_TYPE</fullName>
        <field>Type__c</field>
        <literalValue>Communication</literalValue>
        <name>CE_OUTLOOK_SET_TYPE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Completed_Date</fullName>
        <description>Only for PS Customer Request BU and Material Extension tasks - set Actual Finish Date to today when Status is set to &apos;Completed&apos;</description>
        <field>Actual_Finish_Date__c</field>
        <formula>Today()</formula>
        <name>Stamp Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CE_OUTLOOK_SET_TYPE</fullName>
        <actions>
            <name>CE_OUTLOOK_SET_TYPE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND (    BEGINS(Subject, &quot;Email:&quot;)  ,  RecordType.DeveloperName = &quot;C_E_Task&quot; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PS allMID relevant DOW task</fullName>
        <actions>
            <name>allMID</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 or 3 or 4 or 5 or 6 or 7 or 8 or 9 or 10 or 11 or 12 or 13)</booleanFilter>
        <criteriaItems>
            <field>Task.allMID_relevant_information__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CRM_Acct Mgr APAC PS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CRM_Acct Mgr Dist CHINA PS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CRM_Acct Mgr Dist EU - PS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CRM_Acct Mgr OEM CHINA PS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CRM_Acct Mgr OEM EU PS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CRM_Sales Mgr APAC PS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CRM_Sales Mgr Dist EU PS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CRM_Sales Mgr OEM EU PS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CRM_Service Team Mgr APAC PS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CRM_Service Team Mgr CHINA PS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CRM_Service Team Mgr EU PS</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>CRM_Marketing PS</value>
        </criteriaItems>
        <description>Send notification to DOW creator if allMID relevant</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Completed Date</fullName>
        <actions>
            <name>Stamp_Completed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Order__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Request BU Task,Material Extension Task</value>
        </criteriaItems>
        <description>Only for PS Customer Request BU and Material Extension tasks - set Actual Finish Date to today when Status is set to &apos;Completed&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>allMID</fullName>
        <assignedToType>owner</assignedToType>
        <description>You have created an allMID relevant Activity related to this account (at creation date of this task). Please update allMID accordingly.

Make sure to capture all relevant machine models and components

Contact dzhaobauer@danfoss.com with questions</description>
        <dueDateOffset>30</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Task.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>allMID</subject>
    </tasks>
</Workflow>
