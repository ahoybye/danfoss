<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Status_to_Sent</fullName>
        <field>Status__c</field>
        <literalValue>Message Sent</literalValue>
        <name>Set Status to Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>CE_MI_SEND_OBM</fullName>
        <apiVersion>33.0</apiVersion>
        <endpointUrl>https://integrationtest.danfoss.com/XISOAPAdapter/MessageServlet?senderParty=&amp;senderService=BC_Salesforce&amp;receiverParty=&amp;receiverService=&amp;interface=SFDC_BI_AS_OutBMessage&amp;interfaceNamespace=http://salesforce.com/BI</endpointUrl>
        <fields>AccountID__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>integration.ce@danfoss.com</integrationUser>
        <name>CE_MI_SEND_OBM</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>CE_SEND_MIInterfaceTrigger</fullName>
        <actions>
            <name>Set_Status_to_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CE_MI_SEND_OBM</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>Text(Status__c) = &apos;Initiated&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
