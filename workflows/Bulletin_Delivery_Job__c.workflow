<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Check_Defect_box</fullName>
        <field>Defect_Correction__c</field>
        <literalValue>1</literalValue>
        <name>Check Defect box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_PIB_Number_field</fullName>
        <field>PIB_Number__c</field>
        <formula>Name</formula>
        <name>Populate PIB Number field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Check Defect box</fullName>
        <actions>
            <name>Check_Defect_box</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Bulletin_Delivery_Job__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Defect Correction</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate PIB Number field</fullName>
        <actions>
            <name>Populate_PIB_Number_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Bulletin_Delivery_Job__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Standard</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
