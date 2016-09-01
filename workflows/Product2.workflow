<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Product_Code</fullName>
        <field>ProductCode</field>
        <formula>SAP_Material_Code__c</formula>
        <name>Update Product Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Product Code</fullName>
        <actions>
            <name>Update_Product_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.ProductCode</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Update ProductCode field with SAP_Material_Number value.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
