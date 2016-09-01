<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_Request_Account_Owner</fullName>
        <description>Approval Request - Account Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/ApprovalRequestEmailtoAO</template>
    </alerts>
    <alerts>
        <fullName>Approval_Request_Pricing_Team</fullName>
        <description>Approval Request - Pricing Team</description>
        <protected>false</protected>
        <recipients>
            <field>Pricing_Team_Group_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/ApprovalRequestEmailToPT</template>
    </alerts>
    <alerts>
        <fullName>Approval_Request_Sales_Manager</fullName>
        <description>Approval Request - Sales Manager</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Manager_of_Account__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/ApprovalRequestEmailToSM</template>
    </alerts>
    <alerts>
        <fullName>BU_Rejected_Line_Item_Notification_to_Account_Owner_and_Sales_Manager</fullName>
        <description>BU Rejected Line Item Notification to Account Owner and Sales Manager</description>
        <protected>false</protected>
        <recipients>
            <field>Pricing_Team_Group_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Sales_Manager_of_Account__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/BU_Rejected_Line_Item_Notification_to_Account_Manager_and_Sales_Manager</template>
    </alerts>
    <alerts>
        <fullName>Counter_Proposal_Business_Area</fullName>
        <description>Counter Proposal - BA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/Counter_Proposal_Business_Area</template>
    </alerts>
    <alerts>
        <fullName>Counter_Proposal_Pricing</fullName>
        <description>Counter Proposal - Pricing</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/Counter_Proposal_Pricing</template>
    </alerts>
    <alerts>
        <fullName>Counter_Proposal_Sales_Manager</fullName>
        <description>Counter Proposal - Sales Manager</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/Counter_Proposal_Sales_Manager</template>
    </alerts>
    <alerts>
        <fullName>Fully_Approved_Notification_to_Account_Owner_and_Sales_Manager</fullName>
        <description>Fully Approved Notification to Account Owner and Sales Manager</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Sales_Manager_of_Account__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/Fully_Approved_Notification_to_Account_Owner_and_Sales_Manager</template>
    </alerts>
    <alerts>
        <fullName>Fully_Approved_Notification_to_Sales_Specialists</fullName>
        <description>Fully Approved Notification to Sales Specialists</description>
        <protected>false</protected>
        <recipients>
            <recipient>CRM_SalesSpecOEMAmerPS</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/Fully_Approved_NA_Quote_Notification_to_Sales_Specialists</template>
    </alerts>
    <alerts>
        <fullName>SAP_Price_Status_Updated</fullName>
        <description>SAP Price Status Updated notification to Sales Specialist</description>
        <protected>false</protected>
        <recipients>
            <recipient>CRM_SalesSpecOEMAmerPS</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/Quote_SAP_Price_Review_Date</template>
    </alerts>
    <fieldUpdates>
        <fullName>Customer_Request_Date</fullName>
        <field>Customer_Request_Date__c</field>
        <formula>CreatedDate + 5</formula>
        <name>Customer Request Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Expiration_Date_Update</fullName>
        <field>ExpirationDate</field>
        <formula>CreatedDate + 90</formula>
        <name>Expiration Date Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Price_Updated_Date</fullName>
        <field>Pricing_Updated_in_SAP__c</field>
        <formula>NOW()</formula>
        <name>Stamp Price Updated Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Approval Request - Pricing Team</fullName>
        <actions>
            <name>Approval_Request_Pricing_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Lines_Pending_Pricing_Approval__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>This Workflow kicks off an Approval Request to the Pricing Team, initiated by the Account Manager.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Approval Request - Sales Manager</fullName>
        <actions>
            <name>Approval_Request_Sales_Manager</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Lines_Pending_Sales_Manager_Approval__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>This Workflow kicks off an Approval Request to the Sales Manager, initiated by the Account Manager.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Counter Proposal by Business Unit</fullName>
        <actions>
            <name>Counter_Proposal_Business_Area</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>PRIORVALUE( Lines_Countered_by_Business_Area__c ) &lt; Lines_Countered_by_Business_Area__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Counter Proposal by Pricing</fullName>
        <actions>
            <name>Counter_Proposal_Pricing</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>PRIORVALUE( Lines_Countered_by_Pricing__c ) &lt; Lines_Countered_by_Pricing__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Counter Proposal by Sales Manager</fullName>
        <actions>
            <name>Counter_Proposal_Sales_Manager</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>PRIORVALUE(  Lines_Countered_by_Sales_Manager__c  ) &lt;   Lines_Countered_by_Sales_Manager__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Declined by BU</fullName>
        <actions>
            <name>BU_Rejected_Line_Item_Notification_to_Account_Owner_and_Sales_Manager</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>PRIORVALUE(Lines_Declined_by_BA__c) &lt; Lines_Declined_by_BA__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Fully Approved NA Notification for Sales Specialist</fullName>
        <actions>
            <name>Fully_Approved_Notification_to_Sales_Specialists</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow fires when the Quote goes from Pending to Approved and sends notifications to NA Sales Specialists.</description>
        <formula>AND(ISPICKVAL(PRIORVALUE(Approval_Stage__c),&quot;Pending&quot; ),  ISPICKVAL( Price_Status__c , &quot;Price loaded into SAP&quot;),   
Merge_Formula_Region__c=&quot;Americas&quot;, 
OR (ISPICKVAL(Opportunity.Account.Channel__c, &quot;Direct&quot;), ISPICKVAL (Opportunity.Account.Channel__c, &quot;Global&quot;) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Fully Approved Notification</fullName>
        <actions>
            <name>Fully_Approved_Notification_to_Account_Owner_and_Sales_Manager</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow fires when the Quote goes from Pending to Approved and sends notifications.</description>
        <formula>AND(ISPICKVAL(PRIORVALUE(Approval_Stage__c),&quot;Pending&quot; ),  ISPICKVAL(Approval_Stage__c, &quot;Approved&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Price Updated Date</fullName>
        <actions>
            <name>Stamp_Price_Updated_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote.Price_Status__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Expiration%2FCustomer Request Date</fullName>
        <actions>
            <name>Customer_Request_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Expiration_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This Workflow updates the Expiration/Customer Request Date</description>
        <formula>AND(ISBLANK( ExpirationDate ) ,ISBLANK( Customer_Request_Date__c ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
