<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_to_completed</fullName>
        <description>PS: Campaign change to completed.</description>
        <field>Status</field>
        <literalValue>Completed</literalValue>
        <name>PS:Change to completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_to_inactive</fullName>
        <field>IsActive</field>
        <literalValue>0</literalValue>
        <name>PS: Change to inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Mark campaign completed after completion date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>notContain</operation>
            <value>Completed,Aborted</value>
        </criteriaItems>
        <description>Change status of campaign to completed after it reaches it&apos;s completion date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Change_to_completed</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Change_to_inactive</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Campaign.EndDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
