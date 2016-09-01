<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <flowActions>
        <fullName>CSC_ASSIGNBACKOFFICESALES_MILESTONE_CLOSE</fullName>
        <description>Flow trigger to close the Case Milestone &apos;Assign To Back Office/Sales/TSO&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>Assign To Back Office/Sales/TSO</value>
        </flowInputs>
        <label>CSC_ASSIGNBACKOFFICESALES_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_ASSIGNBACKOFFICE_MILESTONE_CLOSE</fullName>
        <description>Flow trigger to close the Case Milestone &apos;Assign To Back Office&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>Assign To Back Office</value>
        </flowInputs>
        <label>CSC_ASSIGNBACKOFFICE_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_ASSIGNINTERSALES_MILESTONE_CLOSE</fullName>
        <description>Flow Trigger to Close the case milestone &apos;Assign case to THD/TSO/Internal Sales/CSH&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>Assign case to THD/TSO/Internal Sales/CSH</value>
        </flowInputs>
        <label>CSC_ASSIGNINTERSALES_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_ASSIGNSALES_MILESTONE_CLOSE</fullName>
        <description>This Flow trigger is to close the Case Milestone with Name &apos;Assign to Sales&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>Assign to Sales / TSO</value>
        </flowInputs>
        <label>CSC_ASSIGNSALES_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_ASSIGNSERVICECO_MILESTONE_CLOSE</fullName>
        <description>Flow trigger to close the Case Milestone &apos;Assign case to Service coordinator&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>Assign case to Service coordinator</value>
        </flowInputs>
        <label>CSC_ASSIGNSERVICECO_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_ASSIGNSERVICEENGR_MILESTONE_CLOSE</fullName>
        <description>Flow trigger to Close the Case Milestone &apos;Assign case to Service Engineer&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>Assign case to Service Engineer</value>
        </flowInputs>
        <label>CSC_ASSIGNSERVICEENGR_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_ASSIGNSOLSPL_MILESTONE_CLOSE</fullName>
        <description>Flow Trigger to Close the Case Milestone &apos;Assign to Solution specialist owner&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>Assign to Solution specialist owner</value>
        </flowInputs>
        <label>CSC_ASSIGNSOLSPL_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_ASSIGNTSO_MILESTONE_CLOSE</fullName>
        <description>Flow Trigger to Close the Case Milestone &apos;Assign to TSO/Application specialist/THD&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>Assign to TSO/Application specialist/THD</value>
        </flowInputs>
        <label>CSC_ASSIGNTSO_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_CER_FLOW_TRIGGER_CASE_ENTITLEMENT</fullName>
        <flow>EntitlementExample</flow>
        <flowInputs>
            <name>AccountCountry</name>
            <value>{!Account.Country_MainAddress__c}</value>
        </flowInputs>
        <flowInputs>
            <name>AccountID</name>
            <value>{!AccountId}</value>
        </flowInputs>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>GenericAccount</name>
            <value>{!$Setup.EntitlementName__c.AccountName__c}</value>
        </flowInputs>
        <label>CSC_CER_FLOW_TRIGGER_CASE_ENTITLEMENT</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_FIRSTCONTACT_MILESTONE_CLOSE</fullName>
        <description>Flow Trigger to close the Milestone &apos;First Contact with Customer&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>First Contact with Customer</value>
        </flowInputs>
        <label>CSC_FIRSTCONTACT_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_FRF_MILESTONE_CLOSE</fullName>
        <description>Flow trigger to close the Case Milestone &apos;FRF Form Submitted&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>FRF Form Submitted and Case Closed</value>
        </flowInputs>
        <label>CSC_FRF_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_FURTHERANALYSIS_MILESTONE_CLOSE</fullName>
        <description>Flow trigger to close the case milestone &apos;Further analysis required&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>Further analysis required</value>
        </flowInputs>
        <label>CSC_FURTHERANALYSIS_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_FlowTrigger_SpamJunkQueueCases_RestartMilestones</fullName>
        <flow>CSC_SpamJunkQueueCases_RestartMilestones</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <label>CSC- FlowTrigger - SpamJunkQueueCases- RestartMilestones</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_INDIA_FLOW_TRIGGER_CASE_ENTITLEMENT</fullName>
        <flow>CSC_INDIA_CASE_ENTITLEMENT_FLOW</flow>
        <flowInputs>
            <name>AccountCountry</name>
            <value>IN</value>
        </flowInputs>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>CaseRecordType</name>
            <value>{!RecordType.Name}</value>
        </flowInputs>
        <flowInputs>
            <name>GenericAccount</name>
            <value>{!$Setup.EntitlementName__c.AccountName__c}</value>
        </flowInputs>
        <label>CSC_INDIA_FLOW_TRIGGER_CASE_ENTITLEMENT</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_India_Flow_Trigger_SpamJunkQueue_Uncheck_Entitlement_Lookup</fullName>
        <description>Flow Trigger - This flow trigger removes the value in Entitlement Lookup filed, that means we don&apos;t run the Entitlement &amp; Milestones for SPAM Cases.</description>
        <flow>IndiaSpamJunkQueue_Uncheck_Entitlement_Lookup</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <label>CSC India Flow Trigger SpamJunkQueue- Uncheck Entitlement Lookup</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_MFSREPORT_MILESTONE_CLOSE</fullName>
        <description>Flow Trigger to Close the Case Milestone &apos;File MFS Report and Case Close&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>File MFS Report and Case Close</value>
        </flowInputs>
        <label>CSC_MFSREPORT_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_MILESTONE_CLOSE</fullName>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>Accept Case by Agent from Queue</value>
        </flowInputs>
        <label>CSC_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_MILESTONE_CLOSE_CASE_CLOSE</fullName>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>CloseCase</value>
        </flowInputs>
        <label>CSC_MILESTONE_CLOSE_CASE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_SERVICEREPORT_MILESTONE_CLOSE</fullName>
        <description>Flow trigger to Close the Case Milestone &apos;Service Report submitted&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>Service Report submitted</value>
        </flowInputs>
        <label>CSC_SERVICEREPORT_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>CSC_TDA_MILESTONE_CLOSE</fullName>
        <description>Flow trigger to close the case milestone &apos;TDA report submitted&apos;</description>
        <flow>CSC_CLOSE_Q_ENTITLEMENT</flow>
        <flowInputs>
            <name>CaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>MILESTONE_TYPEID</name>
            <value>TDA report submitted</value>
        </flowInputs>
        <label>CSC_TDA_MILESTONE_CLOSE</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
</Workflow>
