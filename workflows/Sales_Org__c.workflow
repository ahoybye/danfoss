<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SetNameFieldonSO</fullName>
        <field>Name</field>
        <formula>SAP_Sales_Org__c</formula>
        <name>SetNameFieldonSO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Name field on SO object</fullName>
        <actions>
            <name>SetNameFieldonSO</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>when saved, populate the Name field with the value from the SAP_Sales_Org__c field</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
