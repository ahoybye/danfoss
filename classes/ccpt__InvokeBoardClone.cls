/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class InvokeBoardClone {
    global InvokeBoardClone() {

    }
    @InvocableMethod(label='Cloned a Board' description='Clones a Board with options to cloned Members, Cards, and Card Assignments.')
    global static List<ccpt__Board__c> cloneBoards(List<ccpt.InvokeBoardClone.InvocableBoardClone> invocables) {
        return null;
    }
global class InvocableBoardClone {
    @InvocableVariable(label='Board Id' description='Required. The id of the Board to clone.' required=true)
    global Id boardId;
    @InvocableVariable(label='Board Name' description='Optional. The name to give the cloned Board. If none provided, defaults to [ClonedBoard.Name] - [RelatedRecord.Name].' required=false)
    global String boardName;
    @InvocableVariable(label='Clone Card Assignments?' description='Optional. A flag indicating whether to clone the Board's Card Assignments. Defaults to false.' required=false)
    global Boolean cloneAssignees;
    @InvocableVariable(label='Clone Cards?' description='Optional. A flag indicating whether to clone the Board's Cards. Defaults to false.' required=false)
    global Boolean cloneCards;
    @InvocableVariable(label='Clone Board Members?' description='Optional. A flag indicating whether to clone the Board's Members. Defaults to false.' required=false)
    global Boolean cloneMembers;
    @InvocableVariable(label='Related Record Id' description='Optional. The Id of the record to relate to.' required=false)
    global String relatedRecordId;
    global InvocableBoardClone() {

    }
}
}
