<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_AccountPlan_KeyAccount</fullName>
        <field>Special_Conditions__c</field>
        <literalValue>Key Account</literalValue>
        <name>Set AccountPlan KeyAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_AccountPlan_NDA</fullName>
        <field>Special_Conditions__c</field>
        <literalValue>NDA</literalValue>
        <name>Set AccountPlan NDA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CE_AccountPan_Set_Key_Account</fullName>
        <actions>
            <name>Set_AccountPlan_KeyAccount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Account__r.Special_Conditions__c , &quot;Key Account&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CE_AccountPan_Set_NDA</fullName>
        <actions>
            <name>Set_AccountPlan_NDA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Account__r.Special_Conditions__c , &quot;NDA&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
