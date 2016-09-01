<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BMCServiceDesk__Notify_Incident_Owner_when_final_Task_Linked_to_Incident_is_Closed</fullName>
        <description>Notify incident owner when final task linked to incident is closed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__All_Tasks_closed_for_Incident</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__Notify_client_when_service_request_status_changes</fullName>
        <description>Notify_client_when_service_request_status_changes</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__SRM_Status_Change</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__Notify_owner_when_linked_task_is_closed</fullName>
        <description>Notify incident owner when linked task is closed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Linked_Task_for_an_incident_is_closed</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__call_status_from_email</fullName>
        <description>call_status_from_email</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_5_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_assign_to_on_ticket_followup</fullName>
        <description>notify_assign_to_on_ticket_followup</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_2_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_assign_to_on_ticket_reopen</fullName>
        <description>notify_assign_to_on_ticket_reopen</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_8_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_on_service_request_reopen</fullName>
        <description>notify_client_on_service_request_reopen</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__SRM_Reopened</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_on_ticket_reopen</fullName>
        <description>notify_client_on_ticket_reopen</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_8_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_when_incident_is_closed</fullName>
        <description>notify_client_when_incident_is_closed</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_6_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_when_incident_is_created</fullName>
        <description>notify_client_when_incident_is_created</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/Incident_Email_Template_10_Version_1_0</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_when_service_request_is_closed</fullName>
        <description>notify_client_when_service_request_is_closed</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__SRM_Closed</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_when_service_request_is_created</fullName>
        <description>notify_client_when_service_request_is_created</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/Service_Request_Email_Template_1_Version_1_0</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_staff_of_incident_due_in_1_hour</fullName>
        <description>notify_staff_of_incident_due_in_1_hour</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_9_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_staff_of_incident_nearing_due_date</fullName>
        <description>notify_staff_of_incident_nearing_due_date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_4_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_staff_when_incident_is_assigned_to_them</fullName>
        <description>notify_staff_when_incident_is_assigned_to_them</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_7_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_staff_when_incident_is_created</fullName>
        <description>notify_staff_when_incident_is_created</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_1_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_staff_when_no_action_has_occurred_for_24_hours</fullName>
        <description>notify_staff_when_no_action_has_occurred_for_24_hours</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_3_Version_2</template>
    </alerts>
    <alerts>
        <fullName>Incident_Closed_Email_Alert</fullName>
        <description>Incident Closed Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/Incident_Closed</template>
    </alerts>
    <alerts>
        <fullName>Incident_Created_Mail_Alert</fullName>
        <description>Incident Created Mail Alert</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/Incident_Created</template>
    </alerts>
    <alerts>
        <fullName>Incident_update_alert_to_owner</fullName>
        <description>Incident update alert to owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/Incident_update_alert_to_owner</template>
    </alerts>
    <alerts>
        <fullName>Notify_Staff_When_Incident_Is_Assigned_TO_Them</fullName>
        <description>Notify_Staff_When_Incident_Is_Assigned_TO_Them</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_7_Version_2</template>
    </alerts>
    <alerts>
        <fullName>Notify_the_Client_when_an_IN_or_SR_is_closed</fullName>
        <description>Notify the Client when an IN or SR is closed</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/IN_SR_Closed_Email_Template_1_Version_1_0</template>
    </alerts>
    <alerts>
        <fullName>Notify_the_Client_when_an_IN_or_SR_is_created</fullName>
        <description>Notify the Client when an IN or SR is created</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/IN_SR_Open_Email_Template_1_Version_1_0</template>
    </alerts>
    <alerts>
        <fullName>Notify_the_Owner_when_an_IN_or_SR_is_update</fullName>
        <description>Notify the Owner when an IN or SR is update</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/IN_SR_Updated_Email_Template_1_Version_1_0</template>
    </alerts>
    <alerts>
        <fullName>SR_update_alert_to_owner</fullName>
        <description>SR update alert to owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/SR_update_alert_to_owner</template>
    </alerts>
    <alerts>
        <fullName>notify_client_when_ticket_is_closed</fullName>
        <description>notify client when ticket is closed</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>dgit-service@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/ticket_email_template_1_version_1_0</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approved_SR</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;Status In Progress&quot;</formula>
        <name>Approved SR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Apply_BBSA_Template</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <name>Apply BBSA Template</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Apply_BSA_Template</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <name>Apply BSA Template</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Apply_EUEM_Template</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <name>Apply EUEM Template</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Asset_Core_Approval_Status_Approved</fullName>
        <description>Update Asset Core Approval Status with Approved after successful operational rule deployment</description>
        <field>BMCServiceDesk__ACApprovalStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>Asset Core Approval Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Asset_Core_Approval_Status_Rejected</fullName>
        <description>Update Asset Core Approval Status with Rejected after failed operational rule deployment</description>
        <field>BMCServiceDesk__ACApprovalStatus__c</field>
        <literalValue>Rejected</literalValue>
        <name>Asset Core Approval Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Update_Service_Request_as_Approved</fullName>
        <description>Updates the flag approved to TRUE on final approval</description>
        <field>BMCServiceDesk__Approved__c</field>
        <literalValue>1</literalValue>
        <name>Update Service Request as Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Update_the_ShowDueDateDialog_Field</fullName>
        <field>BMCServiceDesk__ShowDueDateDialog__c</field>
        <literalValue>1</literalValue>
        <name>Update the ShowDueDateDialog Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_SR_After_Last_Task</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;status Completed&quot;</formula>
        <name>Close SR After Last Task</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_SR</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;status Closed&quot;</formula>
        <name>Rejected SR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BMCServiceDesk__Apply template to BMC Server Automation created incident</fullName>
        <actions>
            <name>BMCServiceDesk__Apply_BSA_Template</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Job id:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Name:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Job Group id:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Job Run id:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Start Time:</value>
        </criteriaItems>
        <description>This workflow will apply a template to the incident created by BMC Server Automation</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Apply template to End User Experience Management created incident</fullName>
        <actions>
            <name>BMCServiceDesk__Apply_EUEM_Template</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Date:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Source:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Incident type:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Incident detection rule:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Watchpoint:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Urgency rating:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Sessions:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Description:</value>
        </criteriaItems>
        <description>This workflow will apply a template to the incident created by End User Experience Management</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify incident owner when each linked task is closed</fullName>
        <actions>
            <name>BMCServiceDesk__Notify_owner_when_linked_task_is_closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies incident owner when each linked task of the incident is closed.</description>
        <formula>AND( ISCHANGED( BMCServiceDesk__Task_Closed_Controller__c), NOT(ISBLANK( BMCServiceDesk__Task_Closed_Controller__c) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify incident owner when final task linked to incident is closed</fullName>
        <actions>
            <name>BMCServiceDesk__Notify_Incident_Owner_when_final_Task_Linked_to_Incident_is_Closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify incident owner when final task linked to incident is closed</description>
        <formula>AND( BMCServiceDesk__state__c, NOT( BMCServiceDesk__inactive__c ), IF(BMCServiceDesk__AllTaskCloseController__c, ISCHANGED(BMCServiceDesk__AllTaskCloseController__c), false) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify staff of incident due in 1 hour</fullName>
        <active>true</active>
        <description>Notify staff of incident due in 1 hour</description>
        <formula>BMCServiceDesk__state__c  = True  &amp;&amp;  NOT(ISBLANK(BMCServiceDesk__dueDateTime__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify staff of incident nearing due date</fullName>
        <active>true</active>
        <description>Notify staff of incident nearing due date</description>
        <formula>BMCServiceDesk__state__c  = True  &amp;&amp;  NOT(ISBLANK(BMCServiceDesk__dueDateTime__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify staff when no action has occurred for 24 hours</fullName>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__state__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Notifies the assigned staff member if the staff member has not taken any action on the incident for 24 Hours</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the assigned staff member when an incident has been marked for follow up</fullName>
        <actions>
            <name>BMCServiceDesk__notify_assign_to_on_ticket_followup</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies the staff member when an incident assigned to the staff member has been marked for follow up</description>
        <formula>BMCServiceDesk__followUp__c  = True &amp;&amp;  BMCServiceDesk__state__c  = False &amp;&amp;  PRIORVALUE( BMCServiceDesk__state__c )  = True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the assigned staff member when an incident is created and assigned to the staff member</fullName>
        <actions>
            <name>BMCServiceDesk__notify_staff_when_incident_is_created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the staff member when an incident is created and assigned to the staff member</description>
        <formula>$User.Id  &lt;&gt;  OwnerId  &amp;&amp;  BMCServiceDesk__state__c  = True</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the assigned staff member when an incident is reassigned to the staff member</fullName>
        <actions>
            <name>BMCServiceDesk__notify_staff_when_incident_is_assigned_to_them</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the staff member when an incident is reassigned to the staff member</description>
        <formula>OwnerId &lt;&gt; $User.Id  &amp;&amp;  ISCHANGED( OwnerId )  &amp;&amp;   NOT(ISNEW() ) &amp;&amp; BMCServiceDesk__state__c  = True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the assigned staff member when an incident is reopened</fullName>
        <actions>
            <name>BMCServiceDesk__notify_assign_to_on_ticket_reopen</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies the staff member when a closed incident is reopened and assigned to the staff member</description>
        <formula>$User.Id  &lt;&gt;  OwnerId  &amp;&amp;  BMCServiceDesk__state__c  = True &amp;&amp;  PRIORVALUE( BMCServiceDesk__state__c ) = False</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when a service request is closed</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_when_service_request_is_closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the client’s service request is closed</description>
        <formula>(BMCServiceDesk__state__c  =  false) &amp;&amp; NOT( ISBLANK( BMCServiceDesk__FKRequestDetail__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when a service request is created</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_when_service_request_is_created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the service request requested by the client is created</description>
        <formula>NOT( ISBLANK( BMCServiceDesk__FKRequestDetail__c ) || ISBLANK(  BMCServiceDesk__FKRequestDefinition__c  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when a service request is reopened</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_on_service_request_reopen</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the client’s service request is reopened</description>
        <formula>BMCServiceDesk__state__c  = True &amp;&amp;  PRIORVALUE( BMCServiceDesk__state__c ) = False &amp;&amp;   NOT(ISBLANK( BMCServiceDesk__FKRequestDetail__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when a service request status is changed</fullName>
        <actions>
            <name>BMCServiceDesk__Notify_client_when_service_request_status_changes</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the client’s service request status has changed</description>
        <formula>( BMCServiceDesk__FKStatus__c &lt;&gt; PRIORVALUE( BMCServiceDesk__FKStatus__c)) &amp;&amp; NOT(ISBLANK( BMCServiceDesk__FKRequestDetail__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when an incident is closed</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_when_incident_is_closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the client’s incident is closed</description>
        <formula>(BMCServiceDesk__state__c  = False) &amp;&amp; (BMCServiceDesk__followUp__c = False) &amp;&amp; (ISBLANK( BMCServiceDesk__FKRequestDetail__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when an incident is created</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_when_incident_is_created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the incident requested by the client is created</description>
        <formula>(BMCServiceDesk__state__c = True) &amp;&amp; (ISBLANK( BMCServiceDesk__FKRequestDetail__c)  &amp;&amp; ISBLANK(  BMCServiceDesk__FKRequestDefinition__c  ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when an incident is reopened</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_on_ticket_reopen</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the client’s incident is reopened</description>
        <formula>BMCServiceDesk__state__c  = True &amp;&amp;  PRIORVALUE( BMCServiceDesk__state__c ) = False &amp;&amp;  ISBLANK( BMCServiceDesk__FKRequestDetail__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Open popup dialog for recalculating due date when priority of incident changes</fullName>
        <actions>
            <name>BMCServiceDesk__Update_the_ShowDueDateDialog_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This rule has been deprecated. If the rule is active, deactivate it.</description>
        <formula>ISCHANGED( BMCServiceDesk__FKPriority__c ) &amp;&amp; IF( BMCServiceDesk__ShowDueDateDialog__c   = false,true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Update the incident%E2%80%99s status through email</fullName>
        <actions>
            <name>BMCServiceDesk__call_status_from_email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sends the status of the incident to the sender of the email</description>
        <formula>ISCHANGED( BMCServiceDesk__WorkflowController__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Incident Closed</fullName>
        <actions>
            <name>Incident_Closed_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__state__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__Type__c</field>
            <operation>equals</operation>
            <value>Incident</value>
        </criteriaItems>
        <description>Incident Closed 
State Open = False AND Type = Incident</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Incident Created</fullName>
        <actions>
            <name>Incident_Created_Mail_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the incident requested by the client is created</description>
        <formula>(BMCServiceDesk__state__c = True) 
&amp;&amp; 
ISBLANK( BMCServiceDesk__FKRequestDetail__c) 
&amp;&amp; 
ISBLANK( BMCServiceDesk__FKRequestDefinition__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Incident update alert to owner</fullName>
        <actions>
            <name>Incident_update_alert_to_owner</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>(OwnerId &lt;&gt; LastModifiedById = True) &amp;&amp; (ISBLANK( BMCServiceDesk__FKRequestDetail__c) &amp;&amp; ISBLANK( BMCServiceDesk__FKRequestDefinition__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Last Task Closed SR</fullName>
        <actions>
            <name>Close_SR_After_Last_Task</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(BMCServiceDesk__Type__c = &apos;Service Request&apos;,  OR(BMCServiceDesk__Category_ID__c = &apos;Power Solutions Specific IT Services&apos;,BMCServiceDesk__Category_ID__c = &apos;Vacon Specific IT Services&apos;), BMCServiceDesk__state__c, NOT( BMCServiceDesk__inactive__c ), IF(BMCServiceDesk__AllTaskCloseController__c, ISCHANGED(BMCServiceDesk__AllTaskCloseController__c), false) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify the Client when an IN or SR is closed</fullName>
        <actions>
            <name>Notify_the_Client_when_an_IN_or_SR_is_closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends a notification to the Client when an Incident or Service Request they reported/requested is closed.</description>
        <formula>BMCServiceDesk__state__c = False</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify the Client when an IN or SR is created</fullName>
        <actions>
            <name>Notify_the_Client_when_an_IN_or_SR_is_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends a notification to the Client when an Incident or Service Request they reported/requested is created.</description>
        <formula>(BMCServiceDesk__state__c = True)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify the Owner when an IN or SR is updated</fullName>
        <actions>
            <name>Notify_the_Owner_when_an_IN_or_SR_is_update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notification to the Owner/Assignee when an IN or SR is updated by someone else.</description>
        <formula>OwnerId &lt;&gt;  LastModifiedById &amp;&amp;  BMCServiceDesk__state__c  = True &amp;&amp;  ISCHANGED(OwnerId) = False</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify the assigned staff member when an incident is created and assigned to the staff member</fullName>
        <actions>
            <name>BMCServiceDesk__notify_staff_when_incident_is_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies the staff member when an Incident is created and assigned to the staff member.  This does not send an email to the staff when a Service Request is created and assigned to a Staff member.</description>
        <formula>$User.Id  &lt;&gt;  OwnerId  &amp;&amp;  BMCServiceDesk__state__c  = True  &amp;&amp;  BMCServiceDesk__Type__c = &quot;Incident&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify the assigned staff member when an incident is reassigned to the staff member</fullName>
        <actions>
            <name>BMCServiceDesk__notify_staff_when_incident_is_assigned_to_them</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies the staff member when an incident is reassigned to the staff member.  This does not send an email to the staff when a Service Request is reassigned to a Staff member.</description>
        <formula>OwnerId &lt;&gt; $User.Id  &amp;&amp;  ISCHANGED( OwnerId )  &amp;&amp;   NOT(ISNEW() ) &amp;&amp; BMCServiceDesk__state__c  = True  &amp;&amp; BMCServiceDesk__Type__c = &quot;Incident&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SR update alert to owner</fullName>
        <actions>
            <name>SR_update_alert_to_owner</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>(OwnerId &lt;&gt; LastModifiedById = True) &amp;&amp; (ISBLANK( BMCServiceDesk__FKRequestDetail__c)=FALSE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>notify client when a ticket is closed</fullName>
        <actions>
            <name>notify_client_when_ticket_is_closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>BMCServiceDesk__state__c = False</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
