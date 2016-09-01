trigger DeselectAllContactBUs on Contact (before insert, before update) {
    for (Contact c :Trigger.new){
        if (!c.Product_Information_Bulletin__c && !c.Service_Bulletin__c)
            c.PIB_BU__c = '';
        if (Trigger.isInsert && (c.Product_Information_Bulletin__c || c.Service_Bulletin__c))
            c.PIB_BU__c = 'Corporate; Electronic Components; High Power CC; High Power OC; Low Power; Medium Power CC; Medium Power OC; Motors; Parts & Service; PVG Valves; Steering';
    } 
}