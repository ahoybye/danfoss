<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CE_Notify_SAP_Backoffice_CC</fullName>
        <description>CE Notify SAP Backoffice - CC</description>
        <protected>false</protected>
        <recipients>
            <recipient>CE_Customer_Request_CC</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Notifications/CE_Prospect_Account_to_Customer</template>
    </alerts>
    <alerts>
        <fullName>CE_Notify_SAP_Backoffice_DD</fullName>
        <description>CE Notify SAP Backoffice - DD</description>
        <protected>false</protected>
        <recipients>
            <recipient>CE_Customer_Request_DD</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Notifications/CE_Prospect_Account_to_Customer</template>
    </alerts>
    <alerts>
        <fullName>CE_Notify_SAP_Backoffice_DEN</fullName>
        <description>CE Notify SAP Backoffice - DEN</description>
        <protected>false</protected>
        <recipients>
            <recipient>CE_Customer_Request_DEN</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Notifications/CE_Prospect_Account_to_Customer</template>
    </alerts>
    <alerts>
        <fullName>CE_Notify_SAP_Backoffice_HS</fullName>
        <description>CE Notify SAP Backoffice - HS</description>
        <protected>false</protected>
        <recipients>
            <recipient>CE_Customer_Request_HS</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Notifications/CE_Prospect_Account_to_Customer</template>
    </alerts>
    <alerts>
        <fullName>CE_Notify_SAP_Backoffice_RC</fullName>
        <description>CE Notify SAP Backoffice - RC</description>
        <protected>false</protected>
        <recipients>
            <recipient>CE_Customer_Request_RC</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Notifications/CE_Prospect_Account_to_Customer</template>
    </alerts>
    <alerts>
        <fullName>CE_Request_Decision</fullName>
        <description>CE Request Decision</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Notifications/CE_Prospect_Account_to_Customer_Decision</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Account_Type_to_Customer</fullName>
        <field>Account_Type__c</field>
        <literalValue>Customer</literalValue>
        <name>Set Account Type to Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Customer_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Customer_CE</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Customer Record Type On Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Goldmine_Value</fullName>
        <field>Goldmine__c</field>
        <formula>IF( Left(Text(Back_end_System__c),8) = &quot;Goldmine&quot;,
IF( ISBLANK( Account__r.Goldmine__c ), Goldmine__c , Account__r.Goldmine__c &amp; &quot;, &quot; &amp; Goldmine__c ), Account__r.Goldmine__c )</formula>
        <name>Set Goldmine Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Kompas_Value</fullName>
        <field>Kompas__c</field>
        <formula>IF( Left(Text(Back_end_System__c),6) = &quot;Kompas&quot;,
IF( ISBLANK( Account__r.Kompas__c ), Kompas__c , Account__r.Kompas__c &amp; &quot;, &quot; &amp; Kompas__c ), Account__r.Kompas__c )</formula>
        <name>Set Kompas Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_P02_Value</fullName>
        <field>P02_Account__c</field>
        <formula>IF( Left(Text(Back_end_System__c),3) = &quot;P02&quot;, 
  IF( ISBLANK( Account__r.P02_Account__c ),  P02__c, Account__r.P02_Account__c  &amp; &quot;, &quot; &amp; P02__c),  Account__r.P02_Account__c)</formula>
        <name>Set P02 Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_P08_value</fullName>
        <field>CE_SAP_Account_ID__c</field>
        <formula>IF(  CONTAINS(Text(Back_end_System__c), &quot;P08&quot;),
IF( ISBLANK( Account__r.CE_SAP_Account_ID__c ),  &quot;A&quot; &amp; SAP__c, Account__r.CE_SAP_Account_ID__c ), Account__r.CE_SAP_Account_ID__c )</formula>
        <name>Set P08 value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_P16_value</fullName>
        <field>P16__c</field>
        <formula>IF( LEFT(Text(Back_end_System__c),3) = &quot;P16&quot;, 
  IF( ISBLANK(Account__r.P16__c),  P16__c, Account__r.P16__c  &amp; &quot;, &quot; &amp; P16__c),  Account__r.P16__c)</formula>
        <name>Set P16 value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_PCM_Value</fullName>
        <field>PCM__c</field>
        <formula>IF( LEFT(Text(Back_end_System__c),3) = &quot;PCM&quot;,
IF( ISBLANK(Account__r.PCM__c), PCM__c, Account__r.PCM__c &amp; &quot;, &quot; &amp; PCM__c), Account__r.PCM__c)</formula>
        <name>Set PCM Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Siebel_Value</fullName>
        <field>Siebell__c</field>
        <formula>IF( Left(Text(Back_end_System__c),6) = &quot;Siebel&quot;, 
  IF( ISBLANK( Account__r.Siebell__c ),   Siebel__c , Account__r.Siebell__c  &amp; &quot;, &quot; &amp; Siebel__c ),  Account__r.Siebell__c )</formula>
        <name>Set Siebel Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Turbocor_value</fullName>
        <field>Turbocor__c</field>
        <formula>IF( Left(Text(Back_end_System__c),8) = &quot;Turbocor&quot;, 
  IF( ISBLANK(  Account__r.Turbocor__c  ),    Turbocor__c  , Account__r.Turbocor__c  &amp; &quot;, &quot; &amp; Turbocor__c  ),  Account__r.Turbocor__c )</formula>
        <name>Set Turbocor value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>CE PROSPECT TO ACCOUNT - CC</fullName>
        <actions>
            <name>CE_Notify_SAP_Backoffice_CC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Master_Data_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Master_Data_Request__c.Division__c</field>
            <operation>equals</operation>
            <value>Commercial Compressors</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CE PROSPECT TO ACCOUNT - Completed %28type Customer%29 - P08</fullName>
        <actions>
            <name>Set_Account_Type_to_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Master_Data_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Master_Data_Request__c.Back_end_System__c</field>
            <operation>startsWith</operation>
            <value>P08</value>
        </criteriaItems>
        <criteriaItems>
            <field>Master_Data_Request__c.Master_Data_Type__c</field>
            <operation>equals</operation>
            <value>Customer</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CE PROSPECT TO ACCOUNT - Completed - P08</fullName>
        <actions>
            <name>Set_Customer_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_P08_value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Master_Data_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Master_Data_Request__c.Back_end_System__c</field>
            <operation>startsWith</operation>
            <value>P08</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CE PROSPECT TO ACCOUNT - Completed - Secondary systems</fullName>
        <actions>
            <name>Set_Account_Type_to_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Goldmine_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Kompas_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_P02_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_P16_value</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_PCM_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Siebel_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Turbocor_value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Master_Data_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Master_Data_Request__c.Back_end_System__c</field>
            <operation>notEqual</operation>
            <value>P08 (Global Sales)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CE PROSPECT TO ACCOUNT - DD</fullName>
        <actions>
            <name>CE_Notify_SAP_Backoffice_DD</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Master_Data_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Master_Data_Request__c.Division__c</field>
            <operation>equals</operation>
            <value>Danfoss Drives</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CE PROSPECT TO ACCOUNT - DEN</fullName>
        <actions>
            <name>CE_Notify_SAP_Backoffice_DEN</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Master_Data_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Master_Data_Request__c.Division__c</field>
            <operation>equals</operation>
            <value>District Energy</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CE PROSPECT TO ACCOUNT - Decision</fullName>
        <actions>
            <name>CE_Request_Decision</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Master_Data_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed,Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CE PROSPECT TO ACCOUNT - HS</fullName>
        <actions>
            <name>CE_Notify_SAP_Backoffice_HS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Master_Data_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Master_Data_Request__c.Division__c</field>
            <operation>equals</operation>
            <value>Heating Solutions</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CE PROSPECT TO ACCOUNT - RC</fullName>
        <actions>
            <name>CE_Notify_SAP_Backoffice_RC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Master_Data_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Master_Data_Request__c.Division__c</field>
            <operation>equals</operation>
            <value>Refrigeration Controls</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
