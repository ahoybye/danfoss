public class SAP_PriceService
{   
    public Decimal SAPPrice{get;set;}
    public String SAPCurrency{get;set;}
    public Decimal SAPListPrice{get;set;}  
    
    public class SAPPriceInput{
    	public String SalesOrgId;
    	public String AccountId;
    	public String ParentAccountId;
    	public String AccountGroup;
    	public String Channel;
    	public String ProductCode;
    	public Decimal Quantity;
    	public String acctRecType;
    } 
    
    public class SAPPriceOutput{
    	public Decimal SAPPrice;
    	public Decimal SAPListPrice;
    	public String SAPCurrency;
    	public String RetCode;
    	public String RetMessage;
    }
     
    public SAPPriceOutput InvokeSAPPricing(SAPPriceInput params)
    {                 
        SAPPriceOutput outprice = new SAPPriceOutput();   
        salesforceComQuote.HTTPS_Port stub = new salesforceComQuote.HTTPS_Port();
        stub.inputHttpHeaders_x = new Map<String, String>();        
        
        sapComDocumentSapRfcFunctions.BAPISDHEAD ORDER_HEADER_IN = new sapComDocumentSapRfcFunctions.BAPISDHEAD();
        sapComDocumentSapRfcFunctions.BAPIPARTNR bapipartnr1 = new sapComDocumentSapRfcFunctions.BAPIPARTNR();
        sapComDocumentSapRfcFunctions.BAPIPARTNR bapipartnr2 = new sapComDocumentSapRfcFunctions.BAPIPARTNR();
        sapComDocumentSapRfcFunctions.BAPIPARTNR bapipartnr3 = new sapComDocumentSapRfcFunctions.BAPIPARTNR();
        sapComDocumentSapRfcFunctions.BAPIITEMIN bapiitemin = new sapComDocumentSapRfcFunctions.BAPIITEMIN();

        list<sapComDocumentSapRfcFunctions.BAPIPARTNR> order_partners = new list<sapComDocumentSapRfcFunctions.BAPIPARTNR>();
        list<sapComDocumentSapRfcFunctions.BAPIITEMIN> order_items = new list<sapComDocumentSapRfcFunctions.BAPIITEMIN>();
   
        sapComDocumentSapRfcFunctions.ORDER_PARTNERS_element order_partners_in = new sapComDocumentSapRfcFunctions.ORDER_PARTNERS_element();
        sapComDocumentSapRfcFunctions.ORDER_ITEMS_IN_element order_items_in = new sapComDocumentSapRfcFunctions.ORDER_ITEMS_IN_element();

        ORDER_HEADER_IN.SALES_ORG = params.SalesOrgId;
        ORDER_HEADER_IN.DOC_TYPE = 'ZOR';
        ORDER_HEADER_IN.DISTR_CHAN = '10';
        ORDER_HEADER_IN.DIVISION = '00';
        ORDER_HEADER_IN.REQ_DATE_H = string.valueOf(system.today()).replace('-', '');
        ORDER_HEADER_IN.PURCH_DATE = string.valueOf(system.today()).replace('-', '');

        bapiitemin.MATERIAL = params.ProductCode;
        bapiitemin.REQ_QTY = '1';
        order_items.add(bapiitemin);
        
        bapipartnr1.ITM_NUMBER = '000000';
        bapipartnr2.ITM_NUMBER = '000000';
        bapipartnr3.ITM_NUMBER = '000000';
        system.debug(params.AccountGroup);
        if (params.AccountGroup == '0001')
        {
        	bapipartnr1.PARTN_NUMB = '0000' + params.AccountId;
        	bapipartnr1.PARTN_ROLE = 'AG';
        	order_partners.add(bapipartnr1);
        }
        else if (params.AccountGroup == '0002' && params.Channel != 'Indirect')
        {
        	bapipartnr1.PARTN_NUMB = '0000' + params.ParentAccountId;
        	bapipartnr1.PARTN_ROLE = 'AG';
        	order_partners.add(bapipartnr1);
        }
        else if (params.AccountGroup == '0002' && params.Channel == 'Indirect')
        {
        	system.debug(params);
        	bapipartnr1.PARTN_NUMB = '0000' + params.ParentAccountId;
        	bapipartnr1.PARTN_ROLE = 'AG';
        	order_partners.add(bapipartnr1);
        	
        	bapipartnr2.PARTN_NUMB = '0000' + params.AccountId;
        	bapipartnr2.PARTN_ROLE = 'WE';
        	order_partners.add(bapipartnr2);
        	bapipartnr3.PARTN_NUMB = '0000' + params.AccountId;
        	bapipartnr3.PARTN_ROLE = 'ZF';
        	order_partners.add(bapipartnr3);
        	system.debug(order_partners);
        	
        }
         
        order_partners_in.item = order_partners;
        order_items_in.item = order_items;
  
        String username= SAP_Integration__c.getInstance('User').Value__c;
        String password= SAP_Integration__c.getInstance('Password').Value__c;  
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        
        stub.inputHttpHeaders_x.put('Authorization', authorizationHeader);
        stub.inputHttpHeaders_x.put('Cookie', 'name=value');
        stub.inputHttpHeaders_x.put('myHeader', 'myValue');
        stub.inputHttpHeaders_x.put('Content-Type', 'application/soap+xml');  
        stub.endpoint_x = SAP_Integration__c.getInstance('URL').Value__c;
        stub.timeout_x = 120000;
        
	    sapComDocumentSapRfcFunctions.BAPI_SALESORDER_SIMULATE_Response_element msg;
        msg = stub.BAPI_SALESORDER_SIMULATE_IS_SI(
        	null,        	
	        order_header_in,
	        null,
	        null,
	        null,
	        null,
	        null,
	        null,
	        null,
	        null,
	        null,
	        null,
	        null,	
	        null,
	        null,
	        order_items_in,
	        null,
	        order_partners_in,
	        null,
	        null,
	        null);     
        
        if (msg.ORDER_CONDITION_EX.item!=null){
        	for(sapComDocumentSapRfcFunctions.BAPICOND cond : msg.ORDER_CONDITION_EX.item){
        		if(cond.COND_TYPE=='PNTP'){
        			outprice.SAPPrice = decimal.valueOf(cond.COND_VALUE).setScale(2);
        			outprice.SAPCurrency = cond.CURRENCY_x; 
        		} else if (cond.COND_TYPE=='ZP01'){
        			outprice.SAPListPrice = decimal.valueOf(cond.COND_VALUE).setScale(2);
        		}        	      
        	}   
        	
        }
                
        if (params.AccountGroup == '0012'){
        	outprice.RetCode = 'NoPriceHierarchy';
        }
        else if (params.acctRecType == 'Prospect') {
        	outprice.RetCode = 'Prospect';
        }
        else if (params.AccountGroup == '' || params.AccountGroup == null){
        	outprice.RetCode = 'NoAcctGroup';
        }
        else if ((params.ParentAccountId == '' || params.ParentAccountId == null) && params.AccountGroup == '0002') {
        	outprice.RetCode = 'NoParent';
        }
        else if ((outprice.SAPPrice <= 0 ) && (outprice.RetCode == '' || outprice.RetCode == null)){
        	outprice.RetCode = 'NOPRICE';
        } 
        else {
        	outprice.RetCode = msg.RETURN_x.CODE;
        }
        system.debug(outprice.RetCode);
        outprice.RetMessage = translateSAPError(outprice.RetCode);
                
        return (outprice);
          
    }
    
    public String translateSAPError(String code){
    	String msg;
    	SAP_Error_Message__c sapError = SAP_Error_Message__c.getInstance(code);
    	if (sapError != null){
    		msg = sapError.Error_Message__c;
    	} else{
    		msg = 'SAP Error: Message Undefined.';
    	}
        return msg;
    }
}