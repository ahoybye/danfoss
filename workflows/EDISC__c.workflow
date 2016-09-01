<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_EDISC_name</fullName>
        <field>Name</field>
        <formula>IF(OR(TEXT(Primary_Profile__c)=&quot;&quot;, TEXT(Secondary_Profile__c)=&quot;&quot;), &quot;Not Completed&quot;, TEXT(Primary_Profile__c)+ &quot;/&quot; +TEXT(Secondary_Profile__c) )</formula>
        <name>Update EDISC name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update EDISC Name</fullName>
        <actions>
            <name>Update_EDISC_name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISCHANGED(Primary_Profile__c), ISCHANGED(Secondary_Profile__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
