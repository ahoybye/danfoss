@isTest
public class Test_ExternalWS
{
    public void pingService()
    {
    
         HttpRequest req = new HttpRequest();
         req.setEndpoint('https://x3p.powersolutions.danfoss.com/XISOAPAdapter/MessageServlet?channel=:SalesForce:SFDC_SAPPrice_SOAP_In');         
         req.setMethod('POST');

         Http http = new Http();
         HTTPResponse res = http.send(req);
         System.debug(res.getBody());
         
    }
}