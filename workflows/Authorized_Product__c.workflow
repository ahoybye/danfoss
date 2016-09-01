<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Dist_Territory</fullName>
        <field>Dist_Territory__c</field>
        <formula>TEXT( Distribution_Territory__c )</formula>
        <name>Dist Territory</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Dist Territory</fullName>
        <actions>
            <name>Dist_Territory</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Authorized_Product__c.Distribution_Territory__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Distribution Territory updates to text field from picklist for searching</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
