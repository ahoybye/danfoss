<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Confirmed_Date_Set</fullName>
        <description>Confirmed Date Set</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>TookOwnership__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Confirmed_Date_Set</template>
    </alerts>
    <alerts>
        <fullName>Customer_Requested_Date_Changed</fullName>
        <description>Customer Requested Date Changed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Customer_Requested_Date_Changed</template>
    </alerts>
    <alerts>
        <fullName>Notify_ADC_Contact</fullName>
        <description>Notify ADC Contact</description>
        <protected>false</protected>
        <recipients>
            <field>ADC_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Visitor_Notification_Submitted_ADC</template>
    </alerts>
    <alerts>
        <fullName>Notify_AmsVisitorNotification_Group</fullName>
        <description>Notify AmsVisitorNotification Group</description>
        <protected>false</protected>
        <recipients>
            <field>AmsVisitorNotificationGroup__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Visitor_Notification_Completed_AMSVN</template>
    </alerts>
    <alerts>
        <fullName>Notify_Initiator_When_BU_Makes_Release_To_Production_Decision</fullName>
        <description>Notify Initiator When BU Makes Release To Production Decision</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Release_to_Production_Decision</template>
    </alerts>
    <alerts>
        <fullName>Notify_Initiator_When_Cancelled</fullName>
        <description>Notify Initiator When Cancelled</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Request_Cancelled</template>
    </alerts>
    <alerts>
        <fullName>Notify_Initiator_When_Completed</fullName>
        <description>Notify Initiator When Completed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Request_Completed</template>
    </alerts>
    <alerts>
        <fullName>Notify_Initiator_When_Drawing_Request_Completed</fullName>
        <description>Notify Initiator When Drawing Request Completed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <recipient>PS_Customer_Request_Engineering_Services</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Request_Completed_Drawing</template>
    </alerts>
    <alerts>
        <fullName>Notify_Initiator_When_Logistics_Setup_Rejected</fullName>
        <description>Notify Initiator When Logistics Setup Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Logistics_Setup_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Notify_Owner_When_BU_Review_Completed</fullName>
        <description>Notify Owner When BU Review Completed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/BU_Review_Completed</template>
    </alerts>
    <alerts>
        <fullName>Notify_Owner_When_BU_Review_Completed_2</fullName>
        <description>Notify Owner When BU Review Completed-2</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/BU_Review_Completed_2</template>
    </alerts>
    <alerts>
        <fullName>Notify_Owner_When_Submitted</fullName>
        <description>Notify Owner When Submitted</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Submit_Customer_Request</template>
    </alerts>
    <alerts>
        <fullName>Notify_Owner_When_Submitted_for_Visitor_Notifications</fullName>
        <description>Notify Owner When Submitted for Visitor Notifications</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Submit_Customer_Request_for_Visitor_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Quality</fullName>
        <description>Notify Quality of Customer Visit</description>
        <protected>false</protected>
        <recipients>
            <recipient>PS_Customer_Request_Quality_Review</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Visitor_Notification_Submitted_Quality</template>
    </alerts>
    <alerts>
        <fullName>Ownership_Change</fullName>
        <description>Ownership Change</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/Ownership_Change</template>
    </alerts>
    <alerts>
        <fullName>SAE_Review</fullName>
        <description>SAE Review</description>
        <protected>false</protected>
        <recipients>
            <field>SAE__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_Customer_Requests/SAE_Review</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Account_Region</fullName>
        <field>Account_Region__c</field>
        <formula>Account__r.Region__c</formula>
        <name>Set Account Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Email Initiator When BU Confirms Date</fullName>
        <actions>
            <name>Confirmed_Date_Set</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED(Confirmed_Date__c),  Confirmed_Date__c &gt;  Customer_Requested_Date__c, OR(  RecordType.DeveloperName = &quot;Drawing&quot;,  RecordType.DeveloperName = &quot;New_Material_Number&quot;,  RecordType.DeveloperName = &quot;New_Product_Feature&quot;,  RecordType.DeveloperName = &quot;PPAP&quot;, RecordType.DeveloperName = &quot;Special_Tests_Certificates&quot;,  RecordType.DeveloperName = &quot;System_Model&quot;  )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Initiator When BU Makes Decision</fullName>
        <actions>
            <name>Notify_Initiator_When_BU_Makes_Release_To_Production_Decision</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PS_Customer_Request__c.Release_to_Production__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>New Product Feature,System Model</value>
        </criteriaItems>
        <description>Email to initiator when BU makes Release to Production decision on New Product Feature and System Model</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Initiator When Logistics Setup Rejected</fullName>
        <actions>
            <name>Notify_Initiator_When_Logistics_Setup_Rejected</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PS_Customer_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Logistics Setup</value>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.Implement_Changes__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Initiator When Request Cancelled</fullName>
        <actions>
            <name>Notify_Initiator_When_Cancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PS_Customer_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Initiator When Request Completed</fullName>
        <actions>
            <name>Notify_Initiator_When_Completed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PS_Customer_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.Type__c</field>
            <operation>notEqual</operation>
            <value>Drawing,New Product</value>
        </criteriaItems>
        <description>Email to initiator when Complete Request button is clicked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Initiator When Request Completed-Drawing</fullName>
        <actions>
            <name>Notify_Initiator_When_Drawing_Request_Completed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PS_Customer_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.Type__c</field>
            <operation>equals</operation>
            <value>Drawing</value>
        </criteriaItems>
        <description>Email to initiator when Drawing Request has been completed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Initiator on Ownership Change</fullName>
        <actions>
            <name>Ownership_Change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email to initiator when owner changes</description>
        <formula>AND(ISCHANGED(OwnerId), NOT(ISPICKVAL(Status__c, &quot;Waiting for Ownership&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Owner When Customer Requested Date Changed</fullName>
        <actions>
            <name>Customer_Requested_Date_Changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email to Owner when the Customer Requested Date is changed and Status is In Progress</description>
        <formula>AND(ISPICKVAL(Status__c, &quot;In Progress&quot;),  ISCHANGED( Customer_Requested_Date__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Owner when BU Review Completed</fullName>
        <actions>
            <name>Notify_Owner_When_BU_Review_Completed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PS_Customer_Request__c.BUReviewComplete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.Type__c</field>
            <operation>notEqual</operation>
            <value>New Material Number,New Product Feature,System Model</value>
        </criteriaItems>
        <description>Email to initial owner when last BU Reviewer completes task. For request types NOT with SAE review.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Owner when BU Review Completed-2</fullName>
        <actions>
            <name>Notify_Owner_When_BU_Review_Completed_2</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PS_Customer_Request__c.BUReviewComplete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.Type__c</field>
            <operation>equals</operation>
            <value>New Material Number,New Product Feature,System Model</value>
        </criteriaItems>
        <description>Email to initial owner when last BU Reviewer completes task.  For request types with SAE review.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Owner when Submitted</fullName>
        <actions>
            <name>Notify_Owner_When_Submitted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PS_Customer_Request__c.SubmittedInitially__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Visitor Notification</value>
        </criteriaItems>
        <description>Email sent to initial owner when Submit Request is clicked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Owner when Submitted-Visitor Notification</fullName>
        <actions>
            <name>Notify_Owner_When_Submitted_for_Visitor_Notifications</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PS_Customer_Request__c.SubmittedInitially__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Visitor Notification</value>
        </criteriaItems>
        <description>Email sent to initial owner when  Submit Request is clicked -Visitor Notification</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email SAE For Review</fullName>
        <actions>
            <name>SAE_Review</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PS_Customer_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>In SAE Review</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Account Region Field</fullName>
        <actions>
            <name>Set_Account_Region</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>to avoid an extra query in the trigger, pull down the account region with workflow</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Visitor Notification - Completed - Email AMSVisitorNotification Group</fullName>
        <actions>
            <name>Notify_AmsVisitorNotification_Group</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>PS_Customer_Request__c.Type__c</field>
            <operation>equals</operation>
            <value>Visitor Notification</value>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.Plant_of_Visit__c</field>
            <operation>equals</operation>
            <value>AMS</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Visitor Notification - Submitted - Email ADC Contact</fullName>
        <actions>
            <name>Notify_ADC_Contact</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>PS_Customer_Request__c.Type__c</field>
            <operation>equals</operation>
            <value>Visitor Notification</value>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.SubmittedInitially__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.ADC_Tour_Requested__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If ADC Tour requested</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Visitor Notification - Submitted - Email Quality</fullName>
        <actions>
            <name>Notify_Quality</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PS_Customer_Request__c.SubmittedInitially__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>PS_Customer_Request__c.Is_Quality_part_of_the_agenda__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Email sent to quality when customer visit involves quality</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
