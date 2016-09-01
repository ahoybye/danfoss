<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>sync_Sales_Org_Code</fullName>
        <description>Sync sales org code with the record name</description>
        <field>Sales_Org_Code__c</field>
        <formula>Name</formula>
        <name>sync Sales Org Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate Sales Org Code</fullName>
        <actions>
            <name>sync_Sales_Org_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Sales_Org_Master__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Keeping Sales Org and Sales Org Code in sync - auto update on this field - Integration requires an external id - therefore we created new field with that type</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
