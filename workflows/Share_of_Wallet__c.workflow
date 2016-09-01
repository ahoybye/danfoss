<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <flowActions>
        <fullName>CE_CREATE_UNALLOCATED_AMMOUNT</fullName>
        <flow>CE_UNALLOCATED_AMMOUNT</flow>
        <flowInputs>
            <name>AccountID</name>
            <value>{!Account__r.Id}</value>
        </flowInputs>
        <flowInputs>
            <name>ProductLine</name>
            <value>{!Product_Line__c}</value>
        </flowInputs>
        <label>CE_CREATE_UNALLOCATED_AMMOUNT</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
</Workflow>
