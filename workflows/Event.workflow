<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <flowActions>
        <fullName>CE_EVENT_DIVISION_OUTLOOK_FLOW</fullName>
        <flow>CE_Event_Set_Division_if_Blank_for_Outlook_Integration</flow>
        <flowInputs>
            <name>EventID</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>UserDivision</name>
            <value>{!Owner:User.Division__c}</value>
        </flowInputs>
        <label>CE_EVENT_DIVISION_OUTLOOK_FLOW</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
</Workflow>
