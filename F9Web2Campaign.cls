global class F9Web2Campaign implements Database.AllowsCallouts{
    private static String APIURL = 'https://api.five9.com/web2campaign/AddToList';
    
    public F9Web2CampaignResult doPost(Map<string, string> lead)
    {
        //Let PageReference class format our parameters for us.
        System.PageReference pageReference = new System.PageReference('');
        lead.put('F9retURL', 'localhost');//give it a retUrl so we can grab the url isntead of parsing the html
        lead.put('F9retResults','1');
        pageReference.getParameters().putAll(lead);
        
        String query = pageReference.getUrl().substring(1);//trim off the question mark
        
        // Instantiate a new http object
        Http h = new Http();
        string body;
        Integer statusCode;        
        HttpResponse res = new HttpResponse();        
        HttpRequest req = new HttpRequest(); 
        
        req.setMethod('POST');
        req.setEndpoint(APIURL);
        req.setBody(query);
        res = h.send(req);
        body = res.getBody();        
        statusCode = res.getStatusCode();
        
        if (Test.isRunningTest())
        {
            res.setHeader('Expecto', 'Patronum');
        }
        
        Integer errCode = -1;
        String errDesc = '';
        
        if(statusCode == 302){
            List<String> temp = res.getHeader('Location').replace('http://localhost?', '').split('&',0);
            Map<String, String> params = new Map<String, String>();
            for(String v: temp) {
                List<String> t2 = v.split('=', 2);
                if(t2.size() > 1) params.put(t2[0], t2[1]); }            
            if(params.get('F9errCode')!=null) errCode = Integer.valueOf(params.get('F9errCode'));
            if(params.get('F9errDesc')!=null) errDesc = params.get('F9errDesc'); }
        else return new F9Web2CampaignResult(statusCode, 'Server returned error code: '+statusCode);
        
        return new F9Web2CampaignResult(errCode, errDesc);
    }
    
}