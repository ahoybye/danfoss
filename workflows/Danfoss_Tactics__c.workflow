<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Set Due Date Task</fullName>
        <actions>
            <name>Strategy_Due_Date</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Danfoss_Tactics__c.Due_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>test</fullName>
        <active>false</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>Strategy_Due_Date</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Danfoss_Tactics__c.Due_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Strategy Due Date</subject>
    </tasks>
</Workflow>
