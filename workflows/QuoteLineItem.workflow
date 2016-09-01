<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Line_Item_Cancelled_Please_Stop_Working_on_Approval_BA</fullName>
        <description>Line Item Cancelled - Please Stop Working on Approval BA</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Area_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/Cancelled_Notice</template>
    </alerts>
    <alerts>
        <fullName>Line_Item_Cancelled_Please_Stop_Working_on_Approval_PT</fullName>
        <description>Line Item Cancelled - Please Stop Working on Approval - PT</description>
        <protected>false</protected>
        <recipients>
            <field>Email_of_Pricing__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/Cancelled_Notice</template>
    </alerts>
    <alerts>
        <fullName>Line_Item_Cancelled_Please_Stop_Working_on_Approval_SM</fullName>
        <description>Line Item Cancelled - Please Stop Working on Approval - SM</description>
        <protected>false</protected>
        <recipients>
            <field>Email_of_Sales_Manager__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/Cancelled_Notice</template>
    </alerts>
    <alerts>
        <fullName>QLI_Level_Notification</fullName>
        <description>QLI Level Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quote_Approvals/QLI_Approved_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_User_Stamp</fullName>
        <field>Approver_Name__c</field>
        <formula>$User.FirstName + &quot; &quot; + $User.LastName</formula>
        <name>Approval User Stamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_Time_Stamp</fullName>
        <field>Approved_Time__c</field>
        <formula>NOW()</formula>
        <name>Approved Time Stamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submitted_for_Approval_Time_Stamp</fullName>
        <field>Submitted_for_Approval_Time__c</field>
        <formula>NOW()</formula>
        <name>Submitted for Approval Time Stamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Updated_Countered_Status</fullName>
        <field>Countered__c</field>
        <literalValue>1</literalValue>
        <name>Updated Countered Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Approved Time Stamp</fullName>
        <actions>
            <name>Approval_User_Stamp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Approved_Time_Stamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.Line_Item_Approval_Stage__c</field>
            <operation>equals</operation>
            <value>Sales Manager - Approved,Pricing Team - Approved,Business Unit - Approved,Account Owner - Approved,Business Unit - Declined,Cancelled by Account Owner</value>
        </criteriaItems>
        <criteriaItems>
            <field>QuoteLineItem.Approved_Time__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Cancel Quote BU Alert</fullName>
        <actions>
            <name>Line_Item_Cancelled_Please_Stop_Working_on_Approval_BA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This rule sends notifications to BU approvers about a Cancellation.</description>
        <formula>AND(   ISPICKVAL((PRIORVALUE(Line_Item_Approval_Stage__c)),&quot;Business Unit - Requires Review&quot;),  ISPICKVAL(Line_Item_Approval_Stage__c, &quot;Cancelled by Account Owner&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Cancel Quote Pricing Alert</fullName>
        <actions>
            <name>Line_Item_Cancelled_Please_Stop_Working_on_Approval_PT</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This rule sends notifications to Pricing approvers about a Cancellation.</description>
        <formula>AND(   ISPICKVAL((PRIORVALUE(Line_Item_Approval_Stage__c)),&quot;Pricing Team - Requires Review&quot;),  ISPICKVAL(Line_Item_Approval_Stage__c, &quot;Cancelled by Account Owner&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Cancel Quote SM Alert</fullName>
        <actions>
            <name>Line_Item_Cancelled_Please_Stop_Working_on_Approval_SM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This rule sends notifications to Sales Manager approvers about a Cancellation.</description>
        <formula>AND(   ISPICKVAL((PRIORVALUE(Line_Item_Approval_Stage__c)),&quot;Sales Manager - Requires Review&quot;),  ISPICKVAL(Line_Item_Approval_Stage__c, &quot;Cancelled by Account Owner&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QLI Approved Notification</fullName>
        <actions>
            <name>QLI_Level_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.Line_Item_Approval_Stage__c</field>
            <operation>equals</operation>
            <value>Business Unit - Approved,Pricing Team - Approved,Sales Manager - Approved</value>
        </criteriaItems>
        <description>This workflow fires when the Quote Line Item is Approved by SM, PT, and BA and sends notifications.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Submitted for Approval Time Stamp</fullName>
        <actions>
            <name>Submitted_for_Approval_Time_Stamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.Line_Item_Approval_Stage__c</field>
            <operation>equals</operation>
            <value>,Sales Manager - Requires Review,Pricing Team - Requires Review,Business Unit - Requires Review,Sales Manager - Countered,Pricing Team - Countered,Business Unit - Countered,Account Owner - Approved,Sales Manager - Approved,Pricing Team - Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>QuoteLineItem.Submitted_for_Approval_Time__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>QuoteLineItem.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>1/1/2015 7:00 AM</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Countered Status</fullName>
        <actions>
            <name>Updated_Countered_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.Line_Item_Approval_Stage__c</field>
            <operation>equals</operation>
            <value>Sales Manager - Countered,Pricing Team - Countered,Business Unit - Countered</value>
        </criteriaItems>
        <criteriaItems>
            <field>QuoteLineItem.Countered__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow updates the &quot;Countered&quot; field - this supports analytics around Account Owner discounting.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
