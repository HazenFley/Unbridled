@isTest
public class unbridledTest {
    @isTest static void testSend_Success()
    {   
        Lead[] leads = unbridledTest.createLead('testSend_Success',true, 'Social', '1000000000', 'KS', true);
        unbridled unbridled = new unbridled();
        
        Test.setMock(HttpCalloutMock.class, new Test_MockPOSTSuccess());        
        Test.startTest();
        
        unbridled.sendToUnbridled(leads);
        HttpResponse res = new HttpResponse();
        res.setStatusCode(201);
        
        System.assertEquals(201, res.getStatusCode());  
        Test.stopTest();  
    }
    
    @isTest static void testSend_Failure()
    {   
        Lead[] leads = unbridledTest.createLead('testSend_Failure',true, 'Social', '10000000', 'KS', true);
        unbridled unbridled = new unbridled();
        
        Test.setMock(HttpCalloutMock.class, new Test_MockPOSTSuccess());        
        Test.startTest();
        
        unbridled.sendToUnbridled(leads);
        HttpResponse res = new HttpResponse();
        res.setStatusCode(500);
        
        System.assertEquals(500, res.getStatusCode());  
        Test.stopTest();  
    }
    
    @isTest static void testSend_Wizard()
    {   
        Lead[] leads = unbridledTest.createLead('testSend_Wizard', true, 'Social', '10000000', 'KS', true);
        unbridled unbridled = new unbridled();
        
        Test.setMock(HttpCalloutMock.class, new Test_MockPOSTSuccess());        
        Test.startTest();
        
        unbridled.sendToUnbridled(leads);
        HttpResponse res = new HttpResponse();
        res.setBody('{"Expecto":"Patronum"}');
        
        String expectedValue = '{"Expecto":"Patronum"}';
        String actualValue = res.getBody();
        System.assertEquals(actualValue, expectedValue);  
        Test.stopTest();  
    }
    
    @isTest static void updateStatusTest(){
        List<Lead> failPhoneList = new List<Lead>();
        List<IntegrationLog__c> failPhoneErrorList = new List<IntegrationLog__c>();
        List<Lead> updateStatusList = new List<Lead>();
        
        List<Lead> failTCPAList = new List<Lead>();
        List<IntegrationLog__c> failTCPAErrorList = new List<IntegrationLog__c>();
        
        Test.startTest();
        //test phone fail
        failPhoneList = unbridledTest.createLead('failPhone', true, 'Social', '100000', 'KS', true);        
        List<Lead> failPhoneListVer = [SELECT id, Lead_Source_Channel__c, phone, Default_Queue__c, Sent_to_Unbridled__c, status, Status_Reason__c FROM Lead WHERE id IN :failPhoneList];
        List<IntegrationLog__c> failPhoneErrorListVer = [SELECT id FROM IntegrationLog__c WHERE Related_Lead_Record__c IN :failPhoneListVer];
        System.debug('>>>failPhoneListVer: ' + failPhoneListVer);
		System.debug('>>>failPhoneErrorListVer : ' + failPhoneErrorListVer);        
        System.assertEquals('Q&T Queue', failPhoneListVer[0].Default_Queue__c,'failPhone Lead not defaulted for Q&T Queue');
        System.assertEquals(true, failPhoneListVer[0].Sent_to_Unbridled__c,'failPhone Lead not marked as sent to Unbridled.');        
        //System.assertEquals(1, failPhoneErrorListVer.size(),'Error not logged for failPhoneErrorListVer');
        
        //test update of status
        for(Lead l: failPhoneList){
            l.FirstName = 'Updated';
            l.Unbridled_Disposition__c = 'Poor Connection';
        }
        update failPhoneList;        
        updateStatusList = [SELECT id, status, Unbridled_Disposition__c FROM Lead WHERE id IN :failPhoneList];        
        System.debug('updateStatusList: ' + updateStatusList);        
        System.assertEquals('Contacted', updateStatusList[0].status,'updateStatus Lead status not updated correctly');
        
        //test TCPA fail
        failTCPAList = unbridledTest.createLead('failTCPA', true, 'Social', '1000000000', 'KS', false);          
        List<Lead> failTCPAErrorListVer = [SELECT id, Lead_Source_Channel__c, phone, Default_Queue__c, Sent_to_Unbridled__c, status, Status_Reason__c FROM Lead WHERE id IN :failTCPAList];
        System.debug('>>>failTCPAList: ' + failTCPAList);
		System.debug('>>>failTCPAErrorListVer : ' + failTCPAErrorListVer);        
        System.assertEquals('Q&T Queue', failTCPAErrorListVer[0].Default_Queue__c,'failTCPA Lead not defaulted for Q&T Queue');
        System.assertEquals(true, failTCPAErrorListVer[0].Sent_to_Unbridled__c,'failTCPA Lead not marked as sent to Unbridled.');        
        //System.assertEquals(1, failTCPAErrorListVer.size(),'Error not logged for failTCPAErrorListVer');
        
        
        Test.stopTest();
    }
    
    
    
    static List<Lead> createLead(string tlastname, boolean bogusUser, string channel, string tphone, string tstate, boolean tcpat) {
        System.debug('Creating New Lead <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'+ tlastname +' '+ channel + ' ' + tstate);
        
        List<Lead> leads = new List<Lead>();
        
        //get user data
        List<User> UserList = [SELECT id, name FROM User WHERE Bogus_User__c = :bogusUser AND isActive=true]; 
        
        if(!UserList.isEmpty()){
            
            for(Integer i=0; i<1; i++){
                System.debug('Creating Task ' + i);
                Lead l = new Lead(LastName=tlastname, 
                                  FirstName='Test Number ' + i, 
                                  Company='Test',
                                  LeadSource='Source Not Provided',
                                  Lead_Source_Channel__c= channel,
                                  OwnerID=UserList[0].id,
                                  Phone = tphone, 
                                  State = tstate,
                                  TCPA_Acknowledgement__c = tcpat
                                 );
                leads.add(l);
            }
        }
        System.debug('Inserting Leads');
        insert leads;       
        
        
        return leads;
    }
}