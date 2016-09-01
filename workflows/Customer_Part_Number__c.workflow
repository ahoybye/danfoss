<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IsDeleted_To_True_For_Null_Value</fullName>
        <description>Upon Insert/Update, Mark IsDeleted = True if Material_Number__c = null</description>
        <field>isDeleted__c</field>
        <literalValue>1</literalValue>
        <name>IsDeleted To True For Null Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IsDeleted %3D True For Null Value</fullName>
        <actions>
            <name>IsDeleted_To_True_For_Null_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Part_Number__c.Material_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Upon Insert/Update, Delete record if Material_Number__c = Null</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
