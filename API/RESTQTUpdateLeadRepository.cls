public class RESTQTUpdateLeadRepository 
{
    public static RESTQTUpdateLeadResponse ProcessReturn(integer statusCode, string message)
    {
        boolean success = false;  
        string jsonRequest = RestContext.request.requestBody.toString(); // JSON request as a string
        System.debug(message + '; Request: ' + jsonRequest + ';'); 
        
        if(statusCode == 200 || statusCode == 201) success = true;
        RESTQTUpdateLeadResponse res = new RESTQTUpdateLeadResponse(success, statusCode, message, jsonRequest);            
        RestContext.response.statusCode = res.StatusCode;
        
        return res; 
    }    
    
} // End of Class