<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Account_Merge_request_Drives</fullName>
        <description>Notify if new Account Merge is requested for Drives</description>
        <protected>false</protected>
        <recipients>
            <recipient>k.nitsch@danfoss.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lars.sorensen@danfoss.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Notifications/New_Account_Merge_is_requested_1</template>
    </alerts>
    <alerts>
        <fullName>New_Account_Merge_request_Heating</fullName>
        <description>Notify if new Account Merge is requested for Heating</description>
        <protected>false</protected>
        <recipients>
            <recipient>k.nitsch@danfoss.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>liliya.todorova@danfoss.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Notifications/New_Account_Merge_is_requested_1</template>
    </alerts>
    <alerts>
        <fullName>Notify_if_new_Account_Merge_request_Cooling</fullName>
        <description>Notify if new Account Merge is requested for Cooling</description>
        <protected>false</protected>
        <recipients>
            <recipient>k.nitsch@danfoss.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Notifications/New_Account_Merge_is_requested_1</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Merged_Account_Name</fullName>
        <field>Merged_Account_Name__c</field>
        <formula>Merged_Account__r.Name</formula>
        <name>Set Merged Account Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CE New Account Merge is requested %28Cooling%29</fullName>
        <actions>
            <name>Notify_if_new_Account_Merge_request_Cooling</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account_Merge_Request__c.Danfoss_Segment__c</field>
            <operation>equals</operation>
            <value>Cooling</value>
        </criteriaItems>
        <description>When a New Account Merge is requested, an email alert will be sent to Cooling segment responsible</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CE New Account Merge is requested %28Drives%29</fullName>
        <actions>
            <name>New_Account_Merge_request_Drives</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Merge_Request__c.Danfoss_Segment__c</field>
            <operation>equals</operation>
            <value>Drives</value>
        </criteriaItems>
        <description>When a New Account Merge is requested, an email alert will be sent to Drives segment responsible</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CE New Account Merge is requested %28Heating%29</fullName>
        <actions>
            <name>New_Account_Merge_request_Heating</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Merge_Request__c.Danfoss_Segment__c</field>
            <operation>equals</operation>
            <value>Heating</value>
        </criteriaItems>
        <description>When a New Account Merge is requested, an email alert will be sent to heating segment responsible</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Merged Account Name</fullName>
        <actions>
            <name>Set_Merged_Account_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK( Merged_Account__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
