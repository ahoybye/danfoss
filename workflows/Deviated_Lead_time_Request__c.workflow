<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DLR_Approval_Notify</fullName>
        <description>DLR Approval Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_DLR/PS_DLR_Reviewed_Notification</template>
    </alerts>
    <alerts>
        <fullName>DLR_Customer_submission_received_notification</fullName>
        <description>DLR Customer submission received notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>partnerlink@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PS_DLR/PS_DLR_Customer_Notification</template>
    </alerts>
    <alerts>
        <fullName>DLR_Next_Step_Approval_Notification</fullName>
        <description>DLR Next Step Approval Notification</description>
        <protected>false</protected>
        <recipients>
            <field>CSR__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_DLR/PS_DLR_Notification_Internal</template>
    </alerts>
    <alerts>
        <fullName>DLR_Notification</fullName>
        <description>DLR Notification with Premium</description>
        <protected>false</protected>
        <recipients>
            <field>CSR__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partnerlink@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PS_DLR/PS_DLR_Notification_Internal</template>
    </alerts>
    <alerts>
        <fullName>DLR_Prototype_Request</fullName>
        <description>DLR Prototype Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>partnerlink@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PS_DLR/PS_DLR_Notification_Internal</template>
    </alerts>
    <alerts>
        <fullName>DLR_Rejection_No_Premium</fullName>
        <description>DLR Rejection No Premium</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>partnerlink@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PS_DLR/PS_DLR_No_Premium</template>
    </alerts>
    <alerts>
        <fullName>DLR_Rejection_Notify</fullName>
        <description>DLR Rejection Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PS_DLR/PS_DLR_Reviewed_Notification</template>
    </alerts>
    <alerts>
        <fullName>DLR_Request_Email</fullName>
        <description>DLR Request Email</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Specialist__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>partnerlink@danfoss.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PS_DLR/PS_DLR_Notification_Internal</template>
    </alerts>
</Workflow>
