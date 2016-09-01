<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SLA_Comatrol_Lead_Nitification</fullName>
        <description>SLA:Comatrol Lead Nitification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Lead_Notifications/SLA_Comatrol_Lead_Notification</template>
    </alerts>
    <alerts>
        <fullName>SLA_Comatrol_Lead_Nitification_Account_Manager</fullName>
        <description>SLA:Comatrol Lead Nitification(Account Manager)</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Lead_Notifications/SLA_Comatrol_Lead_Notification</template>
    </alerts>
    <alerts>
        <fullName>SLA_DPS_Lead_Notification</fullName>
        <description>SLA:DPS Lead Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Lead_Notifications/SD_Lead_Notification</template>
    </alerts>
    <alerts>
        <fullName>SLA_DPS_Lead_Notification_Account_Manager</fullName>
        <description>SLA:DPS Lead Notification(Account Manager)</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Lead_Notifications/SD_Lead_Notification</template>
    </alerts>
    <alerts>
        <fullName>SLA_Turolla_Lead_Notification</fullName>
        <description>SLA:Turolla Lead Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Lead_Notifications/SLA_Turolla_Lead_Notification</template>
    </alerts>
    <alerts>
        <fullName>SLA_Turolla_Lead_Notification_Account_Manager</fullName>
        <description>SLA:Turolla Lead Notification(Account Manager)</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Lead_Notifications/SLA_Turolla_Lead_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assigned_Back_to_Distributor</fullName>
        <description>If Distributor recall request then again Assign it to Distributor</description>
        <field>Assigned_To__c</field>
        <literalValue>Distributor</literalValue>
        <name>Assigned Back to Distributor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Assigned_To</fullName>
        <field>Assigned_To__c</field>
        <literalValue>Account Manager</literalValue>
        <name>Populate Assigned To</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Qualified</fullName>
        <field>Status</field>
        <literalValue>Qualified</literalValue>
        <name>Status: Qualified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Unqualified</fullName>
        <field>Status</field>
        <literalValue>Unqualified</literalValue>
        <name>Status: Unqualified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Lead SLA Notification to Account Manager%28Comatrol%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Account Manager</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Business_Org__c</field>
            <operation>equals</operation>
            <value>Comatrol</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.IsConverted</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Unqualified</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead SLA Notification to Account Manager%28DPS%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Account Manager</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Business_Org__c</field>
            <operation>notEqual</operation>
            <value>Integrated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.IsConverted</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Unqualified</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead SLA Notification to Account Manager%28Turolla%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Account Manager</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Business_Org__c</field>
            <operation>equals</operation>
            <value>Turolla</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.IsConverted</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Unqualified</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead SLA Notification to Distributor%28Comatrol%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Distributor</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Business_Org__c</field>
            <operation>equals</operation>
            <value>Comatrol</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead SLA Notification to Distributor%28DPS%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Distributor</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Business_Org__c</field>
            <operation>equals</operation>
            <value>Integrated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead SLA Notification to Distributor%28Turolla%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Distributor</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Business_Org__c</field>
            <operation>equals</operation>
            <value>Turolla</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead SLA Notification to Marketing Team %28DPS%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Marketing Team</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Business_Org__c</field>
            <operation>equals</operation>
            <value>Integrated</value>
        </criteriaItems>
        <description>If Marketing Team have not process lead for 2 Days. Send reminder to them.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead SLA Notification to Marketing Team%28Comatrol%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Marketing Team</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Business_Org__c</field>
            <operation>equals</operation>
            <value>Comatrol</value>
        </criteriaItems>
        <description>If Marketing Team have not process lead for 2 Days. Send reminder to them.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead SLA Notification to Marketing Team%28Turolla%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Marketing Team</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Business_Org__c</field>
            <operation>equals</operation>
            <value>Turolla</value>
        </criteriaItems>
        <description>If Marketing Team have not process lead for 2 Days. Send reminder to them.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead SLA Notification to Partner Manager Queue%28Comatrol%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Partner Manager Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Business_Org__c</field>
            <operation>equals</operation>
            <value>Comatrol</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead SLA Notification to Partner Manager Queue%28DPS%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Partner Manager Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Business_Org__c</field>
            <operation>equals</operation>
            <value>Integrated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead SLA Notification to Partner Manager Queue%28Turolla%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Partner Manager Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Business_Org__c</field>
            <operation>equals</operation>
            <value>Turolla</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
