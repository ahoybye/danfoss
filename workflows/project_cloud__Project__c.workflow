<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ccpe_ppm__Project_Dates_Changed_Modstamp</fullName>
        <description>Update the Dates Changed Modstamp so the the trigger can use it</description>
        <field>ccpe_ppm__Dates_Changed_Modstamp__c</field>
        <formula>NOW()</formula>
        <name>Project Dates Changed Modstamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>true</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ccpe_ppm__Project Dates Changed</fullName>
        <actions>
            <name>ccpe_ppm__Project_Dates_Changed_Modstamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK(project_cloud__Start__c)) &amp;&amp; ISBLANK(ccpe_ppm__Program__r.ccpe_ppm__Start__c)) || project_cloud__Start__c &lt; ccpe_ppm__Program__r.ccpe_ppm__Start__c || (NOT(ISBLANK(project_cloud__End__c)) &amp;&amp; ISBLANK(ccpe_ppm__Program__r.ccpe_ppm__End__c)) || project_cloud__End__c &gt; ccpe_ppm__Program__r.ccpe_ppm__End__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
