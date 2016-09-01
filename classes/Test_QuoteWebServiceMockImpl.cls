/*
*
*
*/
@isTest
global class Test_QuoteWebServiceMockImpl implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) { 
      
      if(requestName == 'BAPI_SALESORDER_SIMULATE') {
        sapComDocumentSapRfcFunctions.BAPISDHEAD ORDER_HEADER_IN = new sapComDocumentSapRfcFunctions.BAPISDHEAD();
        sapComDocumentSapRfcFunctions.BAPI_SALESORDER_SIMULATE_Response_element respElement = new sapComDocumentSapRfcFunctions.BAPI_SALESORDER_SIMULATE_Response_element();
        sapComDocumentSapRfcFunctions.BAPIRETURN resPonse1 = new sapComDocumentSapRfcFunctions.BAPIRETURN();
        resPonse1.CODE = 'abcd';
        resPonse1.MESSAGE = 'test message';
        sapComDocumentSapRfcFunctions.BAPICOND bapi = new sapComDocumentSapRfcFunctions.BAPICOND();
      
        sapComDocumentSapRfcFunctions.ORDER_CONDITION_EX_element order = new sapComDocumentSapRfcFunctions.ORDER_CONDITION_EX_element();
        order.item = new List<sapComDocumentSapRfcFunctions.BAPICOND>{bapi};
        respElement.RETURN_x = resPonse1;
        respElement.ORDER_CONDITION_EX = order;

        response.put('response_x', respElement); 
      }
   }
}