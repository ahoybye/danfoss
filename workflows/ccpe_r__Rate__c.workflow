<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ccpe_r__CCPE_Update_Standard_User_Rate</fullName>
        <field>ccpe_r__Initial_Rate__c</field>
        <formula>ccpe_r__User__r.ccpe_r__Rate__c</formula>
        <name>CCPE - Update Standard User Rate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ccpe_r__CCPE - Update Standard User Rate</fullName>
        <actions>
            <name>ccpe_r__CCPE_Update_Standard_User_Rate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>ccpe_r__Rate__c.ccpe_r__Initial_Rate__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
