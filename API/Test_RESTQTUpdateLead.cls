@isTest
private class Test_RESTQTUpdateLead 
{
    static testMethod void POST_BadRequest_CannotDeserializeRequest()
    {
        string json= '{"Id":"00Q18000004XXXXXXX","Unbridled_Last_Update__c":"CallFromSpace"}';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/QTUpdateLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTQTUpdateLeadResponse postResponse = RESTQTUpdateLeadController.UpdateLead();        
        System.assert(postResponse.Success == false);
        System.assert(postResponse.StatusCode == 400);
        System.assert(postResponse.Message == 'An error occurred deserializing the request.');
        Test.stopTest();
    }
    
    static testMethod void POST_BadRequest_NullLeadID()
    {
        string json = '{"Id": null,"Unbridled_Last_Update__c":"2018-08-24"}';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/QTUpdateLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTQTUpdateLeadResponse postResponse = RESTQTUpdateLeadController.UpdateLead();        
        System.assert(postResponse.Success == false);
        System.assert(postResponse.StatusCode == 400);
        System.assert(postResponse.Message == 'Unable to obtain the Lead ID.');
        Test.stopTest();
    }
    
    static testMethod void POST_InternalServerError_ErrorUpdatingLead()
    {
        string json = '{"Id":"00Q18000004XXXXXXX","Unbridled_Last_Update__c":"2018-08-24"}';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/QTUpdateLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTQTUpdateLeadResponse postResponse = RESTQTUpdateLeadController.UpdateLead();        
        System.assert(postResponse.Success == false);
        System.assert(postResponse.StatusCode == 500);
        System.assert(postResponse.Message == 'An error occurred updating Lead: 00Q18000004XXXXXXX');
        Test.stopTest();
    }
    
    static testMethod void POST_Success()
    {
        Lead lead = new Lead();
        lead.FirstName = 'Test_RESTQTUpdateLead';
        lead.LastName = 'Test_POST_Success';
        lead.Company = 'Test';
        lead.LeadSource = 'Test';
        insert lead;        
        
        string json = '{"Id":"' + lead.id	+ '","Unbridled_Last_Update__c":"2018-08-24"}';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/QTUpdateLead/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(json);
        
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        RESTQTUpdateLeadResponse postResponse = RESTQTUpdateLeadController.UpdateLead();        
        System.assert(postResponse.Success == true);
        System.assert(postResponse.StatusCode == 201);
        System.assert(postResponse.Message == 'Lead updated. ID: ' + lead.Id);
        Test.stopTest();
    }
    
} // End of Class