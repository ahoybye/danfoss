<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CE_UPDATE_MARKED_DELETION_CONTACT_NULL</fullName>
        <field>Marked_for_Deletion__c</field>
        <literalValue>1</literalValue>
        <name>CE_UPDATE_MARKED_DELETION_CONTACT_NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>CE_CONTACT_INTERFACE_SEND_OBM</fullName>
        <apiVersion>33.0</apiVersion>
        <endpointUrl>https://integrationtest.danfoss.com/XISOAPAdapter/MessageServlet?senderParty=&amp;senderService=BC_Salesforce&amp;receiverParty=&amp;receiverService=&amp;interface=SFDC_Contacts_AS_OutBMessage&amp;interfaceNamespace=http://salesforce.com/Contacts</endpointUrl>
        <fields>Contact__c</fields>
        <fields>Id</fields>
        <fields>SAP_Number__c</fields>
        <fields>SubAccountSAPID__c</fields>
        <fields>SubAccount__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>integration.ce@danfoss.com</integrationUser>
        <name>CE_CONTACT_INTERFACE_SEND_OBM</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>CE_SAP_CONTACT_INTERFACE_SEND_OBM</fullName>
        <actions>
            <name>CE_CONTACT_INTERFACE_SEND_OBM</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
