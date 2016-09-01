/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class InvokeMeetingTemplateConversion {
    global InvokeMeetingTemplateConversion() {

    }
    @InvocableMethod(label='Create Meeting From Template' description='Creates a Meeting from a Template.')
    global static List<Id> convertTemplates(List<ccpt.InvokeMeetingTemplateConversion.InvocableMeetingTemplate> invocables) {
        return null;
    }
global class InvocableMeetingTemplate {
    @InvocableVariable(label='Include contacts from Related Record' description='Optional. If true the contacts associated with the Related Record are added as Attendees. Defaults to false.' required=false)
    global Boolean includeRelatedRecordContacts;
    @InvocableVariable(label='Meeting Name' description='Optional. The name to give to the created Meeting. If empty, will use [template.Name] - [RelatedRecord.Name].' required=false)
    global String meetingName;
    @InvocableVariable(label='Meeting Start Time' description='Optional. The time the meeting should start. Defaults to 2 hours from now.' required=false)
    global Datetime meetingStartTime;
    @InvocableVariable(label='Omit Minutes from Template' description='Optional. If true the Minutes from the Agenda Items will not be included. Defaults to false.' required=false)
    global Boolean omitMinutes;
    @InvocableVariable(label='Related Record Id' description='Optional. The Id of the record to related to.' required=false)
    global String relatedRecordId;
    @InvocableVariable(label='Meeting Template Id' description='Required. The Id of the meeting template to create the meeting from.' required=true)
    global String templateId;
    @InvocableVariable(label='Copy Related Record Ownership' description='Optional. If true the specified related record's owner becomes the created meeting's owner. Only User Owners supported.' required=false)
    global Boolean transferOwnership;
    global InvocableMeetingTemplate() {

    }
}
}
