@RestResource(urlMapping='/QTUpdateLead/*')
global with sharing class RESTQTUpdateLeadController
{
	@HttpPost
    global static RESTQTUpdateLeadResponse UpdateLead()
    {
        // Initialize our variables
        Lead lead; // The deserialized JSON request
        Lead leadUpdate = new Lead(); // Lead to update        
        
        // Gather data from request        
        string jsonRequest = RestContext.request.requestBody.toString(); // JSON request as a string    
        System.debug(jsonRequest);
        
        // Configure response
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        // Deserialize the incoming JSON, casting to a Lead sobject 
        try
        {
            lead = (Lead) System.JSON.deserialize(jsonRequest, Lead.class);
        }
        catch(Exception ex)
        {
            System.debug('Exception: ' + ex.getMessage());
            IntegrationLogHelper.CreateIntegrationLogs(ex);
            return RESTQTUpdateLeadRepository.ProcessReturn(400, 'An error occurred deserializing the request.'); 
        }
        
        // Null check the Lead ID
        if(lead.Id == null)           
            return RESTQTUpdateLeadRepository.ProcessReturn(400, 'Unable to obtain the Lead ID.');
        
        // Build & update the Lead
        try
        {
            leadUpdate.Id = lead.Id;
            leadUpdate.Unbridled_Call_Type__c = lead.Unbridled_Call_Type__c;
            leadUpdate.Unbridled_Disposition__c = lead.Unbridled_Disposition__c;
            leadUpdate.Unbridled_Campaign__c = lead.Unbridled_Campaign__c;
            leadUpdate.Unbridled_Last_Update__c = lead.Unbridled_Last_Update__c;    
            
            update leadUpdate;
        }
        catch(Exception ex)
        {           
            System.debug('Exception: ' + ex.getMessage());
            IntegrationLogHelper.CreateIntegrationLogs(ex);
            return RESTQTUpdateLeadRepository.ProcessReturn(500, 'An error occurred updating Lead: ' + leadUpdate.Id); 
        }
            
        return RESTQTUpdateLeadRepository.ProcessReturn(201, 'Lead updated. ID: ' + leadUpdate.Id);
            
    }
    
} // End of Class