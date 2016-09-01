public with sharing class CustomerRequestHistoryComponentCtrl{

	public Id CRId {get; set;}
	public cHistories[] histories; 

	// Variables
	public Static final Map<String, Schema.SObjectField> CRFieldmap = Schema.SObjectType.PS_Customer_Request__c.fields.getMap();
	public Static final List<Schema.PicklistEntry> fieldPicklistValues = PS_Customer_Request__History.Field.getDescribe().getPicklistValues();

	public List<cHistories> getHistories()
	{
		list<cHistories> histories = new list<cHistories>();
		String prevDate = '';		
		for(PS_Customer_Request__History cHistory : [Select CreatedDate, CreatedBy.Name, CreatedBy.Id, Field, NewValue, OldValue from PS_Customer_Request__History where ParentId = :CRId order by CreatedDate desc])
		{
			if((cHistory.newValue == null && cHistory.oldValue == null) 
				|| (cHistory.newValue != null && !(string.valueOf(cHistory.newValue).startsWith('005') || string.valueOf(cHistory.newValue).startsWith('00G')))
				|| (cHistory.oldValue != null && !(string.valueOf(cHistory.oldValue).startsWith('005') || string.valueOf(cHistory.oldValue).startsWith('00G'))))
			{
				cHistories tempHistory = new cHistories();
				// Set the Date and who performed the action
				if(String.valueOf(cHistory.CreatedDate) != prevDate)
				{
					tempHistory.theDate = String.valueOf(cHistory.CreatedDate);
					tempHistory.who = cHistory.CreatedBy.Name;
					tempHistory.userId = cHistory.CreatedBy.Id;
				}
				else
				{
					tempHistory.theDate = '';
					tempHistory.who = '';
					tempHistory.userId = cHistory.CreatedBy.Id;
				}
				prevDate = String.valueOf(cHistory.CreatedDate);
				String fieldLabel = CustomerRequestHistoryComponentCtrl.returnFieldLabel(String.valueOf(cHistory.Field));

				if (String.valueOf(cHistory.Field) == 'created') { // on Creation
					tempHistory.action = 'Created.';
				}
				else if(cHistory.OldValue != null && cHistory.NewValue == null){ // when deleting a value from a field
					try {
						tempHistory.action = 'Deleted ' + Date.valueOf(cHistory.OldValue).format() + ' in <b>' + fieldLabel + '</b>.';
					} catch (Exception e){
						tempHistory.action = 'Deleted ' + String.valueOf(cHistory.OldValue) + ' in <b>' + fieldLabel + '</b>.';
					}
				}
				else{ // all other scenarios
					String fromText = '';
					if (cHistory.OldValue != null) {
						try {
							fromText = ' from ' + Date.valueOf(cHistory.OldValue).format();
						} catch (Exception e) {
							fromText = ' from ' + String.valueOf(cHistory.OldValue);
						}
					}

					String toText = '';
					if (cHistory.OldValue != null) {
						try {
							toText = Date.valueOf(cHistory.NewValue).format();
						} catch (Exception e) {
							toText = String.valueOf(cHistory.NewValue);
						}
					}
					if(toText != '')
						tempHistory.action = 'Changed <b>' + fieldLabel + '</b>' + fromText + ' to <b>' + toText + '</b>.';
					else
						tempHistory.action = 'Changed <b>' + fieldLabel;
				}
				histories.add(tempHistory);
			}
		}
		return histories;
	}	

	// Function to return Field Label of a Case field given a Field API name
	public Static String returnFieldLabel(String fieldName)
	{
		if(CustomerRequestHistoryComponentCtrl.CRFieldmap.containsKey(fieldName))
			return CustomerRequestHistoryComponentCtrl.CRFieldmap.get(fieldName).getDescribe().getLabel();
		else
		{
			for(Schema.PicklistEntry pickList : fieldPicklistValues)
			{
				if(pickList.getValue() == fieldName)
				{
					if(pickList.getLabel() != null)
						return pickList.getLabel();
					else
						return pickList.getValue();
				}
			}
		}
		return '';
	}
	// Inner Class to store the detail of the case histories	
	public class cHistories {

		public String theDate {get; set;}
		public String who {get; set;}
		public Id userId {get; set;} 
		/*public String fromValue {get; set;}
		public String toValue {get; set;} */
		public String action {get; set;}
        public String fieldLabel {get; set;}
	    public Id parentId {get; set;}      
	}	
}