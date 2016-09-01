public class SAP_CEPriceService {
    
    public class SAPPriceInput{
        public String SalesOrgId;
        public String DistributionChannel;
        public String Division;
        public String AccountId;
        public String ProductCode;
    } 
     
    public class SAPPriceOutput{
        public Decimal SAPPrice;
        public String SAPCurrency;
        public Boolean HasError;
        public String ErrorMessage;
    }
     
    public SAPPriceOutput InvokeSAPPricing(SAPPriceInput params)
    {                 
        SAPPriceOutput outprice = new SAPPriceOutput();   
        SAP_CEPriceWsdl.HTTPS_Port stub = new SAP_CEPriceWsdl.HTTPS_Port();
        stub.inputHttpHeaders_x = new Map<String, String>();        
        
        SAP_CEPriceWsdl.BAPISDHEAD ORDER_HEADER_IN = new SAP_CEPriceWsdl.BAPISDHEAD();
        SAP_CEPriceWsdl.BAPIPARTNR bapipartnr1 = new SAP_CEPriceWsdl.BAPIPARTNR();
        SAP_CEPriceWsdl.BAPIITEMIN bapiitemin = new SAP_CEPriceWsdl.BAPIITEMIN();

        list<SAP_CEPriceWsdl.BAPIPARTNR> order_partners = new list<SAP_CEPriceWsdl.BAPIPARTNR>();
        list<SAP_CEPriceWsdl.BAPIITEMIN> order_items = new list<SAP_CEPriceWsdl.BAPIITEMIN>();
   
        SAP_CEPriceWsdl.ORDER_PARTNERS_element order_partners_in = new SAP_CEPriceWsdl.ORDER_PARTNERS_element();
        SAP_CEPriceWsdl.ORDER_ITEMS_IN_element order_items_in = new SAP_CEPriceWsdl.ORDER_ITEMS_IN_element();

        ORDER_HEADER_IN.SALES_ORG = params.SalesOrgId;
        ORDER_HEADER_IN.DOC_TYPE = /*params.IsProductGroup ? 'ZOPP' :*/ 'ZOOR';
        ORDER_HEADER_IN.DISTR_CHAN = params.DistributionChannel;
        ORDER_HEADER_IN.DIVISION = params.Division;
        ORDER_HEADER_IN.REQ_DATE_H = string.valueOf(system.today()).replace('-', '');
        ORDER_HEADER_IN.PURCH_DATE = string.valueOf(system.today()).replace('-', '');

        bapiitemin.MATERIAL = params.ProductCode;
        bapiitemin.REQ_QTY = '1000'; // should we set correct quantity?
        order_items.add(bapiitemin);
        
        String CustomerNo = params.AccountId;
        CustomerNo = CustomerNo.leftPad(10, '0');
        
        bapipartnr1.ITM_NUMBER = '000000';
        bapipartnr1.PARTN_NUMB = CustomerNo;
        bapipartnr1.PARTN_ROLE = 'AG';
        order_partners.add(bapipartnr1);
        
        order_partners_in.item = order_partners;
        order_items_in.item = order_items;
  
        String username= SAP_Integration__c.getInstance('CE_User').Value__c;
        String password= SAP_Integration__c.getInstance('CE_Password').Value__c;  
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        
        stub.inputHttpHeaders_x.put('Authorization', authorizationHeader);
        stub.inputHttpHeaders_x.put('Cookie', 'name=value');
        stub.inputHttpHeaders_x.put('myHeader', 'myValue');
        stub.inputHttpHeaders_x.put('Content-Type', 'application/soap+xml');  
        stub.endpoint_x = SAP_Integration__c.getInstance('CE_URL').Value__c;
        stub.timeout_x = 120000;
      
        SAP_CEPriceWsdl.Y_SF_BAPI_SALESORDER_SIMULATE_Response_element msg;
        msg = stub.Y_SF_BAPI_SALESORDER_SIMULATE_OS_SI(
            null,           
            order_header_in,
            null,
            null,
            //null,
            //null,
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
        
        if (msg.ORDER_ITEMS_OUT.item!=null){
            for(SAP_CEPriceWsdl.BAPIITEMEX cond : msg.ORDER_ITEMS_OUT.item){
                outprice.SAPPrice = (decimal.valueOf(cond.NET_VALUE) / 100).setScale(2);
                outprice.SAPCurrency = cond.CURRENCY_x;
            }
        }
                
        String retCode = msg.RETURN_x.CODE;
        outprice.ErrorMessage = translateSAPError(retCode);
        outprice.HasError = retCode!=null && retCode!='';
                
        return outprice;
          
    }
    
    public String translateSAPError(String code){
        String msg;
        SAP_Error_Message__c sapError = SAP_Error_Message__c.getInstance(code);
        if (sapError != null){
            msg = sapError.Error_Message__c;
        } else{
            msg = 'SAP Error: Message Undefined. (' + code + ')';
        }
        return msg;
    }
}