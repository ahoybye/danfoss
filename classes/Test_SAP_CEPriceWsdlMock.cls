@isTest
public class Test_SAP_CEPriceWsdlMock implements WebServiceMock {
    public void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType
    ) {
        SAP_CEPriceWsdl.Y_SF_BAPI_SALESORDER_SIMULATE_Response_element msg = new SAP_CEPriceWsdl.Y_SF_BAPI_SALESORDER_SIMULATE_Response_element();
        msg.ORDER_ITEMS_OUT = new SAP_CEPriceWsdl.ORDER_ITEMS_OUT_element();
        msg.ORDER_ITEMS_OUT.item = new List<SAP_CEPriceWsdl.BAPIITEMEX>();
        msg.ORDER_ITEMS_OUT.item.add(new SAP_CEPriceWsdl.BAPIITEMEX());
        msg.ORDER_ITEMS_OUT.item[0].NET_VALUE = '3300';
        msg.ORDER_ITEMS_OUT.item[0].CURRENCY_x = 'USD';
        msg.RETURN_x = new SAP_CEPriceWsdl.BAPIRETURN();
        msg.RETURN_x.CODE = null;
        response.put('response_x', msg);
        
        // coverage
        new SAP_CEPriceWsdl.SFDC_Quote_Fault_MT_element();
        new SAP_CEPriceWsdl.ExchangeLogData();
        new SAP_CEPriceWsdl.ExchangeFaultData();
        new SAP_CEPriceWsdl.ORDER_CFGS_PART_OF_element();
        new SAP_CEPriceWsdl.BAPISOLDTO();
        new SAP_CEPriceWsdl.ORDER_ITEMS_IN_element();
        new SAP_CEPriceWsdl.ORDER_ITEMS_OUT_element();
        new SAP_CEPriceWsdl.ORDER_CCARD_EX_element();
        new SAP_CEPriceWsdl.BAPICUINS();
        new SAP_CEPriceWsdl.Y_SF_BAPI_SALESORDER_SIMULATE_element();
        new SAP_CEPriceWsdl.BAPICCARD();
        new SAP_CEPriceWsdl.BAPIPARTNR();
        new SAP_CEPriceWsdl.BAPICUPRT();
        new SAP_CEPriceWsdl.BAPISCHDL();
        new SAP_CEPriceWsdl.BAPISDHEAD();
        new SAP_CEPriceWsdl.ORDER_SCHEDULE_IN_element();
        new SAP_CEPriceWsdl.BAPICUBLB();
        new SAP_CEPriceWsdl.BAPIITEMEX();
        new SAP_CEPriceWsdl.BAPIITEMIN();
        new SAP_CEPriceWsdl.BAPIRETURN();
        new SAP_CEPriceWsdl.ORDER_CFGS_INST_element();
        new SAP_CEPriceWsdl.MESSAGETABLE_element();
        new SAP_CEPriceWsdl.ORDER_CFGS_BLOB_element();
        new SAP_CEPriceWsdl.BAPICOND();
        new SAP_CEPriceWsdl.BAPIPAREX();
        new SAP_CEPriceWsdl.BAPIINCOMP();
        new SAP_CEPriceWsdl.EXTENSIONIN_element();
        new SAP_CEPriceWsdl.BAPICCARD_EX();
        new SAP_CEPriceWsdl.BAPICUVAL();
        new SAP_CEPriceWsdl.ORDER_CFGS_REF_element();
        new SAP_CEPriceWsdl.BAPISDHEDU();
        new SAP_CEPriceWsdl.BAPIADDR1();
        new SAP_CEPriceWsdl.BAPIPAYER();
        new SAP_CEPriceWsdl.BAPIRET2();
        new SAP_CEPriceWsdl.ORDER_CFGS_VALUE_element();
        new SAP_CEPriceWsdl.ORDER_CONDITION_EX_element();
        new SAP_CEPriceWsdl.ORDER_CCARD_element();
        new SAP_CEPriceWsdl.BAPICUCFG();
        new SAP_CEPriceWsdl.ORDER_PARTNERS_element();
        new SAP_CEPriceWsdl.PARTNERADDRESSES_element();
        new SAP_CEPriceWsdl.BAPISHIPTO();
        new SAP_CEPriceWsdl.Y_SF_BAPI_SALESORDER_SIMULATE_Response_element();
        new SAP_CEPriceWsdl.ORDER_INCOMPLETE_element();
        new SAP_CEPriceWsdl.ORDER_SCHEDULE_EX_element();
    }
}