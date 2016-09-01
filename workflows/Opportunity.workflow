<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <flowActions>
        <fullName>CSC_CLOSE_CASE_FROM_OPP</fullName>
        <flow>CSC_CER_CLOSE_CASE</flow>
        <flowInputs>
            <name>CaseApplication</name>
            <value>{!Originating_Case__r.Application__c}</value>
        </flowInputs>
        <flowInputs>
            <name>CaseAttribute</name>
            <value>{!Originating_Case__r.Opportunity_Attribute__c}</value>
        </flowInputs>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Originating_Case__c}</value>
        </flowInputs>
        <flowInputs>
            <name>OppID</name>
            <value>{!Id}</value>
        </flowInputs>
        <label>CSC_CLOSE_CASE_FROM_OPP</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
</Workflow>
