<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CE_CSC_UPDATE_ROUTING_EMAIL2</fullName>
        <field>Case_Email_Sent_To__c</field>
        <formula>TRIM(LEFT(ToAddress, 255))</formula>
        <name>CE_CSC_UPDATE_ROUTING_EMAIL2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>CE_CSC_STORE_ROUTING_EMAIL</fullName>
        <actions>
            <name>CE_CSC_UPDATE_ROUTING_EMAIL2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to store the Email id at which the customer email was recieved for Email to Case. This will be Used to Set the Default From Email</description>
        <formula>AND(ISBLANK(Parent.Case_Email_Sent_To__c),  Incoming )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
